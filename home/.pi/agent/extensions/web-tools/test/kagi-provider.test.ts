import test from "node:test";
import assert from "node:assert/strict";
import { ok, type Result } from "../result.ts";
import { parsePublicHttpUrl, parseSearchQuery } from "../types.ts";
import {
	KagiSearchProvider,
	parseKagiSearchResponse,
	type HttpClientError,
	type HttpTextClient,
	type HttpTextRequest,
	type HttpTextResponse,
} from "../providers/kagi.ts";

class RecordingHttpTextClient implements HttpTextClient {
	readonly requests: HttpTextRequest[] = [];

	constructor(private readonly response: Result<HttpTextResponse, HttpClientError>) {}

	async requestText(
		request: HttpTextRequest,
		_options?: { readonly signal?: AbortSignal },
	): Promise<Result<HttpTextResponse, HttpClientError>> {
		this.requests.push(request);
		return this.response;
	}
}

test("parseKagiSearchResponse keeps only data.search results", () => {
	const body = JSON.stringify({
		data: {
			related_search: [
				{ url: "/search?q=related+one", title: "related one" },
				{ url: "/search?q=related+two", title: "related two" },
			],
			search: [
				{
					url: "https://example.com/",
					title: "Example Domain",
					snippet: "Documentation-safe <strong>example</strong> domain.",
				},
				{
					url: "https://example.org/",
					title: "Example Org",
					snippet: "Another result",
					time: "2024-01-01T00:00:00Z",
				},
			],
		},
	});

	const parsed = parseKagiSearchResponse(body);
	assert.equal(parsed._tag, "ok");
	assert.equal(parsed.value.length, 2);
	assert.equal(parsed.value[0]?.title, "Example Domain");
	assert.equal(parsed.value[0]?.url, "https://example.com/");
	assert.equal(parsed.value[0]?.snippet, "Documentation-safe example domain.");
	assert.equal(parsed.value[1]?.publishedAt, "2024-01-01T00:00:00Z");
});

test("KagiSearchProvider sends Bot auth and JSON POST body", async () => {
	const http = new RecordingHttpTextClient(
		ok({
			status: 200,
			statusText: "OK",
			headers: new Headers({ "content-type": "application/json" }),
			bodyText: JSON.stringify({
				data: {
					search: [
						{
							url: "https://example.com/",
							title: "Example Domain",
							snippet: "Documentation-safe example domain.",
						},
					],
				},
			}),
			bytes: 123,
		}),
	);
	const endpoint = parsePublicHttpUrl("https://example.test/search");
	const query = parseSearchQuery("example");
	assert.equal(endpoint._tag, "ok");
	assert.equal(query._tag, "ok");

	const provider = new KagiSearchProvider(endpoint.value, http, () => "test-key");
	const result = await provider.search({ query: query.value, maxResults: 5, depth: "auto" });

	assert.equal(result._tag, "ok");
	assert.equal(result.value.length, 1);
	assert.equal(http.requests.length, 1);
	assert.equal(http.requests[0]?.method, "POST");
	assert.equal(http.requests[0]?.url, "https://example.test/search");
	assert.equal(http.requests[0]?.headers.authorization, "Bot test-key");
	assert.equal(http.requests[0]?.headers["content-type"], "application/json");
	assert.deepEqual(JSON.parse(http.requests[0]?.body ?? "{}"), {
		query: "example",
		limit: 5,
		workflow: "search",
	});
});

test("KagiSearchProvider fails safely when API key is missing", async () => {
	const http = new RecordingHttpTextClient(
		ok({
			status: 200,
			statusText: "OK",
			headers: new Headers({ "content-type": "application/json" }),
			bodyText: JSON.stringify({ data: { search: [] } }),
			bytes: 2,
		}),
	);
	const endpoint = parsePublicHttpUrl("https://example.test/search");
	const query = parseSearchQuery("example");
	assert.equal(endpoint._tag, "ok");
	assert.equal(query._tag, "ok");

	const provider = new KagiSearchProvider(endpoint.value, http, () => undefined);
	const result = await provider.search({ query: query.value, maxResults: 5, depth: "auto" });

	assert.deepEqual(result, {
		_tag: "err",
		error: {
			_tag: "SearchProviderReturnedError",
			provider: "kagi",
			safeMessage: "Missing KAGI_API_KEY environment variable",
		},
	});
	assert.equal(http.requests.length, 0);
});

test("KagiSearchProvider surfaces v1 error messages", async () => {
	const http = new RecordingHttpTextClient(
		ok({
			status: 400,
			statusText: "Bad Request",
			headers: new Headers({ "content-type": "application/json" }),
			bodyText: JSON.stringify({
				data: null,
				errors: [{ code: "search.query_empty", message: "Query cannot be empty" }],
			}),
			bytes: 80,
		}),
	);
	const endpoint = parsePublicHttpUrl("https://example.test/search");
	const query = parseSearchQuery("example");
	assert.equal(endpoint._tag, "ok");
	assert.equal(query._tag, "ok");

	const provider = new KagiSearchProvider(endpoint.value, http, () => "test-key");
	const result = await provider.search({ query: query.value, maxResults: 5, depth: "auto" });

	assert.deepEqual(result, {
		_tag: "err",
		error: {
			_tag: "SearchProviderReturnedError",
			provider: "kagi",
			safeMessage: "Query cannot be empty",
		},
	});
});
