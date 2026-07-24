import { decodeTextBuffer, isAbortError, parseContentType, readBodyWithLimit } from "../network.ts";
import { err, ok, type Result } from "../result.ts";
import { parsePublicHttpUrl, type PublicHttpUrl } from "../types.ts";
import type {
	NormalizedSearchResult,
	SearchProvider,
	SearchProviderError,
	SearchProviderRequest,
} from "./types.ts";

export const MAX_SEARCH_RESPONSE_BYTES = 1 * 1024 * 1024;
export const DEFAULT_KAGI_SEARCH_ENDPOINT = "https://kagi.com/api/v1/search";
export const DEFAULT_KAGI_API_KEY_ENV = "KAGI_API_KEY";

export interface HttpTextRequest {
	readonly url: string;
	readonly method: "GET" | "POST";
	readonly headers: Readonly<Record<string, string>>;
	readonly body?: string;
	readonly maxResponseBytes: number;
}

export interface HttpTextResponse {
	readonly status: number;
	readonly statusText: string;
	readonly headers: Headers;
	readonly bodyText: string;
	readonly bytes: number;
}

export type HttpClientError =
	| { readonly _tag: "HttpRequestFailed"; readonly cause: unknown }
	| { readonly _tag: "HttpResponseTooLarge"; readonly maxBytes: number }
	| { readonly _tag: "HttpCancelled"; readonly cause?: unknown };

export interface HttpTextClient {
	requestText(
		request: HttpTextRequest,
		options?: { readonly signal?: AbortSignal },
	): Promise<Result<HttpTextResponse, HttpClientError>>;
}

export class FetchHttpTextClient implements HttpTextClient {
	/** Perform an HTTP request and return bounded response text. */
	async requestText(
		request: HttpTextRequest,
		options: { readonly signal?: AbortSignal } = {},
	): Promise<Result<HttpTextResponse, HttpClientError>> {
		try {
			const response = await fetch(request.url, {
				method: request.method,
				headers: request.headers,
				body: request.body,
				signal: options.signal,
			});

			const contentLength = response.headers.get("content-length");
			if (contentLength) {
				const declaredBytes = Number.parseInt(contentLength, 10);
				if (Number.isFinite(declaredBytes) && declaredBytes > request.maxResponseBytes) {
					await response.body?.cancel().catch(() => undefined);
					return err({ _tag: "HttpResponseTooLarge", maxBytes: request.maxResponseBytes });
				}
			}

			const parsedContentType = parseContentType(response.headers.get("content-type"));
			const body = await readBodyWithLimit(response, request.maxResponseBytes, options.signal);
			const decoded = decodeTextBuffer(body.buffer, parsedContentType.charset);

			return ok({
				status: response.status,
				statusText: response.statusText,
				headers: response.headers,
				bodyText: decoded.text,
				bytes: body.bytes,
			});
		} catch (cause: unknown) {
			if (options.signal?.aborted || isAbortError(cause)) {
				return err({ _tag: "HttpCancelled", cause });
			}
			if (isResponseTooLargeCause(cause)) {
				return err({ _tag: "HttpResponseTooLarge", maxBytes: request.maxResponseBytes });
			}
			return err({ _tag: "HttpRequestFailed", cause });
		}
	}
}

export type KagiApiKeySource = () => string | undefined;

export class KagiSearchProvider implements SearchProvider {
	readonly name = "kagi" as const;

	constructor(
		private readonly endpoint: PublicHttpUrl,
		private readonly http: HttpTextClient,
		private readonly apiKeySource: KagiApiKeySource = () => process.env[DEFAULT_KAGI_API_KEY_ENV],
	) {}

	/** Search Kagi and return normalized public-web results. */
	async search(
		input: SearchProviderRequest,
		options: { readonly signal?: AbortSignal } = {},
	): Promise<Result<readonly NormalizedSearchResult[], SearchProviderError>> {
		const apiKey = this.apiKeySource()?.trim();
		if (!apiKey) {
			return err({
				_tag: "SearchProviderReturnedError",
				provider: this.name,
				safeMessage: `Missing ${DEFAULT_KAGI_API_KEY_ENV} environment variable`,
			});
		}

		const response = await this.http.requestText(
			{
				url: this.endpoint,
				method: "POST",
				headers: {
					accept: "application/json",
					authorization: `Bot ${apiKey}`,
					"content-type": "application/json",
				},
				body: JSON.stringify({
					query: input.query,
					limit: input.maxResults,
					workflow: "search",
				}),
				maxResponseBytes: MAX_SEARCH_RESPONSE_BYTES,
			},
			{ signal: options.signal },
		);

		if (response._tag === "err") {
			return err(mapHttpClientError(response.error));
		}

		if (response.value.status === 401 || response.value.status === 403) {
			return err({
				_tag: "SearchProviderReturnedError",
				provider: this.name,
				safeMessage: "Kagi API authentication failed",
			});
		}

		if (response.value.status < 200 || response.value.status >= 300) {
			const providerMessage = extractKagiErrorMessage(response.value.bodyText);
			if (providerMessage) {
				return err({
					_tag: "SearchProviderReturnedError",
					provider: this.name,
					safeMessage: providerMessage,
				});
			}

			return err({
				_tag: "SearchProviderStatusRejected",
				provider: this.name,
				status: response.value.status,
			});
		}

		const parsed = parseKagiSearchResponse(response.value.bodyText);
		if (parsed._tag === "err") {
			return err({
				_tag: "SearchProviderProtocolInvalid",
				provider: this.name,
				reason: parsed.error,
			});
		}

		return ok(parsed.value.slice(0, input.maxResults));
	}
}

