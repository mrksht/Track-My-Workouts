-- =============================================
-- Migration 008: Day 4 exercise swaps
-- Data-only (no DDL). Already applied to the live DB via the REST API;
-- this file is the repo record of that change.
-- =============================================
-- Day 4 (Posterior Chain + Power):
--   Plyo Push-ups         -> Incline Plyo Push-ups   (6, 3 sets — unchanged)
--   Bulgarian Split Squat -> Single-Leg Lunges       ('8 each leg', 3 — unchanged)
-- Both targets are new movement variants, so they are added to the library
-- and the Day 4 template rows are repointed. The old exercises are left in
-- the library so past logged sessions stay linked to what was performed.
-- Sets/reps are kept as-is per the request ("just the names").
--
-- Note: the UPDATEs match on the pre-change exercise_ids, so re-running
-- against an already-migrated DB is a harmless no-op. Per-session logs are
-- personal training data and are intentionally not captured here.
-- =============================================

BEGIN;

INSERT INTO exercises (id, name, category, tracking_type, muscle_group) VALUES
  ('a1000001-0000-0000-0000-000000000013', 'Incline Plyo Push-ups', 'explosive', 'bodyweight', 'chest'),
  ('c1000001-0000-0000-0000-000000000014', 'Single-Leg Lunges',     'strength',  'weighted',   'legs')
ON CONFLICT (id) DO NOTHING;

-- Plyo Push-ups -> Incline Plyo Push-ups (keep sets/reps)
UPDATE template_exercises
  SET exercise_id = 'a1000001-0000-0000-0000-000000000013'
  WHERE template_id = 'd0000001-0000-0000-0000-000000000004'
    AND exercise_id = 'a1000001-0000-0000-0000-000000000002';

-- Bulgarian Split Squat -> Single-Leg Lunges (keep sets/reps)
UPDATE template_exercises
  SET exercise_id = 'c1000001-0000-0000-0000-000000000014'
  WHERE template_id = 'd0000001-0000-0000-0000-000000000004'
    AND exercise_id = 'c1000001-0000-0000-0000-000000000007';

COMMIT;
