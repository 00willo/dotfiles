# ~/.config/zsh/worktrees.zsh
#
# Git worktree helpers for parallel coding sessions.
#
# Intended use:
#   - agent coding sessions
#   - parallel feature branches
#   - safe experiments
#
# Directory convention:
#
#   <repo-root>/<host>/<namespace>/<repo>/
#   <repo-root>/<host>/<namespace>/_worktrees/<repo>-<branch-name>/
#
# Example:
#
#   ~/projects/github.com/00willo/my-app
#   ~/projects/github.com/00willo/_worktrees/my-app-agent-auth-refactor
#
# This keeps worktrees relative to the namespace/owner directory, not inside the
# main repo itself.

# Return the current repository root.
_git_root() {
  git rev-parse --show-toplevel 2>/dev/null
}

# Return the current repository name.
_git_repo_name() {
  local repo_root

  repo_root="$(_git_root)" || return
  basename "$repo_root"
}

# Convert a branch name into a filesystem-safe-ish name.
_worktree_slug() {
  printf '%s\n' "$1" | sed 's#[/ ]#-#g'
}

# Return the namespace/owner directory for the current repo.
#
# Example:
#   repo root:  ~/projects/github.com/00willo/my-app
#   owner dir:  ~/projects/github.com/00willo
_worktree_owner_dir() {
  local repo_root

  repo_root="$(_git_root)" || return
  dirname "$repo_root"
}

# Return the namespace-relative worktrees directory for the current repo.
#
# Example:
#   ~/projects/github.com/00willo/_worktrees
_worktree_dir() {
  local owner_dir

  owner_dir="$(_worktree_owner_dir)" || return
  printf '%s\n' "$owner_dir/_worktrees"
}

# Create a worktree for a branch.
#
# Usage:
#   wtnew agent/auth-refactor
#   wtnew agent/codex/add-tests
#   wtnew feature/new-cli
#
# From:
#   ~/projects/github.com/00willo/my-app
#
# Creates:
#   ~/projects/github.com/00willo/_worktrees/my-app-agent-auth-refactor
wtnew() {
  local branch_name="$1"
  local repo_root
  local repo_name
  local worktrees_dir
  local branch_slug
  local worktree_path

  if [[ -z "$branch_name" ]]; then
    echo "Usage: wtnew <branch-name>" >&2
    echo "Example: wtnew agent/auth-refactor" >&2
    return 1
  fi

  repo_root="$(_git_root)" || {
    echo "Not inside a Git repository." >&2
    return 1
  }

  repo_name="$(basename "$repo_root")"
  worktrees_dir="$(_worktree_dir)" || return
  branch_slug="$(_worktree_slug "$branch_name")"
  worktree_path="$worktrees_dir/$repo_name-$branch_slug"

  mkdir -p "$worktrees_dir"

  git worktree add "$worktree_path" -b "$branch_name" || return
  cd "$worktree_path" || return
}

# Create an agent worktree with a shorter task name.
#
# Usage:
#   wtagent auth-refactor
#   wtagent add-tests
#   wtagent docs-cleanup
#
# This creates branch:
#   agent/auth-refactor
#
# And path:
#   ../_worktrees/<repo>-agent-auth-refactor
wtagent() {
  local task_name="$1"

  if [[ -z "$task_name" ]]; then
    echo "Usage: wtagent <task-name>" >&2
    echo "Example: wtagent auth-refactor" >&2
    return 1
  fi

  wtnew "agent/$task_name"
}

# Create an agent worktree with a tool prefix.
#
# Usage:
#   wttool codex add-tests
#   wttool claude refactor-auth
#   wttool cursor fix-ui
#
# This creates branch:
#   agent/codex/add-tests
#
# And path:
#   ../_worktrees/<repo>-agent-codex-add-tests
wttool() {
  local tool_name="$1"
  local task_name="$2"

  if [[ -z "$tool_name" || -z "$task_name" ]]; then
    echo "Usage: wttool <tool-name> <task-name>" >&2
    echo "Example: wttool codex add-tests" >&2
    return 1
  fi

  wtnew "agent/$tool_name/$task_name"
}

# List worktrees for the current repo.
#
# Usage:
#   wtlist
wtlist() {
  git worktree list
}

# Fuzzy-select a worktree for the current repo and cd into it.
#
# Requires:
#   brew install fzf
#
# Usage:
#   wt
wt() {
  local selected_worktree

  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf is not installed or not in PATH." >&2
    echo "Install with: brew install fzf" >&2
    return 1
  fi

  selected_worktree="$(
    git worktree list |
      awk '{print $1}' |
      fzf --prompt='worktree> '
  )" || return

  cd "$selected_worktree" || return
}

# Fuzzy-select any namespace-relative worktree and cd into it.
#
# This looks in:
#   <namespace>/_worktrees/
#
# Usage:
#   wtlocal
wtlocal() {
  local worktrees_dir
  local selected_worktree

  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf is not installed or not in PATH." >&2
    echo "Install with: brew install fzf" >&2
    return 1
  fi

  worktrees_dir="$(_worktree_dir)" || {
    echo "Not inside a Git repository." >&2
    return 1
  }

  if [[ ! -d "$worktrees_dir" ]]; then
    echo "No namespace-relative worktree directory found: $worktrees_dir" >&2
    return 1
  fi

  selected_worktree="$(
    find "$worktrees_dir" \
      -mindepth 1 \
      -maxdepth 1 \
      -type d 2>/dev/null |
    sort |
    fzf --prompt='local worktree> '
  )" || return

  cd "$selected_worktree" || return
}

# Remove a worktree by path, using a fuzzy picker.
#
# Usage:
#   wtrm
wtrm() {
  local selected_worktree
  local current_root

  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf is not installed or not in PATH." >&2
    echo "Install with: brew install fzf" >&2
    return 1
  fi

  current_root="$(_git_root)" || {
    echo "Not inside a Git repository." >&2
    return 1
  }

  selected_worktree="$(
    git worktree list |
      awk '{print $1}' |
      fzf --prompt='remove worktree> '
  )" || return

  if [[ "$selected_worktree" == "$current_root" ]]; then
    echo "Refusing to remove the current/main worktree: $selected_worktree" >&2
    return 1
  fi

  git worktree remove "$selected_worktree"
}

# Prune stale worktree metadata.
#
# Usage:
#   wtprune
wtprune() {
  git worktree prune
}

# Show the namespace-relative worktree directory for the current repo.
#
# Usage:
#   wtdir
wtdir() {
  _worktree_dir
}

# Show a short help summary.
#
# Usage:
#   wthelp
wthelp() {
  cat <<EOF
Git worktree helpers

Create:
  wtnew <branch-name>          Create a worktree for an explicit branch
  wtagent <task-name>          Create branch agent/<task-name>
  wttool <tool> <task-name>    Create branch agent/<tool>/<task-name>

Navigate:
  wt                           Pick from git worktree list
  wtlocal                      Pick from namespace _worktrees directory
  wtdir                        Print namespace _worktrees path

Manage:
  wtlist                       List worktrees
  wtrm                         Remove selected worktree
  wtprune                      Prune stale worktree metadata

Examples:
  wtagent auth-refactor
  wttool codex add-tests
  wtnew feature/new-cli
EOF
}
