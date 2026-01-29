---
name: decomplecting
description: "Architectural analysis for Ruby and Ruby on Rails codebases focused on simplicity, pragmatic OOD, and Rails-native design choices. Use for design reviews, refactors, and assessing coupling/cohesion in Ruby and Rails systems."
---

# Decomplecting

Architectural analysis for Ruby and Ruby on Rails, grounded in simplicity, pragmatic object-oriented design, and Rails-native patterns.

## Usage

```
/decomplecting                 # Run all analyzers
/decomplecting --simplicity    # Rich Hickey-inspired simplicity (adapted for Ruby)
/decomplecting --ood           # Pragmatic OOD (Kay, Metz, Fowler)
/decomplecting --rails-native  # Rails conventions (concerns, AR, callbacks)
/decomplecting --coupling      # Cohesion/coupling checks
```

## Analyzers

| Analyzer | Question |
|----------|----------|
| **simplicity-analyzer** | Is the Ruby code simple (decomplected) rather than merely easy? |
| **ood-analyzer** | Are responsibilities clear with pragmatic OOD and composable objects? |
| **rails-native-analyzer** | Are Rails features used thoughtfully to reduce ceremony? |
| **coupling-analyzer** | Are modules cohesive with minimal coupling? |

## What It Checks

| Pillar | Focus |
|--------|-------|
| **Simplicity** | Clear roles, explicit dependencies, small objects, decomplected concerns |
| **OOD** | Object boundaries, message passing, composition, and readable APIs |
| **Rails-native** | Concerns, Active Record, callbacks, `CurrentAttributes` used with intent |
| **Coupling** | Dependency direction, data boundaries, reduced global state |

## When to Use

- Reviewing Ruby/Rails architecture
- Before large refactors
- When Rails code feels tangled or over-abstracted
- When you want pragmatic, framework-friendly design guidance

## Supported Languages

- Ruby
- Ruby on Rails

## Reference Documentation

- [Simplicity & Decomplecting for Ruby](reference/simplicity.md)
- [Pragmatic OOD in Ruby](reference/ood.md)
- [Rails-Native Design Guidance](reference/rails-native.md)
- [Cohesion & Coupling](reference/coupling.md)
- [Examples (Ruby + Rails)](reference/examples.md)

Load these references when detailed analyzer information is needed.
