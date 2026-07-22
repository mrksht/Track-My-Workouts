-- =============================================
-- Migration 007: Day 3 exercise swap
-- Data-only (no DDL). Already applied to the live DB via the REST API;
-- this file is the repo record of that change.
-- =============================================
-- Day 3 (Conditioning + Agility + Core):
--   Hanging Knee Raises -> Dead Bugs   (reps unchanged)
-- Dead Bugs already exists in the library (a3000001-...-005, also used on
-- Day 2) and is reused, so logged history stays linked. Only the exercise
-- name changes; sets/reps ('10', 3) are kept as-is per the request.
--
-- Note: the UPDATE matches on the pre-change exercise_id, so re-running
-- against an already-migrated DB is a harmless no-op. Per-session logs are
-- personal training data and are intentionally not captured here.
-- =============================================

BEGIN;

-- Hanging Knee Raises -> Dead Bugs (keep reps/sets)
UPDATE template_exercises
  SET exercise_id = 'a3000001-0000-0000-0000-000000000005'
  WHERE template_id = 'd0000001-0000-0000-0000-000000000003'
    AND exercise_id = 'a5000001-0000-0000-0000-000000000007';

COMMIT;
