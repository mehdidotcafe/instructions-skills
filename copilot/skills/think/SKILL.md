---
name: think
description: 'Strategic thinking skill — analyze a problem and present 4 solution options (3 practical + 1 innovative) WITHOUT writing code. Use when the user wants to explore approaches before implementation, evaluate trade-offs, plan architecture, choose between strategies, or break down a complex problem. Triggered by: /think, "think about", "what are my options", "how should I approach", "explore solutions", "brainstorm".'
argument-hint: 'Describe the problem or decision you want to think through'
user-invocable: true
disable-model-invocation: false
---

# Think — Strategic Options Skill

## Purpose

Analyze the given problem and present **4 solution options** with trade-offs. No code is generated unless explicitly requested afterward.

## When to Use

- Before starting implementation — choose the right approach first
- Architecture decisions — evaluate patterns, layers, dependencies
- Debugging strategy — plan where to look before diving in
- Refactoring decisions — weigh approaches before touching code
- Any time the user says: "think about X", "what are my options for X", or invokes `/think`

---

## Procedure

### Step 1 — Restate the Problem

Briefly restate the problem in your own words (1–3 sentences). This confirms you understand the scope.

> If the problem is ambiguous, ask ONE clarifying question before continuing.

### Step 2 — Identify Constraints & Goals

Extract the key constraints and success criteria from the context:
- Technical constraints (framework, language, existing patterns)
- Time/complexity constraints
- Quality goals (performance, maintainability, testability)
- Non-negotiables (breaking changes, backward compatibility, etc.)

### Step 3 — Generate 3 Practical Options

For each option, provide:

```
### Option [N]: [Name]
**Approach:** One-sentence summary of the strategy.
**How it works:** 3–5 bullet points on what changes.
**Pros:** Key advantages.
**Cons / Trade-offs:** Honest downsides.
**Best when:** Ideal context for choosing this option.
**Complexity:** Low / Medium / High
```

Options should be genuinely different (not minor variations). Cover the spectrum:
- Option 1: Conservative / least change
- Option 2: Balanced / pragmatic
- Option 3: Thorough / more effort, more gain

### Step 4 — Generate 1 Innovative Option

```
### Option 4: [Creative Name] ✨
**Approach:** One-sentence summary of the unconventional strategy.
**Why it's different:** What makes this non-obvious or creative.
**How it works:** 3–5 bullet points.
**Pros:** What makes it worth considering.
**Cons / Risks:** What could go wrong.
**Best when:** Niche or forward-thinking context where this shines.
**Complexity:** Low / Medium / High
```

This option should challenge assumptions — a different abstraction level, an alternative tool, an inversion of the problem, or a long-term strategic bet.

### Step 5 — Recommendation Summary

End with a concise comparison table:

| Option | Strategy | Complexity | Best For |
|--------|----------|------------|----------|
| 1 | ... | Low | ... |
| 2 | ... | Medium | ... |
| 3 | ... | High | ... |
| 4 ✨ | ... | Varies | ... |

Finish with a **1-sentence recommendation** based on the constraints identified in Step 2. Use this format:

> **Recommendation:** If [context/constraint], go with **Option N** because [reason].

---

## Rules

- **No code.** Do not generate code snippets unless the user explicitly asks after seeing the options.
- **Be honest about trade-offs.** Don't oversell any option.
- **Stay specific.** Options must be tailored to the actual problem, not generic advice.
- **4 options exactly.** Never fewer, never more unless asked.
- **Option 4 must be genuinely creative** — not just "Option 3 but harder."
