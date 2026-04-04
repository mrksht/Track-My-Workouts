import { useState } from 'react';
import type { ExerciseSet, WorkoutExerciseEntry } from '../types/database';
import { SkipForward, ArrowLeftRight, RotateCcw } from 'lucide-react';

interface Props {
  entry: WorkoutExerciseEntry;
  onUpdate: (entry: WorkoutExerciseEntry) => void;
  onSwap: (entry: WorkoutExerciseEntry) => void;
}

const SECTION_COLORS: Record<string, string> = {
  explosive: 'bg-accent-red/20 text-accent-red',
  strength: 'bg-accent-blue/20 text-accent-blue',
  core: 'bg-accent-yellow/20 text-accent-yellow',
  finisher: 'bg-primary/20 text-primary',
  cardio: 'bg-accent-green/20 text-accent-green',
  mobility: 'bg-purple-500/20 text-purple-400',
};

export default function ExerciseCard({ entry, onUpdate, onSwap }: Props) {
  const [expanded, setExpanded] = useState(true);
  const { exercise, templateExercise, skipped, sets, originalExercise } = entry;

  const trackingType = exercise.tracking_type; // 'weighted' | 'bodyweight' | 'timed'

  const toggleSkip = () => {
    const newSkipped = !skipped;
    const newSets = sets.map((s) => ({
      ...s,
      skipped: newSkipped,
      weight_kg: newSkipped ? 0 : s.weight_kg,
      reps: newSkipped ? 0 : s.reps,
      duration_sec: newSkipped ? 0 : s.duration_sec,
      rpe: newSkipped ? null : s.rpe,
    }));
    onUpdate({ ...entry, skipped: newSkipped, sets: newSets });
  };

  const updateSet = (index: number, field: keyof ExerciseSet, value: number | null) => {
    const newSets = [...sets];
    newSets[index] = { ...newSets[index], [field]: value };
    onUpdate({ ...entry, sets: newSets });
  };



  return (
    <div
      className={`bg-surface rounded-xl border transition-all overflow-hidden ${
        skipped ? 'border-border opacity-50' : 'border-border'
      }`}
    >
      {/* Header */}
      <div
        className="p-3 flex items-center gap-3 cursor-pointer"
        onClick={() => setExpanded(!expanded)}
      >
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 mb-1">
            <span
              className={`text-[10px] font-semibold uppercase px-1.5 py-0.5 rounded ${
                SECTION_COLORS[templateExercise.section] || 'bg-surface-lighter text-text-muted'
              }`}
            >
              {templateExercise.section}
            </span>
            {originalExercise && (
              <span className="text-[10px] text-accent-yellow">
                ↔ swapped from {originalExercise.name}
              </span>
            )}
          </div>
          <h3 className={`font-medium text-sm ${skipped ? 'line-through text-text-muted' : 'text-text-primary'}`}>
            {exercise.name}
          </h3>
          <p className="text-xs text-text-muted">
            {templateExercise.sets} × {templateExercise.reps}
          </p>
        </div>

        <div className="flex items-center gap-1">
          <button
            onClick={(e) => {
              e.stopPropagation();
              onSwap(entry);
            }}
            className="p-2.5 rounded-lg hover:bg-surface-light text-text-muted hover:text-accent-blue transition-colors"
            title="Swap exercise"
          >
            <ArrowLeftRight className="w-4 h-4" />
          </button>
          <button
            onClick={(e) => {
              e.stopPropagation();
              toggleSkip();
            }}
            className={`p-2.5 rounded-lg transition-colors ${
              skipped
                ? 'bg-accent-red/20 text-accent-red hover:bg-accent-red/30'
                : 'hover:bg-surface-light text-text-muted hover:text-accent-red'
            }`}
            title={skipped ? 'Unskip' : 'Skip'}
          >
            {skipped ? <RotateCcw className="w-4 h-4" /> : <SkipForward className="w-4 h-4" />}
          </button>
        </div>
      </div>

      {/* Sets */}
      {expanded && !skipped && (
        <div className="px-3 pb-3">
          {trackingType === 'timed' ? (
            /* ---- TIMED: duration (sec) + RPE per round ---- */
            <>
              <div className="grid grid-cols-[1.5rem_1fr_2.8rem] gap-2 text-xs text-text-muted uppercase mb-1.5">
                <span>#</span>
                <span>Duration (sec)</span>
                <span>RPE</span>
              </div>
              {sets.map((set, i) => (
                <div
                  key={i}
                  className="grid grid-cols-[1.5rem_1fr_2.8rem] gap-2 items-center mb-2"
                >
                  <span className="text-xs text-text-muted text-center">{set.set_number}</span>
                  <input
                    type="number"
                    inputMode="numeric"
                    value={set.duration_sec || ''}
                    onChange={(e) => updateSet(i, 'duration_sec', Number(e.target.value) || 0)}
                    className="w-full h-10 px-2 bg-surface-light border border-border rounded-lg text-center text-base text-text-primary focus:outline-none focus:ring-2 focus:ring-primary"
                    placeholder="sec"
                  />
                  <select
                    value={set.rpe ?? ''}
                    onChange={(e) => updateSet(i, 'rpe', e.target.value ? Number(e.target.value) : null)}
                    className="w-full h-10 bg-surface-light border border-border rounded-lg text-base text-text-primary text-center focus:outline-none focus:ring-2 focus:ring-primary appearance-none"
                  >
                    <option value="">-</option>
                    {[1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map((v) => (
                      <option key={v} value={v}>{v}</option>
                    ))}
                  </select>
                </div>
              ))}
            </>
          ) : trackingType === 'bodyweight' ? (
            /* ---- BODYWEIGHT: reps + RPE (no weight) ---- */
            <>
              <div className="grid grid-cols-[1.5rem_1fr_2.8rem] gap-2 text-xs text-text-muted uppercase mb-1.5">
                <span>#</span>
                <span>Reps</span>
                <span>RPE</span>
              </div>
              {sets.map((set, i) => (
                <div
                  key={i}
                  className="grid grid-cols-[1.5rem_1fr_2.8rem] gap-2 items-center mb-2"
                >
                  <span className="text-xs text-text-muted text-center">{set.set_number}</span>
                  <input
                    type="number"
                    inputMode="numeric"
                    value={set.reps || ''}
                    onChange={(e) => updateSet(i, 'reps', Number(e.target.value) || 0)}
                    className="w-full h-10 px-2 bg-surface-light border border-border rounded-lg text-center text-base text-text-primary focus:outline-none focus:ring-2 focus:ring-primary"
                    placeholder="0"
                  />
                  <select
                    value={set.rpe ?? ''}
                    onChange={(e) => updateSet(i, 'rpe', e.target.value ? Number(e.target.value) : null)}
                    className="w-full h-10 bg-surface-light border border-border rounded-lg text-base text-text-primary text-center focus:outline-none focus:ring-2 focus:ring-primary appearance-none"
                  >
                    <option value="">-</option>
                    {[1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map((v) => (
                      <option key={v} value={v}>{v}</option>
                    ))}
                  </select>
                </div>
              ))}
            </>
          ) : (
            /* ---- WEIGHTED: kg + reps + RPE ---- */
            <>
              <div className="grid grid-cols-[1.5rem_1fr_1fr_2.8rem] gap-2 text-xs text-text-muted uppercase mb-1.5">
                <span>#</span>
                <span>Kg</span>
                <span>Reps</span>
                <span>RPE</span>
              </div>
              {sets.map((set, i) => (
                <div
                  key={i}
                  className="grid grid-cols-[1.5rem_1fr_1fr_2.8rem] gap-2 items-center mb-2"
                >
                  <span className="text-xs text-text-muted text-center">{set.set_number}</span>
                  <input
                    type="number"
                    inputMode="decimal"
                    value={set.weight_kg || ''}
                    onChange={(e) => updateSet(i, 'weight_kg', Number(e.target.value) || 0)}
                    className="w-full h-10 px-2 bg-surface-light border border-border rounded-lg text-center text-base text-text-primary focus:outline-none focus:ring-2 focus:ring-primary"
                    placeholder="0"
                  />
                  <input
                    type="number"
                    inputMode="numeric"
                    value={set.reps || ''}
                    onChange={(e) => updateSet(i, 'reps', Number(e.target.value) || 0)}
                    className="w-full h-10 px-2 bg-surface-light border border-border rounded-lg text-center text-base text-text-primary focus:outline-none focus:ring-2 focus:ring-primary"
                    placeholder="0"
                  />
                  <select
                    value={set.rpe ?? ''}
                    onChange={(e) => updateSet(i, 'rpe', e.target.value ? Number(e.target.value) : null)}
                    className="w-full h-10 bg-surface-light border border-border rounded-lg text-base text-text-primary text-center focus:outline-none focus:ring-2 focus:ring-primary appearance-none"
                  >
                    <option value="">-</option>
                    {[1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map((v) => (
                      <option key={v} value={v}>{v}</option>
                    ))}
                  </select>
                </div>
              ))}
            </>
          )}
        </div>
      )}

      {skipped && (
        <div className="px-3 pb-3">
          <p className="text-xs text-accent-red italic">Skipped</p>
        </div>
      )}
    </div>
  );
}
