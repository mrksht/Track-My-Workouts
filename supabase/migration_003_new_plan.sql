-- =============================================
-- Migration 003: New 5-Day Athletic / Trek-Prep Plan
-- Run this in Supabase SQL Editor ONCE
-- =============================================
-- Restructures:
--   Day 1 → Lower Body Athletic
--   Day 2 → Upper Body + Conditioning
--   Day 3 → Functional Power (Trek)
--   Day 4 → Posterior Chain + Power
--   Day 5 → Hybrid Endurance + Athletic
-- =============================================

BEGIN;

-- ============ NEW EXERCISES ============

INSERT INTO exercises (id, name, category, tracking_type, muscle_group) VALUES
  ('b1000001-0000-0000-0000-000000000001', 'Battle Ropes',                'explosive', 'timed',      'full body'),
  ('b1000001-0000-0000-0000-000000000002', 'Weighted Step-ups',           'strength',  'weighted',    'legs'),
  ('b1000001-0000-0000-0000-000000000003', 'Stairmaster',                 'cardio',    'timed',       'legs'),
  ('b1000001-0000-0000-0000-000000000004', 'Jump Lunges',                 'explosive', 'bodyweight',  'legs'),
  ('b1000001-0000-0000-0000-000000000005', 'Hip Thrusts',                 'strength',  'weighted',    'legs'),
  ('b1000001-0000-0000-0000-000000000006', 'Broad Jumps',                 'explosive', 'bodyweight',  'legs'),
  ('b1000001-0000-0000-0000-000000000007', 'Leg Press',                   'strength',  'weighted',    'legs'),
  ('b1000001-0000-0000-0000-000000000008', 'Brisk Walk (Backpack Optional)', 'cardio', 'timed',       'full body'),
  ('b1000001-0000-0000-0000-000000000009', 'Agility Ladder / Fast Feet',  'explosive', 'timed',       'legs'),
  ('b1000001-0000-0000-0000-000000000010', 'Mountain Climbers',           'explosive', 'timed',       'full body')
ON CONFLICT (id) DO NOTHING;


-- ============ UPDATE DAY TEMPLATES ============

UPDATE day_templates SET name = 'Lower Body Athletic',
  description = 'Barbell squats, calf raises, incline treadmill, jump squats, box jumps'
  WHERE day_number = 1;

UPDATE day_templates SET name = 'Upper Body + Conditioning',
  description = 'Bench press, lat pulldown, rowing intervals, battle ropes, med-ball slams'
  WHERE day_number = 2;

UPDATE day_templates SET name = 'Functional Power (Trek)',
  description = 'Weighted step-ups, walking lunges, stairmaster, jump lunges, hill sprints'
  WHERE day_number = 3;

UPDATE day_templates SET name = 'Posterior Chain + Power',
  description = 'Deadlifts, hip thrusts, incline treadmill/cycling, kettlebell swings, broad jumps'
  WHERE day_number = 4;

UPDATE day_templates SET name = 'Hybrid Endurance + Athletic',
  description = 'Leg press, core circuit, brisk walk, agility ladder, mountain climbers'
  WHERE day_number = 5;


-- ============ REPLACE TEMPLATE EXERCISES ============

-- Clear old template exercises
DELETE FROM template_exercises;

-- Day 1: Lower Body Athletic
INSERT INTO template_exercises (template_id, exercise_id, section, sets, reps, sort_order) VALUES
  -- Strength (15 min)
  ((SELECT id FROM day_templates WHERE day_number = 1), 'a2000001-0000-0000-0000-000000000003', 'strength',  4, '6',     1),  -- Barbell Squats
  ((SELECT id FROM day_templates WHERE day_number = 1), 'a2000001-0000-0000-0000-000000000006', 'strength',  3, '15',    2),  -- Calf Raises
  -- Cardio (15 min)
  ((SELECT id FROM day_templates WHERE day_number = 1), 'a3000001-0000-0000-0000-000000000008', 'cardio',    1, '15 min steady climb', 3),  -- Incline Treadmill
  -- Explosiveness (10 min)
  ((SELECT id FROM day_templates WHERE day_number = 1), 'a2000001-0000-0000-0000-000000000002', 'explosive', 3, '10',    4),  -- Jump Squats
  ((SELECT id FROM day_templates WHERE day_number = 1), 'a2000001-0000-0000-0000-000000000001', 'explosive', 3, '8',     5);  -- Box Jumps

