---
name: think
description: Analyze a problem and lay out exactly 4 solution options — 3 practical (conservative / balanced / thorough) plus 1 genuinely inventive — each with honest trade-offs, ending in a comparison table and a one-line recommendation. Explores and explains without touching any project files. Use this whenever the user wants to weigh approaches before committing to one: "think about X", "what are my options", "how should I approach this", "explore solutions", "brainstorm", "which pattern fits here", "is it worth refactoring X", picking an architecture, choosing a library, or planning a debugging strategy — even when they never say the word "options" and even when the request sounds like it wants an implementation. Also invoked directly as /think.
argument-hint: the problem or decision you want to think through
---

# Think — strategic options

Turn a fuzzy decision into 4 concrete, genuinely different options the user can choose
between. The user is not asking you to solve the problem; they are asking you to map the
solution space so they can pick a direction.

## Ground the options in the real code first

Generic advice is the failure mode of this skill. "Use a repository pattern" is worthless;
"move the three Prisma calls in `OrderService.submit` behind an `OrderRepository` port so
the two integration tests stop needing a live DB" is a decision someone can actually make.

So before writing anything, spend a few minutes reading. Find the files the decision
touches, the existing patterns the codebase already commits to, the tests that would have
to change, and any constraint the user hasn't mentioned but the repo enforces. If the
problem is a bug or a debugging strategy, look at the actual failing path.

Scale the reading to the stakes — a one-file naming question needs a glance; an
architecture decision deserves real exploration, and a subagent is a good way to do it
without flooding this conversation. If there's genuinely no code involved (a greenfield
choice, a process question), skip straight to the procedure.

## Procedure

### 1. Restate the problem

One to three sentences, in your own words. This is a cheap way to catch a
misunderstanding before you spend the user's attention on four detailed options.

If the problem is ambiguous in a way that would change the options themselves, ask **one**
clarifying question and stop. If it's ambiguous in a way you can resolve by picking a
reasonable reading, state your reading and continue — don't stall on a question you can
answer yourself.

### 2. Name the constraints and goals

Pull these from the code and the conversation, not from a checklist:

- Technical constraints — framework, language, patterns the codebase already uses
- Effort and time budget — is this an afternoon or a quarter?
- Quality goals — performance, maintainability, testability, whichever actually apply here
- Non-negotiables — backward compatibility, public API stability, things that can't break

Keep it to the ones that discriminate between options. A constraint that every option
satisfies equally isn't worth listing.

### 3. Three practical options

Cover the spectrum so the user sees a real range, not three flavors of the same idea:

- **Option 1 — conservative:** the smallest change that addresses the problem
- **Option 2 — balanced:** the pragmatic middle, usually the one you'd default to
- **Option 3 — thorough:** more effort now, more payoff later

Use this shape for each:

```
### Option N: [Name]
**Approach:** One sentence on the strategy.
**How it works:** 3–5 bullets on what concretely changes — name real files, modules, or functions.
**Pros:** Key advantages.
**Cons / Trade-offs:** Honest downsides. If you can't name a real one, the option isn't understood well enough yet.
**Best when:** The context where this is the right call.
**Complexity:** Low / Medium / High
```

The test for whether they're genuinely different: could a reasonable engineer prefer each
one? If two options differ only in a parameter, a naming choice, or how much of the same
work you do, collapse them and find a real third direction.

### 4. One inventive option

```
### Option 4: [Creative Name] ✨
**Approach:** One sentence on the unconventional strategy.
**Why it's different:** What assumption this drops that options 1–3 all share.
**How it works:** 3–5 bullets.
**Pros:** What makes it worth considering.
**Cons / Risks:** What could go wrong.
**Best when:** The niche or forward-looking context where this shines.
**Complexity:** Low / Medium / High
```

This one earns its place by challenging a premise the other three accept. Productive moves:
invert the problem (don't fix it, make it impossible), change the abstraction level
(solve it in the type system, the build, or the schema instead of the runtime), delete
instead of add (does this feature need to exist?), buy instead of build, or bet on where
the codebase is heading rather than where it is.

What it must not be: "Option 3 but more of it." Bigger, harder, or more thorough is not
creative. If your option 4 is just the most ambitious version of the same plan, you haven't
found it yet — go back and ask what all three options are quietly assuming.

An inventive option that's clearly wrong for this situation is still worth including, as
long as you say so plainly in the risks. It shows the user the edge of the space.

### 5. Compare and recommend

| Option | Strategy | Complexity | Best For |
|--------|----------|------------|----------|
| 1 | ... | Low | ... |
| 2 | ... | Medium | ... |
| 3 | ... | High | ... |
| 4 ✨ | ... | Varies | ... |

Then commit to one:

> **Recommendation:** If [the constraint that decides it], go with **Option N** because [reason].

Make an actual call. "It depends on your priorities" is what the user came here to escape —
they've read the trade-offs already. Tie the recommendation to a specific constraint from
step 2 so they can override it if that constraint is wrong.

## Ground rules

**Change nothing on disk.** Read freely, but don't edit, create, or delete a single project
file, and don't run anything with side effects. This is a thinking step — the user hasn't
picked a direction yet, so any code you write is code written against a decision that
hasn't been made. They'll ask for the implementation once they've chosen.

Snippets in your reply are welcome when they make an option concrete: a signature that
shows the shape of an interface, a config fragment, a few lines contrasting how two options
would read at the call site. Keep them short and illustrative. The moment a snippet grows
into a working draft, the conversation shifts from "which direction" to "review my code"
and the comparison dies.

**Exactly 4 options.** The constraint is doing real work: three forces you past the two
obvious answers, and the fourth forces you past the comfortable ones. Deviate only if the
user asks for a different number.

**Don't oversell.** If option 2 is clearly the right answer, options 1, 3, and 4 still get
honest treatment — the user needs to see what they're not choosing to trust that you
looked. But don't manufacture appeal for a bad option either; say it's a bad fit here and
why.
