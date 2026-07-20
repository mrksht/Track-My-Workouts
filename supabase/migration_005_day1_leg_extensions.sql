-- =============================================
-- Migration 005: Day 1 — Walking Lunges -> Leg Extensions
-- Data-only (no DDL). Can be applied via the REST API or the SQL editor.
-- =============================================
-- Swaps Walking Lunges for Leg Extensions (3x15) on Day 1. Walking Lunges
-- stays in the exercise library so any logged history referencing it is
-- preserved; it is simply no longer part of the Day 1 template.
-- =============================================

BEGIN;

INSERT INTO exercises (id, name, category, tracking_type, muscle_group) VALUES
  ('c1000001-0000-0000-0000-000000000011', 'Leg Extensions', 'strength', 'weighted', 'legs')
ON CONFLICT (id) DO NOTHING;

UPDATE template_exercises
  SET exercise_id = 'c1000001-0000-0000-0000-000000000011',
      reps        = '15',
      sets        = 3
  WHERE template_id = 'd0000001-0000-0000-0000-000000000001'   -- Day 1
    AND exercise_id = 'a2000001-0000-0000-0000-000000000005';  -- Walking Lunges

-- Keep the Day 1 summary in sync with the swap.
UPDATE day_templates
  SET description = 'Squats, RDLs, leg extensions, calf raises, box jumps, sprint intervals. WU: 5min jog + dynamic mobility. CD: hamstring, quad, hip, calf stretches.'
  WHERE day_number = 1;

COMMIT;
