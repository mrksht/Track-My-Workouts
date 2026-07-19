# Design docs

Decisions with lasting consequences, and the reasoning behind them. A design doc
exists so that a future session can tell the difference between a deliberate
choice and an accident.

Write one when a change affects the data model, the routing/auth structure, how
sessions are recorded, or any interaction that other work will have to build
around. Skip it for local refactors and bug fixes.

## Filename

`NNN-short-slug.md`, numbered in creation order — `001-set-tracking-types.md`.

## Format

```markdown
---
title: Per-exercise tracking types
status: accepted        # proposed | accepted | superseded
date: 2026-07-19
supersedes:             # filename, if this replaces an earlier doc
---

## Context

What was true that forced a decision. Constraints, not narrative.

## Decision

What we chose, in the present tense: "Exercise sets store weight, reps, and
duration on one table; `tracking_type` decides which fields the UI shows."

## Consequences

What this makes easy, what it makes hard, and what a future change would have to
touch. Be honest about the costs — this section is the reason the doc is worth
reading.

## Alternatives considered

Each with the reason it lost. An alternative with no stated objection reads as
an oversight rather than a rejection.
```

## Superseding

Do not rewrite an accepted doc when the decision changes. Set its status to
`superseded`, and write a new doc naming it in `supersedes:`. The trail of
reversals is itself useful information.
