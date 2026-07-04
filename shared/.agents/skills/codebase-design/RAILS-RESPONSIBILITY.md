# Rails Responsibility

Use this when code placement is the question: services, callbacks, `Current`, controllers, models, jobs, policies, forms, queries, presenters, components, clients, or agents.

## Rails Responsibility Map

Use responsibility, not folder name, as the classifier:

| Responsibility | Rails homes |
|---|---|
| Presentation: HTTP, params, response, view formatting, UI state | controllers, views, helpers, presenters, components, serializers, forms, filters |
| Application orchestration: use cases, transactions, side-effect coordination, authorization entry points | operation/service/interactor objects, policies, jobs, deliveries, notifiers, agents |
| Domain: rules, invariants, calculations, state transitions, domain queries | models, scopes, concerns, query objects, value objects, collaborators |
| Infrastructure: persistence mechanics, external APIs, transport, storage, SDK wrappers | Active Record, clients, adapters, mailers, queues, storage, HTTP/SDK wrappers |

Rule: lower/domain code must not depend on request/presentation context or application orchestration. Rails exceptions are allowed only when they are defaults or framework glue, not business decisions.

## Specification Test

For the target object, outline the tests it would need if fully specified. Annotate each context:

- ✓ belongs to this object's responsibility
- ⚠️ borderline; may stay but signals design pressure
- ✗ belongs elsewhere

Layer symptoms:

- Controller spec proves pricing, state transitions, or data derivation → domain leaked upward.
- Model spec proves email delivery, job enqueueing, HTTP calls, or authorization by current user → application/presentation leaked downward.
- Service spec proves pure calculations over one model's data → anemic-model risk.
- Component/helper spec needs database setup or policy decisions → presentation owns too much.

A refactor is justified when moving the ✗ contexts to a better seam makes tests smaller, faster, or more direct.

## Purpose First, Regex Second

Classify service-shaped classes by purpose:

1. Derives information from domain data → domain query/calculator/model method.
2. Wraps a small bundle of values with pure behaviour → value object.
3. Owns one model's coherent behaviour slice → collaborator/delegate or concern.
4. Coordinates a use case, transaction, delivery, job, SDK call, or outward side effect → application orchestration.
5. Wraps HTTP/SDK/storage with little domain policy → client/adapter/infrastructure.

Names corroborate but do not decide. `*Calculator` can be an agent if it calls an LLM; `*Notifier` can be application even if it only creates records that downstream callbacks deliver.

## Waiting Room

`app/{services,interactors}` is a waiting room, not a junk drawer. Treat `Service`, `Interactor`, `Operation`, `Action`, and `Command` names as local dialects for the same temporary role unless the codebase gives them distinct contracts.

Keep a waiting-room object when it orchestrates a real use case across multiple collaborators or side effects. Otherwise:

- **Promote up** recognizable application/presentation shapes: policy, form, filter, presenter, component, serializer, delivery, notifier, job, client, agent, importer.
- **Demote down** domain shapes: model method, scope, query object, value object, collaborator/delegate, behavioral concern.
- **Inline/delete** pass-through wrappers that add no leverage.
- **Wait** when a cluster is small or structurally inconsistent; a wrong abstraction is worse than duplication.

Before proposing a shared base class, sample bodies and tests. Shared names are not enough; there must be shared machinery, shared interface, or shared test vocabulary.

## Common Moves

### Current

Acceptable: framework defaults, audit/default attribution, explicit fallback params (`user: Current.user`) when callers can override.

Suspicious: business decisions, authorization, query scoping, service dependencies, or job logic that silently requires request context.

Move: pass context explicitly from controller/job, or put permission rules in a policy.

### Callbacks

Score by purpose:

| Score | Type | Keep? |
|---|---|---|
| 5 | Transformer/default on same record | yes |
| 4 | Normalizer or local maintainer | yes |
| 3 | Simple timestamp/state bookkeeping | usually |
| 2 | Background trigger / observer | review |
| 1 | Business operation or external side effect | extract |

Move operation callbacks to the caller, an operation object, a job, delivery, or event subscriber. Keep model callbacks local and unsurprising.

### Concerns

Good concern: cohesive trait with a small public surface, readable as "has/acts as", optionally shared.

Bad concern: code-slicing by artifact type, hidden callbacks, many unrelated private helpers, or dependency on host internals.

Move: inline if organizational only; extract collaborator/delegate for a one-model behaviour slice; extract operation object for workflows.

### Controllers

Keep HTTP, params, auth entry point, response shape, simple CRUD. Move pricing, eligibility, state transitions, reporting queries, and multi-model transactions down or across.

### Models

Keep invariants, calculations, state transitions, simple scopes, cohesive domain behaviour. Do not hide mailers, jobs, SDK calls, request objects, or non-overridable `Current` decisions inside models.

God-object brake: do not demote more behaviour into an already overloaded model. Use collaborators, concerns, associated objects, or application orchestration instead.

### Queries

Atomic scopes stay on models. Complex, parameterized, context-specific, or reused query chains become query objects. Query objects should return relations when composability matters.

### Jobs, Deliveries, and Mailers

Jobs execute async work. Deliveries/notifiers decide when and whom to notify. Mailers format and deliver messages. A job that only delegates may be unnecessary; a model that enqueues jobs, calls deliveries, or calls mailers is probably hiding orchestration.

## Reporting Checklist

For each recommendation, state:

1. Current owner and responsibility.
2. Evidence from code/tests.
3. Move: keep, inline, deepen, promote, demote, or wait.
4. New seam/interface.
5. Test impact: what moves, what gets simpler, what remains at the caller.
6. Tradeoff or stop condition.
