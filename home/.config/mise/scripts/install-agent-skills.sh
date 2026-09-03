#!/usr/bin/env bash
set -euo pipefail

root=${AGENT_SKILLS_DOTFILES:?AGENT_SKILLS_DOTFILES is unset; run through mise exec}
exec ruby "$root/home/.local/bin/agent-skills" install
