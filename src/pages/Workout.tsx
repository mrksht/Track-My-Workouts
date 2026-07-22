import { useEffect, useState } from 'react';
import { useSearchParams, useNavigate } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import type {
  DayTemplate,
  Exercise,
  WorkoutExerciseEntry,
} from '../types/database';
import ExerciseCard from '../components/ExerciseCard';
import SwapExerciseModal from '../components/SwapExerciseModal';
import { Save, Loader2 } from 'lucide-react';

export default function Workout() {
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();
  const templateId = searchParams.get('template');

  const [templates, setTemplates] = useState<DayTemplate[]>([]);
  const [selectedTemplate, setSelectedTemplate] = useState<DayTemplate | null>(null);
  const [entries, setEntries] = useState<WorkoutExerciseEntry[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  // Swap modal state
  const [swapTarget, setSwapTarget] = useState<WorkoutExerciseEntry | null>(null);

  useEffect(() => {
    loadTemplates();
  }, []);

  useEffect(() => {
    if (templateId && templates.length > 0) {
      const t = templates.find((t) => t.id === templateId);
      if (t) selectTemplate(t);
    }
  }, [templateId, templates]);

  async function loadTemplates() {
    const { data } = await supabase
      .from('day_templates')
      .select('*')
      .order('day_number');
    if (data) setTemplates(data);
    setLoading(false);
  }

  async function selectTemplate(template: DayTemplate) {
    setSelectedTemplate(template);
    setLoading(true);

    const { data: templateExercises } = await supabase
      .from('template_exercises')
      .select('*, exercise:exercises(*)')
      .eq('template_id', template.id)
      .order('sort_order');

    if (templateExercises) {
      const entries: WorkoutExerciseEntry[] = templateExercises.map((te: any) => {
        const ex = te.exercise as Exercise;
        return {
          templateExercise: te,
          exercise: ex,
          originalExercise: null,
          skipped: false,
          sets: Array.from({ length: te.sets }, (_, i) => ({
            set_number: i + 1,
            weight_kg: 0,
            reps: 0,
            duration_sec: 0,
            skipped: false,
          })),
        };
      });
      setEntries(entries);
    }
    setLoading(false);
  }

  function updateEntry(index: number, updated: WorkoutExerciseEntry) {
    const newEntries = [...entries];
    newEntries[index] = updated;
    setEntries(newEntries);
  }

  function handleSwap(exercise: Exercise) {
    if (!swapTarget) return;
    const index = entries.findIndex(
      (e) => e.templateExercise.id === swapTarget.templateExercise.id
    );
    if (index === -1) return;

    const updated: WorkoutExerciseEntry = {
      ...entries[index],
      exercise,
      originalExercise: entries[index].originalExercise || entries[index].exercise,
    };
    updateEntry(index, updated);
    setSwapTarget(null);
  }

  async function saveWorkout() {
    if (!selectedTemplate) return;
    setSaving(true);

    try {
      // 1. Create workout session
      const { data: session, error: sessionError } = await supabase
        .from('workout_sessions')
        .insert({
          date: new Date().toISOString().split('T')[0],
          template_id: selectedTemplate.id,
          status: 'completed',
        })
        .select()
        .single();

      if (sessionError || !session) throw sessionError;

      // 2. Create session exercises
      const sessionExercises = entries.map((entry, i) => ({
        session_id: session.id,
        exercise_id: entry.exercise.id,
        original_exercise_id: entry.originalExercise?.id || null,
        section: entry.templateExercise.section,
        sort_order: i,
        skipped: entry.skipped,
      }));

      const { data: insertedExercises, error: exError } = await supabase
        .from('session_exercises')
        .insert(sessionExercises)
        .select();

      if (exError || !insertedExercises) throw exError;

      // 3. Create exercise sets
      const allSets: any[] = [];
      entries.forEach((entry, entryIndex) => {
        const sessionExercise = insertedExercises[entryIndex];
        entry.sets.forEach((set) => {
          allSets.push({
            session_exercise_id: sessionExercise.id,
            set_number: set.set_number,
            weight_kg: set.weight_kg,
            reps: set.reps,
            duration_sec: set.duration_sec,
            skipped: entry.skipped || set.skipped,
          });
        });
      });

      const { error: setsError } = await supabase
        .from('exercise_sets')
        .insert(allSets);

      if (setsError) throw setsError;

      navigate('/', { replace: true });
    } catch (err) {
      console.error('Failed to save workout:', err);
      alert('Failed to save workout. Check console for details.');
    } finally {
      setSaving(false);
    }
  }

  // Group entries by section
  const sections = entries.reduce(
    (acc, entry) => {
      const section = entry.templateExercise.section;
      if (!acc[section]) acc[section] = [];
      acc[section].push(entry);
      return acc;
    },
    {} as Record<string, WorkoutExerciseEntry[]>
  );

  // Order sections by where each first appears in the plan (entries arrive
  // sorted by sort_order), so the workout follows the order the day was
  // written in rather than a fixed section priority. This also means any
  // section renders automatically — a hardcoded list silently dropped
  // 'agility', hiding Day 3's entire footwork block.
  const sectionOrder = entries.reduce<string[]>((order, entry) => {
    const section = entry.templateExercise.section;
    if (!order.includes(section)) order.push(section);
    return order;
  }, []);

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin w-8 h-8 border-2 border-primary border-t-transparent rounded-full" />
      </div>
    );
  }

  // Template picker
  if (!selectedTemplate) {
    return (
      <div className="space-y-4">
        <h2 className="text-lg font-semibold text-text-primary">Choose Your Workout</h2>
        <div className="space-y-3">
          {templates.map((t) => (
            <button
              key={t.id}
              onClick={() => {
                selectTemplate(t);
                window.history.replaceState(null, '', `/workout?template=${t.id}`);
              }}
              className="w-full text-left bg-surface hover:bg-surface-light rounded-xl p-4 border border-border hover:border-primary/50 transition-all"
            >
              <span className="text-xs font-medium px-2 py-0.5 rounded-full bg-primary/20 text-primary">
                Day {t.day_number}
              </span>
              <h3 className="font-medium text-text-primary mt-1">{t.name}</h3>
              <p className="text-xs text-text-muted mt-0.5">{t.description}</p>
            </button>
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-4 pb-4">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <span className="text-xs font-medium px-2 py-0.5 rounded-full bg-primary/20 text-primary">
            Day {selectedTemplate.day_number}
          </span>
          <h2 className="text-lg font-semibold text-text-primary mt-1">
            {selectedTemplate.name}
          </h2>
        </div>
      </div>

      {/* Exercise sections */}
      {sectionOrder
        .filter((s) => sections[s])
        .map((section) => (
          <div key={section}>
            <h3 className="text-xs font-semibold uppercase tracking-wide text-text-muted mb-2 capitalize">
              {section}
            </h3>
            <div className="space-y-2">
              {sections[section].map((entry) => {
                const index = entries.indexOf(entry);
                return (
                  <ExerciseCard
                    key={entry.templateExercise.id}
                    entry={entry}
                    onUpdate={(updated) => updateEntry(index, updated)}
                    onSwap={(e) => setSwapTarget(e)}
                  />
                );
              })}
            </div>
          </div>
        ))}

      {/* Save button */}
      <button
        onClick={saveWorkout}
        disabled={saving}
        className="w-full py-3 bg-action hover:bg-action-hover text-on-action font-semibold rounded-xl flex items-center justify-center gap-2 transition-colors disabled:opacity-50 glow-action"
      >
        {saving ? (
          <Loader2 className="w-5 h-5 animate-spin" />
        ) : (
          <Save className="w-5 h-5" />
        )}
        {saving ? 'Saving...' : 'Save Workout'}
      </button>

      {/* Swap modal */}
      <SwapExerciseModal
        isOpen={!!swapTarget}
        onClose={() => setSwapTarget(null)}
        onSelect={handleSwap}
        currentExerciseId={swapTarget?.exercise.id || ''}
        filterCategory={swapTarget?.exercise.category}
      />
    </div>
  );
}
