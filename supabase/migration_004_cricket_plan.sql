-- =============================================
-- Migration 004: 5-Day Cricket Gym Plan
-- Run this in the Supabase SQL Editor ONCE.
-- Supersedes migration_003 (the trek-prep plan).
-- =============================================
-- Prerequisites: migration.sql (base schema) must exist. Safe to run on top
-- of migration_003; it replaces all template_exercises and rewrites the five
-- day_templates. Existing workout_sessions / exercise_sets are untouched, so
-- logged history and progress charts are preserved.
--
-- Restructures the week to:
--   Day 1 -> Lower Body Strength + Sprint Power
--   Day 2 -> Upper Body Strength + Shoulder Care
--   Day 3 -> Conditioning + Agility + Core
--   Day 4 -> Power + Rotational Strength
--   Day 5 -> Full-Body Endurance + Mobility
--
-- Adds a first-class 'agility' section/category for cricket footwork work.
-- Per-day warm-ups and cooldowns live in the template description, not as
-- tracked exercises, to keep each session's logging list short.
-- =============================================

BEGIN;

-- ---- 1. Allow the new 'agility' value on both constrained columns ----
-- The base schema declares these CHECKs inline, so Postgres auto-named them
-- <table>_<column>_check. Drop and re-add with 'agility' included.
ALTER TABLE exercises DROP CONSTRAINT IF EXISTS exercises_category_check;
ALTER TABLE exercises ADD CONSTRAINT exercises_category_check
  CHECK (category IN ('explosive','strength','core','cardio','mobility','finisher','warmup','agility'));

ALTER TABLE template_exercises DROP CONSTRAINT IF EXISTS template_exercises_section_check;
ALTER TABLE template_exercises ADD CONSTRAINT template_exercises_section_check
  CHECK (section IN ('explosive','strength','core','finisher','cardio','mobility','stretch','agility'));

-- ---- 2. New exercises for the cricket plan ----
INSERT INTO exercises (id, name, category, tracking_type, muscle_group) VALUES
  ('c1000001-0000-0000-0000-000000000001', 'Single-Arm Dumbbell Row',        'strength',  'weighted',   'back'),
  ('c1000001-0000-0000-0000-000000000002', 'Cable External Rotations',       'strength',  'weighted',   'shoulders'),
  ('c1000001-0000-0000-0000-000000000003', 'Pallof Press',                   'core',      'weighted',   'abs'),
  ('c1000001-0000-0000-0000-000000000004', 'Lateral Shuffles',               'agility',   'timed',      'legs'),
  ('c1000001-0000-0000-0000-000000000005', 'Cone Sprint + Backpedal',        'agility',   'timed',      'legs'),
  ('c1000001-0000-0000-0000-000000000006', 'Medicine Ball Rotational Throws','explosive', 'weighted',   'abs'),
  ('c1000001-0000-0000-0000-000000000007', 'Bulgarian Split Squat',          'strength',  'weighted',   'legs'),
  ('c1000001-0000-0000-0000-000000000008', 'Farmer''s Carries',              'strength',  'weighted',   'full body'),
  ('c1000001-0000-0000-0000-000000000009', 'Dumbbell Thrusters',             'strength',  'weighted',   'full body'),
  ('c1000001-0000-0000-0000-000000000010', 'Push-ups',                       'strength',  'bodyweight', 'chest')
ON CONFLICT (id) DO NOTHING;

-- ---- 3. Reclassify existing footwork movements as agility ----
UPDATE exercises SET category = 'agility'
  WHERE id IN (
    'a4000001-0000-0000-0000-000000000009',  -- Shuttle Runs
    'b1000001-0000-0000-0000-000000000009'   -- Agility Ladder / Fast Feet
  );

-- ---- 4. Rewrite the five day templates ----
UPDATE day_templates SET name = 'Lower Body Strength + Sprint Power',
  description = 'Squats, RDLs, lunges, calf raises, box jumps, sprint intervals. WU: 5min jog + dynamic mobility. CD: hamstring, quad, hip, calf stretches.'
  WHERE day_number = 1;

UPDATE day_templates SET name = 'Upper Body Strength + Shoulder Care',
  description = 'Bench, pull-ups, DB rows, shoulder press, face pulls, external rotations, core. WU: 5min row + band shoulder prep. CD: chest, lat, shoulder stretches.'
  WHERE day_number = 2;

