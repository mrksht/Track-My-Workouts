import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import type { DayTemplate, WorkoutSession } from '../types/database';
import { Dumbbell, CheckCircle2, Calendar, Flame } from 'lucide-react';

const DAY_ICONS = ['💪', '🦵', '🧘', '🔥', '🧲'];

function getWeekRange() {
  const now = new Date();
  const day = now.getDay();
  const monday = new Date(now);
  monday.setDate(now.getDate() - ((day + 6) % 7));
  monday.setHours(0, 0, 0, 0);
  const sunday = new Date(monday);
  sunday.setDate(monday.getDate() + 6);
  sunday.setHours(23, 59, 59, 999);
  return { monday, sunday };
}

export default function Dashboard() {
  const navigate = useNavigate();
  const [templates, setTemplates] = useState<DayTemplate[]>([]);
  const [sessions, setSessions] = useState<WorkoutSession[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadData();
  }, []);

  async function loadData() {
    const { monday, sunday } = getWeekRange();
    const [templatesRes, sessionsRes] = await Promise.all([
      supabase.from('day_templates').select('*').order('day_number'),
      supabase
        .from('workout_sessions')
        .select('*, template:day_templates(*)')
        .gte('date', monday.toISOString().split('T')[0])
        .lte('date', sunday.toISOString().split('T')[0])
        .order('date', { ascending: false }),
    ]);
    if (templatesRes.data) setTemplates(templatesRes.data);
    if (sessionsRes.data) setSessions(sessionsRes.data);
    setLoading(false);
  }

  const completedTemplateIds = new Set(sessions.map((s) => s.template_id));
  const completedCount = completedTemplateIds.size;

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin w-8 h-8 border-2 border-primary border-t-transparent rounded-full" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Week summary */}
      <div className="bg-surface rounded-2xl p-5 border border-border">
        <div className="flex items-center justify-between mb-3">
          <div className="flex items-center gap-2">
            <Calendar className="w-5 h-5 text-primary" />
            <h2 className="font-semibold text-text-primary">This Week</h2>
          </div>
          <span className="text-sm text-text-secondary">
            {completedCount}/5 days
          </span>
        </div>
        <div className="flex gap-2">
          {[1, 2, 3, 4, 5].map((day) => {
            const template = templates.find((t) => t.day_number === day);
            const done = template ? completedTemplateIds.has(template.id) : false;
            return (
              <div
                key={day}
                className={`flex-1 h-2 rounded-full ${
                  done ? 'bg-accent-green' : 'bg-surface-lighter'
                }`}
              />
            );
          })}
        </div>
        {completedCount >= 5 && (
          <div className="flex items-center gap-2 mt-3 text-accent-green text-sm">
            <Flame className="w-4 h-4" />
            All 5 days completed this week!
          </div>
        )}
      </div>

      {/* Recent sessions */}
      {sessions.length > 0 && (
        <div>
          <h3 className="text-sm font-medium text-text-secondary mb-2 uppercase tracking-wide">
            Recent Sessions
          </h3>
          <div className="space-y-2">
            {sessions.slice(0, 3).map((session) => (
              <div
                key={session.id}
                className="bg-surface rounded-xl p-3 border border-border flex items-center justify-between"
              >
                <div>
                  <p className="text-sm font-medium text-text-primary">
                    {(session as any).template?.name || 'Workout'}
                  </p>
                  <p className="text-xs text-text-muted">
                    {new Date(session.date).toLocaleDateString('en-GB', {
                      weekday: 'short',
                      day: 'numeric',
                      month: 'short',
                    })}
                  </p>
                </div>
                <CheckCircle2 className="w-5 h-5 text-accent-green" />
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Day template cards */}
      <div>
        <h3 className="text-sm font-medium text-text-secondary mb-3 uppercase tracking-wide">
          Start a Workout
        </h3>
        <div className="space-y-3">
          {templates.map((template) => {
            const done = completedTemplateIds.has(template.id);
            return (
              <button
                key={template.id}
                onClick={() => navigate(`/workout?template=${template.id}`)}
                className={`w-full text-left bg-surface hover:bg-surface-light rounded-xl p-4 border transition-all ${
                  done
                    ? 'border-accent-green/30'
                    : 'border-border hover:border-primary/50'
                }`}
              >
                <div className="flex items-center gap-3">
                  <span className="text-2xl">{DAY_ICONS[template.day_number - 1]}</span>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2">
                      <span className="text-xs font-medium px-2 py-0.5 rounded-full bg-primary/20 text-primary">
                        Day {template.day_number}
                      </span>
                      {done && (
                        <span className="text-xs px-2 py-0.5 rounded-full bg-accent-green/20 text-accent-green">
                          Done
                        </span>
                      )}
                    </div>
                    <h3 className="font-medium text-text-primary mt-1 truncate">
                      {template.name}
                    </h3>
                    <p className="text-xs text-text-muted mt-0.5 truncate">
                      {template.description}
                    </p>
                  </div>
                  <Dumbbell className="w-5 h-5 text-text-muted flex-shrink-0" />
                </div>
              </button>
            );
          })}
        </div>
      </div>
    </div>
  );
}
