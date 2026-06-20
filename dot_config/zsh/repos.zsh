# ~/.config/zsh/repos.zsh
#
# Repository directory helpers.
#
# Layout intent:
#
#   ~/config/       Dotfiles, chezmoi source repos, machine bootstrap config
#   ~/projects/     Personal projects, reusable tools, open-source contribution repos
#   ~/lab/          Homelab, SOC lab, detection engineering, Proxmox, infra experiments
#   ~/ventures/     Side-hustle, business, AI automation, client prototype repos
#   ~/reference/    Public or private repos you mostly read/pull
#   ~/scratch/git/  Temporary clones, tutorials, examples, quick tests, disposable experiments
#
# Work MacBook only:
#
#   ~/work/         Active work repos you actually contribute to
#
# ghq creates host/owner/repo paths underneath each root.
#
# Examples:
#
#   ~/config/github.com/00willo/dotfiles
#   ~/config/github.com/<work-org>/dotfiles-work
#   ~/projects/github.com/00willo/python-tools
#   ~/lab/github.com/00willo/homelab
#   ~/ventures/github.com/00willo/credential-vault-prototype
#   ~/reference/github.com/<work-org>/some-readonly-repo
#   ~/scratch/git/github.com/LazyVim/starter
#
# Work MacBook example:
#
#   ~/work/github.com/<work-org>/identity-automation

# Repo roots
export REPO_CONFIG="$HOME/config"
export REPO_PROJECTS="$HOME/projects"
export REPO_LAB="$HOME/lab"
export REPO_VENTURES="$HOME/ventures"
export REPO_REFERENCE="$HOME/reference"
export REPO_SCRATCH="$HOME/scratch/git"

# Work repo root
#
# This is mainly useful on the work MacBook. It is kept separate so it can
# be templated or conditionally included later if needed.
export REPO_WORK="$HOME/work"

# Internal helper: resolve a friendly root name to a path.
_repo_root() {
  case "$1" in
    config|cfg)
      printf '%s\n' "$REPO_CONFIG"
      ;;
    projects|project|proj|personal|src)
      printf '%s\n' "$REPO_PROJECTS"
      ;;
    lab)
      printf '%s\n' "$REPO_LAB"
      ;;
    ventures|venture|ven|side|business)
      printf '%s\n' "$REPO_VENTURES"
      ;;
    work)
      printf '%s\n' "$REPO_WORK"
      ;;
    reference|ref|refs|readonly|read-only)
      printf '%s\n' "$REPO_REFERENCE"
      ;;
    scratch|tmp|temp)
      printf '%s\n' "$REPO_SCRATCH"
      ;;
    *)
      echo "Unknown repo root: $1" >&2
      echo "Valid roots: config, projects, lab, ventures, work, reference, scratch" >&2
      return 1
      ;;
  esac
}

# Internal helper: show usage for ghq clone helpers.
_repo_clone_usage() {
  local root_path="$1"
  local helper_name="${2:-gclone}"

  cat <<EOF >&2
Missing repo URL or GitHub shorthand.

Usage:
  $helper_name <repo>
  $helper_name <owner/repo>
  $helper_name <host/owner/repo>
  $helper_name <git-url>

Examples:
  $helper_name dotfiles
  $helper_name 00willo/dotfiles
  $helper_name github.com/00willo/dotfiles
  $helper_name git@github.com:00willo/dotfiles.git

Notes:
  - Single repo names use ghq.user as the default GitHub owner.
  - Repositories are cloned via SSH using: ghq get -p
  - This helper clones into: $root_path
  - For more detail, run: repo-help
EOF
}