UPDATE day_templates SET name = 'Conditioning + Agility + Core',
  description = 'Lateral shuffles, shuttles, cone drills, ladder, rowing intervals, core. WU: 5min bike + dynamic drills. CD: full-body stretch.'
  WHERE day_number = 3;

UPDATE day_templates SET name = 'Power + Rotational Strength',
  description = 'Med-ball throws, KB swings, jump squats, plyo push-ups, deadlifts, split squats, cable rows, carries. WU: row + mobility. CD: hips, t-spine, hamstrings.'
  WHERE day_number = 4;

UPDATE day_templates SET name = 'Full-Body Endurance + Mobility',
  description = '4-round circuit: thrusters, rows, step-ups, push-ups, KB swings, ropes. Then 15min Zone 2 cardio. WU: easy cardio + mobility. CD: full-body stretch.'
  WHERE day_number = 5;

-- ---- 5. Replace all template exercises ----
DELETE FROM template_exercises;

INSERT INTO template_exercises (template_id, exercise_id, section, sets, reps, sort_order) VALUES
  -- ===== Day 1: Lower Body Strength + Sprint Power =====
  ((SELECT id FROM day_templates WHERE day_number = 1), 'a2000001-0000-0000-0000-000000000003', 'strength',  4, '5',                   1),  -- Barbell Squats
  ((SELECT id FROM day_templates WHERE day_number = 1), 'a2000001-0000-0000-0000-000000000004', 'strength',  3, '8',                   2),  -- Romanian Deadlifts
  ((SELECT id FROM day_templates WHERE day_number = 1), 'a2000001-0000-0000-0000-000000000005', 'strength',  3, '10 each leg',         3),  -- Walking Lunges
  ((SELECT id FROM day_templates WHERE day_number = 1), 'a2000001-0000-0000-0000-000000000006', 'strength',  3, '15',                  4),  -- Calf Raises
  ((SELECT id FROM day_templates WHERE day_number = 1), 'a2000001-0000-0000-0000-000000000001', 'explosive', 4, '4',                   5),  -- Box Jumps
  ((SELECT id FROM day_templates WHERE day_number = 1), 'a1000001-0000-0000-0000-000000000009', 'finisher',  10,'20s hard / 40s easy', 6),  -- Assault Bike / Rower Intervals

  -- ===== Day 2: Upper Body Strength + Shoulder Care =====
  ((SELECT id FROM day_templates WHERE day_number = 2), 'a1000001-0000-0000-0000-000000000003', 'strength',  4, '6',                   1),  -- Bench Press
  ((SELECT id FROM day_templates WHERE day_number = 2), 'a1000001-0000-0000-0000-000000000004', 'strength',  4, '8',                   2),  -- Pull-ups / Assisted
  ((SELECT id FROM day_templates WHERE day_number = 2), 'c1000001-0000-0000-0000-000000000001', 'strength',  3, '10 each side',        3),  -- Single-Arm Dumbbell Row
  ((SELECT id FROM day_templates WHERE day_number = 2), 'a4000001-0000-0000-0000-000000000005', 'strength',  3, '8',                   4),  -- Shoulder Press
  ((SELECT id FROM day_templates WHERE day_number = 2), 'a5000001-0000-0000-0000-000000000006', 'strength',  3, '15',                  5),  -- Face Pulls
  ((SELECT id FROM day_templates WHERE day_number = 2), 'c1000001-0000-0000-0000-000000000002', 'strength',  3, '12 each arm',         6),  -- Cable External Rotations
  ((SELECT id FROM day_templates WHERE day_number = 2), 'c1000001-0000-0000-0000-000000000003', 'core',      3, '12 each side',        7),  -- Pallof Press
  ((SELECT id FROM day_templates WHERE day_number = 2), 'a3000001-0000-0000-0000-000000000005', 'core',      3, '10 each side',        8),  -- Dead Bugs
  ((SELECT id FROM day_templates WHERE day_number = 2), 'a3000001-0000-0000-0000-000000000006', 'core',      2, '30-45s each side',    9),  -- Side Plank

  -- ===== Day 3: Conditioning + Agility + Core =====
  ((SELECT id FROM day_templates WHERE day_number = 3), 'c1000001-0000-0000-0000-000000000004', 'agility',   4, '20 sec',              1),  -- Lateral Shuffles
  ((SELECT id FROM day_templates WHERE day_number = 3), 'a4000001-0000-0000-0000-000000000009', 'agility',   5, '5-10-5 rounds',       2),  -- Shuttle Runs
  ((SELECT id FROM day_templates WHERE day_number = 3), 'c1000001-0000-0000-0000-000000000005', 'agility',   5, 'rounds',              3),  -- Cone Sprint + Backpedal
  ((SELECT id FROM day_templates WHERE day_number = 3), 'b1000001-0000-0000-0000-000000000009', 'agility',   1, '5 min drills',        4),  -- Agility Ladder / Fast Feet
  ((SELECT id FROM day_templates WHERE day_number = 3), 'a5000001-0000-0000-0000-000000000009', 'cardio',    5, '500m hard, 90s rest', 5),  -- Rowing Machine Intervals
  ((SELECT id FROM day_templates WHERE day_number = 3), 'a5000001-0000-0000-0000-000000000007', 'core',      3, '10',                  6),  -- Hanging Knee Raises
  ((SELECT id FROM day_templates WHERE day_number = 3), 'a1000001-0000-0000-0000-000000000008', 'core',      3, '20',                  7),  -- Russian Twists
  ((SELECT id FROM day_templates WHERE day_number = 3), 'a4000001-0000-0000-0000-000000000008', 'core',      3, '20',                  8),  -- Plank Shoulder Taps

  -- ===== Day 4: Power + Rotational Strength =====
  ((SELECT id FROM day_templates WHERE day_number = 4), 'c1000001-0000-0000-0000-000000000006', 'explosive', 4, '6 each side',         1),  -- Medicine Ball Rotational Throws
  ((SELECT id FROM day_templates WHERE day_number = 4), 'a5000001-0000-0000-0000-000000000001', 'explosive', 4, '10',                  2),  -- Kettlebell Swings
  ((SELECT id FROM day_templates WHERE day_number = 4), 'a2000001-0000-0000-0000-000000000002', 'explosive', 3, '5',                   3),  -- Jump Squats (Light Weight)
  ((SELECT id FROM day_templates WHERE day_number = 4), 'a1000001-0000-0000-0000-000000000002', 'explosive', 3, '6',                   4),  -- Plyo Push-ups
  ((SELECT id FROM day_templates WHERE day_number = 4), 'a5000001-0000-0000-0000-000000000003', 'strength',  4, '4',                   5),  -- Deadlifts
  ((SELECT id FROM day_templates WHERE day_number = 4), 'c1000001-0000-0000-0000-000000000007', 'strength',  3, '8 each leg',          6),  -- Bulgarian Split Squat
  ((SELECT id FROM day_templates WHERE day_number = 4), 'a1000001-0000-0000-0000-000000000006', 'strength',  3, '10',                  7),  -- Seated Cable Rows
  ((SELECT id FROM day_templates WHERE day_number = 4), 'c1000001-0000-0000-0000-000000000008', 'strength',  4, '30-40m',              8),  -- Farmer's Carries

  -- ===== Day 5: Full-Body Endurance + Mobility (4-round circuit) =====
  ((SELECT id FROM day_templates WHERE day_number = 5), 'c1000001-0000-0000-0000-000000000009', 'strength',  4, '10',                  1),  -- Dumbbell Thrusters
  ((SELECT id FROM day_templates WHERE day_number = 5), 'a1000001-0000-0000-0000-000000000006', 'strength',  4, '12',                  2),  -- Seated Cable Rows
  ((SELECT id FROM day_templates WHERE day_number = 5), 'b1000001-0000-0000-0000-000000000002', 'strength',  4, '10 each leg',         3),  -- Weighted Step-ups
  ((SELECT id FROM day_templates WHERE day_number = 5), 'c1000001-0000-0000-0000-000000000010', 'strength',  4, '12-15',               4),  -- Push-ups
  ((SELECT id FROM day_templates WHERE day_number = 5), 'a5000001-0000-0000-0000-000000000001', 'strength',  4, '12',                  5),  -- Kettlebell Swings
  ((SELECT id FROM day_templates WHERE day_number = 5), 'b1000001-0000-0000-0000-000000000001', 'cardio',    4, '30 sec',              6),  -- Battle Ropes
  ((SELECT id FROM day_templates WHERE day_number = 5), 'a3000001-0000-0000-0000-000000000008', 'cardio',    1, '15 min Zone 2',       7);  -- Incline Treadmill Walk

COMMIT;
