# Rails Testing Checklist

Load this for non-trivial test edits or reviews. Reject or repair every changed trap that appears.

## Receiver-driven unit tests

- `let(:klass) { MyObject }` instead of naming `MyObject` directly.
- Free-form unit `describe` strings such as `describe "attribute assignment"`; use `describe ".method"` or `describe "#method"`.
- Unit `describe` blocks ordered differently from the source methods.
- `subject { SomeClass.some_method }` when the `describe` is for `.some_method`; `subject` must be the receiver.
- Side-effectful `subject` setup such as persistence, HTTP requests, collaborator mutation, or any other work that belongs in scoped `before`/`let` setup.
- Calling the method under test only in `before`, or only through a precomputed subject, instead of inside each `it`.
- Bypassing `subject` in unit examples by fetching a fresh receiver or asserting on unrelated variables.

## Adapter tests

- `subject { get path }`, `subject { post path }`, or any HTTP/request work in `subject`.
- Any `subject` in controller or integration tests.

## Setup shape

- Broad top-level `before`, `let`, or `subject` that only some examples use.
- Setup code in `it` blocks that belongs in a scoped `before` under a `given`.
- Repeating the same `let` or `before` in sibling `given` blocks instead of nesting the shared condition.
- Nested `given "with ..."`; write only the variation, such as `given "an explicit time zone String"`.
- `context "when ..."`; use `given "..." do`.
- Single-line `before { ... }` or `after { ... }`; use `do`/`end`.
- Declaring `let` or `subject` before `before`/`after` in the same block.

## Assertions and language

- Raw `assert_*` / `refute_*` where expectation matchers exist.
- `expect(-> { code }).must_*`; use `expect { code }.must_*`.
- Vague examples like `it "works"`, `it "succeeds"`, or `it "equals something"`.
- Abbreviations such as `desc`, `msg`, `err`, `val`, `subj`, or `ctx` unless explicitly allowed by the project.
- Junk meta-comments such as “exercise the method under test” or “call on subject inside the it”.

## Seams and doubles

- Stubbing or mocking methods on the object under test when real inputs or injected collaborators can prove the behavior.
- Reaching for `mock`, `stubs`, or `expects` before trying real data, plain Ruby test doubles, or a small dependency-injection seam.
