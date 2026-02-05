# Pragmatic OOD in Ruby

## Influences

- Alan Kay: objects as message-passing boundaries
- Sandy Metz: small objects, readable interfaces, low coupling
- Martin Fowler: domain models, refactoring, and patterns as vocabulary

## Ruby-Oriented OOD Guidelines

### 1) Prefer message passing over reach-through

```ruby
# Reach-through (bad)
class OrderPresenter
  def total(order)
    order.line_items.sum { |i| i.price_cents * i.quantity }
  end
end

# Message passing (good)
class Order
  def total_cents
    line_items.sum { |i| i.total_cents }
  end
end

class LineItem
  def total_cents
    price_cents * quantity
  end
end
```

### 2) Use composition to hide complexity

```ruby
class Account
  def terminate
    Account::Termination.new(self).run
  end
end

class Account::Termination
  def initialize(account)
    @account = account
  end

  def run
    purge_or_incinerate
  end

  private

  def purge_or_incinerate
    eligible_for_purge? ? purge : incinerate
  end

  def purge
    Account::Closing::Purging.new(@account).run
  end

  def incinerate
    Account::Closing::Incineration.new(@account).run
  end
end
```

### 3) Keep public APIs small and intention-revealing

```ruby
# Good: reads like a sentence
account.terminate
recording.copy_to(bucket)
```

### 4) Avoid anemic domain models

```ruby
# Bad: all logic in services
class PaymentsController
  def create
    PaymentService.new(params).run
  end
end

# Better: domain models expose behavior
class Payment
  def charge!(processor:)
    processor.charge(amount_cents)
  end
end
```

### 5) Use names that reflect domain roles

- Prefer `Account::Closing::Purging` over `PurgeAccountService`.
- Prefer `InvitationToken::Signup` over `SignUpService`.

## OOD Heuristics (Ruby)

- If an object exposes too many unrelated public methods, split by trait.
- Extract operations into objects when complexity grows, but keep the API on the domain model.
- Prefer smaller objects collaborating over large conditional methods.

## Domain Modeling (Pragmatic Rails)

- Put invariants on the model (what must always be true).
- Use value objects for domain concepts (Money, DateRange, EmailAddress).
- Extract policies/calculators when logic becomes branchy.
- Define aggregates by asking: what must change together?
- Keep cross-aggregate workflows explicit (operation object or job).

```ruby
class Pricing
  def initialize(tax_rate:)
    @tax_rate = tax_rate
  end

  def total_cents(subtotal_cents)
    (subtotal_cents * (1 + @tax_rate)).round
  end
end
```

## SRP in Ruby (pragmatic)

A class can expose multiple methods as long as it delegates the heavy lifting to focused collaborators. SRP is violated at the implementation level, not just the interface level.

## Suggested Reading

- Sandy Metz: "Practical Object-Oriented Design in Ruby"
- Martin Fowler: "Refactoring" and "Patterns of EAA"
- Alan Kay: "The Early History of Smalltalk"
