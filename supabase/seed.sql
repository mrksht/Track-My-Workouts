-- =============================================
-- Track My Workout - Seed Data
-- Run this AFTER migration.sql in Supabase SQL Editor
-- =============================================

-- ============ EXERCISES ============

-- Day 1: Upper Body Strength + Power
insert into exercises (id, name, category, tracking_type, muscle_group) values
  ('a1000001-0000-0000-0000-000000000001', 'Medicine Ball Chest Throws', 'explosive', 'weighted', 'chest'),
  ('a1000001-0000-0000-0000-000000000002', 'Plyo Push-ups', 'explosive', 'bodyweight', 'chest'),
  ('a1000001-0000-0000-0000-000000000003', 'Bench Press', 'strength', 'weighted', 'chest'),
  ('a1000001-0000-0000-0000-000000000004', 'Pull-ups / Assisted', 'strength', 'bodyweight', 'back'),
  ('a1000001-0000-0000-0000-000000000005', 'Overhead Press', 'strength', 'weighted', 'shoulders'),
  ('a1000001-0000-0000-0000-000000000006', 'Seated Cable Rows', 'strength', 'weighted', 'back'),
  ('a1000001-0000-0000-0000-000000000007', 'Hanging Leg Raises', 'core', 'bodyweight', 'abs'),
  ('a1000001-0000-0000-0000-000000000008', 'Russian Twists', 'core', 'weighted', 'abs'),
  ('a1000001-0000-0000-0000-000000000009', 'Assault Bike / Rower Intervals', 'finisher', 'timed', 'full body');

-- Day 2: Lower Body Strength + Explosiveness
insert into exercises (id, name, category, tracking_type, muscle_group) values
  ('a2000001-0000-0000-0000-000000000001', 'Box Jumps', 'explosive', 'bodyweight', 'legs'),
  ('a2000001-0000-0000-0000-000000000002', 'Jump Squats (Light Weight)', 'explosive', 'weighted', 'legs'),
  ('a2000001-0000-0000-0000-000000000003', 'Barbell Squats', 'strength', 'weighted', 'legs'),
  ('a2000001-0000-0000-0000-000000000004', 'Romanian Deadlifts', 'strength', 'weighted', 'legs'),
  ('a2000001-0000-0000-0000-000000000005', 'Walking Lunges', 'strength', 'weighted', 'legs'),
  ('a2000001-0000-0000-0000-000000000006', 'Calf Raises', 'strength', 'weighted', 'legs'),
  ('a2000001-0000-0000-0000-000000000007', 'Plank', 'core', 'timed', 'abs'),
  ('a2000001-0000-0000-0000-000000000008', 'Cable Crunch', 'core', 'weighted', 'abs'),
  ('a2000001-0000-0000-0000-000000000009', 'Treadmill Intervals', 'finisher', 'timed', 'full body');

-- Day 3: Active Recovery + Core + Mobility
insert into exercises (id, name, category, tracking_type, muscle_group) values
  ('a3000001-0000-0000-0000-000000000001', 'Deep Squat Hold', 'mobility', 'timed', 'legs'),
  ('a3000001-0000-0000-0000-000000000002', 'Hip Flexor Stretch', 'mobility', 'timed', 'hips'),
  ('a3000001-0000-0000-0000-000000000003', 'Thoracic Rotations', 'mobility', 'bodyweight', 'back'),
  ('a3000001-0000-0000-0000-000000000004', 'Shoulder Mobility', 'mobility', 'timed', 'shoulders'),
  ('a3000001-0000-0000-0000-000000000005', 'Dead Bugs', 'core', 'bodyweight', 'abs'),
  ('a3000001-0000-0000-0000-000000000006', 'Side Plank', 'core', 'timed', 'abs'),
  ('a3000001-0000-0000-0000-000000000007', 'Cable Woodchoppers', 'core', 'weighted', 'abs'),
  ('a3000001-0000-0000-0000-000000000008', 'Incline Treadmill Walk', 'cardio', 'timed', 'full body');

-- Day 4: Push + Conditioning
insert into exercises (id, name, category, tracking_type, muscle_group) values
  ('a4000001-0000-0000-0000-000000000001', 'Medicine Ball Slams', 'explosive', 'weighted', 'full body'),
  ('a4000001-0000-0000-0000-000000000002', 'Clap Push-ups', 'explosive', 'bodyweight', 'chest'),
  ('a4000001-0000-0000-0000-000000000003', 'Incline Dumbbell Press', 'strength', 'weighted', 'chest'),
  ('a4000001-0000-0000-0000-000000000004', 'Dips', 'strength', 'bodyweight', 'chest'),
  ('a4000001-0000-0000-0000-000000000005', 'Shoulder Press', 'strength', 'weighted', 'shoulders'),
  ('a4000001-0000-0000-0000-000000000006', 'Lateral Raises', 'strength', 'weighted', 'shoulders'),
  ('a4000001-0000-0000-0000-000000000007', 'Toe Touches', 'core', 'bodyweight', 'abs'),
  ('a4000001-0000-0000-0000-000000000008', 'Plank Shoulder Taps', 'core', 'bodyweight', 'abs'),
  ('a4000001-0000-0000-0000-000000000009', 'Shuttle Runs', 'finisher', 'timed', 'full body');

