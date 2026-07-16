# Dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

This repository contains shell, terminal, package, git, and workflow configuration for quickly creating a consistent development environment across personal and work machines.

The configuration is designed around:

* XDG-friendly paths
* layered chezmoi data
* profile-aware configuration (personal and work)
* modular shell configuration
* reproducible package installation
* clean separation between personal and work environments

## What this repo manages

* Modular Zsh configuration
* XDG shell startup files
* Starship prompt
* WezTerm terminal
* Homebrew package installation on macOS
* Git identity and GitHub configuration
* Repository layout helpers using ghq
* Git worktree helpers
* Machine bootstrap experiments
* Profile-aware personal/work customisation

## Repository layout

```text
.
├── .chezmoidata/
│ ├── 00-profile.yaml
│ ├── 10-base.yaml
│ ├── 15-personal.yaml
│ └── 90-work.yaml (optional)
├── .chezmoiexternal.toml
├── dot_bootstrap/
│   └── setup.yaml
├── dot_config/
│   ├── git/
│   │   └── config.tmpl
│   ├── starship.toml
│   ├── wezterm/
│   │   └── wezterm.lua
│   └── zsh/
│       ├── aliases.zsh
│       ├── completion.zsh
│       ├── fzf.zsh
│       ├── history.zsh
│       ├── homebrew.zsh
│       ├── keybindings.zsh
│       ├── lmstudio.zsh
│       ├── navigation.zsh
│       ├── options.zsh
│       ├── plugins.zsh
│       ├── prompt.zsh
│       ├── python.zsh
│       ├── repos.zsh
│       ├── work.zsh
│       ├── worktrees.zsh
│       └── zoxide.zsh
├── dot_zprofile
├── dot_zshenv
├── dot_zshrc
├── scripts/
└── .chezmoiscripts/
    └── run_onchange_*.tmpl
```

## Configuration model

Configuration is layered using chezmoi data files.

Example:
```text
.chezmoidata/
├── 00-profile.yaml
├── 10-base.yaml
├── 15-personal.yaml
└── 90-work.yaml
```

## Profile selection

Default:
```yaml
profile:
  kind: personal
```
Work overrides:
```yaml
profile:
  kind: work
```
Templates can use:

```text
{{ if eq .profile.kind "work" }}
...
{{ end }}
```

## Package management

Packages are defined as structured data and rendered into Homebrew Bundle format.

Example:

```yaml
packages:
  darwin:
    base_taps: []
    base_cli_brews: []
    base_casks: []
```

Profile-specific extensions:

```yaml
packages:
  darwin:
    personal_taps: []
    personal_cli_brews: []
    personal_casks: []
```

```yaml
packages:
  darwin:
    work_taps: []
    work_cli_brews: []
    work_casks: []
```

Package installation is performed through:

```text
.chezmoiscripts/run_onchange_darwin-install-packages.sh.tmpl
```

Apply:

```sh
chezmoi apply
```

## Shell structure

Shell config lives under:

```text
~/.config/zsh/
```

Current load order:

```text
options.zsh
homebrew.zsh
history.zsh
completion.zsh
prompt.zsh
keybindings.zsh
plugins.zsh
fzf.zsh
zoxide.zsh
aliases.zsh
python.zsh
navigation.zsh
work.zsh
repos.zsh
worktrees.zsh
lmstudio.zsh
```

## Git configuration

Git identity and GitHub configuration are templated.

Example data:

```yaml
git:
  name: Graham Williamson
  email: example@example.com

github:
  user: username
```

Rendered into Git’s XDG global config:

```text
~/.config/git/config
```

## Key tools

This setup currently leans on:

* `zsh`
* `chezmoi`
* `homebrew`
* `starship`
* `wezterm`
* `fzf`
* `zoxide`
* `ghq`
* `glow`
* `gitleaks`
* `neovim`
* `bat`
* `eza`
* `fd`


## Install

