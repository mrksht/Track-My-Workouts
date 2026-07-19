# References

Pointers to material that lives outside this repository, with the context needed
to know why it matters here.

A reference is not a bookmark dump. Each entry says what we use the thing for and
which part of it is relevant — otherwise the next session re-reads the whole
document to find the one paragraph that mattered.

## Filename

`topic.md` — `supabase.md`, `recharts.md`, `training-program.md`. One file per
subject, appended to over time.

## Format

```markdown
---
title: Supabase
updated: 2026-07-19
---

## Why we care

Supabase is the entire backend: Postgres, the JS client, and the SQL editor we
apply migrations through by hand.

## Links

- [supabase-js query builder](https://supabase.com/docs/reference/javascript/select)
  — `.select()` with nested relations, which is how pages load sessions with
  their exercises and sets in one round trip.
- [Row Level Security](https://supabase.com/docs/guides/database/postgres/row-level-security)
  — relevant if this app ever gains a second user; today every policy is
  `using (true)`.

## Project-specific notes

Anything about how *we* use it that the official docs will not tell you.
Version quirks, settings chosen in the dashboard, workarounds.
```

## Candidates for this directory

The Supabase project dashboard, the JS client reference, Recharts API docs, the
Vite and Tailwind 4 configuration guides, and the source training program the
day templates in [../../supabase/seed.sql](../../supabase/seed.sql) encode.

Keep credentials out. Link to dashboards; never paste keys — the anon key and
the app PIN belong in `.env`, which is gitignored.
