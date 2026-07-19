# docs/

The project's durable memory. Code says what the app does now; these documents
say why it got that way and what we learned along the route.

```
docs/
├── design-docs/      decisions and their rationale
├── learnings/        gotchas discovered while working
├── plans/
│   ├── active/       work in flight
│   └── completed/    what shipped
└── references/       pointers to external material
```

Start from [../AGENTS.md](../AGENTS.md) for the repository map. Each directory
below has a README describing its own format — follow it so documents stay
greppable by frontmatter.

## What belongs here

Write a document when the knowledge would otherwise be lost between sessions:

- a decision someone would reasonably second-guess later
- a bug whose cause was not where the symptom was
- a constraint imposed from outside the codebase (Supabase behavior, a
  device limitation, a training-program requirement)

## What does not

- Anything the code already states plainly. A document that restates
  `src/types/database.ts` will drift and mislead.
- Session narration ("first I tried X, then Y"). Record the conclusion and the
  evidence for it.
- Duplicates. Update the existing document instead of adding a second one on the
  same topic.

## Maintenance

Documents describe the codebase at a point in time. If you find one that
contradicts current code, fix or delete it in the same session — a stale
document is worse than a missing one, because it is trusted.
