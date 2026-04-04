export interface Exercise {
  id: string;
  name: string;
  category: 'explosive' | 'strength' | 'core' | 'cardio' | 'mobility' | 'finisher' | 'warmup';
  tracking_type: 'weighted' | 'bodyweight' | 'timed';
  muscle_group: string;
}

export interface DayTemplate {
  id: string;
  day_number: number;
  name: string;
  description: string | null;
}

export interface TemplateExercise {
  id: string;
  template_id: string;
  exercise_id: string;
  section: string;
  sets: number;
  reps: string;
  sort_order: number;
  exercise?: Exercise;
}

export interface WorkoutSession {
  id: string;
  date: string;
  template_id: string;
  status: 'completed' | 'skipped';
  notes: string | null;
  duration_mins: number | null;
  created_at: string;
  template?: DayTemplate;
  session_exercises?: SessionExercise[];
}

export interface SessionExercise {
  id: string;
  session_id: string;
  exercise_id: string;
  original_exercise_id: string | null;
  section: string;
  sort_order: number;
  skipped: boolean;
  exercise?: Exercise;
  original_exercise?: Exercise;
  sets?: ExerciseSet[];
}

export interface ExerciseSet {
  id?: string;
  session_exercise_id?: string;
  set_number: number;
  weight_kg: number;
  duration_sec: number;
  reps: number;
  rpe: number | null;
  skipped: boolean;
}

// Used during workout logging before submission
export interface WorkoutExerciseEntry {
  templateExercise: TemplateExercise;
  exercise: Exercise;
  originalExercise: Exercise | null; // non-null if swapped
  skipped: boolean;
  sets: ExerciseSet[];
}
