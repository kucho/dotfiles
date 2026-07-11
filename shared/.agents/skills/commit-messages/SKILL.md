---
name: commit-messages
description: >
  Commit message proof. Use when writing or rewriting commit messages,
  splitting a change into atomic commits, rewording a series or stack,
  addressing PR feedback on commit messages, or when the user explicitly
  asks to create a git commit.
---

# Commit Messages

Write the commit's proof: the diff shows what changed; the message explains why this change exists, why this boundary is right, and what makes it safe to review or operate.

Never run `git commit` unless the user explicitly asks you to create a commit.

## Branch

First decide the user's **target**:

- **Message-only**: inspect the relevant diff and write the message; do not stage or commit.
- **Explicit commit**: only when the user asks you to create a commit, verify the staged boundary, stage only intended files or hunks if needed, then commit.
- **Split**: divide work by atomic boundary into multiple commits; output messages unless the user explicitly asks you to create the commits.

Then decide **write shape**:

- **Single**: one commit, or messages that do not share a stack goal with siblings.
- **Series**: a multi-commit stack that shares one goal — including a new split, rewording an existing stack, or PR feedback about tying commits together / cold landing.

When write shape is series, load [`SERIES.md`](SERIES.md) **before** drafting any message and apply it to every commit in the stack.

Completion criterion: the target and write shape are clear; `git commit` is gated on an explicit commit request; series runs have loaded `SERIES.md`.

## Steps

### 1. Inspect the Diff

```bash
git status --short
git diff
git diff --cached
```

Extract message facts only from the diff, test output, logs, command output, existing code, issue text, or user-provided context.

Completion criterion: the intended diff, unrelated worktree changes, and evidence available for the message are known.

### 2. Establish the Boundary

Make each commit one logical change. If staged changes already exist, treat them as user intent and do not rewrite the staged set without checking. Never use `git add .` unless the user explicitly asks and the status is cleanly understood; prefer explicit paths or patch staging.

Completion criterion: `git diff --cached` contains one logical change and excludes unrelated files or hunks. For a split, every planned commit has a clear boundary.

### 3. Choose the Proof Branch

Pick the proof this commit needs. If several apply, use the riskiest or most review-relevant branch as primary.

- **Bug fix**: observed failure, cause, fix, verification.
- **Refactor**: preserved behavior, better shape, coverage or call-site review.
- **Optimization**: old cost, new shape, measurement or concrete expected reduction.
- **Dead-code removal**: why unused, how verified, compatibility or dependency caveats.
- **Mechanical/generated**: tool or process, semantic boundary, validation.
- **Upgrade/migration/rollout**: old/new state, ordering, compatibility, deploy or cleanup constraints.

For risky or non-obvious commits, load [`PROOF_BRANCHES.md`](PROOF_BRANCHES.md) and apply the selected branch's checklist.

Completion criterion: the message has a primary proof branch, and every safety claim is calibrated to available evidence.

### 4. Write or Commit

Title contract:

- Shape: `Area: Imperative subject` when the change has a clear area; otherwise `Imperative subject`.
- Area is the domain, subsystem, gem, tool, or upgrade track: `Invoices:`, `Sidekiq:`, `AgingSummary:`, `Rails 7.0:`.
- Keep under 60 characters when practical.
- Avoid generic areas like `Fix:` or `Feature:`; ticket prefixes do not replace the subject.

Body contract (single write shape):

- Paragraph 1: why now and what prior state failed, risked, or made hard.
- Paragraph 2: what approach this commit takes and why this boundary is right.
- Final paragraph: evidence, verification, rollout, migration, or compatibility details when they affect confidence.
- Use connected prose. Use bullets only for related evidence; a bullet per file or independent change means split the commit.
- Omit the body only when the title carries the full proof for a low-risk obvious change.

Series write shape: do not use the single body contract alone. Apply [`SERIES.md`](SERIES.md) for the series banner, residual body, and cold-landing test; then approach and evidence as above.

Every residual and approach sentence must be **grounded**:

- Name the thing in the project's words (package, gem, import path, class, file role) — not an invented category ("framework JS", "surface", "artifact", "graph").
- State the human premise when it is the reason (e.g. we are not actively developing X and are moving off it). Do not invent a technical euphemism for that premise ("frozen", "treat as immutable").
- Prefer what the old code *did* over abstract migration talk ("re-resolve the package", "load path ownership").
- Facts only from step 1. If a claim is not in the diff, tests, logs, or user text, drop it.

Before finishing, re-read each body as a cold reviewer with only that commit: any sentence that needs a sibling commit, unstated jargon, or a policy you just coined fails — rewrite it.

```bash
git commit -m "title" -m "body paragraph"
```

For message-only requests, output the title and body without committing.

Completion criterion:

- Title follows the title contract; no unknown context invented.
- Every residual/approach sentence is grounded (project nouns; no invented policy or category jargon).
- Cold re-read of each body passes without sibling commits or unstated terms.
- **Single**: body follows the single body contract or is intentionally omitted.
- **Series**: every message in the stack satisfies [`SERIES.md`](SERIES.md) (shared series banner, residual body, cold landing).

## Calibration

Separate observed behavior from risk: observed is what was measured, reproduced, searched, or tested; risk is what the old code could cause. Mention verification in prose when it affects confidence; do not add a boilerplate test footer unless that is clearer.