### First-time setup

Install chezmoi:

```sh
brew install chezmoi
```

Initialise from GitHub:

```sh
chezmoi init git@github.com:00willo/dotfiles.git
```

Review the changes before applying:

```sh
chezmoi diff
```

Apply the configuration:

```sh
chezmoi apply
```

Or do it in one command:

```sh
chezmoi init --apply git@github.com:00willo/dotfiles.git
```

## Day-to-day usage

Edit the source state:

```sh
chezmoi cd
```

Check what would change:

```sh
chezmoi diff
```

Apply changes:

```sh
chezmoi apply
```

Add a new file to chezmoi:

```sh
chezmoi add ~/.config/example/config.toml
```

Edit a managed file:

```sh
chezmoi edit ~/.zshrc
```

Apply and inspect:

```sh
chezmoi diff
chezmoi apply
```

## Repository workflow helpers

This repo includes helpers for keeping cloned repositories organised by intent.

Current root layout:

```text
~/config/       Dotfiles, chezmoi source repos, machine bootstrap config
~/projects/     Personal projects, reusable tools, open-source contribution repos
~/lab/          Homelab, SOC lab, detection engineering, Proxmox, infra experiments
~/ventures/     Side-hustle, business, AI automation, client prototype repos
~/reference/    Public or private repos mostly used for reading and reference
~/scratch/git/  Temporary clones, tutorials, examples, quick tests
~/work/         Active work repos, mainly for work-managed machines
```

Useful commands:

```sh
roots
roots-mkdir
ghq-roots-sync
repo
repo-help
```

Clone helpers:

```sh
gconfig <repo>
gprojects <repo>
glab <repo>
gventures <repo>
gwork <repo>
greference <repo>
gscratch <repo>
```

Short aliases include:

```sh
gcfg
gproj
gven
gref
```

## Worktree helpers

Git worktree helpers are included for parallel coding sessions, feature branches, and agent-assisted development.

Create a worktree:

```sh
wtnew feature/new-cli
```

Create an agent worktree:

```sh
wtagent auth-refactor
```

Create a tool-specific agent worktree:

```sh
wttool codex add-tests
```

Navigate and manage worktrees:

```sh
wt
wtlocal
wtlist
wtrm
wtprune
wtdir
wthelp
```

The worktree convention keeps worktrees outside the main repository directory:

```text
<repo-root>/<host>/<namespace>/<repo>/
<repo-root>/<host>/<namespace>/_worktrees/<repo>-<branch-name>/
```

## External scripts

Some external helper scripts are managed through chezmoi externals.

Current external configuration:

```text
.chezmoiexternal.toml
```

This allows selected third-party scripts to be refreshed without manually copying them into the repo.

## Security notes

This repository is intended to be safe for public use, but dotfiles can accidentally collect sensitive data.

Before pushing changes, run:

```sh
gitleaks detect --source . --redact
```

Also manually check for:

* access tokens
* private keys
* `.env` files
* cloud credentials
* work-specific hostnames or internal paths
* proxy certificates or private CA bundles
* machine-specific secrets

Do not commit secrets to this repository.

## macOS Terminal profile

The repo includes a chezmoi `run_onchange` script for importing a macOS Terminal profile.

This is useful for keeping terminal font and theme settings reproducible without manually importing the profile on every setup.

## Bootstrap notes

The `dot_bootstrap/setup.yaml` file contains an Ansible-based machine setup playbook, primarily for Linux/Fedora-style bootstrap experiments.

The macOS path is currently centred around Homebrew and chezmoi-managed configuration.

## Design goals

* Keep the shell fast and modular
* Prefer readable configuration over clever tricks
* Keep machine-specific items easy to template later
* Use XDG-friendly paths where practical
* Make repo navigation and worktree workflows low-friction
* Keep public dotfiles free of secrets

## Licence

Personal dotfiles. Reuse what is useful, but review carefully before applying to your own machine.

