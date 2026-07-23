-- =============================================
-- Migration 009: Day 5 exercise swaps + set change
-- Data-only (no DDL). Already applied to the live DB via the REST API;
-- this file is the repo record of that change.
-- =============================================
-- Day 5 (Full-Body Endurance + Mobility):
--   Seated Cable Rows   sets 4 -> 3           (reps '12' unchanged)
--   Push-ups            -> Incline Dumbbell Press  (4x'12-15' unchanged)
--   Weighted Step-ups   -> Bulgarian Split Squat   (4x'10 each leg' unchanged)
--   Battle Ropes        -> Bodyweight Burpees       (4 sets x 10)
-- Incline Dumbbell Press and Bulgarian Split Squat already exist in the
-- library and are reused (history stays linked). Only Bodyweight Burpees is
-- new. The replaced exercises (Push-ups, Weighted Step-ups, Battle Ropes)
-- are left in the library so past logged sessions stay linked to them.
--
-- Note: the UPDATEs match on the pre-change exercise_ids, so re-running
-- against an already-migrated DB is a harmless no-op. Per-session logs are
-- personal training data and are intentionally not captured here.
-- =============================================

BEGIN;

INSERT INTO exercises (id, name, category, tracking_type, muscle_group) VALUES
  ('a1000001-0000-0000-0000-000000000014', 'Bodyweight Burpees', 'cardio', 'bodyweight', 'full body')
ON CONFLICT (id) DO NOTHING;

-- Seated Cable Rows: 4 -> 3 sets (reps unchanged)
UPDATE template_exercises
  SET sets = 3
  WHERE template_id = 'd0000001-0000-0000-0000-000000000005'
    AND exercise_id = 'a1000001-0000-0000-0000-000000000006';

-- Push-ups -> Incline Dumbbell Press (keep sets/reps)
UPDATE template_exercises
  SET exercise_id = 'a4000001-0000-0000-0000-000000000003'
  WHERE template_id = 'd0000001-0000-0000-0000-000000000005'
    AND exercise_id = 'c1000001-0000-0000-0000-000000000010';

-- Weighted Step-ups -> Bulgarian Split Squat (keep sets/reps)
UPDATE template_exercises
  SET exercise_id = 'c1000001-0000-0000-0000-000000000007'
  WHERE template_id = 'd0000001-0000-0000-0000-000000000005'
    AND exercise_id = 'b1000001-0000-0000-0000-000000000002';

-- Battle Ropes -> Bodyweight Burpees (4 sets x 10)
UPDATE template_exercises
  SET exercise_id = 'a1000001-0000-0000-0000-000000000014', sets = 4, reps = '10'
  WHERE template_id = 'd0000001-0000-0000-0000-000000000005'
    AND exercise_id = 'b1000001-0000-0000-0000-000000000001';

COMMIT;
