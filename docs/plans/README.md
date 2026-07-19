# Plans

Work broken into steps, before the work starts.

```
plans/
├── active/      in flight — check here first
└── completed/   shipped, kept as record
```

Check `active/` at the start of a session. If a plan already covers what you
were asked to do, continue it rather than starting a parallel effort.

## Filename

`short-slug.md` — `rest-timer.md`, `weekly-volume-chart.md`. No numbering; plans
move between directories, and renaming on move breaks links.

## Format

```markdown
---
title: Rest timer between sets
status: active          # active | blocked | completed | abandoned
started: 2026-07-19
completed:              # fill in on move to completed/
---

## Goal

The outcome, in one or two sentences. What is true when this is done.

## Approach

The shape of the solution and why this one. Enough that someone else could pick
it up cold.

## Steps

- [ ] Concrete, checkable units of work
- [ ] Each one small enough to finish in a sitting
- [ ] Note the files each step touches

## Open questions

Things that need a decision before or during the work. Resolve them inline as
they are answered — leave the answer, not just the checkmark.

## Notes

Appended during execution: what changed from the plan and why. This is the part
that matters most once the work is done.
```

## Lifecycle

Update the plan as you go — a plan that diverged silently from the work teaches
nothing. When the work ships, set `status: completed`, fill in `completed:`, and
`git mv` the file to `completed/`.

Abandoned plans move to `completed/` too, with `status: abandoned` and a note
explaining what stopped it. Knowing which approaches were dropped, and why, is
worth as much as knowing which shipped.
