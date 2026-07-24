-- =============================================
-- Migration 011: Rename Bulgarian Split Squat -> Reverse Lunges
-- Data-only (no DDL). Already applied to the live DB via the REST API;
-- this file is the repo record of that change.
-- =============================================
-- This is a global rename of the library exercise record (id
-- c1000001-...-007), applied deliberately "overall": because templates and
-- logged sessions reference the exercise by id, renaming the row relabels
-- everywhere it appears (Day 5 template + past logged sessions). Sets/reps
-- and all session data are untouched.
--
-- Note: idempotent by intent — re-running sets the same name.
-- =============================================

BEGIN;

UPDATE exercises
  SET name = 'Reverse Lunges'
  WHERE id = 'c1000001-0000-0000-0000-000000000007';

COMMIT;
