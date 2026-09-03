# Rails Testing Doubles

Load this before choosing how to replace a collaborator or preserve an existing Mocha seam.

## Vocabulary

**Test double** — the umbrella term for an object standing in for a production collaborator.

**Stub double** — a stand-in that returns controlled query results. It is distinct from calling Mocha's `stubs` on an existing object.

**Fake** — a lightweight working implementation, often backed by simplified in-memory state.

**Recording double** — a spy-role double that records received commands for explicit verification after the subject acts.

**Mock** — a double with predeclared interaction expectations, normally verified by a framework.

**Dependency injection** — the seam through which a real collaborator or test double is supplied; it is not an alternative to test doubles.

**Mocha** — a framework that supplies mock and stub doubles and supports full or partial method stubbing; it is not synonymous with all test doubles.

## Choose by collaborator role

1. Use real data or a real collaborator when it is local, deterministic, fast, and inside the intended test boundary.
2. For a query dependency, inject a plain Ruby stub double or fake and verify the subject's result or state.
3. For a command dependency, use a recording double when the sent message is the observable contract; invoke the subject before asserting on recorded calls.
4. Use an injected Mocha mock when predeclared cardinality or ordering is materially clearer than recorded-call state.
5. Reserve partial method stubbing such as `object.stubs`, class stubbing, and `any_instance` for hard/global boundaries or legacy code where an injection seam would harm the production API or exceed the task's scope.

Keep the receiver under test real. Replace its inputs or boundary collaborators rather than its own behavior.

## Query stub double

```ruby
describe "#total" do
  given "the calculator returns no result" do
    let(:calculator) { ->(*) {} }

    subject { OrderSummary.new(calculator:) }

    it "returns zero" do
      result = subject.total
      expect(result).must_equal(0)
    end
  end
end
```

## Recording command double

```ruby
class UploadTest < ActiveSupport::TestCase
  describe "#call" do
    let(:importer) { ImporterDouble.new }

    subject {
      Upload.new(
        account_id: 9,
        path: "/tmp/TEST.csv",
        importer:,
      )
    }

    it "performs the import with the expected attributes" do
      subject.call

      expect(importer.perform_calls).must_equal(
        [{ account_id: 9, path: "/tmp/TEST.csv" }],
      )
    end
  end

  ImporterDouble = Data.define(:perform_calls) do
    def initialize(perform_calls: []) = super(perform_calls:)

    def perform(**attributes)
      perform_calls << attributes
    end
  end
end
```

A recording double still verifies an interaction. Its advantage over `expects` is visible act-before-assert structure and ordinary Ruby failure state.

## Value containers

- Prefer `Data.define` when the project's Ruby version supports it and fields do not need reassignment. Mutating an object held by a field, such as appending to a calls array, is appropriate for a recording double.
- Use `Struct` when field reassignment is part of the double's behavior.
- Use a small class when lifecycle, validation, or behavior makes either value container obscure.
- Follow repository-local constant ordering. Use `private_constant` when it clarifies test-only ownership.

## Mocha seams

An injected Mocha mock is both a test double and dependency injection. Choose it when declaring required cardinality or ordering before the invocation makes the command contract clearer than recorded calls.

Mocha's `object.stubs(:method)` changes an existing object's behavior instead of supplying a separate double. Class stubs and `any_instance` widen that partial replacement further. Keep these seams at hard/global boundaries or in legacy code, and keep them away from the receiver's own behavior.

Completion criterion: the chosen seam matches the collaborator's query or command role, leaves the receiver real, and uses Mocha partial stubbing only where a clearer injected seam is not reasonable.
