import { useState } from 'react';
import { useAuth } from '../lib/auth';
import { Lock } from 'lucide-react';

export default function PinGate() {
  const { login } = useAuth();
  const [pin, setPin] = useState('');
  const [error, setError] = useState(false);
  const [shake, setShake] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!login(pin)) {
      setError(true);
      setShake(true);
      setTimeout(() => setShake(false), 500);
      setPin('');
    }
  };

  return (
    <div className="min-h-dvh flex items-center justify-center bg-[#0f0f1a] px-4">
      <form
        onSubmit={handleSubmit}
        className={`bg-surface rounded-2xl p-8 w-full max-w-sm shadow-xl border border-border ${shake ? 'animate-shake' : ''}`}
      >
        <div className="flex flex-col items-center gap-4 mb-6">
          <div className="w-14 h-14 rounded-full bg-primary/20 flex items-center justify-center">
            <Lock className="w-7 h-7 text-primary" />
          </div>
          <h1 className="text-xl font-semibold text-text-primary">Track My Workout</h1>
          <p className="text-text-secondary text-sm">Enter your PIN to continue</p>
        </div>

        <input
          type="password"
          inputMode="numeric"
          maxLength={10}
          value={pin}
          onChange={(e) => {
            setPin(e.target.value);
            setError(false);
          }}
          placeholder="Enter PIN"
          className="w-full px-4 py-3 bg-surface-light border border-border rounded-xl text-center text-lg tracking-[0.3em] text-text-primary placeholder:text-text-muted focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
          autoFocus
        />

        {error && (
          <p className="text-accent-red text-sm text-center mt-2">Incorrect PIN</p>
        )}

        <button
          type="submit"
          className="w-full mt-4 py-3 bg-primary hover:bg-primary-dark text-white font-medium rounded-xl transition-colors"
        >
          Unlock
        </button>
      </form>
    </div>
  );
}
