# Design It Twice

Use this when the seam or interface is uncertain, the user asks for options, or the first design feels obvious but high-impact.

## Process

### 1. Frame the Problem

State the design target, constraints, current callers, dependencies, Rails responsibilities, and what must remain true. Include a small code sketch only to ground constraints, not as a proposal.

Completion criterion: a designer could propose an interface without rereading the whole codebase.

### 2. Produce Alternatives

Create at least three meaningfully different designs. If subagents are available and the decision is important, run them in parallel; otherwise produce the alternatives yourself.

Use different constraints:

1. **Minimal interface** — 1-3 entry points, maximum leverage.
2. **Rails-native** — use the framework seam first: model, scope, concern, callback, controller, job, component, or policy.
3. **Responsibility-pure** — separate presentation/application/domain/infrastructure responsibilities cleanly.
4. **Caller-optimized** — make the common caller trivial even if implementation is more complex.

Each alternative must include:

- interface sketch;
- example caller;
- what sits behind the seam;
- dependency and test strategy;
- tradeoffs in depth, locality, Rails fit, and migration cost.

### 3. Compare

Compare on:

- **Depth**: behaviour per interface fact callers learn.
- **Locality**: where future changes concentrate.
- **Responsibility**: whether tests/specification match the owner.
- **Rails-native fit**: whether Rails conventions make the design simpler.
- **Migration path**: whether the change can land incrementally.

### 4. Recommend

Give one opinionated recommendation. If a hybrid is strongest, name exactly which pieces combine and which are rejected.

Completion criterion: the user receives a clear choice, not a menu.
