---
title: Tailwind v4 scans docs/ and tree-shakes unreferenced theme tokens
type: tooling
area: build
date: 2026-07-20
files:
  - src/index.css
---

## Symptom

Two unrelated surprises during the light-theme migration, both stemming from
how Tailwind v4 decides what to emit.

**One.** After removing every `bg-[#0f0f1a]` from the source, the built
stylesheet still contained `.bg-\[\#0f0f1a\]{background-color:#0f0f1a}`. A
repo-wide grep found the string only in `docs/` markdown — the plan and
ideation documents that *describe* removing it.

**Two.** Tokens defined for Recharts and consumed only as `var(--color-chart-line)`
inside TSX props did not exist at runtime. SVG strokes fell back to black with
no build error and no TypeScript warning.

## Cause

**Automatic source detection walks markdown.** v4 dropped the v3 `content:`
array in favour of scanning the project, and it does not restrict itself to
code files. A class name quoted in prose is indistinguishable from a class name
used in a template, so documenting `bg-[#0f0f1a]` generates it.

**`@theme` variables are tree-shaken when no utility class references them.**
This is normally desirable — it keeps `:root` small. But a token consumed only
through `var()` in a JS/TSX string is invisible to the scanner, so it gets
dropped. The failure is silent in both directions: no build error, and an
unresolved `var()` in an SVG presentation attribute renders black rather than
throwing.

## Resolution

Exclude the knowledge base, and force emission for var()-only tokens:

```css
@import "tailwindcss";
@source not "../docs";

@theme static {
  --color-chart-line: var(--sky-700);
  /* ... every token consumed only as var() in TSX ... */
}
```

Verified by grepping the built CSS in `dist/assets/` for each token name after
a clean build. All seven chart tokens emit under `static`; under plain `@theme`
they did not.

## How to recognize it again

If a color appears in the built stylesheet but nowhere in `src/`, grep the
whole repo including markdown before assuming a stale build.

If a `var(--color-*)` resolves to nothing at runtime — black stroke, invisible
element, transparent fill — check whether any utility class references that
token. If none does, it was tree-shaken and needs `@theme static`.

Useful namespace traps, all silent when wrong: font *size* is `--text-*` while
`--font-*` is family only; radius is `--radius-*`, not `--border-radius-*`. A
variable in an unrecognized namespace is dropped entirely and is not even
emitted to `:root`.

Avoid `@theme inline` for the semantic tier — it bakes values in at build time
and never emits the semantic variable, which removes the only seam a future
dark mode could override. See [[light-theme-token-architecture]].
