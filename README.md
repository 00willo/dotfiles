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
├── dot_local/
│   └── bin/
│       ├── executable_brew-drift.tmpl
│       ├── executable_brew-upgrade.tmpl
│       ├── executable_fzf-list-old-files
│       └── executable_zoxide-open-files-nvim
├── dot_zprofile
├── dot_zshenv
├── dot_zshrc
└── .chezmoiscripts/
    └── run_onchange_*.tmpl
```

## Configuration model

Configuration is layered using chezmoi data files.

The personal repo contains `00-profile.yaml`, `10-base.yaml` and
`15-personal.yaml`. A separate work repo can replace `15-personal.yaml` with
its own `90-work.yaml`.

## Profile selection

Default:
```yaml
profile:
  kind: personal
```
A work repo selects the work profile in its own `90-work.yaml`:
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

The repo defines package groups in `.chezmoidata/`; each machine selects optional
capabilities in the `[data.capabilities]` section of its local chezmoi config.
Missing capabilities are off. The base selects Git and the Darwin bootstrap
includes chezmoi. Profile-specific packages are kept separately: this repo's
`15-personal.yaml` contains personal additions; a work repo supplies its own.

The current groups are `interactive_cli`, `zsh_extras`, `personal_shell`,
`development`, `python_development`, `go_development`, `rust_development`,
`containers`, `infrastructure_management`, `workstation_apps`, `ai_assistants`
and `local_ai`. Go and Rust currently have no packages. Group definitions live
in the numbered data files and the selected groups are combined and deduplicated
in `.chezmoitemplates/darwin-brewfile`.

`machine.role` describes a workstation or server. `machine.gui` records GUI
availability. `workstation_apps` requires a GUI; `local_ai` can be selected on
a headless Mac to install OMLX without the LM Studio GUI. Colima autostart and
setting the macOS Terminal default profile have separate local settings.
Turning a capability off stops requesting its packages; it does not uninstall
them or stop a service already running.

`packages.universal.base_cli` holds base names shared across supported systems.
Darwin package definitions are implemented now; Fedora, AlmaLinux, Debian and
Ubuntu are placeholders. Linux package installation is not implemented, so the
Fedora example records intent but does not install its selected packages.

When implementing Linux package provisioning, handle repository prerequisites
before resolving and installing the selected packages. For example, some
AlmaLinux packages may require EPEL to be enabled first. Determine whether an
enabled capability needs a repository, account for distribution and version
differences, and respect work-machine repository policies rather than enabling
EPEL unconditionally. Keep chezmoi itself as a bootstrap prerequisite; decide
its package-manager treatment separately to avoid installing a second copy.

### Third-party Homebrew trust

This repo's package configuration is designed to be secure by default. It relies
on Homebrew's trust and security processes for official formulae. For third-party
taps, the default policy is to explicitly trust only the individual formulae
needed. For example, this is how `15-personal.yaml` declares the OMLX tap,
trusts its formula and selects it for installation:

```yaml
profile_packages:
  personal:
    local_ai:
      darwin:
        taps:
          - name: jundot/omlx
            url: https://github.com/jundot/omlx
        trusted_formulae:
          - jundot/omlx/omlx
        cli:
          - omlx
```

`trusted_formulae` grants trust; the separate `cli` entry selects the package
for installation. Each trusted formula must be fully qualified as
`user/tap/formula`, and its tap must also be declared in an enabled group.
The generated Brewfile gives Homebrew Bundle formula-specific trust; it does
not trust the entire tap.

When there is a deliberate reason to trust **all current and future items** in a
tap, set `trusted: true` on that tap entry instead. For example:

```yaml
profile_packages:
  personal:
    development:
      darwin:
        taps:
          - name: example/tools
            url: https://example.org/tools.git
            trusted: true  # Explicitly trusts the entire tap.
        cli:
          - example-tool
```

These examples apply when their respective capability is enabled. Omitting
`trusted` does not trust the entire tap. See Homebrew's
[tap trust documentation](https://docs.brew.sh/Tap-Trust).

### Machine selections and preflight

Tracked starting profiles live in `examples/machines/`. Copy or merge their
`[data.*]` sections into the machine's local chezmoi config, typically
`~/.config/chezmoi/chezmoi.toml`, then edit them to suit the machine. The local
config also holds other chezmoi settings; do not overwrite an existing file.

Run `chezmoi-preflight` after applying the dotfiles, or before the first apply
from the source directory with:

```sh
ruby "$(chezmoi source-path)/dot_local/bin/executable_chezmoi-preflight"
```

The helper requires Ruby. It shows enabled and disabled choices, reports missing
capabilities as off, and prints suggested `false` entries for review. Unknown
capabilities, invalid selections and duplicate package definitions are errors.
The duplicate-definition check inspects root `.chezmoidata` YAML files; it
reports other data formats as unsupported rather than silently skipping them.
A package selected by multiple groups is deduplicated during Brewfile rendering.

The extension installer runs after each apply on a GUI-enabled Mac with Python
development selected. It looks for the VS Code CLI and retries on a later apply
if the editor is unavailable. It only installs extensions not already listed.

Review and apply:

```sh
chezmoi diff
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
lmstudio.zsh
navigation.zsh
work.zsh
repos.zsh
worktrees.zsh
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

