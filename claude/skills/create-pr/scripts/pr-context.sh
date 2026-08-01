#!/usr/bin/env bash
# Collect every piece of git + GitHub state needed to open a pull request, in one pass.
#
# Usage: pr-context.sh [target-branch]
#   target-branch defaults to "main", falling back to the repo's default branch.
#
# Emits a plain-text report. Read it top to bottom before running any other command --
# it answers "can I open a PR right now, and what should be in it?" without a dozen
# round-trips of git plumbing.

set -uo pipefail

target="${1:-}"

section() { printf '\n== %s ==\n' "$1"; }

# --- repo sanity ------------------------------------------------------------
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "error: not inside a git repository"
  exit 1
fi

root=$(git rev-parse --show-toplevel)
remote=$(git remote | head -1)

if [ -z "$remote" ]; then
  echo "error: no git remote configured -- there is nowhere to push or open a PR"
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "warning: gh is not authenticated; run 'gh auth login' before creating the PR"
fi

# --- target branch ----------------------------------------------------------
default_branch=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name 2>/dev/null || echo "")

if [ -z "$target" ]; then
  if git show-ref --verify --quiet "refs/remotes/$remote/main"; then
    target="main"
  elif [ -n "$default_branch" ]; then
    target="$default_branch"
  else
    target="master"
  fi
fi

git fetch --quiet "$remote" "$target" 2>/dev/null

current=$(git rev-parse --abbrev-ref HEAD)
base="$remote/$target"

section "BRANCH"
echo "current: $current"
echo "target: $target"
echo "remote: $remote"
echo "repo_default_branch: ${default_branch:-unknown}"
if [ "$current" = "$target" ]; then
  echo "on_target_branch: yes   # blocker: a PR cannot go from the target branch onto itself"
else
  echo "on_target_branch: no"
fi

if ! git show-ref --verify --quiet "refs/remotes/$base"; then
  echo "target_exists_on_remote: no   # blocker: $base not found"
  exit 0
fi
echo "target_exists_on_remote: yes"

# --- push state -------------------------------------------------------------
upstream=$(git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null || echo "")

section "PUSH STATE"
if [ -z "$upstream" ]; then
  echo "upstream: none   # never pushed; push with: git push -u $remote $current"
  # With no upstream, every commit this branch has beyond the base is unpushed.
  echo "unpushed_commits: $(git rev-list --count "$base..HEAD" 2>/dev/null || echo 0)"
  echo "behind_upstream: 0"
else
  echo "upstream: $upstream"
  echo "unpushed_commits: $(git rev-list --count "$upstream..HEAD" 2>/dev/null || echo 0)"
  echo "behind_upstream: $(git rev-list --count "HEAD..$upstream" 2>/dev/null || echo 0)   # >0 means the remote has commits you lack -- never force-push over them"
fi

# --- commits that the PR would merge ---------------------------------------
count=$(git rev-list --count "$base..HEAD" 2>/dev/null || echo 0)

section "COMMITS TO MERGE ($base..HEAD)"
echo "count: $count"
if [ "$count" -gt 0 ]; then
  git log --reverse --format='- %s' "$base..HEAD"
else
  echo "# blocker: nothing to merge -- this branch has no commits the target lacks"
fi

section "COMMIT BODIES"
if [ "$count" -gt 0 ]; then
  git log --reverse --format='--- %h %s%n%b' "$base..HEAD" | head -120
fi

section "FILES CHANGED"
if [ "$count" -gt 0 ]; then
  git diff --stat "$base...HEAD" 2>/dev/null | tail -25
fi

# --- working tree -----------------------------------------------------------
section "WORKING TREE"
dirty=$(git status --porcelain | wc -l | tr -d ' ')
echo "uncommitted_changes: $dirty   # these are NOT part of the PR"
if [ "$dirty" -gt 0 ]; then
  git status --short
fi

# --- existing PR ------------------------------------------------------------
section "EXISTING PR"
# Iterate with .[] rather than indexing .[0]: an empty result set then produces no
# output at all, instead of a record full of the string "null".
existing=$(gh pr list --head "$current" --state open \
  --json number,url,title,isDraft \
  -q '.[] | "number: \(.number)\nurl: \(.url)\ntitle: \(.title)\ndraft: \(.isDraft)"' 2>/dev/null || echo "")
if [ -n "$existing" ]; then
  echo "$existing"
  echo "# an open PR already exists for this branch -- report it instead of creating a duplicate"
else
  echo "none"
fi

# --- PR template ------------------------------------------------------------
section "PR TEMPLATE"
found=""
for candidate in \
  ".github/PULL_REQUEST_TEMPLATE.md" \
  ".github/pull_request_template.md" \
  ".github/PULL_REQUEST_TEMPLATE.txt" \
  "docs/PULL_REQUEST_TEMPLATE.md" \
  "docs/pull_request_template.md" \
  "PULL_REQUEST_TEMPLATE.md" \
  "pull_request_template.md"; do
  if [ -f "$root/$candidate" ]; then
    found="$candidate"
    break
  fi
done

if [ -z "$found" ]; then
  for f in "$root"/.github/PULL_REQUEST_TEMPLATE/*.md; do
    if [ -f "$f" ]; then
      found="${f#"$root"/}"
      break
    fi
  done
fi

if [ -n "$found" ]; then
  echo "path: $found   # read this file and fill its sections"
else
  echo "none   # use the fallback body structure from SKILL.md"
fi

# --- commit style sample ----------------------------------------------------
section "RECENT COMMIT STYLE ON TARGET"
echo "# match this repo's actual convention when writing the PR title"
git log --format='- %s' -12 "$base" 2>/dev/null
