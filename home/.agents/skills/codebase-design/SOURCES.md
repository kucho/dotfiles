# Sources and Influences

This skill is our Ruby/Rails codebase-design vocabulary. It intentionally combines several sources rather than copying any one of them wholesale.

## Matt Pocock — `codebase-design`

Source: https://github.com/mattpocock/skills/tree/main/skills/engineering/codebase-design

Borrowed/adapted ideas:

- shared vocabulary over generic advice;
- **module**, **interface**, **seam**, **adapter**, **depth**, **leverage**, and **locality**;
- deep modules as small interfaces hiding substantial behaviour;
- callers and tests crossing the same seam;
- one adapter as hypothetical, two adapters as a real seam;
- `DESIGN-IT-TWICE.md` as a disclosed workflow for alternative interfaces;
- `DEEPENING.md` as a disclosed workflow for making shallow clusters deeper.

Our adaptation:

- examples and decisions are Ruby/Rails-oriented rather than TypeScript-oriented;
- Rails-native seams are first-class: models, scopes, concerns, callbacks, jobs, mailers, policies, components, query objects, and operation objects;
- purity is subordinate to Rails-native depth.

## Vladimir Dementyev / Palkan — `layered-rails`

Source: https://github.com/palkan/skills/tree/master/layered-rails/skills/layered-rails

Borrowed/adapted ideas:

- presentation/application/domain/infrastructure responsibility map;
- the **specification test** as a way to reveal misplaced responsibility;
- `app/services` as a **waiting room**, generalized here to `app/{services,interactors}`;
- **promote up / demote down** classification for service-shaped code;
- purpose-first classification instead of filename-only classification;
- callback scoring;
- god-object brakes;
- CurrentAttributes cautions;
- canonical Rails refactoring moves: Current out of models, callbacks to orchestrators, query objects, policies, form objects, presenters/components, state machines, and collaborators.

Our adaptation:

- reduced the top-level skill to vocabulary + process;
- avoided large pattern catalogs in always-loaded context;
- resolved layer language into a pragmatic responsibility lens instead of strict architecture ceremony;
- kept Rails-native tradeoffs explicit.

## Existing local `decomplecting` skill

Former location: `shared/.agents/skills/decomplecting/`

Carried forward:

- Rich Hickey's simple-versus-easy distinction;
- decomplecting as unbraiding concerns that should vary independently;
- pragmatic Ruby OOD: message passing, small intention-revealing interfaces, collaborators;
- Rails-native bias: rich Active Record models, cohesive concerns, judicious callbacks and CurrentAttributes.

Changed:

- `decomplecting` is now a design move inside `codebase-design`, not a separate skill identity.
- The skill now has deterministic branches and completion criteria instead of analyzer labels.

## Further background

- Rich Hickey — "Simple Made Easy", "The Value of Values"
- John Ousterhout — deep modules, design it twice
- Michael Feathers — seams
- Sandy Metz — practical object-oriented design in Ruby
- Martin Fowler — refactoring vocabulary and patterns
- 37signals Rails writing — vanilla Rails, good concerns, Active Record nice and blended, callbacks/globals tradeoffs
