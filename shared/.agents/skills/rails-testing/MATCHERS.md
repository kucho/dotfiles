# Rails Testing Matchers

Load this when choosing assertion, response, or job matcher names.

Use expectation-style assertions through `ActiveSupport::TestCase` + minitest/spec:

- `expect(value).must_equal(42)` / `.wont_equal(43)`
- `expect(object).must_be(:active?)` / `.wont_be(:inactive?)`
- `expect(object).must_be_nil` / `.wont_be_nil`
- `expect(array).must_include(2)` / `.wont_include(4)`
- `expect(value).must_be_instance_of(String)` / `.must_be_kind_of(Numeric)`
- `expect { code }.must_raise(SomeError)`
- `expect { code }.must_change("User.count", 1)`
- `expect { code }.must_change(["User.count", "Profile.count"], [1, 1])`
- `expect(string).must_match(/world/)` / `.wont_match(/goodbye/)`
- `expect { code }.must_output("hello")`
- `expect { code }.must_be_silent`
- `expect(value).must_be_within_delta(3.14, 0.01)`
- Comparisons: `expect(actual).must_be(:<, limit)`, `expect(actual).must_be(:<=, maximum)`, and related operators
- Controller/integration responses: `must_respond_with(:ok)`, `must_respond_with(:redirect)`, `must_redirect_to(...)`, and related local response helpers
- Active Job tests: `must_enqueue_jobs`, `wont_enqueue_jobs`, `must_perform_jobs`, `must_enqueue_with`, `must_perform_with`, and related helpers

When a matcher is not listed here, check the local test helper or minitest expectation documentation before inventing an assertion style.
