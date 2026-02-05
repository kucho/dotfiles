# Cohesion & Coupling (Ruby + Rails)

## Cohesion

High cohesion means a class or module has a clear, single purpose.

```ruby
# Good: cohesive
class PasswordHasher
  def hash(password)
    BCrypt::Password.create(password)
  end

  def verify(password, digest)
    BCrypt::Password.new(digest) == password
  end
end
```

## Coupling

Low coupling means objects depend on each other through narrow, stable interfaces.

```ruby
# Tight coupling (bad)
class OrdersController
  def create
    order = Order.new(order_params)
    order.instance_variable_set(:@state, :confirmed)
  end
end

# Looser coupling (good)
class OrdersController
  def create
    order = Order.new(order_params)
    order.confirm!
  end
end
```

## Dependency Direction

- Controllers -> domain models (OK)
- Domain models -> controllers (avoid)
- Richer objects hide details behind APIs

## Coupling Checklist

- Is the dependency graph easy to describe?
- Can I test this class without constructing half the app?
- Are we sharing data structures we only partially use?
- Are callbacks making dependencies non-obvious?

## Decoupling Strategies

- Move conditionals to polymorphic objects.
- Use `ActiveSupport::Concern` to isolate traits.
- Extract query objects for complicated database access.
