---
name: codebase-design
description: Codebase design for Ruby/Rails. Use when designing or reviewing module interfaces, Rails seams, responsibility placement, deepening shallow code, reducing coupling, or making code easier to test.
---

# Codebase Design

Design **deep Rails-native modules**: a small interface at a clean seam, with enough behaviour behind it to give callers leverage and maintainers locality. Decomplect concerns that should vary independently, but do not add ceremony unless it creates depth, clarifies responsibility, or removes a real coupling cost.

## Vocabulary

Use these terms exactly.

**Module** — anything with an interface and implementation: method, class, model, concern, component, query, operation, subsystem. Avoid using "service" as the generic word.

**Interface** — everything callers must know to use the module correctly: method names, params, invariants, ordering, side effects, errors, and performance shape.

**Seam** — the place where a module's interface lives; callers and tests cross the same seam.

**Adapter** — a concrete implementation that satisfies an interface at a seam. One adapter is hypothetical; two adapters make the seam real.

**Depth** — leverage at the interface. A deep module hides substantial behaviour behind a small interface; a shallow module mostly passes complexity through.

**Leverage** — callers get more capability per interface fact they learn.

**Locality** — change, bugs, knowledge, and verification concentrate in one place instead of spreading across callers.

**Rails-native** — using Rails conventions when they create clarity: rich models, associations, scopes, concerns, callbacks, controllers, jobs, mailers, and components are allowed. Purity loses to simple Rails unless a real concern is braided.

**Responsibility** — what the code owns. In Rails, misplaced responsibility is often clearer than abstract coupling.

**Specification test** — list what a full test would need to prove. If those contexts describe responsibilities outside the object's layer or role, the seam is wrong.

**Waiting room** — `app/{services,interactors}` as temporary residence for orchestration until a better abstraction emerges; not a permanent junk drawer.

**Promote / demote** — move code toward the layer or abstraction its responsibility proves: promote orchestration to an application/presentation specialization; demote domain derivation to models, value objects, query objects, or collaborators.

## Branch

Choose the branch before recommending a design:

- **Review**: inspect existing code or a diff and report design findings.
- **Design**: propose the interface and seam for new or changed code.
- **Deepen**: collapse shallow modules into a deeper module; load [`DEEPENING.md`](DEEPENING.md).
- **Rails responsibility**: resolve service objects, callbacks, `Current`, controllers, models, jobs, policies, queries, forms, or components; load [`RAILS-RESPONSIBILITY.md`](RAILS-RESPONSIBILITY.md).
- **Alternatives**: when the seam/interface is unclear or the user wants options, load [`DESIGN-IT-TWICE.md`](DESIGN-IT-TWICE.md).

Completion criterion: the active branch and any loaded reference are named before analysis begins.

## Steps

### 1. Scope the Target

Identify the files, caller flow, changed diff, or proposed feature. Read enough call sites and tests to see how callers cross the current seam.

Completion criterion: the current or intended caller path is known, including tests when they exist.

### 2. Map the Design

Name the module, interface, seam, responsibility, dependencies, side effects, and hidden state. For Rails code, classify responsibilities as presentation, application orchestration, domain rule/derivation, or infrastructure interaction.

Completion criterion: each important behaviour has an owner and each cross-seam dependency is visible.

### 3. Find the Design Pressure

Look for shallow interfaces, reach-through, duplicated caller knowledge, hidden `Current`/global state, callback-driven workflows, business logic in presentation, domain logic stranded in services, side effects in models, overgrown concerns, or tests that must cross too many layers.

Completion criterion: every finding cites concrete evidence from code, tests, diff, command output, or user-provided context.

### 4. Choose the Smallest Move

Prefer the smallest Rails-native move that increases depth or fixes responsibility:

- Inline or keep code when the abstraction is shallow and no real variation exists.
- Deepen by moving behaviour behind the interface callers already want.
- Promote orchestration or presentation concerns to policies, forms, presenters, components, deliveries, jobs, clients, agents, or operation objects.
- Demote domain rules, queries, calculations, value concepts, or one-model behaviour slices into models, query objects, value objects, collaborators, or concerns.
- Leave an operation object in the waiting room when it orchestrates a real use case and no clearer abstraction has emerged.

Completion criterion: the recommendation states why this seam creates more depth/locality than the alternatives.

### 5. Report the Design

Report findings in priority order. Include: location, current responsibility/seam, problem, recommended move, why it is Rails-native, test impact, and tradeoffs. If no change is worth making, say so and name the evidence.

Completion criterion: the user can act without re-running the analysis and can see what not to change.

## Rails Biases

- Domain logic belongs near the domain model unless that would create a god object or hide orchestration.
- Waiting-room objects orchestrate; they should not steal calculations, invariants, or state transitions from models.
- Concerns are for cohesive traits, not code-slicing by Rails artifact type.
- Callbacks are fine for normalization and local consistency; they are suspicious for workflows and external side effects.
- `Current` is a defaulting/request context mechanism, not a primary dependency for domain decisions.
- One adapter is hypothetical; two adapters make a real seam.
- A test that must pierce the interface is evidence the interface is wrong.
- Use the deletion test: if deleting a module makes complexity vanish, it was a pass-through; if complexity reappears across callers, it was earning its keep.

## Rejected Framings

- Do not use **service** as the generic word for every module.
- Do not measure depth by implementation size; measure caller leverage.
- Do not add layers for purity; add seams when behaviour actually varies or responsibility is misplaced.
- Do not treat Rails layers as rigid architecture ceremony; use them to find misplaced responsibility.

## Sources

This skill combines the deep-module vocabulary from Matt Pocock's `codebase-design`, the Rails responsibility diagnostics from Vladimir Dementyev/Palkan's `layered-rails`, and our existing Ruby/Rails decomplecting guidance. See [`SOURCES.md`](SOURCES.md) when revisiting the intellectual sources or upstream references.
