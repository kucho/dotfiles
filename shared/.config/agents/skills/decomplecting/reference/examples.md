# Examples (Ruby + Rails)

All examples are real Ruby/Rails patterns and rely on Rails APIs that are standard.

## 1) Concern + Delegation (traits + object collaboration)

```ruby
# app/models/account.rb
class Account < ApplicationRecord
  include Account::Closable
end

# app/models/account/closable.rb
module Account::Closable
  def terminate
    Account::Closing::Purging.new(self).run
  end
end

# app/models/account/closing/purging.rb
class Account::Closing::Purging
  def initialize(account)
    @account = account
  end

  def run
    # ... domain logic
  end
end
```

## 2) Rich domain model with query object

```ruby
# app/controllers/reports/users/progress_controller.rb
class Reports::Users::ProgressController < ApplicationController
  def show
    @events = Timeline::Aggregator.new(Current.person, filter: current_page_by_creator_filter).events
  end
end

# app/models/timeline/aggregator.rb
class Timeline::Aggregator
  def initialize(person, filter: nil)
    @person = person
    @filter = filter
  end

  def events
    Event.where(id: event_ids).preload(:recording).reverse_chronologically
  end

  private

  def event_ids
    event_ids_via_optimized_query(1.week.ago) ||
      event_ids_via_optimized_query(3.months.ago) ||
      event_ids_via_regular_query
  end
end
```

## 3) Callbacks for orthogonal concerns

```ruby
# app/models/bucket.rb
class Bucket < ApplicationRecord
  include Eventable
end

# app/models/bucket/eventable.rb
module Bucket::Eventable
  extend ActiveSupport::Concern

  included do
    has_many :events, dependent: :destroy
    after_create :track_created
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

## 4) `CurrentAttributes` for request context

```ruby
# app/models/current.rb
class Current < ActiveSupport::CurrentAttributes
  attribute :account, :person
  attribute :request_id, :user_agent, :ip_address
end

# app/models/event/request.rb
class Event::Request < ApplicationRecord
  belongs_to :event

  before_create :set_from_current

  private

  def set_from_current
    self.request_id ||= Current.request_id
    self.user_agent ||= Current.user_agent
    self.ip_address ||= Current.ip_address
  end
end
```

## 5) Active Record with domain logic (blended)

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