-- Day 5: Pull + Posterior Chain + Speed
insert into exercises (id, name, category, tracking_type, muscle_group) values
  ('a5000001-0000-0000-0000-000000000001', 'Kettlebell Swings', 'explosive', 'weighted', 'full body'),
  ('a5000001-0000-0000-0000-000000000002', 'Treadmill Sprint Starts', 'explosive', 'timed', 'legs'),
  ('a5000001-0000-0000-0000-000000000003', 'Deadlifts', 'strength', 'weighted', 'back'),
  ('a5000001-0000-0000-0000-000000000004', 'Lat Pulldown', 'strength', 'weighted', 'back'),
  ('a5000001-0000-0000-0000-000000000005', 'Barbell Rows', 'strength', 'weighted', 'back'),
  ('a5000001-0000-0000-0000-000000000006', 'Face Pulls', 'strength', 'weighted', 'shoulders'),
  ('a5000001-0000-0000-0000-000000000007', 'Hanging Knee Raises', 'core', 'bodyweight', 'abs'),
  ('a5000001-0000-0000-0000-000000000008', 'Ab Rollout', 'core', 'bodyweight', 'abs'),
  ('a5000001-0000-0000-0000-000000000009', 'Rowing Machine Intervals', 'finisher', 'timed', 'full body');


-- ============ DAY TEMPLATES ============

insert into day_templates (id, day_number, name, description) values
  ('d0000001-0000-0000-0000-000000000001', 1, 'Upper Body Strength + Power', 'Explosive upper body work with bench press, pull-ups, overhead press, and cable rows'),
  ('d0000001-0000-0000-0000-000000000002', 2, 'Lower Body Strength + Explosiveness', 'Box jumps, squats, Romanian deadlifts, lunges, and treadmill intervals'),
  ('d0000001-0000-0000-0000-000000000003', 3, 'Active Recovery + Core + Mobility', 'Mobility work, core circuit, and incline treadmill walk'),
  ('d0000001-0000-0000-0000-000000000004', 4, 'Push + Conditioning', 'Push movements with medicine ball slams, dumbbell press, dips, and shuttle runs'),
  ('d0000001-0000-0000-0000-000000000005', 5, 'Pull + Posterior Chain + Speed', 'Deadlifts, rows, pulldowns, kettlebell swings, and rowing machine intervals');


-- ============ TEMPLATE EXERCISES ============

-- Day 1: Upper Body Strength + Power
insert into template_exercises (template_id, exercise_id, section, sets, reps, sort_order) values
  ('d0000001-0000-0000-0000-000000000001', 'a1000001-0000-0000-0000-000000000001', 'explosive', 3, '10', 1),
  ('d0000001-0000-0000-0000-000000000001', 'a1000001-0000-0000-0000-000000000002', 'explosive', 3, '6', 2),
  ('d0000001-0000-0000-0000-000000000001', 'a1000001-0000-0000-0000-000000000003', 'strength', 4, '6', 3),
  ('d0000001-0000-0000-0000-000000000001', 'a1000001-0000-0000-0000-000000000004', 'strength', 4, '8', 4),
  ('d0000001-0000-0000-0000-000000000001', 'a1000001-0000-0000-0000-000000000005', 'strength', 3, '8', 5),
  ('d0000001-0000-0000-0000-000000000001', 'a1000001-0000-0000-0000-000000000006', 'strength', 3, '10', 6),
  ('d0000001-0000-0000-0000-000000000001', 'a1000001-0000-0000-0000-000000000007', 'core', 3, '12', 7),
  ('d0000001-0000-0000-0000-000000000001', 'a1000001-0000-0000-0000-000000000008', 'core', 3, '20', 8),
  ('d0000001-0000-0000-0000-000000000001', 'a1000001-0000-0000-0000-000000000009', 'finisher', 8, '30s fast + 30s slow', 9);

-- Day 2: Lower Body Strength + Explosiveness
insert into template_exercises (template_id, exercise_id, section, sets, reps, sort_order) values
  ('d0000001-0000-0000-0000-000000000002', 'a2000001-0000-0000-0000-000000000001', 'explosive', 4, '5', 1),
  ('d0000001-0000-0000-0000-000000000002', 'a2000001-0000-0000-0000-000000000002', 'explosive', 3, '8', 2),
  ('d0000001-0000-0000-0000-000000000002', 'a2000001-0000-0000-0000-000000000003', 'strength', 4, '6', 3),
  ('d0000001-0000-0000-0000-000000000002', 'a2000001-0000-0000-0000-000000000004', 'strength', 3, '8', 4),
  ('d0000001-0000-0000-0000-000000000002', 'a2000001-0000-0000-0000-000000000005', 'strength', 3, '12 each leg', 5),
  ('d0000001-0000-0000-0000-000000000002', 'a2000001-0000-0000-0000-000000000006', 'strength', 3, '15', 6),
  ('d0000001-0000-0000-0000-000000000002', 'a2000001-0000-0000-0000-000000000007', 'core', 3, '1 min', 7),
  ('d0000001-0000-0000-0000-000000000002', 'a2000001-0000-0000-0000-000000000008', 'core', 3, '15', 8),
  ('d0000001-0000-0000-0000-000000000002', 'a2000001-0000-0000-0000-000000000009', 'finisher', 8, '20s fast + 40s walk', 9);

