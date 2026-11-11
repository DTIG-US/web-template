#!/usr/bin/env bash
# =============================================================================
# submodule-commit.sh
#
# Safely commits and pushes changes in Git submodules BEFORE updating the
# parent repo pointer. Prevents broken pointer commits where the parent
# references a submodule SHA that has not been pushed yet.
#
# Usage:
#   ./scripts/submodule-commit.sh [options]
#
# Options:
#   -m, --message <msg>    Commit message (applied to all submodules and parent)
#   -s, --submodule <path> Limit to a specific submodule path (repeatable)
#   -n, --dry-run          Show what would happen without making changes
#   -h, --help             Show this help message
#
# Examples:
#   ./scripts/submodule-commit.sh -m "style: update carousel layout"
#   ./scripts/submodule-commit.sh -m "fix: header bug" -s src/app/web-header
#   ./scripts/submodule-commit.sh -m "refactor: cleanup" -n
# =============================================================================

set -euo pipefail

# -- Colours ------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# -- Helpers ------------------------------------------------------------------
info()    { echo -e "${CYAN}[INFO]${RESET}  $*"; }
success() { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; }
die()     { error "$*"; exit 1; }
step()    { echo -e "\n${BOLD}${CYAN}>> $*${RESET}"; }

run() {
  if [[ "$DRY_RUN" == "true" ]]; then
    echo -e "${YELLOW}[DRY-RUN]${RESET} would run: $*"
  else
    "$@"
  fi
}

get_submodule_branch() {
  local sm_path="$1"
  local branch=""

  # 1. Check parent's .gitmodules configuration
  branch="$(git config -f "$REPO_ROOT/.gitmodules" --get submodule."$sm_path".branch 2>/dev/null || true)"
  if [[ -n "$branch" ]]; then
    echo "$branch"
    return 0
  fi

  # 2. Check remote HEAD
  branch="$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||' || true)"
  if [[ -n "$branch" ]]; then
    echo "$branch"
    return 0
  fi

  # 3. Check common remote branch names
  if git show-ref --verify --quiet refs/remotes/origin/main 2>/dev/null; then
    echo "main"
    return 0
  fi
  if git show-ref --verify --quiet refs/remotes/origin/master 2>/dev/null; then
    echo "master"
    return 0
  fi

  # 4. Fallback to local HEAD symbolic ref if not detached
  branch="$(git symbolic-ref --short HEAD 2>/dev/null || true)"
  if [[ -n "$branch" ]]; then
    echo "$branch"
    return 0
  fi

  # Default fallback
  echo "main"
}

has_unpushed_commits() {
  local branch="$1"
  # Check if remote tracking branch exists
  if git show-ref --verify --quiet "refs/remotes/origin/$branch" 2>/dev/null; then
    # If origin/$branch exists, check if HEAD has commits not in origin/$branch
    if [[ -n "$(git log "origin/$branch..HEAD" --oneline 2>/dev/null)" ]]; then
      return 0
    fi
  else
    # If remote branch doesn't exist, all commits in HEAD are unpushed (if repository has commits)
    if git rev-parse HEAD >/dev/null 2>&1; then
      return 0
    fi
  fi
  return 1
}

is_rebase_in_progress() {
  local git_dir
  git_dir=$(git rev-parse --git-dir 2>/dev/null || echo "")
  [[ -n "$git_dir" && ( -d "$git_dir/rebase-merge" || -d "$git_dir/rebase-apply" ) ]]
}

# -- Argument Parsing ---------------------------------------------------------
COMMIT_MESSAGE=""
SPECIFIC_SUBMODULES=()
DRY_RUN="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -m|--message)
      COMMIT_MESSAGE="$2"; shift 2 ;;
    -s|--submodule)
      SPECIFIC_SUBMODULES+=("$2"); shift 2 ;;
    -n|--dry-run)
      DRY_RUN="true"; shift ;;
    -h|--help)
      sed -n '/^# Usage:/,/^# ====/p' "$0" | grep -v "^# ====" | sed 's/^# \?//'
      exit 0 ;;
    *)
      die "Unknown option: $1. Use -h for help." ;;
  esac
