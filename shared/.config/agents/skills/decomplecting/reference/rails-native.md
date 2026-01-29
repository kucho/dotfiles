# Rails-Native Design Guidance

Grounded in pragmatic Rails usage from 37signals: use the framework, avoid ceremony, and keep code readable.

## Concerns

Use concerns to capture a cohesive trait of a model. A concern should read as "has trait" or "acts as".

```ruby
# app/models/recording.rb
class Recording < ApplicationRecord
  include Recording::Incineratable
end

# app/models/recording/incineratable.rb
module Recording::Incineratable
  extend ActiveSupport::Concern

  def incinerate
    Recording::Incineration.new(self).run
  end
end
```

Guidelines:
- Avoid concerns as arbitrary buckets.
- Prefer `app/models/<model_name>/` for model-specific concerns.
- For shared concerns, use `app/models/concerns`.
- A concern should add a small, cohesive surface area (usually 1-3 public methods).
- If a concern needs many private helpers, extract a collaborator object instead.
- A concern should not orchestrate a multi-step workflow via callbacks.

## Vanilla Rails is plenty

- Controllers can call domain models directly.
- Prefer rich domain models over extra application layers.
- Only add service/command objects when they encapsulate real complexity.

```ruby
class Boxes::DesignationsController < ApplicationController
  def create
    @contact.designate_to(@box)
  end
end
```

## Active Record, nice and blended

Active Record can host both persistence and domain logic when it reads naturally.

```ruby
class Contact < ApplicationRecord
  include Contactables

  def designate_to(box)
    if box.imbox?
      undesignate_from(box.identity.boxes)
    else
      update_or_create_designation_to(box)
    end
  end
end
```

## Callbacks + CurrentAttributes (use judiciously)

Use callbacks to attach orthogonal concerns (auditing, bookkeeping), not to drive core business flow.

```ruby
class Bucket < ApplicationRecord
  include Eventable
end

module Bucket::Eventable
  extend ActiveSupport::Concern

  included do
    has_many :events, dependent: :destroy
    after_create_commit :track_created
  end

  def track_event(action, creator: Current.person, **particulars)
    Event.create!(bucket: self, creator: creator, action: action, detail: Event::Detail.new(particulars))
  end

  private

  def track_created
    track_event(:created)
  end
end
```

Guidelines:
- Prefer explicit orchestration for primary flows.
- Use `CurrentAttributes` for request-scoped defaults when passing context everywhere harms clarity.
- Use `.suppress` for exceptional cases.
- Avoid `Current` in async jobs unless it is explicitly set in the job.
- Treat `Current` as a defaulting mechanism, not a primary dependency for core domain logic.

Callback safety:
- Use `after_commit`/`after_create_commit` for side effects (emails, jobs, external APIs).
- Avoid `before_*` callbacks for non-trivial logic.

## Tradeoff Reminder

Rails embraces tradeoffs. Avoid purist rules like "never callbacks" or "always services". Choose the simplest design that keeps responsibilities clear.

## References

- https://dev.37signals.com/good-concerns/
- https://dev.37signals.com/vanilla-rails-is-plenty/
- https://dev.37signals.com/active-record-nice-and-blended/
- https://dev.37signals.com/globals-callbacks-and-other-sacrileges/
