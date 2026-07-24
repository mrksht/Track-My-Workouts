-- =============================================
-- Migration 010: Day 5 set normalization
-- Data-only (no DDL). Already applied to the live DB via the REST API;
-- this file is the repo record of that change.
-- =============================================
-- Day 5 (Full-Body Endurance + Mobility): standardize to 3 sets, except
-- Dumbbell Thrusters and Bodyweight Burpees (kept at 4). Incline Treadmill
-- Walk is a single 15-min Zone 2 bout and is intentionally left at 1 set.
--   Bulgarian Split Squat  4 -> 3
--   Incline Dumbbell Press 4 -> 3
--   Kettlebell Swings      4 -> 3
-- (Seated Cable Rows was already 3 from migration 009; no-op here.)
--
-- Note: matches on the pre-change exercise_ids, so re-running against an
-- already-migrated DB is a harmless no-op.
-- =============================================

BEGIN;

UPDATE template_exercises
  SET sets = 3
  WHERE template_id = 'd0000001-0000-0000-0000-000000000005'
    AND exercise_id IN (
      'c1000001-0000-0000-0000-000000000007',  -- Bulgarian Split Squat
      'a4000001-0000-0000-0000-000000000003',  -- Incline Dumbbell Press
      'a5000001-0000-0000-0000-000000000001'   -- Kettlebell Swings
    );

COMMIT;
