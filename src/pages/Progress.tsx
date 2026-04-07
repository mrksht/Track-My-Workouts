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
  // weighted
  maxWeight?: number;
  totalVolume?: number;
  // bodyweight
  totalReps?: number;
  // timed
  totalDuration?: number;
}

type TrackingType = 'weighted' | 'bodyweight' | 'timed';
type Metric = 'maxWeight' | 'totalVolume' | 'totalReps' | 'totalDuration';

const DEFAULT_METRIC: Record<TrackingType, Metric> = {
  weighted: 'maxWeight',
  bodyweight: 'totalReps',
  timed: 'totalDuration',
};

export default function Progress() {
  const [exercises, setExercises] = useState<Exercise[]>([]);
  const [selectedExercise, setSelectedExercise] = useState<string>('');
  const [chartData, setChartData] = useState<ChartDataPoint[]>([]);
  const [loading, setLoading] = useState(false);
  const [metric, setMetric] = useState<Metric>('maxWeight');

  useEffect(() => {
    loadExercises();
  }, []);

  useEffect(() => {
    if (selectedExercise) {
      const ex = exercises.find((e) => e.id === selectedExercise);
      if (ex) setMetric(DEFAULT_METRIC[ex.tracking_type]);
      loadProgressData(selectedExercise);
    }
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

    const selectedEx = exercises.find((e) => e.id === exerciseId);
    const tt = selectedEx?.tracking_type || 'weighted';

    const chartPoints: ChartDataPoint[] = Object.entries(dateGroups)
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([date, dateSets]) => {
        const point: ChartDataPoint = {
          date: new Date(date).toLocaleDateString('en-GB', {
            day: 'numeric',
            month: 'short',
          }),
        };

        if (tt === 'weighted') {
          point.maxWeight = Math.max(...dateSets.map((s) => Number(s.weight_kg)));
          point.totalVolume = dateSets.reduce(
            (sum, s) => sum + Number(s.weight_kg) * s.reps,
            0
          );
        } else if (tt === 'bodyweight') {
          point.totalReps = dateSets.reduce((sum, s) => sum + s.reps, 0);
        } else {
          // timed
          point.totalDuration = dateSets.reduce((sum, s) => sum + (s.duration_sec || 0), 0);
        }

        return point;
      });

    setChartData(chartPoints);
    setLoading(false);
  }

  const selectedEx = exercises.find((e) => e.id === selectedExercise);
  const selectedExerciseName = selectedEx?.name;
  const trackingType = selectedEx?.tracking_type || 'weighted';

  const metricLabel: Record<Metric, string> = {
    maxWeight: 'Max Weight (kg)',
    totalVolume: 'Total Volume (kg×reps)',
    totalReps: 'Total Reps',
    totalDuration: 'Total Duration (sec)',
  };

  const metricButtons: { key: Metric; label: string }[] =
    trackingType === 'weighted'
      ? [
          { key: 'maxWeight', label: 'Max Weight' },
          { key: 'totalVolume', label: 'Total Volume' },
        ]
      : trackingType === 'bodyweight'
        ? [{ key: 'totalReps', label: 'Total Reps' }]
        : [{ key: 'totalDuration', label: 'Total Duration' }];

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
            {metricButtons.map((btn) => (
              <button
                key={btn.key}
                onClick={() => setMetric(btn.key)}
                className={`text-sm px-3 py-2 rounded-full transition-colors ${
                  metric === btn.key
                    ? 'bg-primary text-white'
                    : 'bg-surface-light text-text-muted hover:text-text-secondary'
                }`}
              >
                {btn.label}
              </button>
            ))}
          </div>

          {/* Chart */}
          <div className="bg-surface rounded-xl border border-border p-4">
            <h3 className="text-sm font-medium text-text-primary mb-3">
              {selectedExerciseName} – {metricLabel[metric]}
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
                  name={metricLabel[metric]}
                />
              </LineChart>
            </ResponsiveContainer>
          </div>

          {/* Data table */}
          <div className="bg-surface rounded-xl border border-border overflow-hidden">
            <table className="w-full text-xs">
              <thead>
                <tr className="border-b border-border">
                  <th className="text-left p-2.5 text-text-muted font-medium">Date</th>
                  {metricButtons.map((btn) => (
                    <th key={btn.key} className="text-right p-2.5 text-text-muted font-medium">
                      {btn.label}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {chartData.map((point) => (
                  <tr key={point.date} className="border-b border-border/50 last:border-0">
                    <td className="p-2.5 text-text-primary">{point.date}</td>
                    {trackingType === 'weighted' && (
                      <>
                        <td className="p-2.5 text-text-secondary text-right">{point.maxWeight}kg</td>
                        <td className="p-2.5 text-text-secondary text-right">{point.totalVolume}</td>
                      </>
                    )}
                    {trackingType === 'bodyweight' && (
                      <td className="p-2.5 text-text-secondary text-right">{point.totalReps}</td>
                    )}
                    {trackingType === 'timed' && (
                      <td className="p-2.5 text-text-secondary text-right">{point.totalDuration}s</td>
                    )}
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
