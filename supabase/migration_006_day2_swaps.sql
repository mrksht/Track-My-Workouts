-- =============================================
-- Migration 006: Day 2 exercise swaps
-- Data-only (no DDL). Already applied to the live DB via the REST API;
-- this file is the repo record of that change.
-- =============================================
-- Day 2 (Upper Body Strength + Shoulder Care):
--   Pull-ups / Assisted      -> Lat Pulldown            (4x8)
--   Cable External Rotations -> Cable Lateral Raises     (3x15)
--   Pallof Press             -> Cable Crunch             (3x15)
--   Side Plank               -> removed
-- Lat Pulldown and Cable Crunch already existed in the library and are
-- reused (history stays linked); only Cable Lateral Raises is new.
--
-- Note: the UPDATE/DELETE statements match on the pre-change exercise_ids,
-- so re-running against an already-migrated DB is a harmless no-op.
-- Per-session log corrections (today's Day 2 session, yesterday's Leg
-- Extensions) are personal training data and are intentionally not captured
-- here — migrations describe the program, not individual logged sessions.
-- =============================================

BEGIN;

INSERT INTO exercises (id, name, category, tracking_type, muscle_group) VALUES
  ('c1000001-0000-0000-0000-000000000012', 'Cable Lateral Raises', 'strength', 'weighted', 'shoulders')
ON CONFLICT (id) DO NOTHING;

-- Pull-ups / Assisted -> Lat Pulldown
UPDATE template_exercises
  SET exercise_id = 'a5000001-0000-0000-0000-000000000004', reps = '8', sets = 4
  WHERE template_id = 'd0000001-0000-0000-0000-000000000002'
    AND exercise_id = 'a1000001-0000-0000-0000-000000000004';

-- Cable External Rotations -> Cable Lateral Raises
UPDATE template_exercises
  SET exercise_id = 'c1000001-0000-0000-0000-000000000012', reps = '15', sets = 3
  WHERE template_id = 'd0000001-0000-0000-0000-000000000002'
    AND exercise_id = 'c1000001-0000-0000-0000-000000000002';

-- Pallof Press -> Cable Crunch
UPDATE template_exercises
  SET exercise_id = 'a2000001-0000-0000-0000-000000000008', reps = '15', sets = 3
  WHERE template_id = 'd0000001-0000-0000-0000-000000000002'
    AND exercise_id = 'c1000001-0000-0000-0000-000000000003';

-- Remove Side Plank
DELETE FROM template_exercises
  WHERE template_id = 'd0000001-0000-0000-0000-000000000002'
    AND exercise_id = 'a3000001-0000-0000-0000-000000000006';

COMMIT;
