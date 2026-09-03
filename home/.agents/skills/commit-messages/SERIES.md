# Series Messages

Use this file when write shape is **series**: a multi-commit stack that shares one goal (new split or reword of an existing stack).

Stack identity is separate from **proof type** ([`PROOF_BRANCHES.md`](PROOF_BRANCHES.md)). Every commit still needs its own proof; this file only covers how messages bind the stack.

## Cold landing

Open any one commit alone. The series goal must be obvious without reading siblings. That is the acceptance test for every message in the stack.

## Series banner (required)

Body paragraph 1 on every commit in the stack:

- 1–2 lines, **stable wording** across middle commits
- Names the shared goal and high-level approach
- Middle commits: `This is part of …`
- Last commit: `This wraps up …` with the same goal phrasing
- No emoji required
- `Area:` titles may differ across the stack; the banner is the shared identity when prefixes diverge (`Clients:`, `Search:`, `Publications:`)

### Banner vs preamble sprawl

| | Series banner | Preamble sprawl |
|---|---|---|
| Role | Short, identical stack identity | Re-telling the full saga every commit |
| Required? | Yes on series | Forbidden |

Repeat the short banner. Do not re-explain the entire arc in every message.

## Residual body (after the banner)

Then prove *this* step:

- What prior steps in the stack left unpaid, or why this boundary is separate
- Predecessor by **subject only** when the stack is unmerged; **short SHA + subject** when the predecessor has already landed
- Residual prose is not a substitute for the banner
- Residual is **grounded** (see SKILL.md step 4): project nouns for what still hurts; human premise when that is the reason; no category jargon or invented policy

A shared cleanup premise that spans several commits (e.g. not developing X / moving off X) may repeat in the residuals that need it. That is stack identity for *why we touch X*, not preamble sprawl — still keep it short and do not re-tell the whole arc.

## Approach and evidence

Continue with the single-commit body shape: approach and boundary, then evidence when it affects confidence. Apply [`PROOF_BRANCHES.md`](PROOF_BRANCHES.md) when the proof is risky or non-obvious.

Cleanup or drive-by commits inside a performance (or other) series still take the same banner; the residual paragraph explains why they belong in this stack.

## Minimal example

```
Clients: Use full-text search for client lookup

This is part of restoring sub-second portal search after Searchkick
retirement (AppSignal #65): MySQL FULLTEXT and cheaper result rendering.

After #8661, SearchController#index on staging still sat in multi-second
samples. matching_list_search still used LIKE '%term%' on name/dba …

Add a MySQL FULLTEXT index on clients.name and clients.dba …
```

A later commit keeps the same first paragraph (`This is part of …`), then residual cost for *that* step. The last commit flips only the opener to `This wraps up …`.

Bad residual (not grounded): "Framework JS still resolved through node_modules even though we treat that framework as frozen."

Good residual: "We are not actively developing n2-styles and are moving the portal off it. App packs still imported its prebuilt JS from the npm package (n2-styles/dist/js/…)."

## Footgun

Do not start a commit-message body line with `#` — git strips those lines as comments (e.g. a wrapped `#valid?` disappears).
