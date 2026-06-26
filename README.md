<h2 align="center">kucho/dotfiles</h2>

## Prerequisites
1. [GNU/Stow](https://www.gnu.org/software/stow/)

##  Installation

1. Clone onto your machine:
  ```bash
  git clone git@github.com:kucho/dotfiles.git ~/dotfiles
  ```

2. Install the configuration files you need/want:
  ```bash
  cd ~/dotfiles
  stow zsh
  stow git
  stow osx
  ```

3. Edit/Replace/Create new config files and restow them:
  ```bash
  stow -R zsh # the folder that contains the new config file
  ```

## Vendored agent skills

First-party skills live in `shared/.agents/skills` and are tracked normally. External skills are declared in `shared/.agents/skill-sources.toml`, pinned in `shared/.agents/skill-sources.lock.toml`, and downloaded into ignored directories under `shared/.agents/skills`.

```bash
agent-skills add https://github.com/owner/repo/blob/main/skills/name
agent-skills install
agent-skills update name
agent-skills update --all
agent-skills list
```

`install` uses the lock file's resolved commit hashes. `update` is the command that refreshes those hashes from the manifest refs.
