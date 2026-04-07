-- =============================================
-- Track My Workout - Supabase Migration
-- Run this in the Supabase SQL Editor
-- Safe to re-run: drops and recreates everything
-- =============================================

-- Drop existing tables (reverse dependency order)
drop table if exists exercise_sets cascade;
drop table if exists session_exercises cascade;
drop table if exists workout_sessions cascade;
drop table if exists template_exercises cascade;
drop table if exists day_templates cascade;
drop table if exists exercises cascade;

-- 1. Exercises library
create table exercises (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category text not null check (category in ('explosive', 'strength', 'core', 'cardio', 'mobility', 'finisher', 'warmup')),
  tracking_type text not null default 'weighted' check (tracking_type in ('weighted', 'bodyweight', 'timed')),
  muscle_group text not null,
  created_at timestamptz default now()
);

-- 2. Day templates (5 days)
create table day_templates (
  id uuid primary key default gen_random_uuid(),
  day_number int not null unique check (day_number between 1 and 5),
  name text not null,
  description text,
  created_at timestamptz default now()
);

-- 3. Template exercises (links exercises to day templates)
create table template_exercises (
  id uuid primary key default gen_random_uuid(),
  template_id uuid not null references day_templates(id) on delete cascade,
  exercise_id uuid not null references exercises(id) on delete cascade,
  section text not null check (section in ('explosive', 'strength', 'core', 'finisher', 'cardio', 'mobility', 'stretch')),
  sets int not null,
  reps text not null,
  sort_order int not null default 0
);

-- 4. Workout sessions (each gym visit)
create table workout_sessions (
  id uuid primary key default gen_random_uuid(),
  date date not null,
  template_id uuid not null references day_templates(id),
  status text not null default 'completed' check (status in ('completed', 'skipped')),
  notes text,
  duration_mins int,
  created_at timestamptz default now()
);

-- 5. Session exercises (exercises performed in a session)
create table session_exercises (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references workout_sessions(id) on delete cascade,
  exercise_id uuid not null references exercises(id),
  original_exercise_id uuid references exercises(id),
  section text not null,
  sort_order int not null default 0,
  skipped boolean not null default false
);

-- 6. Exercise sets (individual set data)
create table exercise_sets (
  id uuid primary key default gen_random_uuid(),
  session_exercise_id uuid not null references session_exercises(id) on delete cascade,
  set_number int not null,
  weight_kg numeric not null default 0,
  reps int not null default 0,
  duration_sec int not null default 0,
  skipped boolean not null default false
);

-- Indexes for common queries
create index if not exists idx_workout_sessions_date on workout_sessions(date);
create index if not exists idx_session_exercises_session on session_exercises(session_id);
create index if not exists idx_exercise_sets_session_exercise on exercise_sets(session_exercise_id);
create index if not exists idx_template_exercises_template on template_exercises(template_id);

-- Enable RLS (permissive for single user)
alter table exercises enable row level security;
alter table day_templates enable row level security;
alter table template_exercises enable row level security;
alter table workout_sessions enable row level security;
alter table session_exercises enable row level security;
alter table exercise_sets enable row level security;

-- Permissive policies (allow all for anon key - single user app)
create policy "Allow all on exercises" on exercises for all using (true) with check (true);
create policy "Allow all on day_templates" on day_templates for all using (true) with check (true);
create policy "Allow all on template_exercises" on template_exercises for all using (true) with check (true);
create policy "Allow all on workout_sessions" on workout_sessions for all using (true) with check (true);
create policy "Allow all on session_exercises" on session_exercises for all using (true) with check (true);
create policy "Allow all on exercise_sets" on exercise_sets for all using (true) with check (true);
