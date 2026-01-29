# decomplecting

Use this command to run Ruby/Rails architectural analysis.

## Parameters

- `--simplicity` - Rich Hickey-style simplicity (adapted for Ruby)
- `--ood` - Pragmatic OOD checks (Kay, Metz, Fowler)
- `--rails-native` - Rails-native patterns (concerns, AR, callbacks)
- `--coupling` - Cohesion/coupling checks

## Behavior

- If no flags are provided, run all analyzers in parallel.
- If one or more flags are provided, run only those analyzers.

## Output

- Provide concise findings with actionable recommendations.
- Link to relevant files when citing issues or examples.