Download the macOS/Linux installer, then choose a starting configuration:

```sh
curl -fsSL https://raw.githubusercontent.com/00willo/dotfiles/main/install.sh -o /tmp/dotfiles-install.sh
bash /tmp/dotfiles-install.sh --example personal-macbook
```

The raw URL becomes available after `install.sh` is committed and pushed. The
example mode initialises the personal repository but waits for your review before
applying. Running `bash /tmp/dotfiles-install.sh` without an example instead
initialises and applies immediately; without local selections, optional groups
are off and macOS receives only the base packages.

This creates a local config only if one does not already exist, then stops for
you to review it before `chezmoi diff` and `chezmoi apply`. Use
`personal-fedora-workstation` for the Fedora example. If a config already exists,
merge the relevant example sections into it manually. No existing config is
overwritten.

You can also download the file in a browser, copy it via removable storage, or
host the same file at an internal URL. Run any copy with `bash install.sh`.
It still needs access to the repository and upstream package/binary downloads.
To install a separate work repo, point the installer at that repo using your
normal Git credentials (the installer does not provision SSH keys):

```sh
DOTFILES_REPO=https://git.example.internal/you/dotfiles.git bash install.sh
```

The chosen repository supplies the profile. This personal repo selects `personal`;
a work repo can select `work` in its `90-work.yaml`. The installer does not
create or change profile data. When chezmoi is already initialised, it uses the
existing source directory; do not rely on `DOTFILES_REPO` to switch an existing
checkout to a different repository.

On macOS, the installer checks Xcode Command Line Tools, installs Homebrew if
missing, and installs chezmoi. If the tools are missing, finish Apple's installer
and rerun the command. Homebrew may ask for your administrator password.

On Linux, install `curl` and `git` with your distribution's package manager first.
The installer installs chezmoi into `~/.local/bin` using its
[official installer](https://www.chezmoi.io/install/), then applies the dotfiles.
Linux package provisioning is not implemented yet: the Fedora Ansible playbook is
an inactive experiment. Install Zsh and the tools you need separately; this script
does not change your login shell. VS Code extension installation currently runs
only on macOS.

### Future work repo

The intended work repo will start as a fresh snapshot of reviewed shared files,
not a clone of this repo's Git history. A temporary clone can supply the files;
the work repo would use its own `90-work.yaml` and empty work package choices.
The file boundary, bootstrap script and traceable patch-update workflow are still
to be designed. In the meantime, do not use this personal repo as a work profile.

### Installer verification to do

First-run and rerun testing in isolated environments is still to do. Linux can
be exercised in a container; macOS needs a macOS runner or machine. Include a
work-style fixture without personal data, and check missing prerequisites and
existing chezmoi source directories. Avoid installing the full personal package
set in automated checks unless that is specifically intended.

### Manual setup

With Homebrew and Git access already configured:

```sh
brew install chezmoi
chezmoi init https://github.com/00willo/dotfiles.git
chezmoi diff
chezmoi apply
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

## SSH configuration

`private_dot_ssh/config.tmpl` manages `~/.ssh/config`. On macOS it sets `AddKeysToAgent yes` and `UseKeychain yes` for all hosts except `colima`, so keys are added to `ssh-agent` automatically and their passphrases can be stored in the macOS keychain. On Linux it sets `AddKeysToAgent yes` for all hosts and omits the macOS-specific `UseKeychain` directive.

`UseKeychain` only covers keys ssh-agent already knows about. The first time you add a new key, load it into the agent and save its passphrase to the keychain with:

```sh
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

After that one-time step, macOS restarts (and new terminal sessions) will re-load the key and passphrase automatically via `UseKeychain`.

On Linux there's no keychain integration, so just load the key into the agent for the session with the plain form:

```sh
ssh-add ~/.ssh/id_ed25519
```

To check which keys the agent currently has loaded (on either platform):

```sh
ssh-add -l
```

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

