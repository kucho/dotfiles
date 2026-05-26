---
name: commit-messages
description: Write clear commit messages. Use when asked to commit changes, write a commit message, prepare a commit, or describe changes for version control.
---

# Committing Changes

Make small, atomic commits with narrative messages that explain the reasoning behind the diff.

## Workflow

### 1. Understand the Changes

If you don't already understand the changes, review them first:

```bash
git diff HEAD
git status --short
```

Before writing the message, identify:

- the broader goal or user/system problem this commit supports
- the previous state and why it was insufficient, risky, slow, or hard to maintain
- why this commit is the right boundary for an atomic change
- the design choice or rollout shape the commit introduces

### 2. Stage and Commit

Make small, atomic commits. Each commit should address one logical change. If the work spans independent concerns, split it into separate commits instead of listing unrelated bullets in one message.

```bash
# Stage entire files
git add <files>
git commit -m "title" -m "body paragraph"
```

### 3. Commit Message Format

**Title (first line):**
- Limit to 60 characters maximum
- Capitalize the first word of the main subject
- Use imperative mood ("add feature" not "adds feature")
- Use a short area prefix for readability when helpful (avoid generic "fix:" or "feature:" prefixes)

**Body:**
- Prefer a cohesive narrative over a changelog. The diff already shows what files changed and how.
- Start with the broader purpose: why this change exists now and what larger effort, bug, operational concern, or user need it supports.
- Describe the previous state and the problem it created. Be clear about observed facts versus risks.
- Explain the chosen approach and why it fits the constraints better than the alternatives.
- Include important compatibility, rollout, testing, or tradeoff details when they affect how the commit should be reviewed or operated.
- Use complete paragraphs with proper grammar and punctuation.
- Use imperative mood where it reads naturally, but prefer clarity over forcing every sentence into command form.

## Writing Guidance

- Do not use the body as a changelog or a list of touched files.
- Avoid bullet lists for independent points; if points are independent, consider whether they should be separate commits.
- Be precise and factual. Avoid implying outcomes that were not observed.
- Separate observed behavior from risk:
  - Observed: what you measured or saw.
  - Risk: what the old code could cause.
- Keep language repository-facing and neutral; describe the change, not the reviewer.
- When available, include brief concrete evidence in the narrative (counts, example output, reproducible symptom).
- Call out intent preservation when refactoring tests or structure (what coverage/behavior remains the same).

## Useful Shape

A strong commit body often reads like this:

1. This is part of a broader goal, and this commit handles one safe step of it.
2. The old state had a concrete problem or risk.
3. This change introduces a specific shape to remove that problem.
4. Important operational, compatibility, or design details make the change safe to review and roll out.

Do not mechanically label these sections. Write them as connected paragraphs.
