-- =============================================
-- Migration 002: Remove RPE, Fix Pull-ups tracking type
-- Run this in Supabase SQL Editor ONCE
-- =============================================

-- 1. Reclassify "Pull-ups / Assisted" from bodyweight → weighted
UPDATE exercises
SET tracking_type = 'weighted'
WHERE id = 'a1000001-0000-0000-0000-000000000004';

-- 2. Migrate hacked pull-up set data:
--    User stored assistance weight (55) in reps field.
--    Move reps → weight_kg, set reps to 0 (user can correct manually).
UPDATE exercise_sets
SET weight_kg = reps,
    reps = 0
WHERE session_exercise_id IN (
  SELECT id FROM session_exercises
  WHERE exercise_id = 'a1000001-0000-0000-0000-000000000004'
);

-- 3. Drop the RPE column entirely
ALTER TABLE exercise_sets DROP COLUMN IF EXISTS rpe;
