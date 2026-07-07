---
name: rails-testing
description: "Receiver-driven Rails/Minitest tests. Use when writing, editing, restructuring, or reviewing Rails/Ruby unit tests, controller/integration tests, *_test.rb files, expectations, fixtures, mocks/stubs, or test failures."
metadata:
  short-description: "Follow WET Rails/Minitest testing conventions"
---

# Rails Testing

Write **WET, receiver-driven Rails/Minitest tests**: each example should make one method or HTTP action obvious without hidden setup, helper indirection, mock-heavy seams, raw assertions, or explanatory noise.

## Vocabulary

**WET** — Write Expressive Tests. Repeat clear local setup when it makes the example easier to read; do not hide behavior behind helpers just to reduce duplication.

**Receiver-driven** — a unit test proves behavior by calling the method under test on `subject`, where `subject` is the receiver, not the result.

**Adapter test** — a controller/integration test proves HTTP adapter behavior. It never uses `subject`; the request is made inside each `it`.

## Branch

Choose the branch before editing or reviewing tests:

- **Unit/model/interactor** — `describe` names a method, `subject` is that method's receiver, and every `it` calls the method on `subject`.
- **Controller/integration** — `describe` names the action, no `subject` is used, and every `it` exercises the action through HTTP helpers.
- **Create/restructure** — load [`TEMPLATES.md`](TEMPLATES.md) for the copyable shape that matches the branch.
- **Review/repair** — for non-trivial edits or reviews, load [`CHECKLIST.md`](CHECKLIST.md) and repair every changed trap.
- **Pattern check** — load [`CHECKLIST.md`](CHECKLIST.md) before approving a questionable test shape, setup pattern, assertion style, or mocking seam.
- **Matcher lookup** — load [`MATCHERS.md`](MATCHERS.md) for expectation and response matcher names.

Completion criterion: the active branch is known, including whether `subject` is required or forbidden.

## Core Contracts

### WET, narrow, self-describing examples

- Prefer **WET: Write Expressive Tests**. Repeat clear setup over hiding behavior behind helpers or abstractions.
- Scope `before`, `after`, `let`, and `subject` to the smallest `describe` or `given` that needs them. Avoid top-level setup unless every example uses it.
- Test files should read from `describe` + `given` + `it` strings and clean code. Do not add junk comments that restate the structure.
- Do not abbreviate words in test identifiers, comments, `describe`/`given`/`it` strings, or helper names unless the project explicitly allows the abbreviation.

### Unit tests are receiver-driven

- Use class-based minitest/spec tests, normally inheriting from `ActiveSupport::TestCase` or the more specific Rails test base.
- A unit-test `describe` string must be exactly the method under test: `".method_name"` for class methods or `"#method_name"` for instance methods. Descriptive context belongs in `given` or `it`.
- Order unit-test `describe` blocks to match the source method order. Skip untested methods; do not alphabetize or regroup by theme.
- `subject` is the **receiver** of the method under test: the class constant for `.method`, an instance for `#method`. Never set `subject` to the result of the method under test.
- Keep `subject` to the receiver only; do not hide persistence, HTTP requests, calls to the method under test, or other side-effectful setup in `subject`.
- Every `it` inside a method `describe` must explicitly call `subject.<method_under_test>(...)` in the `it` body, either directly in an expectation or by assigning a clearly named `result`. Conversely, an example that proves `subject.<other_method>` belongs under that other method's `describe`.
- `before` sets preconditions only. It must not be the only place the method under test is exercised.

### Setup order is fixed

Within every `describe` or `given`, declare setup in this order:

1. `before` / `after`
2. `let`
3. `subject` (unit tests only)
4. `it` and nested `given` blocks

Use multi-line `before do ... end` and `after do ... end`, never single-line `before { ... }`. Keep cleanup in the narrow `after` for the state it cleans up.

### Use `given` for conditions

- Use `given "..." do`, not `context`, for preconditions and variations.
- Nest shared preconditions instead of repeating the same `let` or `before` across sibling `given` blocks.
- Inner `given` strings name only the variation. Do not start nested `given` strings with `"with"`; the nesting already reads as “with”.

### Assertions are expectation-style

- Use `expect(...).must_*` and `expect(...).wont_*`. Do not use raw `assert_*` / `refute_*` when an expectation matcher exists.
- For code under test, use block expectations: `expect { subject.save! }.must_raise(Error)`, `must_change`, `must_output`, `must_be_silent`, etc. Never use `expect(-> { ... })`.
- Controller/integration tests should use response helpers such as `must_respond_with(:ok)`, `must_respond_with(:redirect)`, and `must_redirect_to(...)` instead of low-level response expectations.

### Prefer dependency injection over mocks

- Prefer real inputs and real objects when they exercise the behavior clearly.
- When a seam is needed, inject collaborators, callables, clocks, clients, parsers, or configuration through the public API.
- Plain Ruby test doubles are preferred: lambdas, small structs/classes, or simple objects.
- Use mocks/stubs only at hard boundaries such as external services, nondeterministic time/randomness, slow I/O, or legacy seams. Do not stub methods on the object under test when real input or an injected dependency would work.
- If production code is only testable by stubbing internals, consider a small dependency-injection refactor before adding mock-heavy tests.

## Controller / Integration Exception

Controller and integration tests verify adapter behavior, not object receivers:

- The `describe` still names the action, usually `"#show"`, `"#create"`, etc.
- Do not declare `subject`.
- Setup order is `before`/`after`, then `let`, then examples.
- Each `it` calls `get`, `post`, `patch`, `delete`, or the relevant request helper inside the example and asserts on the response or redirect.
- Keep business logic in unit-tested collaborators; controller/integration tests should cover thin routing, authorization, response, and handoff behavior.

## Steps

### 1. Read the receiver

Before editing a unit test, read the implementation enough to know the method order, receiver, public API, side effects, and existing collaborator seams. For controller/integration tests, read the route/action and the relevant adapter behavior.

Completion criterion: the receiver/action, source method order when applicable, existing local test style, relevant test base, and collaborator seam or adapter boundary are known.

### 2. Shape the test around the contracts

Place or move the `describe` into source order, choose the correct test base, narrow setup to the owning `given`, and make `subject` the receiver when the branch requires it. For new files or restructures, load [`TEMPLATES.md`](TEMPLATES.md).

Completion criterion: the skeleton obeys branch, setup-order, source-order, and receiver contracts before assertions are filled in.

### 3. Write small examples

Keep each `it` focused on one observable result, side effect, raised error, enqueue, output, response, or redirect. Name the returned value `result` when it improves readability.

Completion criterion: every unit-test example calls `subject.<method_under_test>` in the example body, and every controller/integration example performs the request in the example body.

### 4. Check the traps

For non-trivial edits or reviews, load [`CHECKLIST.md`](CHECKLIST.md) and scan the changed examples before finalizing.

Completion criterion: no changed example violates the receiver, setup-order, assertion, `given`, abbreviation, mock, or controller/integration contracts.

### 5. Verify narrowly

Run the smallest useful test command for the changed file or example. Broaden only when shared test helpers, production seams, or cross-file behavior changed.

Completion criterion: the changed test file or narrowest affected example has been run unless unavailable; broader commands are used only when shared helpers or production seams changed.
