#!/usr/bin/env bash
set -u

repo_dir="${1:-}"
if [ -z "$repo_dir" ]; then
  echo "NO_REPO_DIR"
  exit 2
fi

cd "$repo_dir"

branches="${BRANCH_PRIORITY:-}"
prefer_current="${PREFER_CURRENT:-1}"
allow_remote="${ALLOW_REMOTE_BRANCHES:-1}"
remote_name="${REMOTE_NAME:-origin}"
pull_ff_only="${PULL_FF_ONLY:-1}"
dry_run="${DRY_RUN:-0}"
remote_prefix="$remote_name/"

current="$(git symbolic-ref --short -q HEAD || true)"

has_local() { git show-ref --verify --quiet "refs/heads/$1"; }
has_remote() { git show-ref --verify --quiet "refs/remotes/$remote_name/$1"; }

choose=""

if [ "$prefer_current" = "1" ] && [ -n "$current" ]; then
  choose="$current"
fi

if [ -z "$choose" ] && [ -n "$branches" ]; then
  for b in $branches; do
    if has_local "$b"; then
      choose="$b"
      break
    fi
    if [ "$allow_remote" = "1" ] && has_remote "$b"; then
      choose="$remote_name/$b"
      break
    fi
  done
fi

if [ -z "$choose" ]; then
  choose="$(git for-each-ref --format='%(refname:short)' refs/heads | head -n 1 || true)"
fi

if [ -z "$choose" ]; then
  echo "NO_BRANCH"
  exit 0
fi

if [ "${choose#$remote_prefix}" != "$choose" ]; then
  remote_branch="${choose#$remote_prefix}"
  if [ "$dry_run" = "1" ]; then
    if [ "$current" != "$remote_branch" ]; then
      checkout="checkout -B $remote_branch $remote_name/$remote_branch"
    else
      checkout="checkout (no-op, already on $remote_branch)"
    fi
    branch_out="$remote_branch"
  else
    if [ "$current" != "$remote_branch" ]; then
      git checkout -B "$remote_branch" "$choose" >/dev/null
    fi
    branch_out="$remote_branch"
  fi
else
  if [ "$dry_run" = "1" ]; then
    if [ "$current" != "$choose" ]; then
      checkout="checkout $choose"
    else
      checkout="checkout (no-op, already on $choose)"
    fi
    branch_out="$choose"
  else
    if [ "$current" != "$choose" ]; then
      git checkout "$choose" >/dev/null
    fi
    branch_out="$choose"
  fi
fi

if [ "$dry_run" = "1" ]; then
  if [ "$pull_ff_only" = "1" ]; then
    pull_cmd="git pull --ff-only"
  else
    pull_cmd="git pull"
  fi
  echo "branch=$branch_out checkout=\"$checkout\" pull=\"$pull_cmd\""
else
  echo "$branch_out"
fi
