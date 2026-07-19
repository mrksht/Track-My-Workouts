-- =============================================
-- Track My Workout - Seed Data
-- Run this AFTER migration.sql in Supabase SQL Editor
-- =============================================

-- ============ EXERCISES ============
-- Reused from previous plan + new exercises for the athletic/trek plan

-- Shared exercises (used across multiple days)
insert into exercises (id, name, category, tracking_type, muscle_group) values
  ('a1000001-0000-0000-0000-000000000003', 'Bench Press', 'strength', 'weighted', 'chest'),
  ('a1000001-0000-0000-0000-000000000007', 'Hanging Leg Raises', 'core', 'bodyweight', 'abs'),
  ('a2000001-0000-0000-0000-000000000001', 'Box Jumps', 'explosive', 'bodyweight', 'legs'),
  ('a2000001-0000-0000-0000-000000000002', 'Jump Squats', 'explosive', 'weighted', 'legs'),
  ('a2000001-0000-0000-0000-000000000003', 'Barbell Squats', 'strength', 'weighted', 'legs'),
  ('a2000001-0000-0000-0000-000000000005', 'Walking Lunges', 'strength', 'weighted', 'legs'),
  ('a2000001-0000-0000-0000-000000000006', 'Calf Raises', 'strength', 'weighted', 'legs'),
  ('a2000001-0000-0000-0000-000000000007', 'Plank', 'core', 'timed', 'abs'),
  ('a3000001-0000-0000-0000-000000000008', 'Incline Treadmill Walk', 'cardio', 'timed', 'full body'),
  ('a4000001-0000-0000-0000-000000000001', 'Medicine Ball Slams', 'explosive', 'weighted', 'full body'),
  ('a5000001-0000-0000-0000-000000000001', 'Kettlebell Swings', 'explosive', 'weighted', 'full body'),
  ('a5000001-0000-0000-0000-000000000002', 'Treadmill Sprint Starts', 'explosive', 'timed', 'legs'),
  ('a5000001-0000-0000-0000-000000000003', 'Deadlifts', 'strength', 'weighted', 'back'),
  ('a5000001-0000-0000-0000-000000000004', 'Lat Pulldown', 'strength', 'weighted', 'back'),
  ('a5000001-0000-0000-0000-000000000009', 'Rowing Machine Intervals', 'finisher', 'timed', 'full body')
ON CONFLICT (id) DO NOTHING;

-- New exercises for the athletic/trek plan
insert into exercises (id, name, category, tracking_type, muscle_group) values
  ('b1000001-0000-0000-0000-000000000001', 'Battle Ropes', 'explosive', 'timed', 'full body'),
  ('b1000001-0000-0000-0000-000000000002', 'Weighted Step-ups', 'strength', 'weighted', 'legs'),
  ('b1000001-0000-0000-0000-000000000003', 'Stairmaster', 'cardio', 'timed', 'legs'),
  ('b1000001-0000-0000-0000-000000000004', 'Jump Lunges', 'explosive', 'bodyweight', 'legs'),
  ('b1000001-0000-0000-0000-000000000005', 'Hip Thrusts', 'strength', 'weighted', 'legs'),
  ('b1000001-0000-0000-0000-000000000006', 'Broad Jumps', 'explosive', 'bodyweight', 'legs'),
  ('b1000001-0000-0000-0000-000000000007', 'Leg Press', 'strength', 'weighted', 'legs'),
  ('b1000001-0000-0000-0000-000000000008', 'Brisk Walk (Backpack Optional)', 'cardio', 'timed', 'full body'),
  ('b1000001-0000-0000-0000-000000000009', 'Agility Ladder / Fast Feet', 'explosive', 'timed', 'legs'),
  ('b1000001-0000-0000-0000-000000000010', 'Mountain Climbers', 'explosive', 'timed', 'full body')
ON CONFLICT (id) DO NOTHING;


-- ============ DAY TEMPLATES ============

insert into day_templates (id, day_number, name, description) values
  ('d0000001-0000-0000-0000-000000000001', 1, 'Lower Body Athletic', 'Barbell squats, calf raises, incline treadmill, jump squats, box jumps'),
  ('d0000001-0000-0000-0000-000000000002', 2, 'Upper Body + Conditioning', 'Bench press, lat pulldown, rowing intervals, battle ropes, med-ball slams'),
  ('d0000001-0000-0000-0000-000000000003', 3, 'Functional Power (Trek)', 'Weighted step-ups, walking lunges, stairmaster, jump lunges, hill sprints'),
  ('d0000001-0000-0000-0000-000000000004', 4, 'Posterior Chain + Power', 'Deadlifts, hip thrusts, incline treadmill/cycling, kettlebell swings, broad jumps'),
  ('d0000001-0000-0000-0000-000000000005', 5, 'Hybrid Endurance + Athletic', 'Leg press, core circuit, brisk walk, agility ladder, mountain climbers')
ON CONFLICT (id) DO NOTHING;


-- ============ TEMPLATE EXERCISES ============
-- Clear existing to avoid duplicates on re-run
DELETE FROM template_exercises;

