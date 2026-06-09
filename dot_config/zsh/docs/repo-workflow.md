# Local Repository Workflow

This machine uses a purpose-based repository layout, with `ghq` creating the usual:

```text
<root>/<host>/<owner-or-org>/<repo>
```

Example:

```text
~/projects/github.com/00willo/some-tool
~/lab/github.com/00willo/homelab
~/scratch/git/github.com/LazyVim/starter
```

## Repo roots

### Personal MacBook

```text
~/config/       Dotfiles, chezmoi source repos, machine bootstrap config
~/projects/     Personal projects, reusable tools, open-source contribution repos
~/lab/          Homelab, SOC lab, detection engineering, Proxmox, infra experiments
~/ventures/     Side-hustle, business, AI automation, client prototype repos
~/reference/    Public or private repos mostly cloned for reading or occasional pulls
~/scratch/git/  Temporary clones, tutorials, examples, quick tests, disposable experiments
```

### Work MacBook

```text
~/config/       Base dotfiles, work override dotfiles, machine bootstrap config
~/work/         Active work repos actually being contributed to
~/reference/    Work or public repos mostly cloned for reading or occasional pulls
~/scratch/git/  Temporary clones, vendor examples, quick tests, disposable experiments
```

## Shell variables

Defined in:

```text
~/.config/zsh/repos.zsh
```

```zsh
REPO_CONFIG="$HOME/config"
REPO_PROJECTS="$HOME/projects"
REPO_LAB="$HOME/lab"
REPO_VENTURES="$HOME/ventures"
REPO_REFERENCE="$HOME/reference"
REPO_SCRATCH="$HOME/scratch/git"

REPO_WORK="$HOME/work"
```

## Required tools

Install with Homebrew:

```zsh
brew install ghq fzf
```

Optional but useful:

```zsh
brew install gh zoxide mise
```

| Tool | Purpose |
|---|---|
| `ghq` | Clones repos into structured host/owner/repo paths |
| `fzf` | Fuzzy-select repos and worktrees |
| `gh` | GitHub CLI for auth, PRs, forks and repo operations |
| `zoxide` | Smarter `cd` based on directory history |
| `mise` | Per-project tool/runtime/task management |

## First-time setup

Create all repo root directories:

```zsh
roots-mkdir
```

Show configured repo roots:

```zsh
roots
```

Configure `ghq` to know about all repo roots:

```zsh
ghq-roots-sync
```

Check configured `ghq` roots:

```zsh
git config --global --get-all ghq.root
```

## Clone helpers

These helpers clone with `ghq` into the correct root.

### Config repos

Use for dotfiles, chezmoi source repos and machine bootstrap config.

```zsh
gconfig git@github.com:00willo/dotfiles.git
```

Short alias:

```zsh
gcfg git@github.com:00willo/dotfiles.git
```

Work MacBook override dotfiles:

```zsh
gconfig git@github.com:<work-org>/dotfiles-work.git
```

Result:

```text
~/config/github.com/00willo/dotfiles
~/config/github.com/<work-org>/dotfiles-work
```

## Personal projects

Use for personal tools, reusable code and open-source contribution repos.

```zsh
gprojects git@github.com:00willo/some-python-tool.git
```

Short alias:

```zsh
gproj git@github.com:00willo/some-python-tool.git
```

Result:

```text
~/projects/github.com/00willo/some-python-tool
```

## Lab repos

Use for homelab, SOC lab, detection engineering, Proxmox and infra experiments.

```zsh
glab git@github.com:00willo/homelab.git
```

Result:

```text
~/lab/github.com/00willo/homelab
```

## Venture repos

Use for side-hustle, business, AI automation and client prototype repos.

```zsh
gventures git@github.com:00willo/credential-vault-prototype.git
```

Short alias:

```zsh
gven git@github.com:00willo/credential-vault-prototype.git
```

Result:

```text
~/ventures/github.com/00willo/credential-vault-prototype
```

## Work repos

Use for active work repos you actually contribute to.

```zsh
gwork git@github.com:<work-org>/identity-automation.git
```

Result:

```text
~/work/github.com/<work-org>/identity-automation
```

## Reference repos

Use for repos you mostly read, inspect or occasionally pull.

```zsh
gref git@github.com:<work-org>/some-readonly-repo.git
```

Public example:

```zsh
gref git@github.com:some-public-org/useful-reference-tool.git
```

Result:

```text
~/reference/github.com/<work-org>/some-readonly-repo
```

## Scratch repos

Use for temporary clones, tutorials, examples, quick tests and disposable experiments.