done

# -- Validate environment -----------------------------------------------------
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" \
  || die "Not inside a git repository."

cd "$REPO_ROOT"

[[ -f ".gitmodules" ]] \
  || die "No .gitmodules found. This repo has no submodules."

if [[ -z "$COMMIT_MESSAGE" ]]; then
  error "A commit message is required."
  echo "  Usage: $0 -m \"your commit message\""
  exit 1
fi

# -- Discover all registered submodule paths ----------------------------------
ALL_SUBMODULE_PATHS=()
while IFS= read -r line; do
  path="${line#path = }"
  ALL_SUBMODULE_PATHS+=("$path")
done < <(grep '^\s*path' .gitmodules | sed 's/^\s*//g')

# -- Determine which submodules to process ------------------------------------
step "Scanning for submodule changes..."

TARGETS=()
if [[ ${#SPECIFIC_SUBMODULES[@]} -gt 0 ]]; then
  TARGETS=("${SPECIFIC_SUBMODULES[@]}")
else
  for sm_path in "${ALL_SUBMODULE_PATHS[@]}"; do
    if [[ -d "$sm_path" ]]; then
      pushd "$sm_path" > /dev/null
      has_changes=false
      # Unstaged changes
      if ! git diff --quiet 2>/dev/null; then has_changes=true; fi
      # Staged but not committed
      if ! git diff --cached --quiet 2>/dev/null; then has_changes=true; fi
      # Committed locally but not pushed
      branch=$(get_submodule_branch "$sm_path")
      if has_unpushed_commits "$branch"; then has_changes=true; fi
      popd > /dev/null
      if [[ "$has_changes" == "true" ]]; then
        TARGETS+=("$sm_path")
      fi
    fi
  done

  # Also catch submodule pointer changes already visible in the parent's status
  while IFS= read -r p; do
    [[ -z "$p" ]] && continue
    for sm in "${ALL_SUBMODULE_PATHS[@]}"; do
      if [[ "$p" == "$sm" ]] && [[ ! " ${TARGETS[*]} " =~ " $sm " ]]; then
        TARGETS+=("$sm")
      fi
    done
  done < <(git status --short | awk '{print $2}')
fi

if [[ ${#TARGETS[@]} -eq 0 ]]; then
  if git diff --quiet && git diff --cached --quiet; then
    info "No changes detected anywhere. Nothing to do."
    exit 0
  else
    warn "No submodule changes -- will only commit parent repo changes."
  fi
else
  echo ""
  info "Submodules to process (${#TARGETS[@]}):"
  for t in "${TARGETS[@]}"; do echo "   * $t"; done
fi

# -- Phase 1: Commit and push each submodule ----------------------------------
step "Phase 1 -- Committing and pushing submodules"

PUSHED_SUBMODULES=()
FAILED_SUBMODULES=()

for sm_path in "${TARGETS[@]}"; do
  echo ""
  echo -e "  ${BOLD}-> $sm_path${RESET}"

  if [[ ! -d "$sm_path" ]]; then
    warn "Path '$sm_path' not found. Skipping."
    continue
  fi

  pushd "$sm_path" > /dev/null

  branch=$(get_submodule_branch "$sm_path")

  has_local_changes=false
  if ! git diff --quiet 2>/dev/null; then has_local_changes=true; fi
  if ! git diff --cached --quiet 2>/dev/null; then has_local_changes=true; fi
  has_unpushed=false
  if has_unpushed_commits "$branch"; then has_unpushed=true; fi

  if [[ "$has_local_changes" == "false" && "$has_unpushed" == "false" ]]; then
    info "Nothing to do in $sm_path -- skipping."
    popd > /dev/null
    continue
  fi

  # Stash unstaged changes so git pull --rebase doesn't refuse to run,
  # then restore them immediately after the pull.
  STASHED=false
  if ! git diff --quiet 2>/dev/null; then
    info "Stashing unstaged changes before pull..."
    if [[ "$DRY_RUN" == "true" ]]; then
      echo -e "${YELLOW}[DRY-RUN]${RESET} would run: git stash push -u -m 'submodule-commit-script-auto-stash'"
    else
      git stash push -u -m "submodule-commit-script-auto-stash"
      STASHED=true
    fi
  fi

  # Pull with rebase to avoid push rejection
  info "Pulling latest from remote (origin/$branch --rebase)..."
  pull_ok=true
  if ! run git pull --rebase origin "$branch" 2>&1; then
    pull_ok=false
  fi

  # Restore stash
  if [[ "$STASHED" == "true" ]]; then
    if is_rebase_in_progress; then
      warn "Rebase in progress in $sm_path. Stash not popped to avoid conflicts."
      warn "Your changes are safe in stash. Pop manually with 'git stash pop' after resolving conflicts."
    else
      info "Restoring stashed changes..."
      if ! git stash pop; then
        error "git stash pop failed in $sm_path -- manual intervention required."
        FAILED_SUBMODULES+=("$sm_path")
        popd > /dev/null
        continue
      fi
    fi
  fi

  if [[ "$pull_ok" == "false" ]]; then
    error "git pull --rebase failed in $sm_path. Resolve conflicts and re-run."
    FAILED_SUBMODULES+=("$sm_path")
    popd > /dev/null
    continue
  fi

  # Stage everything
  if [[ "$has_local_changes" == "true" ]]; then
    info "Staging all changes..."
    run git add -A
  fi

  # Commit if there is something staged
  if [[ "$DRY_RUN" == "true" ]] || ! git diff --cached --quiet 2>/dev/null; then
    info "Committing..."
    run git commit -m "$COMMIT_MESSAGE"
  else
    info "Nothing new to commit (changes may already be committed)."
  fi

  # Push -- this MUST succeed before we touch the parent
  info "Pushing..."
  if run git push origin HEAD:"$branch"; then
    success "Pushed: $sm_path"
    PUSHED_SUBMODULES+=("$sm_path")
  else
    error "Push FAILED for $sm_path"
    FAILED_SUBMODULES+=("$sm_path")
  fi

  popd > /dev/null
done

# -- Abort if any submodule push failed ---------------------------------------
if [[ ${#FAILED_SUBMODULES[@]} -gt 0 ]]; then
  echo ""
  error "The following submodules failed to push:"
  for f in "${FAILED_SUBMODULES[@]}"; do echo "   * $f"; done
  error ""
  error "Aborting parent repo commit to prevent a broken pointer reference."
  error "Fix the issues above and re-run this script."
  exit 1
fi

# -- Phase 2: Commit and push parent repo -------------------------------------
step "Phase 2 -- Committing parent repo"

cd "$REPO_ROOT"

info "Staging parent repo changes (submodule pointers + any other files)..."
run git add -A

if [[ "$DRY_RUN" == "false" ]] && git diff --cached --quiet; then
  info "No parent repo changes to commit."
else
  info "Committing parent repo..."
  run git commit -m "$COMMIT_MESSAGE"

  info "Pushing parent repo..."
  if run git push; then
    success "Parent repo pushed."
  else
    die "Parent push failed. Submodules are already pushed -- retry manually: git push"
  fi
fi

# -- Summary ------------------------------------------------------------------
echo ""
echo -e "${BOLD}${GREEN}Done!${RESET}"
if [[ ${#PUSHED_SUBMODULES[@]} -gt 0 ]]; then
  echo "  Submodules committed & pushed:"
  for s in "${PUSHED_SUBMODULES[@]}"; do echo "   * $s"; done
fi
echo "  Parent repo: committed & pushed"
echo ""
