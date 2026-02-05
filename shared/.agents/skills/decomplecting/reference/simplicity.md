# Simplicity & Decomplecting for Ruby

## Core Philosophy (Rich Hickey, adapted)

- **Simple** means not intertwined. A method or object has one role.
- **Easy** means familiar or convenient. Easy is subjective; simple is objective.
- **Complecting** is braiding concerns that should be independent.

## Ruby-Specific Decomplecting

### Prefer explicit dependencies over hidden state

```ruby
# Complected: hidden dependency (global)
class Billing
  def charge(order)
    Payments.charge(order.total_cents) # global
  end
end

# Decomplected: explicit dependency
class Billing
  def initialize(payments:)
    @payments = payments
  end

  def charge(order)
    @payments.charge(order.total_cents)
  end
end
```

### Decomplect object state from behavior

```ruby
# Complected: object both holds state and orchestrates IO
class Newsletter
  def deliver
    subscribers.each { |s| Emailer.send_newsletter(s) }
    update!(last_sent_at: Time.current)
  end
end

# Decomplected: object exposes facts, other objects orchestrate
class Newsletter
  def to_delivery
    { id: id, subscribers: subscribers }
  end
end

class NewsletterDelivery
  def initialize(newsletter:, emailer:, clock:)
    @newsletter = newsletter
    @emailer = emailer
    @clock = clock
  end

  def run
    @newsletter.subscribers.each { |s| @emailer.send_newsletter(s) }
    @newsletter.update!(last_sent_at: @clock.call)
  end
end
```

### Prefer data flow to time coupling

```ruby
# Complected: time coupling
class Report
  def generate
    load_data
    normalize
    persist
  end
end

# Decomplected: data flow clarifies order
class Report
  def generate
    data = load_data
    normalized = normalize(data)
    persist(normalized)
  end
end
```

## Simplicity Checklist

- Can this object be understood in isolation?
- Can I test it without stubs for unrelated IO?
- Are dependencies explicit (initializer args or parameters)?
- Is the method doing one conceptual thing?
- Are side-effects at the edge of the call graph?

## Heuristics

- Avoid mixing persistence, orchestration, and policy in the same method.
- Avoid callbacks for primary control flow; prefer explicit calls unless the concern is orthogonal and small.
- Prefer value-like objects for calculations and decisions; keep them free of IO.

## Suggested Reading

- Rich Hickey: "Simple Made Easy"
- Rich Hickey: "The Value of Values"