-- Day 1: Lower Body Athletic
insert into template_exercises (template_id, exercise_id, section, sets, reps, sort_order) values
  ('d0000001-0000-0000-0000-000000000001', 'a2000001-0000-0000-0000-000000000003', 'strength',  4, '6',     1),  -- Barbell Squats
  ('d0000001-0000-0000-0000-000000000001', 'a2000001-0000-0000-0000-000000000006', 'strength',  3, '15',    2),  -- Calf Raises
  ('d0000001-0000-0000-0000-000000000001', 'a3000001-0000-0000-0000-000000000008', 'cardio',    1, '15 min steady climb', 3),  -- Incline Treadmill
  ('d0000001-0000-0000-0000-000000000001', 'a2000001-0000-0000-0000-000000000002', 'explosive', 3, '10',    4),  -- Jump Squats
  ('d0000001-0000-0000-0000-000000000001', 'a2000001-0000-0000-0000-000000000001', 'explosive', 3, '8',     5);  -- Box Jumps

-- Day 2: Upper Body + Conditioning
insert into template_exercises (template_id, exercise_id, section, sets, reps, sort_order) values
  ('d0000001-0000-0000-0000-000000000002', 'a1000001-0000-0000-0000-000000000003', 'strength',  3, '6-8',   1),  -- Bench Press
  ('d0000001-0000-0000-0000-000000000002', 'a5000001-0000-0000-0000-000000000004', 'strength',  3, '8-10',  2),  -- Lat Pulldown
  ('d0000001-0000-0000-0000-000000000002', 'a5000001-0000-0000-0000-000000000009', 'cardio',    1, '1 min fast / 1 min slow intervals', 3),  -- Rowing Machine
  ('d0000001-0000-0000-0000-000000000002', 'b1000001-0000-0000-0000-000000000001', 'explosive', 6, '30 sec', 4),  -- Battle Ropes
  ('d0000001-0000-0000-0000-000000000002', 'a4000001-0000-0000-0000-000000000001', 'explosive', 3, '10',    5);  -- Medicine Ball Slams

-- Day 3: Functional Power (Trek)
insert into template_exercises (template_id, exercise_id, section, sets, reps, sort_order) values
  ('d0000001-0000-0000-0000-000000000003', 'b1000001-0000-0000-0000-000000000002', 'strength',  3, '10 each leg', 1),  -- Weighted Step-ups
  ('d0000001-0000-0000-0000-000000000003', 'a2000001-0000-0000-0000-000000000005', 'strength',  3, '12 each leg', 2),  -- Walking Lunges
  ('d0000001-0000-0000-0000-000000000003', 'b1000001-0000-0000-0000-000000000003', 'cardio',    1, '15 min steady', 3),  -- Stairmaster
  ('d0000001-0000-0000-0000-000000000003', 'b1000001-0000-0000-0000-000000000004', 'explosive', 3, '8 each leg',   4),  -- Jump Lunges
  ('d0000001-0000-0000-0000-000000000003', 'a5000001-0000-0000-0000-000000000002', 'explosive', 5, '1 round',      5);  -- Hill Sprints

-- Day 4: Posterior Chain + Power
insert into template_exercises (template_id, exercise_id, section, sets, reps, sort_order) values
  ('d0000001-0000-0000-0000-000000000004', 'a5000001-0000-0000-0000-000000000003', 'strength',  4, '5',     1),  -- Deadlifts
  ('d0000001-0000-0000-0000-000000000004', 'b1000001-0000-0000-0000-000000000005', 'strength',  3, '10',    2),  -- Hip Thrusts
  ('d0000001-0000-0000-0000-000000000004', 'a3000001-0000-0000-0000-000000000008', 'cardio',    1, '15 min incline / cycling', 3),  -- Incline Treadmill / Cycling
  ('d0000001-0000-0000-0000-000000000004', 'a5000001-0000-0000-0000-000000000001', 'explosive', 3, '15',    4),  -- Kettlebell Swings
  ('d0000001-0000-0000-0000-000000000004', 'b1000001-0000-0000-0000-000000000006', 'explosive', 3, '6',     5);  -- Broad Jumps

-- Day 5: Hybrid Endurance + Athletic
insert into template_exercises (template_id, exercise_id, section, sets, reps, sort_order) values
  ('d0000001-0000-0000-0000-000000000005', 'b1000001-0000-0000-0000-000000000007', 'strength',  3, '10',    1),  -- Leg Press
  ('d0000001-0000-0000-0000-000000000005', 'a2000001-0000-0000-0000-000000000007', 'core',      1, '2.5 min', 2),  -- Plank
  ('d0000001-0000-0000-0000-000000000005', 'a1000001-0000-0000-0000-000000000007', 'core',      1, '2.5 min', 3),  -- Hanging Leg Raises
  ('d0000001-0000-0000-0000-000000000005', 'b1000001-0000-0000-0000-000000000008', 'cardio',    1, '15 min continuous', 4),  -- Brisk Walk
  ('d0000001-0000-0000-0000-000000000005', 'b1000001-0000-0000-0000-000000000009', 'explosive', 1, '10 min drills', 5),  -- Agility Ladder / Fast Feet
  ('d0000001-0000-0000-0000-000000000005', 'b1000001-0000-0000-0000-000000000010', 'explosive', 6, '30 sec', 6);  -- Mountain Climbers
