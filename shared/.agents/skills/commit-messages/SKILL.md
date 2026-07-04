---
name: commit-messages
description: Commit messages. Use when asked to write or rewrite a commit message, split work into atomic commit messages, or when the user explicitly asks you to create a git commit.
---

# Commit Messages

Write the commit's proof: the diff shows what changed; the message explains why this change exists, why this boundary is right, and what makes it safe to review or operate.

Never run `git commit` unless the user explicitly asks you to create a commit.

## Branch

First decide the user's target:

- **Message-only**: inspect the relevant diff and write the message; do not stage or commit.
- **Explicit commit**: only when the user asks you to create a commit, verify the staged boundary, stage only intended files or hunks if needed, then commit.
- **Series**: split work by atomic boundary; output messages unless the user explicitly asks you to create the commits.

Completion criterion: the target is clear, and `git commit` is gated on an explicit commit request.

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

Completion criterion: `git diff --cached` contains one logical change and excludes unrelated files or hunks.

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

Body contract:

- Paragraph 1: why now and what prior state failed, risked, or made hard.
- Paragraph 2: what approach this commit takes and why this boundary is right.
- Final paragraph: evidence, verification, rollout, migration, or compatibility details when they affect confidence.
- Use connected prose. Use bullets only for related evidence; a bullet per file or independent change means split the commit.
- Omit the body only when the title carries the full proof for a low-risk obvious change.

For series commits, reference the predecessor and say why this is separate. Use short SHA plus subject for landed commits; use subject only for earlier commits in the same unmerged stack. Do not copy-paste the same preamble across the series.

```bash
git commit -m "title" -m "body paragraph"
```

For message-only requests, output the title and body without committing.

Completion criterion: the title follows the title contract, the body follows the body contract or is intentionally omitted, and no unknown context has been invented.

## Calibration

Separate observed behavior from risk: observed is what was measured, reproduced, searched, or tested; risk is what the old code could cause. Mention verification in prose when it affects confidence; do not add a boilerplate test footer unless that is clearer.