```zsh
gscratch git@github.com:LazyVim/starter.git
```

Result:

```text
~/scratch/git/github.com/LazyVim/starter
```

If a scratch repo becomes important, promote it later by recloning or moving it into the appropriate root.

## Jump to a repo

Use the fuzzy repo picker:

```zsh
repo
```

This searches across the configured repo roots and changes into the selected repo.

Descriptive alias:

```zsh
repojump
```

## Worktree convention

Worktrees are used for parallel coding sessions, especially agent coding sessions.

They are placed relative to the GitHub owner or organisation namespace:

```text
<root>/github.com/<owner>/_worktrees/
```

Example main repo:

```text
~/projects/github.com/00willo/my-app
```

Example worktrees:

```text
~/projects/github.com/00willo/_worktrees/my-app-agent-auth-refactor
~/projects/github.com/00willo/_worktrees/my-app-agent-add-tests
```

For work repos:

```text
~/work/github.com/<work-org>/identity-automation
~/work/github.com/<work-org>/_worktrees/identity-automation-agent-add-tests
```

## Create agent worktrees

From inside the repo:

```zsh
wtagent auth-refactor
```

Creates branch:

```text
agent/auth-refactor
```

Creates path:

```text
<namespace>/_worktrees/<repo>-agent-auth-refactor
```

Example:

```text
~/projects/github.com/00willo/_worktrees/my-app-agent-auth-refactor
```

## Tool-specific agent worktrees

Use when multiple tools or agents are working in parallel.

```zsh
wttool codex add-tests
wttool claude refactor-auth
wttool cursor fix-ui
```

Creates branches like:

```text
agent/codex/add-tests
agent/claude/refactor-auth
agent/cursor/fix-ui
```

Creates paths like:

```text
<namespace>/_worktrees/<repo>-agent-codex-add-tests
```

## Explicit worktree branch

Use when the branch is not agent-specific.

```zsh
wtnew feature/new-cli
```

Creates branch:

```text
feature/new-cli
```

Creates path:

```text
<namespace>/_worktrees/<repo>-feature-new-cli
```

## Navigate worktrees

List worktrees:

```zsh
wtlist
```

Fuzzy-select from `git worktree list`:

```zsh
wt
```

Fuzzy-select from the local namespace `_worktrees` directory:

```zsh
wtlocal
```

Show the namespace-relative worktree directory:

```zsh
wtdir
```

Show helper summary:

```zsh
wthelp
```

## Remove worktrees

Fuzzy-remove a worktree:

```zsh
wtrm
```

Prune stale worktree metadata:

```zsh
wtprune
```

If a branch has already been merged:

```zsh
git branch -d agent/auth-refactor
```

If abandoning the branch intentionally:

```zsh
git branch -D agent/auth-refactor
```

## Fork workflow

For forks, the local directory does not need a special root. Keep the repo in the root matching its purpose.

Example open-source contribution:

```zsh
gproj git@github.com:00willo/some-fork.git
```

Inside the repo:

```zsh
git remote -v
```

Recommended remote layout:

```text
origin    git@github.com:00willo/some-fork.git
upstream  git@github.com:original-owner/some-repo.git
```

Add upstream if needed:

```zsh
git remote add upstream git@github.com:original-owner/some-repo.git
```

Fetch upstream:

```zsh
git fetch upstream
```

Sync main branch:

```zsh
git switch main
git merge upstream/main
git push origin main
```

## Subtree guidance

Use `git subtree` only when intentionally embedding another repo inside a repo as a subdirectory.

Good subtree use cases:

```text
vendor/
third_party/
shared-libraries/
shared-detections/
```

Do not use subtrees for parallel agent coding sessions. Use worktrees instead.

Example subtree add:

```zsh
git remote add shared-detections git@github.com:00willo/shared-detections.git
git subtree add --prefix vendor/shared-detections shared-detections main --squash
```

Pull subtree updates:

```zsh
git subtree pull --prefix vendor/shared-detections shared-detections main --squash
```

Push subtree changes:

```zsh
git subtree push --prefix vendor/shared-detections shared-detections main
```

## Quick decision guide

| Situation | Use |
|---|---|
| Personal reusable code | `gproj` |
| Dotfiles or bootstrap config | `gconfig` |
| Homelab, SOC or detection engineering | `glab` |
| Side-hustle or business repo | `gven` |
| Active work repo | `gwork` |
| Read-mostly repo | `gref` |
| Disposable clone | `gscratch` |
| Parallel agent session | `wtagent` or `wttool` |
| Embedded external repo inside another repo | `git subtree` |
| Jump around quickly | `repo` |
