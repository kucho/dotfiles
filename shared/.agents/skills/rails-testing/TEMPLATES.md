# Rails Testing Templates

Load this when creating a new test file, restructuring a test, or needing a copyable shape for the active branch.

## Unit Test Template

```ruby
class ModelNameTest < ActiveSupport::TestCase
  describe ".class_method_name" do
    let(:argument) { "TEST" }

    subject { ModelName }

    it "returns the expected String" do
      result = subject.class_method_name(argument)
      expect(result).must_equal("EXPECTED")
    end

    given "an explicit option" do
      let(:option) { "OPTION" }

      it "returns the option-specific String" do
        result = subject.class_method_name(argument, option:)
        expect(result).must_equal("OPTION EXPECTED")
      end
    end
  end

  describe "#instance_method_name" do
    subject { ModelName.new }

    given "a meaningful precondition" do
      let(:argument) { "TEST" }

      it "returns the expected String" do
        result = subject.instance_method_name(argument)
        expect(result).must_equal("EXPECTED")
      end
    end
  end
end
```

## Nested `given` Template

When sibling conditions share setup, surface what varies: hoist the shared shell into a parent `given` and redefine only the changing input.

```ruby
describe ".label" do
  subject { AccessLevel }

  given "a USER role" do
    let(:role) { "USER" }

    given "enabled" do
      let(:enabled) { true }

      it "returns the enabled label" do
        result = subject.label(role, enabled:)
        expect(result).must_equal("ENABLED USER")
      end
    end

    given "disabled" do
      let(:enabled) { false }

      it "returns the disabled label" do
        result = subject.label(role, enabled:)
        expect(result).must_equal("DISABLED USER")
      end
    end
  end
end
```

## Nested Production Child Template

Keep a lexically owned production child in its parent's test file unless the repository already gives it independent ownership. Place it after the parent's method describes.

```ruby
class Application::PagerTest < ActiveSupport::TestCase
  describe ".turbo_target" do
    subject { Application::Pager }

    it "returns the pager frame identifier" do
      expect(subject.turbo_target).must_equal("pager")
    end
  end

  describe "Null" do
    subject { Application::Pager::Null.new }

    describe "#empty?" do
      it "returns true" do
        expect(subject.empty?).must_equal(true)
      end
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
        must_redirect_to(login_path)
      end
    end
  end
end
```
