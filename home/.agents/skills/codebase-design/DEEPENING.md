# Deepening

Use this when a cluster of shallow code should become one deeper module, or when testability/caller complexity suggests the seam is wrong.

## Goal

A deep module gives callers leverage: they learn a small interface and get substantial behaviour. It gives maintainers locality: the behaviour changes in one place.

Do not deepen by stacking wrappers. Deepen by moving caller knowledge behind the interface callers already want.

## Process

### 1. Identify the Cluster

List the modules, callers, tests, and duplicated caller knowledge. Include the behaviour that currently leaks through the interface: ordering, setup, params, side effects, error handling, retries, authorization, query shape, or caching.

Completion criterion: the complexity that would reappear if the modules were deleted is visible.

### 2. Pick the Seam

Choose where callers should stop knowing details. In Rails, common seams are model methods, query objects, form objects, policies, components, deliveries, jobs, operation objects, clients, and collaborators.

Completion criterion: callers and tests would cross the same proposed interface.

### 3. Classify Dependencies

Dependency type determines the test strategy:

| Dependency | Strategy |
|---|---|
| In-process Ruby / pure domain data | put behind the module and test directly through the interface |
| Active Record / database | prefer relation/model seams; test with records or a focused fixture, not mocks of AR internals |
| Rails framework services | keep at Rails-native seams: job enqueue, mail delivery, component render, controller response |
| Owned remote service | define a port only if production and test/adapters both need it |
| Third-party service | inject or isolate a client/adapter; test the module with a fake/mock adapter |

One adapter is hypothetical; two adapters make a real seam.

### 4. Design the Interface

The interface includes method names, params, invariants, ordering, errors, side effects, and performance. Prefer one or a few intention-revealing entry points over many knobs.

Ask:

- Can callers stop reaching through associations or collaborators?
- Can params be domain concepts instead of request-shaped hashes?
- Can side effects be explicit at the seam?
- Can tests assert observable outcomes instead of internals?
- Does this hide complexity or merely rename it?

Completion criterion: a caller example is shorter and knows less than before.

### 5. Replace Tests, Don't Layer Them

Write tests at the new interface. Delete or collapse tests that only covered the old shallow internals once equivalent interface tests exist. Keep caller tests as delegation/contract tests when the lower module now owns the behaviour.

Completion criterion: no test has to pierce the new interface to prove normal behaviour.

## Brakes

Stop before deepening when:

- the module would be a pass-through wrapper;
- the behaviour varies in only one place and no second adapter/caller exists;
- the cluster shares names but not structure;
- deepening would move orchestration into an already large god model;
- Rails already gives a clear seam (`scope`, association, validation, callback, job, component) and a custom abstraction adds no leverage.

## Output

Report:

1. Current shallow shape.
2. Proposed deep module and seam.
3. Interface sketch.
4. What moves behind the interface.
5. Dependency/test strategy.
6. What tests become obsolete or simpler.
7. Brakes considered.
