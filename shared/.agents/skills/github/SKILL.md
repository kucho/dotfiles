---
name: github
description: "`gh` CLI for GitHub. Use when working with issues or PRs, or attaching demo images and videos."
---

Always pass `--repo owner/repo` when not in a git directory, or use URLs.

## Demo

When an issue, PR, or comment has local demo (a screenshot, GIF, or recording of the UI, error, or result), `--attach` it on the same `gh` command that writes the body so it renders inline.

Requires `gh` 2.99.0+, push access, and GitHub.com or GitHub Enterprise Cloud. Images and videos only.

`--attach` is on `create`, `edit`, and `comment` for `gh issue` and `gh pr`. Repeat the flag per file. Write the body through `--body` or `--body-file`.

Put ordinary local paths in the Markdown, then `--attach` the same paths. `gh` rewrites those references to uploaded URLs. Unreferenced attachments are appended.

```markdown
The form error:

![the sign-in screen showing an authentication error](./before.png)
```

```bash
gh pr create --title "Fix sign-in error" --body-file body.md --attach ./before.png
```

Rewritten references keep the Markdown alt. Otherwise pass `'PATH#alt text'` (quote it so the shell keeps `#`). Videos have no alt.

A video player is a paragraph whose only content is the image reference:

```markdown
![](./walkthrough.mp4)
```

`gh issue edit --attach` takes one issue.

Every demo file that should render is a local path in the body and a `--attach` value on that command.
