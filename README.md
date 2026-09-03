# Dotfiles

My dotfiles for macOS and Arch/CachyOS.

[mise](https://mise.jdx.dev/) installs the packages and tools, then links the configuration files into `$HOME`.

This README tells agents where changes belong. Read the TOML and source files for the current packages, tools, aliases, and settings.

## Quick install

On a fresh machine:

```bash
curl https://mise.run | sh
mise bootstrap --from git@github.com:kucho/dotfiles.git --from-dir ~/dotfiles --yes
```

From an existing checkout:

```bash
cd ~/dotfiles
mise trust
mise bootstrap --yes
```

## Architecture

```text
                               early discovery
                              ┌───────────────┐
                              │ .miserc.toml  │
                              │ auto_env=true │
                              └───────┬───────┘
                                      │ selects the OS file
                 ┌────────────────────▼────────────────────┐
                 │                mise.toml                │
                 │ shared tools · env · dotfiles · tasks   │
                 └───────────────┬─────────────────────────┘
                                 │ loads one of
                    ┌────────────┴────────────┐
                    ▼                         ▼
          mise.macos.toml              mise.linux.toml
          brew · launchd               pacman · systemd
          macOS paths                  Linux paths
                    └────────────┬────────────┘
                                 ▼
                         mise bootstrap
              packages → dotfiles → services → tools → task
                         │                 │
              ┌──────────┴──────────┐      └─► scripts
              ▼                     ▼
      home/ --symlink-each--> $HOME   templates/ --render--> host file
```

On the first run, mise uses the cloned repository. It then links the main config files into `~/.config/mise/`. Future runs load the shared config and the correct OS-specific file from there.

`home/` has the same layout as `$HOME`. `symlink-each` links each file separately, so files not managed by this repository are left alone. **Every non-excluded file in `home/` is installed on every supported machine.**

## Rules for changes

1. **Share what you can.** Put settings used by both operating systems in `mise.toml` or `home/`. Put only OS-specific settings in the macOS and Linux files.
2. **Prefer configuration over scripts.** Use mise sections such as `[tools]`, `[dotfiles]`, `[bootstrap.packages]`, LaunchAgents, and systemd units when they fit. Write a script only when they do not.
3. **Keep OS differences close to the tool.** Use the tool's own include or conditional support first, a template when a file needs different values, and an OS-specific mise file when the whole resource differs.
4. **Define things once.** Each setting, path, package, and startup action should have one source. Comments should explain why something is unusual, not repeat what the file says.
5. **Make setup safe to rerun.** Hooks, post-install scripts, and bootstrap tasks must work on both fresh and already-configured machines.
6. **Keep machine data out of Git.** Do not commit secrets, caches, databases, downloaded dependencies, generated files, or other local state.
7. **Avoid machine names.** Check the OS or an available capability instead of adding rules for individual computers.

## Repository map

| Path | Purpose |
| --- | --- |
| `.miserc.toml` | Enables OS-specific config loading before the main config is read. |
| `mise.toml` | Settings shared by both systems: tools, environment, dotfiles, hooks, and the final bootstrap task. |
| `mise.macos.toml` | macOS-only packages, LaunchAgents, login shell, and environment. |
| `mise.linux.toml` | Linux-only packages, systemd user units, login shell, and environment. |
| `home/` | Shared configuration and executables, using paths relative to `$HOME`. |
| `templates/` | Files rendered by mise when a machine needs different content. |
| `platform/<os>/home/` | Place for static OS-only files when needed. Mirror their path under `$HOME` and add each one to the OS-specific `[dotfiles]` section. |
| `home/.config/mise/scripts/` | Bootstrap hooks, post-install scripts, and programs called by services. |
| `home/.agents/skills/` | First-party skills tracked in Git. Third-party skills are installed from the manifest and lock file. |
| `home/.agents/skill-sources.toml` | Requested third-party skills. |
| `home/.agents/skill-sources.lock.toml` | Exact revisions used to install third-party skills. |

Read the TOML and scripts for implementation details. This table only says which file owns each kind of change.

## Where a change belongs

Choose the closest row. If a change seems to need two owners, split the shared behavior from the OS-specific parts.

| Change | Put it here |
| --- | --- |
| Cross-platform CLI or runtime managed by mise | `[tools]` in `mise.toml` |
| Native package or desktop application | `[bootstrap.packages]` in the matching OS file |
| Environment value shared by both OSes | `[env]` in `mise.toml` |
| OS-specific path or environment value | `[env]` in `mise.macos.toml` or `mise.linux.toml` |
| Config file that should exist on every machine | Its exact home-relative path under `home/` |
| Small OS variation supported by the tool itself | A shared file in `home/` using the tool's include/conditional mechanism |
| Machine-specific file that must be rendered | A source in `templates/` plus an explicit `[dotfiles]` entry |
| Static OS-only file | Its home-relative path under `platform/<os>/home/`, plus an explicit `[dotfiles]` entry in the OS file |
| User service | LaunchAgent in `mise.macos.toml` or systemd user unit in `mise.linux.toml` |
| Behavior shared by both service managers | One executable in `home/.config/mise/scripts/`, called by both services |
| Setup before tools are installed | A named `[bootstrap.hooks]` phase |
| Setup requiring installed tools | `[tasks.bootstrap]` |
| Multi-line or non-trivial setup logic | A focused script in `home/.config/mise/scripts/`, invoked by a hook, task, or post-install |
| First-party agent skill | A dedicated directory under `home/.agents/skills/` |
| Third-party agent skill | `skill-sources.toml`; regenerate the lock/install state with `agent-skills` |
| Secret value | 1Password, referenced through fnox; only the mapping belongs in the repository |

### Existing examples

Follow these patterns instead of creating another way to handle the same problem:

- **Shell startup:** numbered files in `home/.config/fish/conf.d/` set the order. Keep PATH setup before mise activation and tool initialization.
- **Ghostty:** the shared config loads an optional `override`; mise renders it from `templates/ghostty-override.tmpl`.
- **SSH:** `Match exec` uses OpenSSH's own conditional rules for OS differences. Commands there run under fish, so use `$HOME` rather than `${HOME}`.
- **Services:** launchd and systemd settings stay in their OS files, while both call shared scripts for common behavior.
- **Skills:** edit first-party skill sources directly; update vendored skills through the manifest/lock workflow rather than patching installed directories. `pre-dotfiles` installs vendored skills into `home/` so the single symlink-each pass links them.

## Agent workflow

### Before editing

1. Find the change in the placement table.
2. Read the owning config, the other OS file when shared behavior is involved, and every script or template it calls.
3. Follow the relevant documentation pointer below before introducing unfamiliar mise syntax or a new ownership pattern.
4. Check for an existing owner. Extend it instead of creating a parallel file, hook, initializer, or package declaration.

You are ready to edit when you know which file owns the change, whether it is shared or OS-specific, and which bootstrap phase applies it.

While editing, follow the rules above. Build paths from `$HOME`, XDG variables, mise variables, or tool install variables. Keep scripts small and safe to rerun. Comment only when the reason is not obvious.

### Validate and apply

Inspect first:

```bash
git diff --check
mise config ls
mise bootstrap --dry-run
```

Apply the narrowest safe phase while iterating:

```bash
mise bootstrap --only dotfiles --yes
mise bootstrap --only packages --yes
mise bootstrap --only tools --yes
mise bootstrap --only macos-launchd-agents --yes
mise bootstrap --only linux-systemd-units --yes
```

Run everything when a change affects more than one phase:

```bash
mise bootstrap --yes
mise bootstrap status --missing
```

The change is done when the correct OS config is loaded, bootstrap can be rerun safely, and `mise bootstrap status --missing` exits successfully. Make sure the same setting is not defined twice and no local machine data was added. If files now belong somewhere different, update this guide too.

## Documentation pointers

Read these when needed instead of copying their contents into this README.

| When changing… | Read first |
| --- | --- |
| Bootstrap phases, hooks, tasks, status, or `--only` behavior | [mise bootstrap](https://mise.jdx.dev/bootstrap.html) |
| Dotfile ownership, `symlink-each`, templates, conflicts, or apply semantics | [mise dotfiles](https://mise.jdx.dev/dotfiles.html) |
| OS-specific file loading or `.miserc.toml` | [mise config environments](https://mise.jdx.dev/configuration/environments.html) |
| Native package declarations | [mise bootstrap packages](https://mise.jdx.dev/bootstrap/packages/) |
| Template syntax or machine-specific rendering | [mise templates](https://mise.jdx.dev/templates.html) |
| macOS user services | [mise LaunchAgents](https://mise.jdx.dev/bootstrap/launchd.html) |
| Linux user services | [mise systemd units](https://mise.jdx.dev/bootstrap/systemd.html) |
| Fish startup behavior | [fish configuration files](https://fishshell.com/docs/current/language.html#configuration-files) |
| Ghostty settings or includes | [Ghostty configuration](https://ghostty.org/docs/config) |

For tool-native configuration not listed here, use that tool's official reference and preserve the ownership boundaries above.
