---
name: reproduce-bugs
description: >
  Reproduce n2 web bugs in a headed browser. Use when reproducing or
  verifying a reported bug in portal, pub_maintainer, or hub, or when
  another skill needs live-app evidence.
---

# Reproduce Bugs

Get the reported bug **red** in a headed browser. Keep **evidence** under
`tmp/bug-repro/<branch>/`.

```bash
branch="$(git branch --show-current | tr '/' '-')"
mkdir -p "tmp/bug-repro/${branch}"
```

Before the first browser command, load agent-browser core:
`agent-browser skills get core`.

## Steps

### 1. Reach the app

Read `lib/puma/plugin/puma_dev_urls.rb` and use its `PUMA_DEV_URLS` hosts.
Pick the host the report names; if it names none, use the first entry.

Probe that URL:

```bash
curl -sS -o /dev/null -w "%{http_code}" -k --max-time 5 "$URL"
```

An application response (200, 302, 401, 403, 422) means the existing Rails
process is up — use it.

502 or a failed curl means the app is down. Start it once, from the app
root, with `mise exec -- bin/rails server` in the background. Dotenv already
has `PORT`. Wait until the same URL probe returns an application response.

Completion criterion: the puma-dev URL returns an application response from
the process that was already up, or from the one start this step performed.

### 2. Open headed Chrome

```bash
export AGENT_BROWSER_SESSION="$(agent-browser session id --scope worktree --prefix reproduce)"
```

Drive a headed Chrome the human can watch. Attach with `--auto-connect` when
Chrome is already running. Otherwise open headed with `--profile Default`.

Open the puma-dev URL from step 1.

Completion criterion: a headed window is on the puma-dev host, and a
snapshot shows the login form or the signed-in app.

### 3. Pass SSO when the login form is showing

If the snapshot is already signed-in app chrome, this step is done.

Dev SSO is an Email field and a Sign in button. Sign in as the
`Dev SSO email:` line from `AGENTS.local.md` in the app root, or in the n2
root (the app's parent) if the app file has no line.

If that line is missing, ask for the engineer's n2 work email and write
`Dev SSO email: <email>` into the n2 root `AGENTS.local.md` before signing
in.

Wait for `--url` to leave `/dev/saml/`, then snapshot. If the app shows a
role list, pick the role the report requires.

Completion criterion: a snapshot shows signed-in app chrome, or the login
form with a user-not-found (or equivalent) that is itself the finding.

### 4. Reproduce the report

Follow the report's steps on the live app. After each screen change, wait
with `--url`, `--text`, or `--load load`, then snapshot. These apps keep
sockets open, so `networkidle` never completes.

Completion criterion: the report's steps have been exercised, or a blocker
(auth, missing data, 500) is captured as evidence.

### 5. Keep evidence

Put screenshots of the symptom the report names, and of the steps that
produce it, in `tmp/bug-repro/<branch>/`. Add command output, log fragments
from `log/development.log`, and network errors that prove the same thing.
Name files in order (`01-….png`).

Completion criterion: every reproduced symptom has a screenshot or other
irrefutable artifact in `tmp/bug-repro/<branch>/`.

### 6. Report

Say whether the bug went **red**. Point at the evidence files. If it did
not reproduce, say what you did, what you saw, and which step diverged.

Completion criterion: the user can open the evidence folder and match it to
the verdict without re-running the session.
