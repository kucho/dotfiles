# Proof Branches

Use this reference after selecting a risky or non-obvious non-bug proof branch. The universal bug-fix evidence contract lives inline in `SKILL.md` because every bug fix must apply it.

## Refactor

Name the behavior intended to stay the same. Explain why the new shape is easier to maintain, reason about, test, or extend. Call out coverage, call-site review, or deliberately mechanical movement when that is the safety argument.

## Optimization

Prefer concrete evidence over adjectives: timings, query counts, row counts, EXPLAIN shape, AppSignal observations, queue activity, cache/materialization boundaries, or reproducible slow paths. If measurement is unavailable, state the old work shape and the concrete reduction expected.

## Dead-Code Removal

The safety claim is that nothing reaches this anymore. Support it with search, call-site review, config state, runtime path analysis, prior commit context, or dependency state. Mention remaining transitive dependencies or compatibility caveats when they affect future archaeology.

## Mechanical or Generated Change

Keep semantic changes out of the commit when practical. Explain the tool, script, or process that produced the diff; what semantic cleanup is deferred; and how the output was validated.

## Upgrade, Migration, or Rollout

Make operational safety explicit: old and new versions or states, ordering, compatibility risks, fallback behavior, deploy constraints, temporary files or workarounds, and cleanup timing.