/** Parse a Kagi Search API v1 JSON body into normalized results. */
export function parseKagiSearchResponse(
	bodyText: string,
): Result<readonly NormalizedSearchResult[], string> {
	let payload: unknown;
	try {
		payload = JSON.parse(bodyText);
	} catch {
		return err("Invalid JSON payload");
	}

	if (!isRecord(payload)) {
		return err("Expected an object payload");
	}

	// Kagi error responses use { error|errors: ... } with null/empty data.
	if (hasKagiErrorPayload(payload) && !hasUsableSearchData(payload["data"])) {
		return err(extractKagiErrorMessageFromPayload(payload) ?? "Provider returned an error object");
	}

	const data = payload["data"];
	if (!isRecord(data)) {
		return err("Missing data object");
	}

	const search = data["search"];
	if (!Array.isArray(search)) {
		return err("Missing data.search array");
	}

	const results: NormalizedSearchResult[] = [];
	for (const item of search) {
		if (!isRecord(item)) {
			continue;
		}

		const title = typeof item["title"] === "string" ? cleanKagiText(item["title"]) : "";
		const rawUrl = typeof item["url"] === "string" ? item["url"].trim() : "";
		if (!title || !rawUrl) {
			continue;
		}

		const parsedUrl = parsePublicHttpUrl(rawUrl);
		if (parsedUrl._tag === "err") {
			continue;
		}

		const snippet =
			typeof item["snippet"] === "string" ? cleanKagiText(item["snippet"]) || undefined : undefined;
		const publishedAt =
			typeof item["time"] === "string"
				? item["time"]
				: typeof item["published"] === "string"
					? item["published"]
					: undefined;

		results.push({
			title,
			url: parsedUrl.value,
			...(snippet ? { snippet } : {}),
			...(publishedAt ? { publishedAt } : {}),
			source: "kagi",
		});
	}

	return ok(results);
}

function mapHttpClientError(error: HttpClientError): SearchProviderError {
	switch (error._tag) {
		case "HttpRequestFailed":
			return { _tag: "SearchProviderUnavailable", provider: "kagi", cause: error.cause };
		case "HttpResponseTooLarge":
			return { _tag: "SearchProviderResponseTooLarge", provider: "kagi", maxBytes: error.maxBytes };
		case "HttpCancelled":
			return { _tag: "SearchProviderCancelled", provider: "kagi", cause: error.cause };
	}
}

function extractKagiErrorMessage(bodyText: string): string | undefined {
	try {
		const payload: unknown = JSON.parse(bodyText);
		if (!isRecord(payload)) {
			return undefined;
		}
		return extractKagiErrorMessageFromPayload(payload);
	} catch {
		return undefined;
	}
}

function extractKagiErrorMessageFromPayload(payload: Record<string, unknown>): string | undefined {
	const errors = payload["errors"] ?? payload["error"];
	if (!Array.isArray(errors) || errors.length === 0) {
		return undefined;
	}

	const messages: string[] = [];
	for (const item of errors) {
		if (!isRecord(item)) {
			continue;
		}
		const message = typeof item["message"] === "string" ? item["message"].trim() : "";
		const code = typeof item["code"] === "string" ? item["code"].trim() : "";
		if (message) {
			messages.push(message);
		} else if (code) {
			messages.push(code);
		}
	}

	if (messages.length === 0) {
		return undefined;
	}

	return messages.join("; ");
}

function hasKagiErrorPayload(payload: Record<string, unknown>): boolean {
	const errors = payload["errors"] ?? payload["error"];
	return errors != null;
}

function hasUsableSearchData(data: unknown): boolean {
	return isRecord(data) && Array.isArray(data["search"]);
}

function cleanKagiText(input: string): string {
	return decodeHtmlEntities(input.replace(/<[^>]+>/g, " "))
		.replace(/\s+/g, " ")
		.trim();
}

function decodeHtmlEntities(input: string): string {
	return input
		.replace(/&#39;/g, "'")
		.replace(/&quot;/g, '"')
		.replace(/&amp;/g, "&")
		.replace(/&lt;/g, "<")
		.replace(/&gt;/g, ">")
		.replace(/&#(\d+);/g, (_, code: string) => {
			const value = Number.parseInt(code, 10);
			return Number.isFinite(value) ? String.fromCodePoint(value) : _;
		});
}

function isRecord(value: unknown): value is Record<string, unknown> {
	return typeof value === "object" && value !== null && !Array.isArray(value);
}

function isResponseTooLargeCause(cause: unknown): boolean {
	return cause instanceof Error && cause.message.startsWith("Response too large");
}