-- Day 2: Upper Body + Conditioning
INSERT INTO template_exercises (template_id, exercise_id, section, sets, reps, sort_order) VALUES
  -- Strength (15 min)
  ((SELECT id FROM day_templates WHERE day_number = 2), 'a1000001-0000-0000-0000-000000000003', 'strength',  3, '6-8',   1),  -- Bench Press
  ((SELECT id FROM day_templates WHERE day_number = 2), 'a5000001-0000-0000-0000-000000000004', 'strength',  3, '8-10',  2),  -- Lat Pulldown
  -- Cardio (15 min)
  ((SELECT id FROM day_templates WHERE day_number = 2), 'a5000001-0000-0000-0000-000000000009', 'cardio',    1, '1 min fast / 1 min slow intervals', 3),  -- Rowing Machine Intervals
  -- Explosiveness (10 min)
  ((SELECT id FROM day_templates WHERE day_number = 2), 'b1000001-0000-0000-0000-000000000001', 'explosive', 6, '30 sec', 4),  -- Battle Ropes
  ((SELECT id FROM day_templates WHERE day_number = 2), 'a4000001-0000-0000-0000-000000000001', 'explosive', 3, '10',    5);  -- Medicine Ball Slams

-- Day 3: Functional Power (Trek)
INSERT INTO template_exercises (template_id, exercise_id, section, sets, reps, sort_order) VALUES
  -- Strength (15 min)
  ((SELECT id FROM day_templates WHERE day_number = 3), 'b1000001-0000-0000-0000-000000000002', 'strength',  3, '10 each leg', 1),  -- Weighted Step-ups
  ((SELECT id FROM day_templates WHERE day_number = 3), 'a2000001-0000-0000-0000-000000000005', 'strength',  3, '12 each leg', 2),  -- Walking Lunges
  -- Cardio (15 min)
  ((SELECT id FROM day_templates WHERE day_number = 3), 'b1000001-0000-0000-0000-000000000003', 'cardio',    1, '15 min steady', 3),  -- Stairmaster
  -- Explosiveness (10 min)
  ((SELECT id FROM day_templates WHERE day_number = 3), 'b1000001-0000-0000-0000-000000000004', 'explosive', 3, '8 each leg',   4),  -- Jump Lunges
  ((SELECT id FROM day_templates WHERE day_number = 3), 'a5000001-0000-0000-0000-000000000002', 'explosive', 5, '1 round',      5);  -- Hill Sprints / Treadmill Sprint

-- Day 4: Posterior Chain + Power
INSERT INTO template_exercises (template_id, exercise_id, section, sets, reps, sort_order) VALUES
  -- Strength (15 min)
  ((SELECT id FROM day_templates WHERE day_number = 4), 'a5000001-0000-0000-0000-000000000003', 'strength',  4, '5',     1),  -- Deadlifts
  ((SELECT id FROM day_templates WHERE day_number = 4), 'b1000001-0000-0000-0000-000000000005', 'strength',  3, '10',    2),  -- Hip Thrusts
  -- Cardio (15 min)
  ((SELECT id FROM day_templates WHERE day_number = 4), 'a3000001-0000-0000-0000-000000000008', 'cardio',    1, '15 min incline / cycling', 3),  -- Incline Treadmill / Cycling
  -- Explosiveness (10 min)
  ((SELECT id FROM day_templates WHERE day_number = 4), 'a5000001-0000-0000-0000-000000000001', 'explosive', 3, '15',    4),  -- Kettlebell Swings
  ((SELECT id FROM day_templates WHERE day_number = 4), 'b1000001-0000-0000-0000-000000000006', 'explosive', 3, '6',     5);  -- Broad Jumps

-- Day 5: Hybrid Endurance + Athletic
INSERT INTO template_exercises (template_id, exercise_id, section, sets, reps, sort_order) VALUES
  -- Strength (15 min)
  ((SELECT id FROM day_templates WHERE day_number = 5), 'b1000001-0000-0000-0000-000000000007', 'strength',  3, '10',    1),  -- Leg Press
  -- Core (part of strength block)
  ((SELECT id FROM day_templates WHERE day_number = 5), 'a2000001-0000-0000-0000-000000000007', 'core',      1, '2.5 min', 2),  -- Plank
  ((SELECT id FROM day_templates WHERE day_number = 5), 'a1000001-0000-0000-0000-000000000007', 'core',      1, '2.5 min', 3),  -- Hanging Leg Raises
  -- Cardio (15 min)
  ((SELECT id FROM day_templates WHERE day_number = 5), 'b1000001-0000-0000-0000-000000000008', 'cardio',    1, '15 min continuous', 4),  -- Brisk Walk
  -- Explosiveness (10 min)
  ((SELECT id FROM day_templates WHERE day_number = 5), 'b1000001-0000-0000-0000-000000000009', 'explosive', 1, '10 min drills', 5),  -- Agility Ladder / Fast Feet
  ((SELECT id FROM day_templates WHERE day_number = 5), 'b1000001-0000-0000-0000-000000000010', 'explosive', 6, '30 sec', 6);  -- Mountain Climbers

COMMIT;
