# web-tools

Pi extension that registers two public-web tools:

- `webfetch` — fetch one public URL as markdown, text, html, or an inline raster image
- `websearch` — search the public web for current information and candidate URLs

## Tools

### `webfetch`

Parameters:

- `url` — required
- `format` — optional: `markdown`, `text`, `html`
- `timeout` — optional timeout in seconds, clamped to `1..120`

Current defaults:

- `defaultFormat`: `markdown`
- `timeoutSeconds`: `30`
- `maxResponseBytes`: `5 MB`
- `blockPrivateHosts`: `true`
- `maxRedirects`: `5`
- `fallbackUserAgent`: `opencode`

Behavior notes:

- only `http://` and `https://` URLs are supported
- URL userinfo credentials (`https://user:pass@example.com`) are rejected and redacted in diagnostics
- private/local hosts and IPs are blocked by default
- raster images (`png`, `jpeg`, `gif`, `webp`) are returned inline as images
- HTML is converted to markdown or text when requested
- binary content is rejected
- if a site returns `403` with `cf-mitigated: challenge`, the tool retries with the fallback user agent

### `websearch`

Parameters:

- `query` — required
- `maxResults` — optional, clamped to `1..20`
- `depth` — optional: `auto`, `fast`, `deep` (accepted for compatibility; ignored by Kagi)

Current defaults:

- `enabled`: `true`
- `provider`: `kagi`
- `endpoint`: `https://kagi.com/api/v1/search`
- `timeoutSeconds`: `25`
- `defaultMaxResults`: `8`
- `defaultDepth`: `auto`

Behavior notes:

- uses the Kagi Search API v1 (`POST`, `Authorization: Bot $KAGI_API_KEY`)
- request body: `{ query, limit, workflow: "search" }`
- requires `KAGI_API_KEY` in the environment
- search responses are limited to `1 MB`
- only `data.search` rows are returned; related searches and other result groups are ignored

## Configuration

The extension has an internal settings shape:

```ts
{
  fetch: {
    defaultFormat: "markdown" | "text" | "html";
    timeoutSeconds: number;
    maxResponseBytes: number;
    blockPrivateHosts: boolean;
    maxRedirects: number;
    fallbackUserAgent: string;
  };
  search: {
    enabled: boolean;
    provider: "kagi";
    endpoint: PublicHttpUrl;
    timeoutSeconds: number;
    defaultMaxResults: number;
    defaultDepth: "auto" | "fast" | "deep";
  };
}
```

Defaults are hardcoded in `settings.ts`. The API key is read from `KAGI_API_KEY` at request time.

That means:

- `webfetch.format` and `webfetch.timeout` can be overridden per call
- `websearch.maxResults` and `websearch.depth` can be overridden per call
- the underlying defaults are not currently exposed through Pi settings, extension settings, or env vars (except the API key)

To change the defaults, edit:

- `shared/.pi/agent/extensions/web-tools/settings.ts`

## Source of truth

- extension entry: `shared/.pi/agent/extensions/web-tools/index.ts`
- settings/defaults: `shared/.pi/agent/extensions/web-tools/settings.ts`
- fetch Pi adapter: `shared/.pi/agent/extensions/web-tools/webfetch.ts`
- fetch service: `shared/.pi/agent/extensions/web-tools/fetch-page.ts`
- public web adapter: `shared/.pi/agent/extensions/web-tools/network.ts`
- search Pi adapter: `shared/.pi/agent/extensions/web-tools/websearch.ts`
- search service: `shared/.pi/agent/extensions/web-tools/search-web.ts`
- Kagi provider adapter: `shared/.pi/agent/extensions/web-tools/providers/kagi.ts`
- tool output projection: `shared/.pi/agent/extensions/web-tools/tool-output.ts`
