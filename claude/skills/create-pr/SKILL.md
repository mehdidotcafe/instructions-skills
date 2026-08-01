---
name: create-pr
description: Open a GitHub pull request with the gh CLI - pushes any unpushed commits first, synthesizes one title covering every commit on the branch, and fills the repo's PR template. Use this whenever the user asks to create, open, raise, submit, or "put up" a PR or pull request, says things like "PR this", "make a PR against main", "open this for review", or asks to turn finished branch work into a reviewable change - even when they never mention gh, GitHub, or a target branch.
---

# Create a pull request

Open a PR from the current branch into the target branch, defaulting to `main`.

A good PR is one a reviewer can act on without asking you anything. That means the
title says what the whole branch does (not what its last commit did), the body
answers the questions this repo's reviewers actually ask, and every commit being
merged is already on the remote. Most of the work below is in service of those
three things.

## Step 1: Read the state before touching anything

Run the bundled context script. It gathers branch state, push state, the commit
list, the working tree, any existing PR, and the repo's PR template in one pass,
so you are not guessing at any of it:

```bash
bash ~/.claude/skills/create-pr/scripts/pr-context.sh [target-branch]
```

Omit the argument to target `main` (falling back to the repo's default branch).
Pass one when the user names a different target, e.g. `develop`.

If the user named a target branch, pass it. If they said nothing, `main` is the default.

## Step 2: Resolve blockers before proceeding

The script flags these. Each needs a decision, not a workaround:

**An open PR already exists for this branch.** Report its URL and stop. Don't
create a duplicate. If the user wants the existing PR's title or body refreshed to
match the branch's current commits, do that with `gh pr edit` instead.

**You are on the target branch.** A PR from `main` into `main` is not a thing.
Stop and ask before rewriting any history — the user may have committed to `main`
by accident, or may have meant a different target entirely, and you cannot tell
which from here. Propose the concrete recovery and wait:

> You're on `main`, which is also the PR target, so there's nothing to open a PR
> from. I can move these 2 commits onto a new branch `feat/imap-starttls` and
> reset `main` back to `origin/main`, then open the PR from there. Want me to?

Only after they agree:

```bash
git branch <new-branch>          # mark the current commits
git reset --hard <remote>/<target>   # rewind the local target branch
git checkout <new-branch>
```

That ordering is deliberate: the branch is created first so the commits are
already reachable from a ref before the reset discards them from the target
branch's history.

**Nothing to merge** (`count: 0`). The branch has no commits the target lacks.
Say so and stop — there is no PR to open.

**Behind upstream** (`behind_upstream` > 0). The remote branch has commits you
don't have locally. Don't force-push over them. Report it and let the user decide
whether to pull, rebase, or investigate.

**Uncommitted changes.** These are not part of the PR. Mention them so the user
isn't surprised that work they can see in their editor is missing from the diff,
then continue with what's committed. Don't commit them on your own initiative —
deciding what belongs in a commit is the user's call.

## Step 3: Push unpushed commits

A PR can only describe commits GitHub can see, so push before creating it.

```bash
git push -u <remote> <current-branch>   # upstream: none
git push                                # upstream exists, unpushed_commits > 0
```

Skip this when `unpushed_commits: 0` and an upstream is already set.

## Step 4: Write the title from all the commits

The title describes the branch as a whole. A reviewer scanning a list of PRs
should learn what this one changes without opening it — which is exactly what
they don't learn from a title that just repeats the newest commit subject.

Read the commit subjects from the script's output, then:

- **Find the dominant type.** If most commits are `feat`, it's a feature PR, even
  when it also carries tests, refactors, and a docs tweak. Supporting commits
  don't change what the branch is for.
- **Keep a scope only if it covers everything.** Three commits all scoped `imap`
  keep `(imap)`. Commits spread across `db`, `scheduler`, and `docs` drop the
  scope rather than picking a misleading one.
- **Name the capability, not the steps.** When commits are increments toward one
  outcome, describe the outcome.
- **One commit means one title.** Reuse its subject verbatim. Paraphrasing a
  perfectly good subject just makes the PR harder to match against the commit.
- **Match the repo, not a convention you prefer.** The script prints recent
  commit subjects from the target branch. If that history doesn't use
  `type(scope):` prefixes, don't introduce them here — a PR title that looks
  foreign to the repo reads as noise.

Keep it under ~72 characters, imperative mood, no trailing period.

**Example 1 — supporting commits don't shift the type**

```
feat(imap): add read-only fetch
feat(imap): handle STARTTLS toggle
test(imap): cover reconnect path
→ feat(imap): read-only IMAP fetch with STARTTLS support
```

The test commit exists to support the feature. Scope survives because all three
commits share it.

**Example 2 — incidental commits don't earn a place in the title**

```
fix(digest): drop empty sections
fix(digest): escape markdown in subjects
chore: bump anthropic to 0.40
→ fix(digest): correct empty-section and markdown escaping bugs
```

The dependency bump is real work but it isn't what this PR is about.

**Example 3 — a branch of steps toward one capability**

```
feat(db): add digest_runs table
refactor(scheduler): extract cadence resolver
docs: document runtime cadence changes
→ feat: runtime-configurable digest cadence
```

No single scope covers db + scheduler + docs, so the scope is dropped. The title
names what the user gets, not the three steps it took.

**Example 4 — a single commit**

```
feat(telegram): add /cadence command
→ feat(telegram): add /cadence command
```

## Step 5: Write the body

**When the repo has a template** (the script reports its path), read the file and
fill in its sections. The template exists because this repo's reviewers decided
those are the questions worth answering, so honor its structure rather than
substituting your own. Fill what the diff lets you answer honestly. Leave
checklist items unchecked — those are assertions the human has to make, and
pre-ticking them launders your guess into their sign-off. Keep sections you can't
speak to and leave them empty rather than deleting them, so the reviewer can see
what still needs filling.

**When there is no template**, use this structure:

```markdown
## Summary
<1-3 sentences: what changes and why. Written for someone who hasn't read the commits.>

## Commits
- <commit subject>
- <commit subject>

## Test plan
- [ ] <the command that exercises this, e.g. `uv run pytest tests/test_imap.py`>
- [ ] <anything needing manual verification>
```

End every body — templated or not — with:

```
🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

Write the body to a temp file and pass `--body-file`. PR bodies contain backticks,
newlines, and quotes that shells mangle when inlined into `--body`, and a mangled
body is a PR you have to go fix by hand.

## Step 6: Create it

```bash
gh pr create --base <target> --title "<title>" --body-file <path>
```

PRs are created ready for review. Add `--draft` only when the user asks for a
draft.

If `gh` rejects the push target or reports no commits between branches, re-read
the script output rather than retrying the same command — it means a Step 2
blocker was missed.

## Step 7: Report

Print the PR URL, then open it:

```bash
gh pr view --web
```

Browsers often can't open from headless shells, containers, or WSL. That failure
is harmless — the URL you already printed is what the user needs, so don't retry
or treat it as an error.

Close with the URL, the target branch, and the number of commits included. If you
skipped uncommitted changes or reused an existing PR, say that here too — those
are the two things most likely to surprise the user afterward.
