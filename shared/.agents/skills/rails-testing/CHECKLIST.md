# Rails Testing Checklist

Load this for non-trivial test edits or reviews. Scan every changed example, touched setup block, expected value, and introduced test double. Repair each detected trap or justify it with a repository-local constraint.

## Receiver scan

Against the [receiver-driven contract](SKILL.md#receiver-driven-unit-tests), detect:

- result-valued, request-valued, or side-effectful `subject` blocks;
- free-form method `describe` strings or source-order drift;
- examples missing an explicit call to the described method on `subject`;
- method execution hidden in `before` or assertions made through another receiver;
- `let(:klass)` indirection where the production constant is the receiver.

## Adapter scan

Against the [adapter contract](SKILL.md#adapter-tests-exercise-http-behavior), detect `subject`, requests outside `it`, or example names that promise a response or redirect more specific than the assertion.

## Scope scan

Against [surface what varies](SKILL.md#setup-surfaces-what-varies), detect:

- top-level or parent setup used by only a subset of examples;
- repeated sibling wiring instead of one shared shell with varying inputs;
- setup in `it` that belongs to a scoped condition;
- setup declared out of order or with the wrong block form;
- `context`, nested `given "with ..."`, or hidden variations.

## Oracle scan

Against the [independent-oracle contract](SKILL.md#assertions-use-independent-oracles), detect the same path helper, enum source, parser, formatter, calculator, or collaborator expression in production and expected-value derivation. Also detect vague example names and raw assertions where the configured expectation API has a matcher.

## Seam scan

Load [`DOUBLES.md`](DOUBLES.md), then detect receiver stubbing, `any_instance`, class/global stubbing, or predeclared interactions where a real input or injected plain Ruby double would be clearer. For recording doubles, verify only meaningful command protocol rather than incidental call sequence.

## Ownership and data scan

Against the [test-data contract](SKILL.md#test-data-is-deliberately-synthetic) and nested-child template, detect:

- nested production children split from their parent without established independent ownership;
- fabricated records where a suitable fixture already expresses the scenario;
- invented values carrying irrelevant narrative meaning, invalid domain formats, or excessive numeric noise.

Completion criterion: every applicable scan covers every changed example, setup block, expected value, and test double; every detected trap is repaired or explicitly justified.
