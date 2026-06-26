---
name: commit-messages
description: Write clear commit messages. Use when asked to commit changes, write a commit message, prepare a commit, or describe changes for version control.
---

# Committing Changes

Make small, atomic commits with messages that explain the reasoning behind the staged diff. Write for future maintainers: the diff shows what changed; the message should explain why this change exists, why this boundary is right, and why it is safe to review or operate.

## Workflow

### 1. Understand the Intended Commit

Before writing the message, review the worktree and the exact staged diff:

```bash
git status --short
git diff
git diff --cached
```

Stage only the files or hunks that belong in this commit. Do not assume every worktree change is yours or belongs in the same commit.

Before committing, identify:

- the broader goal or user/system problem this commit supports
- the previous state and why it was insufficient, risky, slow, or hard to maintain
- why this commit is the right boundary for an atomic change
- the design choice or rollout shape the commit introduces
- the evidence, verification, or call-site review that makes the change safe

### 2. Stage and Commit

Each commit should address one logical change. If the work spans independent concerns, split it into separate commits instead of listing unrelated bullets in one message.

```bash
# Stage only the intended files or hunks
git add <files>
git diff --cached
git commit -m "title" -m "body paragraph"
```

### 3. Commit Message Format

**Title (first line):**
- Keep it under 60 characters when practical
- Capitalize the first word of the main subject
- Use imperative mood ("add feature" not "adds feature")
- Use a useful area prefix when it helps scan history, such as `Invoices:`, `Sidekiq:`, `Feature Flags:`, or `AgingSummary:`
- Ticket prefixes are fine when they add traceability, but they do not replace a clear subject
- Avoid generic prefixes like `Fix:` or `Feature:` and avoid author prefixes

**Body:**
- Scale the body to the risk and review burden. A mechanical rename, narrow dependency cleanup, or generated-test-data fix may only need one paragraph. Incident fixes, migrations, behavior changes, and stacked refactors usually need the fuller narrative.
- Prefer connected prose over a changelog. Do not narrate the diff file-by-file; spend the body on why the change is correct and reviewable.
- Start with why this change exists now: incident, trace, bug report, ticket, rollout state, feature flag state, upgrade pressure, prior commit, or user/system need.
- Do not invent context. If a commit depends on product approval, owner sign-off, destructive migration ordering, or rollout authorization and you do not know it, ask the user or state only what is known.
- Describe the previous state and the concrete problem or risk it created. Be clear about observed facts versus possible risks.
- Explain the chosen approach and why this commit is the right atomic boundary.
- Call out deliberate non-goals or tradeoffs when they prevent review churn or clarify the risk boundary.
- Substantiate any safety or correctness claim with the scope actually verified: callers checked, behavior preserved, generated data intentionally included, migration ordering, rollout constraints, tests run, measurements taken, or no other consumers found.
- Include important compatibility, rollout, migration, testing, or operational details when they affect review or operation.
- Use complete sentences with proper grammar and punctuation. The reasoning should read as prose, but keep it skimmable.

## Writing Guidance

- Bullets are for a small set of *related* facts supporting one point — for example, the checks that prove a change is safe. A bullet per touched file, or a bullet per independent change, is the changelog smell; independent changes usually want separate commits instead.
- Be precise, factual, and direct: state the load-bearing fact plainly. Calibrate the claim to what you actually verified — directness is not license to overstate certainty. For instance, if you only confirmed a flag was configured off in production, say that; do not upgrade it to "never used."
- Separate observed behavior from risk:
  - Observed: what you measured or saw.
  - Risk: what the old code could cause.
- Keep language repository-facing and neutral; describe the change, not the reviewer.
- Prefer concrete evidence over adjectives for performance, incident, and flaky-test commits: timings, query counts, row counts, EXPLAIN shape, error output, AppSignal observations, queue activity, or reproducible failures.
- Call out intent preservation when refactoring tests or structure (what coverage/behavior remains the same).
- Mention verification in prose when it affects confidence. Do not add a boilerplate test footer unless that is clearer.

## Commits in a Series

When work is split into a stack of dependent commits, each commit after the first has to justify itself:

- Reference its predecessor and say *why it is a separate commit* — what it builds on and why that work was committed first. A reader looking at the second commit alone should understand it is a follow-up, not a standalone change.
- For already-landed historical commits, use short SHA + subject when it helps future archaeology.
- For earlier commits in the same unmerged stack, reference the predecessor by subject, not SHA. SHAs churn on every rebase or amend while the series is unmerged; the subject stays stable and is clearer to a reader.
- Do not copy-paste the broader-goal preamble across the series. Shared context may recur, but rewrite it from this commit's vantage point — explain how *this* commit advances the goal, rather than reprinting the same opening paragraph verbatim.
