import { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import type { Exercise } from '../types/database';
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Legend,
} from 'recharts';
import { TrendingUp } from 'lucide-react';

interface ChartDataPoint {
  date: string;
  maxWeight: number;
  totalVolume: number;
  avgRpe: number | null;
}

export default function Progress() {
  const [exercises, setExercises] = useState<Exercise[]>([]);
  const [selectedExercise, setSelectedExercise] = useState<string>('');
  const [chartData, setChartData] = useState<ChartDataPoint[]>([]);
  const [loading, setLoading] = useState(false);
  const [metric, setMetric] = useState<'maxWeight' | 'totalVolume'>('maxWeight');

  useEffect(() => {
    loadExercises();
  }, []);

  useEffect(() => {
    if (selectedExercise) loadProgressData(selectedExercise);
  }, [selectedExercise]);

  async function loadExercises() {
    const { data } = await supabase
      .from('exercises')
      .select('*')
      .order('name');
    if (data) setExercises(data);
  }

  async function loadProgressData(exerciseId: string) {
    setLoading(true);

    // Get all session_exercises for this exercise
    const { data: sessionExercises } = await supabase
      .from('session_exercises')
      .select('id, session_id, skipped')
      .eq('exercise_id', exerciseId)
      .eq('skipped', false);

    if (!sessionExercises || sessionExercises.length === 0) {
      setChartData([]);
      setLoading(false);
      return;
    }

    // Get session dates
    const sessionIds = sessionExercises.map((se) => se.session_id);
    const { data: sessions } = await supabase
      .from('workout_sessions')
      .select('id, date')
      .in('id', sessionIds)
      .order('date');

    if (!sessions) {
      setChartData([]);
      setLoading(false);
      return;
    }

    // Get all sets
    const seIds = sessionExercises.map((se) => se.id);
    const { data: sets } = await supabase
      .from('exercise_sets')
      .select('*')
      .in('session_exercise_id', seIds)
      .eq('skipped', false);

    if (!sets) {
      setChartData([]);
      setLoading(false);
      return;
    }

    // Build chart data grouped by session date
    const sessionDateMap = new Map(sessions.map((s) => [s.id, s.date]));
    const seSessionMap = new Map(sessionExercises.map((se) => [se.id, se.session_id]));

    const dateGroups: Record<string, typeof sets> = {};
    sets.forEach((set) => {
      const sessionId = seSessionMap.get(set.session_exercise_id);
      const date = sessionId ? sessionDateMap.get(sessionId) : null;
      if (date) {
        if (!dateGroups[date]) dateGroups[date] = [];
        dateGroups[date].push(set);
      }
    });

    const chartPoints: ChartDataPoint[] = Object.entries(dateGroups)
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([date, dateSets]) => {
        const maxWeight = Math.max(...dateSets.map((s) => Number(s.weight_kg)));
        const totalVolume = dateSets.reduce(
          (sum, s) => sum + Number(s.weight_kg) * s.reps,
          0
        );
        const rpeSets = dateSets.filter((s) => s.rpe != null);
        const avgRpe =
          rpeSets.length > 0
            ? Math.round(
                (rpeSets.reduce((sum, s) => sum + (s.rpe || 0), 0) / rpeSets.length) * 10
              ) / 10
            : null;

        return {
          date: new Date(date).toLocaleDateString('en-GB', {
            day: 'numeric',
            month: 'short',
          }),
          maxWeight,
          totalVolume,
          avgRpe,
        };
      });

    setChartData(chartPoints);
    setLoading(false);
  }

  const selectedExerciseName = exercises.find((e) => e.id === selectedExercise)?.name;

  return (
    <div className="space-y-4">
      <h2 className="text-lg font-semibold text-text-primary">Progress</h2>

      {/* Exercise selector */}
      <select
        value={selectedExercise}
        onChange={(e) => setSelectedExercise(e.target.value)}
        className="w-full px-3 py-3 bg-surface border border-border rounded-xl text-base text-text-primary focus:outline-none focus:ring-1 focus:ring-primary"
      >
        <option value="">Select an exercise...</option>
        {exercises.map((ex) => (
          <option key={ex.id} value={ex.id}>
            {ex.name}
          </option>
        ))}
      </select>

      {!selectedExercise && (
        <div className="flex flex-col items-center justify-center h-48 text-text-muted">
          <TrendingUp className="w-12 h-12 mb-3 opacity-50" />
          <p>Select an exercise to view progress</p>
        </div>
      )}

      {selectedExercise && loading && (
        <div className="flex items-center justify-center h-48">
          <div className="animate-spin w-8 h-8 border-2 border-primary border-t-transparent rounded-full" />
        </div>
      )}

      {selectedExercise && !loading && chartData.length === 0 && (
        <div className="flex flex-col items-center justify-center h-48 text-text-muted bg-surface rounded-xl border border-border">
          <p className="text-sm">No data for {selectedExerciseName} yet</p>
          <p className="text-xs mt-1">Log some workouts first!</p>
        </div>
      )}

      {selectedExercise && !loading && chartData.length > 0 && (
        <>
          {/* Metric toggle */}
          <div className="flex gap-2">
            <button
              onClick={() => setMetric('maxWeight')}
              className={`text-sm px-3 py-2 rounded-full transition-colors ${
                metric === 'maxWeight'
                  ? 'bg-primary text-white'
                  : 'bg-surface-light text-text-muted hover:text-text-secondary'
              }`}
            >
              Max Weight
            </button>
            <button
              onClick={() => setMetric('totalVolume')}
              className={`text-sm px-3 py-2 rounded-full transition-colors ${
                metric === 'totalVolume'
                  ? 'bg-primary text-white'
                  : 'bg-surface-light text-text-muted hover:text-text-secondary'
              }`}
            >
              Total Volume
            </button>
          </div>

          {/* Chart */}
          <div className="bg-surface rounded-xl border border-border p-4">
            <h3 className="text-sm font-medium text-text-primary mb-3">
              {selectedExerciseName} – {metric === 'maxWeight' ? 'Max Weight (kg)' : 'Total Volume (kg×reps)'}
            </h3>
            <ResponsiveContainer width="100%" height={250}>
              <LineChart data={chartData}>
                <CartesianGrid strokeDasharray="3 3" stroke="#334155" />
                <XAxis
                  dataKey="date"
                  tick={{ fill: '#94a3b8', fontSize: 11 }}
                  stroke="#334155"
                />
                <YAxis
                  tick={{ fill: '#94a3b8', fontSize: 11 }}
                  stroke="#334155"
                />
                <Tooltip
                  contentStyle={{
                    backgroundColor: '#1e1e2e',
                    border: '1px solid #334155',
                    borderRadius: '8px',
                    color: '#f1f5f9',
                    fontSize: '12px',
                  }}
                />
                <Legend />
                <Line
                  type="monotone"
                  dataKey={metric}
                  stroke="#6366f1"
                  strokeWidth={2}
                  dot={{ fill: '#6366f1', r: 4 }}
                  name={metric === 'maxWeight' ? 'Max Weight (kg)' : 'Volume (kg×reps)'}
                />
                {chartData.some((d) => d.avgRpe !== null) && (
                  <Line
                    type="monotone"
                    dataKey="avgRpe"
                    stroke="#eab308"
                    strokeWidth={1.5}
                    strokeDasharray="4 4"
                    dot={{ fill: '#eab308', r: 3 }}
                    name="Avg RPE"
                    yAxisId={0}
                  />
                )}
              </LineChart>
            </ResponsiveContainer>
          </div>

          {/* Data table */}
          <div className="bg-surface rounded-xl border border-border overflow-hidden">
            <table className="w-full text-xs">
              <thead>
                <tr className="border-b border-border">
                  <th className="text-left p-2.5 text-text-muted font-medium">Date</th>
                  <th className="text-right p-2.5 text-text-muted font-medium">Max Weight</th>
                  <th className="text-right p-2.5 text-text-muted font-medium">Volume</th>
                  <th className="text-right p-2.5 text-text-muted font-medium">Avg RPE</th>
                </tr>
              </thead>
              <tbody>
                {chartData.map((point) => (
                  <tr key={point.date} className="border-b border-border/50 last:border-0">
                    <td className="p-2.5 text-text-primary">{point.date}</td>
                    <td className="p-2.5 text-text-secondary text-right">{point.maxWeight}kg</td>
                    <td className="p-2.5 text-text-secondary text-right">{point.totalVolume}</td>
                    <td className="p-2.5 text-text-secondary text-right">
                      {point.avgRpe ?? '-'}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </>
      )}
    </div>
  );
}
