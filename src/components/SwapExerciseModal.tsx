import { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import type { Exercise } from '../types/database';
import { Search, X } from 'lucide-react';

interface Props {
  isOpen: boolean;
  onClose: () => void;
  onSelect: (exercise: Exercise) => void;
  currentExerciseId: string;
  filterCategory?: string;
}

export default function SwapExerciseModal({
  isOpen,
  onClose,
  onSelect,
  currentExerciseId,
  filterCategory,
}: Props) {
  const [exercises, setExercises] = useState<Exercise[]>([]);
  const [search, setSearch] = useState('');
  const [selectedCategory, setSelectedCategory] = useState(filterCategory || '');

  useEffect(() => {
    if (isOpen) {
      loadExercises();
      setSearch('');
      setSelectedCategory(filterCategory || '');
    }
  }, [isOpen, filterCategory]);

  async function loadExercises() {
    const { data } = await supabase
      .from('exercises')
      .select('*')
      .order('name');
    if (data) setExercises(data);
  }

  const categories = [...new Set(exercises.map((e) => e.category))].sort();

  const filtered = exercises.filter((e) => {
    if (e.id === currentExerciseId) return false;
    if (selectedCategory && e.category !== selectedCategory) return false;
    if (search && !e.name.toLowerCase().includes(search.toLowerCase())) return false;
    return true;
  });

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-[100] flex items-end sm:items-center justify-center">
      <div className="absolute inset-0 bg-black/60" onClick={onClose} />
      <div className="relative bg-surface border border-border rounded-t-2xl sm:rounded-2xl w-full max-w-lg max-h-[80dvh] flex flex-col">
        {/* Header */}
        <div className="flex items-center justify-between p-4 border-b border-border">
          <h2 className="font-semibold text-text-primary">Swap Exercise</h2>
          <button
            onClick={onClose}
            className="p-2.5 rounded-lg hover:bg-surface-light text-text-muted transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Search */}
        <div className="p-3 border-b border-border space-y-2">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-text-muted" />
            <input
              type="text"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Search exercises..."
              className="w-full pl-9 pr-3 py-2.5 bg-surface-light border border-border rounded-xl text-base text-text-primary placeholder:text-text-muted focus:outline-none focus:ring-1 focus:ring-primary"
              autoFocus
            />
          </div>
          <div className="flex gap-1.5 flex-wrap">
            <button
              onClick={() => setSelectedCategory('')}
              className={`text-xs px-3 py-2 rounded-full transition-colors ${
                !selectedCategory
                  ? 'bg-primary text-bg'
                  : 'bg-surface-light text-text-muted hover:text-text-secondary'
              }`}
            >
              All
            </button>
            {categories.map((cat) => (
              <button
                key={cat}
                onClick={() => setSelectedCategory(cat === selectedCategory ? '' : cat)}
                className={`text-xs px-3 py-2 rounded-full capitalize transition-colors ${
                  cat === selectedCategory
                    ? 'bg-primary text-bg'
                    : 'bg-surface-light text-text-muted hover:text-text-secondary'
                }`}
              >
                {cat}
              </button>
            ))}
          </div>
        </div>

        {/* Exercise list */}
        <div className="flex-1 overflow-y-auto p-3 pb-6 space-y-1.5">
          {filtered.length === 0 ? (
            <p className="text-sm text-text-muted text-center py-8">No exercises found</p>
          ) : (
            filtered.map((exercise) => (
              <button
                key={exercise.id}
                onClick={() => {
                  onSelect(exercise);
                  onClose();
                }}
                className="w-full text-left px-3 py-3 rounded-xl hover:bg-surface-light active:bg-surface-lighter transition-colors"
              >
                <p className="text-sm font-medium text-text-primary">{exercise.name}</p>
                <p className="text-xs text-text-muted capitalize">
                  {exercise.category} · {exercise.muscle_group}
                </p>
              </button>
            ))
          )}
        </div>
      </div>
    </div>
  );
}