-- Day 3: Active Recovery + Core + Mobility
insert into template_exercises (template_id, exercise_id, section, sets, reps, sort_order) values
  ('d0000001-0000-0000-0000-000000000003', 'a3000001-0000-0000-0000-000000000001', 'mobility', 1, '60 sec hold', 1),
  ('d0000001-0000-0000-0000-000000000003', 'a3000001-0000-0000-0000-000000000002', 'mobility', 1, '60 sec each side', 2),
  ('d0000001-0000-0000-0000-000000000003', 'a3000001-0000-0000-0000-000000000003', 'mobility', 1, '10 each side', 3),
  ('d0000001-0000-0000-0000-000000000003', 'a3000001-0000-0000-0000-000000000004', 'mobility', 1, '2 mins', 4),
  ('d0000001-0000-0000-0000-000000000003', 'a3000001-0000-0000-0000-000000000005', 'core', 3, '12', 5),
  ('d0000001-0000-0000-0000-000000000003', 'a3000001-0000-0000-0000-000000000006', 'core', 3, '30 sec each side', 6),
  ('d0000001-0000-0000-0000-000000000003', 'a3000001-0000-0000-0000-000000000007', 'core', 3, '12', 7),
  ('d0000001-0000-0000-0000-000000000003', 'a3000001-0000-0000-0000-000000000008', 'cardio', 1, '15-20 mins', 8);

-- Day 4: Push + Conditioning
insert into template_exercises (template_id, exercise_id, section, sets, reps, sort_order) values
  ('d0000001-0000-0000-0000-000000000004', 'a4000001-0000-0000-0000-000000000001', 'explosive', 3, '12', 1),
  ('d0000001-0000-0000-0000-000000000004', 'a4000001-0000-0000-0000-000000000002', 'explosive', 3, '6', 2),
  ('d0000001-0000-0000-0000-000000000004', 'a4000001-0000-0000-0000-000000000003', 'strength', 4, '8', 3),
  ('d0000001-0000-0000-0000-000000000004', 'a4000001-0000-0000-0000-000000000004', 'strength', 3, '10', 4),
  ('d0000001-0000-0000-0000-000000000004', 'a4000001-0000-0000-0000-000000000005', 'strength', 3, '10', 5),
  ('d0000001-0000-0000-0000-000000000004', 'a4000001-0000-0000-0000-000000000006', 'strength', 3, '12', 6),
  ('d0000001-0000-0000-0000-000000000004', 'a4000001-0000-0000-0000-000000000007', 'core', 3, '15', 7),
  ('d0000001-0000-0000-0000-000000000004', 'a4000001-0000-0000-0000-000000000008', 'core', 3, '20', 8),
  ('d0000001-0000-0000-0000-000000000004', 'a4000001-0000-0000-0000-000000000009', 'finisher', 10, '1 round', 9);

-- Day 5: Pull + Posterior Chain + Speed
insert into template_exercises (template_id, exercise_id, section, sets, reps, sort_order) values
  ('d0000001-0000-0000-0000-000000000005', 'a5000001-0000-0000-0000-000000000001', 'explosive', 3, '15', 1),
  ('d0000001-0000-0000-0000-000000000005', 'a5000001-0000-0000-0000-000000000002', 'explosive', 6, '10-15 sec max effort', 2),
  ('d0000001-0000-0000-0000-000000000005', 'a5000001-0000-0000-0000-000000000003', 'strength', 4, '5', 3),
  ('d0000001-0000-0000-0000-000000000005', 'a5000001-0000-0000-0000-000000000004', 'strength', 3, '10', 4),
  ('d0000001-0000-0000-0000-000000000005', 'a5000001-0000-0000-0000-000000000005', 'strength', 3, '8', 5),
  ('d0000001-0000-0000-0000-000000000005', 'a5000001-0000-0000-0000-000000000006', 'strength', 3, '12', 6),
  ('d0000001-0000-0000-0000-000000000005', 'a5000001-0000-0000-0000-000000000007', 'core', 3, '12', 7),
  ('d0000001-0000-0000-0000-000000000005', 'a5000001-0000-0000-0000-000000000008', 'core', 3, '10', 8),
  ('d0000001-0000-0000-0000-000000000005', 'a5000001-0000-0000-0000-000000000009', 'finisher', 5, '250m fast', 9);
