import test from "node:test";
import assert from "node:assert/strict";
import { err, ok, type Result } from "../result.ts";
import { SearchWeb } from "../search-web.ts";
import { createWebSearchTool } from "../websearch.ts";
import { parsePublicHttpUrl } from "../types.ts";
import type { WebToolsSettings } from "../types.ts";
import type { ToolOutputStore, ToolOutputStoreError } from "../tool-output.ts";
import type { NormalizedSearchResult, SearchProvider, SearchProviderError, SearchProviderRequest } from "../providers/types.ts";

const endpoint = parsePublicHttpUrl("https://example.test/search");
assert.equal(endpoint._tag, "ok");

const settings: WebToolsSettings = {
	fetch: {
		defaultFormat: "markdown",
		timeoutSeconds: 30,
		maxResponseBytes: 5 * 1024 * 1024,
		blockPrivateHosts: true,
		maxRedirects: 5,
		fallbackUserAgent: "opencode",
	},
	search: {
		enabled: true,
		provider: "kagi",
		endpoint: endpoint.value,
		timeoutSeconds: 25,
		defaultMaxResults: 8,
		defaultDepth: "auto",
	},
};

class FakeProvider implements SearchProvider {
	readonly name = "kagi" as const;

	constructor(private readonly response: Result<readonly NormalizedSearchResult[], SearchProviderError>) {}

	async search(
		_input: SearchProviderRequest,
		_options?: { readonly signal?: AbortSignal },
	): Promise<Result<readonly NormalizedSearchResult[], SearchProviderError>> {
		return this.response;
	}
}

class UnusedOutputStore implements ToolOutputStore {
	async writeTextFile(
		_prefix: string,
		_fileName: string,
		_content: string,
	): Promise<Result<string, ToolOutputStoreError>> {
		return ok("/tmp/unused.txt");
	}
}

test("websearch execute throws safe message for provider protocol failures", async () => {
	const searchWeb = new SearchWeb({
		settings: settings.search,
		provider: new FakeProvider(
			err({
				_tag: "SearchProviderProtocolInvalid",
				provider: "kagi",
				reason: "missing result content raw details",
			}),
		),
	});
	const tool = createWebSearchTool({ settings, searchWeb, outputStore: new UnusedOutputStore() });

	await assert.rejects(
		tool.execute("id", { query: "example" }),
		/Search provider returned an invalid response/,
	);
});