# Internal helper: clone a repo into a specific root using ghq.
_ghq_get_into_root() {
  local root_path="$1"
  local helper_name="${2:-gclone}"
  shift 2

  if ! command -v ghq >/dev/null 2>&1; then
    echo "ghq is not installed or not in PATH." >&2
    echo "Install with: brew install ghq" >&2
    return 1
  fi

  if [[ -z "$root_path" ]]; then
    echo "Missing repo root path." >&2
    return 1
  fi

  if [[ $# -eq 0 ]]; then
    _repo_clone_usage "$root_path" "$helper_name"
    return 1
  fi

  mkdir -p "$root_path"
  GHQ_ROOT="$root_path" ghq get -p "$@"
}

# Clone into config/bootstrap repos.
#
# Use this for:
#   - personal dotfiles repo
#   - work override dotfiles repo
#   - machine bootstrap config
#
# Examples:
#   gconfig git@github.com:00willo/dotfiles.git
#   gconfig git@github.com:<work-org>/dotfiles-work.git
gconfig() {
  _ghq_get_into_root "$REPO_CONFIG" "gconfig" "$@"
}

# Short alias for config repos.
gcfg() {
  gconfig "$@"
}

# Clone into personal projects and open-source contribution repos.
#
# Examples:
#   gprojects git@github.com:00willo/python-tools.git
#   gproj git@github.com:some-org/project-you-contribute-to.git
gprojects() {
  _ghq_get_into_root "$REPO_PROJECTS" "gprojects" "$@"
}

# Short alias for personal projects.
gproj() {
  gprojects "$@"
}

# Clone into lab/homelab/SOC/detection engineering repos.
#
# Examples:
#   glab git@github.com:00willo/homelab.git
#   glab git@github.com:00willo/detection-lab.git
glab() {
  _ghq_get_into_root "$REPO_LAB" "glab" "$@"
}

# Clone into side-hustle/business/venture repos.
#
# Examples:
#   gventures git@github.com:00willo/credential-vault-prototype.git
#   gven git@github.com:00willo/ai-agency-discovery.git
gventures() {
  _ghq_get_into_root "$REPO_VENTURES" "gventures" "$@"
}

# Short alias for ventures.
gven() {
  gventures "$@"
}

# Clone into active work repos.
#
# Mainly useful on the work MacBook.
#
# Example:
#   gwork git@github.com:<work-org>/identity-automation.git
gwork() {
  _ghq_get_into_root "$REPO_WORK" "gwork" "$@"
}

# Clone into reference/read-only repos.
#
# Use this for repos you mostly read, pull occasionally, or use as examples.
#
# Examples:
#   gref git@github.com:<work-org>/repo-you-mostly-read.git
#   gref git@github.com:public-org/useful-reference-tool.git
greference() {
  _ghq_get_into_root "$REPO_REFERENCE" "greference" "$@"
}

# Short alias for reference repos.
gref() {
  greference "$@"
}

# Clone into temporary/reference/disposable repos.
#
# Use this for:
#   - tutorial repos
#   - quick experiments
#   - public repos you are inspecting
#   - repos you may delete later
#
# Example:
#   gscratch git@github.com:LazyVim/starter.git
gscratch() {
  _ghq_get_into_root "$REPO_SCRATCH" "gscratch" "$@"
}

# Fuzzy-select a repo and cd into it.
#
# This intentionally does not rely on ghq config. It searches the repo roots
# directly, so it still works even if ghq.root has not been configured globally.
#
# Requires:
#   brew install fzf
#
# Usage:
#   repo
repo() {
  local selected_repo

  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf is not installed or not in PATH." >&2
    echo "Install with: brew install fzf" >&2
    return 1
  fi

  selected_repo="$(
    find \
      "$REPO_CONFIG" \
      "$REPO_PROJECTS" \
      "$REPO_LAB" \
      "$REPO_VENTURES" \
      "$REPO_WORK" \
      "$REPO_REFERENCE" \
      "$REPO_SCRATCH" \
      -mindepth 3 \
      -maxdepth 5 \
      -type d \
      -name .git \
      -prune 2>/dev/null |
    sed 's#/.git$##' |
    sort |
    fzf --prompt='repo> '
  )" || return

  cd "$selected_repo" || return
}

# More descriptive alias for repo picker.
repojump() {
  repo "$@"
}

# Print repo roots.
#
# Usage:
#   roots
roots() {
  cat <<EOF
config:    $REPO_CONFIG
projects:  $REPO_PROJECTS
lab:       $REPO_LAB
ventures:  $REPO_VENTURES
work:      $REPO_WORK
reference: $REPO_REFERENCE
scratch:   $REPO_SCRATCH
EOF
}

# Create all repo root directories.
#
# Usage:
#   roots-mkdir
roots-mkdir() {
  mkdir -p \
    "$REPO_CONFIG" \
    "$REPO_PROJECTS" \
    "$REPO_LAB" \
    "$REPO_VENTURES" \
    "$REPO_WORK" \
    "$REPO_REFERENCE" \
    "$REPO_SCRATCH"
}

# Configure ghq roots globally.
#
# This is optional because the clone helpers use GHQ_ROOT directly.
# It is still useful so manual ghq commands can see all roots.
#
# Usage:
#   ghq-roots-sync
#
# Check afterwards with:
#   git config --global --get-all ghq.root
ghq-roots-sync() {
  if ! command -v ghq >/dev/null 2>&1; then
    echo "ghq is not installed or not in PATH." >&2
    echo "Install with: brew install ghq" >&2
    return 1
  fi

  git config --global --unset-all ghq.root 2>/dev/null || true

  git config --global ghq.root "$REPO_CONFIG"
  git config --global --add ghq.root "$REPO_PROJECTS"
  git config --global --add ghq.root "$REPO_LAB"
  git config --global --add ghq.root "$REPO_VENTURES"
  git config --global --add ghq.root "$REPO_WORK"
  git config --global --add ghq.root "$REPO_REFERENCE"
  git config --global --add ghq.root "$REPO_SCRATCH"

  git config --global --get-all ghq.root
}

# Show the local repo workflow reference.
#
# This opens the Markdown doc that explains the repo roots, clone helpers,
# worktree helpers, fork workflow, and subtree guidance.
#
# Preferred viewer:
#   glow, if installed
#
# Fallback:
#   ${PAGER:-less}
#
# Usage:
#   repo-help
repo-help() {
  local doc_path="$XDG_CONFIG_HOME/zsh/docs/repo-workflow.md"

  if [[ ! -r "$doc_path" ]]; then
    echo "Repo workflow doc not found: $doc_path" >&2
    return 1
  fi

  if command -v glow >/dev/null 2>&1; then
    glow "$doc_path"
  else
    ${PAGER:-less} "$doc_path"
  fi
}

# Optional future helper:
# Clone into a selected root without changing directory.
#
# Usage:
#   gclone config git@github.com:00willo/dotfiles.git
#   gclone projects git@github.com:00willo/python-tools.git
#   gclone lab git@github.com:00willo/homelab.git
#   gclone ventures git@github.com:00willo/ai-agency-prototype.git
#   gclone work git@github.com:<work-org>/identity-automation.git
#   gclone reference git@github.com:<work-org>/repo-you-mostly-read.git
#   gclone scratch git@github.com:LazyVim/starter.git
#
# gclone() {
#   local root_name="$1"
#   local repo_url="$2"
#   local root_path
#
#   if [[ -z "$root_name" || -z "$repo_url" ]]; then
#     echo "Usage: gclone <config|projects|lab|ventures|work|reference|scratch> <repo-url>" >&2
#     return 1
#   fi
#
#   root_path="$(_repo_root "$root_name")" || return
#   _ghq_get_into_root "$root_path" "gclone" "${@:2}"
# }

# Optional future helper:
# Clone into a selected root, then open the fuzzy repo picker.
#
# This is useful if you often clone and immediately jump into the repo.
# It is commented out for now because the simpler helpers above are easier
# to build muscle memory around.
#
# Usage:
#   gget lab git@github.com:00willo/homelab.git
#   gget scratch git@github.com:LazyVim/starter.git
#
# gget() {
#   gclone "$@" || return
#   repo
# }
