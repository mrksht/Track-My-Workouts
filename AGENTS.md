# AGENTS.md

Entry point for agent sessions on **track-my-workout**. Read this first, then
follow the pointers below into the code and the knowledge base.

## What this app is

A single-user workout tracker. One person (the owner) follows a 5-day training
split, logs each session set-by-set, and reviews history and progress charts.
There is no multi-user concept anywhere in the schema or the UI — the app gates
access behind a shared PIN, not real accounts.

## Stack

React 19 + TypeScript, Vite 8, Tailwind CSS 4 (via `@tailwindcss/vite`),
React Router 7, Recharts for charts, `lucide-react` for icons, Supabase
(`@supabase/supabase-js`) as the only backend.

```
npm run dev       # vite dev server
npm run build     # tsc -b && vite build
npm run lint      # eslint
npm run preview   # serve the production build
```

There is no test runner and no CI in this repo. "Verified" means the change was
exercised in the running app, not that a suite passed.

## Repository map

| Path | What lives there |
| --- | --- |
| [src/App.tsx](src/App.tsx) | Route table; wraps everything in `AuthProvider` and gates on the PIN |
| [src/main.tsx](src/main.tsx) | React root + router mount |
| [src/lib/supabase.ts](src/lib/supabase.ts) | The single Supabase client; throws at import if env vars are missing |
| [src/lib/auth.tsx](src/lib/auth.tsx) | PIN gate context (`useAuth`), backed by `sessionStorage` |
| [src/types/database.ts](src/types/database.ts) | Hand-written row types mirroring the SQL schema — **the contract between DB and UI** |
| [src/pages/PinGate.tsx](src/pages/PinGate.tsx) | PIN entry screen shown when unauthenticated |
| [src/pages/Dashboard.tsx](src/pages/Dashboard.tsx) | Week overview, day templates, streak |
| [src/pages/Workout.tsx](src/pages/Workout.tsx) | Live session logging; builds entries then writes the whole session |
| [src/pages/History.tsx](src/pages/History.tsx) | Past sessions list |
| [src/pages/Progress.tsx](src/pages/Progress.tsx) | Recharts progress views |
| [src/components/ExerciseCard.tsx](src/components/ExerciseCard.tsx) | Per-exercise set entry; branches on `tracking_type` |
| [src/components/SwapExerciseModal.tsx](src/components/SwapExerciseModal.tsx) | Substitute an exercise mid-session |
| [src/components/Layout.tsx](src/components/Layout.tsx) | Shell + bottom nav |
| [supabase/](supabase/) | Schema migrations and seed data (see below) |
| [docs/](docs/) | Knowledge base — see "Knowledge base" |

## Data model

Six tables, defined in [supabase/migration.sql](supabase/migration.sql):

```
exercises          library of movements (category, tracking_type, muscle_group)
day_templates      the 5 training days
template_exercises which exercises belong to which day, with sets/reps/section
workout_sessions   one gym visit (date, template, status, notes, duration)
session_exercises  what was actually performed, incl. original_exercise_id when swapped
exercise_sets      per-set weight_kg / reps / duration_sec / skipped
```

Two ideas are worth internalizing because they shape most of the UI code:

**`tracking_type` drives set entry.** `weighted` uses `weight_kg` + `reps`,
`bodyweight` uses `reps` only, `timed` uses `duration_sec`. `exercise_sets`
carries all three columns and defaults the unused ones to `0` rather than
splitting into per-type tables. Any new tracking type means touching both the
SQL check constraint and the branching in `ExerciseCard`.

**Swaps are recorded, not overwritten.** When the user substitutes an exercise,
`session_exercises.exercise_id` becomes the new movement and
`original_exercise_id` preserves what was planned. History and progress views
should keep respecting that distinction.

### Migrations

`migration.sql` is the full baseline and is **destructive — it drops and
recreates every table**. Never run it against data you care about. Incremental
changes go in numbered files (`migration_002_*.sql`, `migration_003_*.sql`) that
are applied by hand in the Supabase SQL editor. There is no migration runner and
no automatic ordering, so a new migration must state its prerequisites in a
header comment. `seed.sql` populates the exercise library and day templates.

When you change the schema, update [src/types/database.ts](src/types/database.ts)
in the same change. Nothing enforces that they agree — the types are hand-written,
so drift is silent until runtime.

### Security posture

RLS is enabled on every table but the policies are `using (true)` for all
operations, so the anon key grants full read/write. The PIN in
`VITE_APP_PIN` is a client-side check compiled into the bundle; it keeps a
casual visitor out of the UI and nothing more. This is a deliberate trade-off
for a single-user personal app — do not describe it as authentication, and flag
it if the app ever grows a second user or holds anything sensitive.

Env vars (see [.env.example](.env.example)): `VITE_SUPABASE_URL`,
`VITE_SUPABASE_ANON_KEY`, `VITE_APP_PIN`. `.env` is gitignored.

## Conventions

- Components are default-export function components; no class components.
- Data fetching lives directly in page components via `useEffect` + `async`
  loader functions. There is no data-fetching library and no shared cache.
- Types are imported with `import type { ... } from '../types/database'`.
- Supabase errors are frequently ignored (`const { data } = await ...`). If you
  touch such a call, prefer handling the error over propagating the pattern.
- Tailwind utility classes inline; no CSS modules beyond `index.css`/`App.css`.

## Knowledge base

`docs/` is the durable memory for this project. Read the relevant directory
before starting work; write back to it when you learn something that the next
session would otherwise rediscover.

| Directory | Purpose | Read it when |
| --- | --- | --- |
| [docs/design-docs/](docs/design-docs/) | Durable design decisions and their rationale | Changing architecture, schema, or a core interaction |
| [docs/learnings/](docs/learnings/) | Bugs, gotchas, and patterns discovered while working | Before debugging or entering an unfamiliar area |
| [docs/plans/active/](docs/plans/active/) | Plans for work in flight | Starting a session — check whether a plan already covers it |
| [docs/plans/completed/](docs/plans/completed/) | Finished plans, kept as a record of what shipped and why | Reconstructing the history of a feature |
| [docs/references/](docs/references/) | Pointers to external docs, dashboards, and specs | Needing Supabase/Vite/Recharts specifics |

Each directory has its own `README.md` describing its format. Follow it.

## Working agreements

- Prefer editing existing files over adding new ones; this codebase is small
  enough that a new abstraction usually costs more than it saves.
- Schema change and type change ship together.
- When a plan in `docs/plans/active/` is done, move it to `completed/` rather
  than deleting it.
- When a session turns up a non-obvious gotcha, write it to `docs/learnings/`
  before finishing.
