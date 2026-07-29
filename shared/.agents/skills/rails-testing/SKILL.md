---
name: rails-testing
description: "Receiver-driven Rails/Minitest tests. Use when writing, editing, restructuring, or reviewing Rails/Ruby unit tests, controller/integration tests, *_test.rb files, expectations, fixtures, mocks/stubs, or test failures."
metadata:
  short-description: "Follow WET Rails/Minitest testing conventions"
---

# Rails Testing

Write **WET, receiver-driven Rails/Minitest tests**: each example makes one method or HTTP action obvious through local setup, an explicit invocation, and an independent oracle.

## Vocabulary

**WET** — Write Expressive Tests. Repeat clear local setup when that keeps an example readable; extract only when indirection improves comprehension.

**Receiver-driven** — a unit example explicitly invokes the described method on `subject`, where `subject` is the method's receiver rather than its result.

**Adapter test** — a controller/integration example invokes the HTTP request inside `it` and observes adapter behavior without `subject`.

**Tautological test** — an expectation derived through the same production collaborator or expression as the actual value. Replace it with an **independent oracle**: a pinned literal, declared fixture fact, or independently calculated invariant.

## Branches

Choose the test branch first:

- **Unit/model/interactor** — `describe` names a method, `subject` is that method's receiver, and every `it` calls the method on `subject`.
- **Controller/integration** — `describe` names the action, no `subject` is used, and every `it` exercises the action through HTTP helpers.

Load disclosed reference only when its trigger is reached:

- **Create/restructure** — load [`TEMPLATES.md`](TEMPLATES.md) for the copyable shape that matches the branch.
- **Review/repair** — load [`CHECKLIST.md`](CHECKLIST.md) for non-trivial edits, reviews, or questionable test shapes.
- **Collaborator seam** — load [`DOUBLES.md`](DOUBLES.md) before choosing how to replace a client, clock, parser, command gateway, external service, nondeterministic source, or existing `stubs`/`expects` call.
- **Matcher lookup** — load [`MATCHERS.md`](MATCHERS.md) for expectation and response matcher names.
- **Nested production child** — load the [`Nested Production Child Template`](TEMPLATES.md#nested-production-child-template) before choosing its test file or `describe` shape.

Completion criterion: the active branch is known, including whether `subject` is required or forbidden.

## Core Contracts

### WET, narrow, self-describing examples

- Scope `before`, `after`, `let`, and `subject` to the smallest `describe` or `given` that needs them. Avoid top-level setup unless every example uses it.
- Let `describe` + `given` + `it` and clean code communicate mechanics; reserve comments for domain facts not evident from the code.
- Use descriptive local names and preserve established domain/API vocabulary, including conventional abbreviations and required parameter keys.

### Receiver-driven unit tests

- Use class-based minitest/spec tests, normally inheriting from `ActiveSupport::TestCase` or the more specific Rails test base.
- A unit-test `describe` string must be exactly the method under test: `".method_name"` for class methods or `"#method_name"` for instance methods. Descriptive context belongs in `given` or `it`.
- Order unit-test `describe` blocks to match the source method order. Skip untested methods; do not alphabetize or regroup by theme.
- Set `subject` to the class for `.method` or an instance for `#method`; keep persistence, HTTP requests, collaborator mutation, and the method invocation outside `subject`.
- Every `it` explicitly calls `subject.<method_under_test>(...)`, including predicates. An example that proves another method belongs under that method's `describe`.
- Use `before` for preconditions; invoke the method under test in each `it`.

### Setup surfaces what varies

Within every `describe` or `given`, declare setup in this order:

1. `before` / `after`
2. `let`
3. `subject` (unit tests only)
4. `it` and nested `given` blocks

Use `do`/`end` for `before` and `after`, and braces for `let` and `subject`. Keep cleanup in the narrow `after` for the state it cleans up.

- Use `given "..." do` for conditions and variations.
- **Surface what varies**: place shared wiring in the nearest common scope and redefine only the changing input in each `given`.
- Nest shared preconditions; inner `given` strings name only the variation because nesting already reads as “with.”

### Assertions use independent oracles

- Use `expect(...).must_*` and `expect(...).wont_*` when an expectation matcher exists.
- For code under test, use block expectations such as `expect { subject.save! }.must_raise(Error)`, `must_change`, `must_output`, and `must_be_silent`.
- Establish expected values independently. A path helper, enum source, parser, formatter, or other collaborator used by production cannot also establish the expected result.
- Keep each `it` focused on one observable result, side effect, error, enqueue, output, response, or redirect.

### Test data is deliberately synthetic

- Reuse a suitable fixture when it already expresses the scenario.
- Otherwise use domain-valid synthetic values: `TEST`-style strings and the shortest unambiguous `9`, `99`, or `999` for numbers.
- Established fixture labels, schemas, protocols, and domain/API formats take precedence. Create a fixture only when a record clarifies the behavior better than a literal.

### Adapter tests exercise HTTP behavior

- Name the action with `describe "#show"`, `describe "#create"`, or the matching action name.
- Declare `before`/`after`, then `let`; adapter tests have no `subject`.
- Each `it` performs the request and verifies the response or exact redirect through response helpers such as `must_respond_with` and `must_redirect_to`.
- Cover routing, authorization, response, and handoff behavior here; keep business behavior in unit-tested collaborators.

## Steps

### 1. Read the receiver

Read enough implementation to know the method order, receiver or action, public API, observable effects, local test base, and collaborator or adapter boundaries.

Completion criterion: the receiver/action, source method order when applicable, existing local test style, relevant test base, and collaborator seam or adapter boundary are known.

### 2. Shape the test around the contracts

Place `describe` blocks in source order, choose the correct test base, narrow setup to the owning condition, and surface what varies. For new files or restructures, load [`TEMPLATES.md`](TEMPLATES.md).

Completion criterion: the skeleton obeys branch, setup-order, source-order, and receiver contracts before assertions are filled in.

### 3. Write small examples

Invoke the described method or HTTP action in each `it`, then verify one observation with an independent oracle. Name a returned value `result` when that makes the example clearer.

Completion criterion: every unit example explicitly calls `subject.<method_under_test>`, every adapter example performs its request, and every expected value is independent of the production path.

### 4. Check the traps

For non-trivial edits or reviews, load [`CHECKLIST.md`](CHECKLIST.md) and scan every changed example, setup block, expected value, and test double.

Completion criterion: every detected trap is repaired or justified by a repository-local constraint.

### 5. Verify narrowly

Run the smallest useful test command for the changed file or example. Broaden when shared test helpers, production seams, or cross-file behavior changed, and run checks required by repository instructions.

Completion criterion: the focused test and applicable repository-required checks pass; any unavailable command is reported with the reason it could not run.
