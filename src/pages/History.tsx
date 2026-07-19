import { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import type { WorkoutSession, SessionExercise, ExerciseSet } from '../types/database';
import { ChevronDown, ChevronUp, Calendar, ArrowLeftRight, SkipForward, Trash2 } from 'lucide-react';

interface ExpandedSession extends Omit<WorkoutSession, 'template'> {
  template: { name: string; day_number: number } | null;
}

export default function HistoryPage() {
  const [sessions, setSessions] = useState<ExpandedSession[]>([]);
  const [loading, setLoading] = useState(true);
  const [expandedId, setExpandedId] = useState<string | null>(null);
  const [exerciseDetails, setExerciseDetails] = useState<Record<string, SessionExercise[]>>({});

  useEffect(() => {
    loadSessions();
  }, []);

  async function loadSessions() {
    const { data } = await supabase
      .from('workout_sessions')
      .select('*, template:day_templates(name, day_number)')
      .order('date', { ascending: false })
      .limit(50);
    if (data) setSessions(data as any);
    setLoading(false);
  }

  async function toggleExpand(sessionId: string) {
    if (expandedId === sessionId) {
      setExpandedId(null);
      return;
    }
    setExpandedId(sessionId);

    if (!exerciseDetails[sessionId]) {
      const { data, error } = await supabase
        .from('session_exercises')
        // session_exercises has two FKs to exercises (exercise_id and
        // original_exercise_id), so a bare `exercises` embed is ambiguous and
        // PostgREST rejects it with PGRST201. Both sides must name their FK.
        // tracking_type is required by the set rendering below.
        .select('*, exercise:exercises!session_exercises_exercise_id_fkey(name, category, muscle_group, tracking_type), original_exercise:exercises!session_exercises_original_exercise_id_fkey(name)')
        .eq('session_id', sessionId)
        .order('sort_order');

      // This query failing silently is what hid the broken embed above: `data`
      // came back null, the panel rendered empty, and nothing reached the
      // console. Surface it rather than swallowing the next one too.
      if (error) console.error('Failed to load session exercises:', error);

      if (data) {
        // Load sets for each exercise
        const exerciseIds = data.map((e: any) => e.id);
        const { data: sets } = await supabase
          .from('exercise_sets')
          .select('*')
          .in('session_exercise_id', exerciseIds)
          .order('set_number');

        const exercisesWithSets = data.map((ex: any) => ({
          ...ex,
          sets: (sets || []).filter((s: any) => s.session_exercise_id === ex.id),
        }));

        setExerciseDetails((prev) => ({ ...prev, [sessionId]: exercisesWithSets }));
      }
    }
  }

  async function deleteSession(sessionId: string) {
    if (!confirm('Delete this workout session?')) return;

    await supabase.from('workout_sessions').delete().eq('id', sessionId);
    setSessions((prev) => prev.filter((s) => s.id !== sessionId));
    setExerciseDetails((prev) => {
      const next = { ...prev };
      delete next[sessionId];
      return next;
    });
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin w-8 h-8 border-2 border-primary border-t-transparent rounded-full" />
      </div>
    );
  }

  if (sessions.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center h-64 text-text-muted">
        <Calendar className="w-12 h-12 mb-3 opacity-50" />
        <p>No workouts logged yet</p>
        <p className="text-sm">Start your first workout from the dashboard!</p>
      </div>
    );
  }

  return (
    <div className="space-y-3">
      <h2 className="text-lg font-semibold text-text-primary">Workout History</h2>

      {sessions.map((session) => {
        const isExpanded = expandedId === session.id;
        const details = exerciseDetails[session.id];

        return (
          <div key={session.id} className="bg-surface rounded-xl border border-border overflow-hidden">
            <div
              className="p-3 flex items-center gap-3 cursor-pointer"
              onClick={() => toggleExpand(session.id)}
            >
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2 mb-0.5">
                  <span className="text-xs font-medium px-2 py-0.5 rounded-full bg-primary/20 text-primary">
                    Day {session.template?.day_number}
                  </span>
                  <span className="text-xs text-text-muted">
                    {new Date(session.date).toLocaleDateString('en-GB', {
                      weekday: 'short',
                      day: 'numeric',
                      month: 'short',
                      year: 'numeric',
                    })}
                  </span>
                </div>
                <h3 className="font-medium text-sm text-text-primary truncate">
                  {session.template?.name || 'Workout'}
                </h3>
              </div>
              <div className="flex items-center gap-1">
                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    deleteSession(session.id);
                  }}
                  className="p-2.5 rounded-lg hover:bg-surface-light text-text-muted hover:text-accent-red transition-colors"
                  title="Delete session"
                >
                  <Trash2 className="w-4 h-4" />
                </button>
                {isExpanded ? (
                  <ChevronUp className="w-5 h-5 text-text-muted" />
                ) : (
                  <ChevronDown className="w-5 h-5 text-text-muted" />
                )}
              </div>
            </div>

            {isExpanded && details && (
              <div className="border-t border-border px-3 pb-3 pt-2 space-y-2">
                {details.map((ex: any) => (
                  <div key={ex.id} className="bg-surface-light rounded-lg p-2.5">
                    <div className="flex items-center gap-2 mb-1.5">
                      <span className="text-xs font-medium text-text-primary">
                        {ex.exercise?.name}
                      </span>
                      {ex.skipped && (
                        <span className="flex items-center gap-0.5 text-[10px] text-accent-red">
                          <SkipForward className="w-3 h-3" /> Skipped
                        </span>
                      )}
                      {ex.original_exercise && (
                        <span className="flex items-center gap-0.5 text-[10px] text-accent-yellow">
                          <ArrowLeftRight className="w-3 h-3" /> from {ex.original_exercise.name}
                        </span>
                      )}
                    </div>

                    {!ex.skipped && ex.sets && ex.sets.length > 0 && (
                      <div className="space-y-0.5">
                        {(() => {
                          const tt = ex.exercise?.tracking_type || 'weighted';
                          return ex.sets.map((set: ExerciseSet) => (
                            <div
                              key={set.set_number}
                              className="text-xs text-text-secondary grid grid-cols-2 gap-2"
                            >
                              <span className="text-text-muted">
                                Set {set.set_number}
                              </span>
                              {tt === 'timed' ? (
                                <span>{(set as any).duration_sec || 0}s</span>
                              ) : tt === 'bodyweight' ? (
                                <span>{set.reps} reps</span>
                              ) : (
                                <span>{set.weight_kg}kg × {set.reps}</span>
                              )}
                            </div>
                          ));
                        })()}
                      </div>
                    )}
                  </div>
                ))}
              </div>
            )}
          </div>
        );
      })}
    </div>
  );
}
