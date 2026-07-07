# Rails Testing Templates

Load this when creating a new test file, restructuring a test, or needing a copyable shape for the active branch.

## Unit Test Template

```ruby
class ModelNameTest < ActiveSupport::TestCase
  describe ".class_method_name" do
    let(:argument) { "input" }
    let(:default_value) { "default output" }

    subject { ModelName }

    it "returns the default value" do
      result = subject.class_method_name(argument)
      expect(result).must_equal(default_value)
    end

    given "an explicit option" do
      before do
        prepare_precondition
      end

      after do
        cleanup_precondition
      end

      let(:option) { "variation" }
      let(:option_value) { "variation output" }

      it "returns the option-specific value" do
        result = subject.class_method_name(argument, option:)
        expect(result).must_equal(option_value)
      end
    end
  end

  describe "#instance_method_name" do
    let(:dependency) { Dependency.new }
    let(:instance_value) { "instance output" }

    subject { ModelName.new(dependency:) }

    given "a meaningful precondition" do
      let(:argument) { "input" }

      it "returns the instance value" do
        result = subject.instance_method_name(argument)
        expect(result).must_equal(instance_value)
      end
    end
  end
end
```

## Nested `given` Template

When sibling conditions share setup, hoist the shared setup into a parent `given` and branch inward.

```ruby
describe ".parse" do
  subject { DateParser }

  given "a timestamp String" do
    let(:timestamp) { "20250831123456" }

    given "in the default time zone" do
      it "returns a Time in the default zone" do
        result = subject.parse(timestamp)
        expect(result).must_equal(Time.zone.parse(timestamp))
      end
    end

    given "an explicit time zone String" do
      let(:time_zone) { "Central Time (US & Canada)" }

      it "returns a Time translated into the default zone" do
        result = subject.parse(timestamp, time_zone:)
        expect(result).must_equal(
          Time.find_zone(time_zone).parse(timestamp).in_time_zone,
        )
      end
    end
  end
end
```

## Dependency Injection Example

Prefer injected plain Ruby collaborators over stubbing the subject.

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

## Controller / Integration Template

Controller and integration tests are adapter tests: no `subject`; the request happens inside each `it`.

```ruby
class HomeIntegrationTest < ActionDispatch::IntegrationTest
  describe "#show" do
    given "user is logged in" do
      before do
        login(user)
      end

      let(:user) { users(:admin1) }

      it "returns a successful response" do
        get root_path
        must_respond_with(:ok)
      end
    end

    given "user is not logged in" do
      it "redirects to the login path" do
        get root_path
        must_respond_with(:redirect)
      end
    end
  end
end
```
