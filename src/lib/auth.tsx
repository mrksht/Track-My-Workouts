import { createContext, useContext, useState, useEffect, type ReactNode } from 'react';

const PIN_KEY = 'workout_tracker_pin';

interface AuthContextType {
  isAuthenticated: boolean;
  login: (pin: string) => boolean;
  logout: () => void;
}

const AuthContext = createContext<AuthContextType | null>(null);

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used within AuthProvider');
  return ctx;
}

export function AuthProvider({ children }: { children: ReactNode }) {
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  useEffect(() => {
    const stored = sessionStorage.getItem(PIN_KEY);
    if (stored === import.meta.env.VITE_APP_PIN) {
      setIsAuthenticated(true);
    }
  }, []);

  const login = (pin: string) => {
    if (pin === import.meta.env.VITE_APP_PIN) {
      sessionStorage.setItem(PIN_KEY, pin);
      setIsAuthenticated(true);
      return true;
    }
    return false;
  };

  const logout = () => {
    sessionStorage.removeItem(PIN_KEY);
    setIsAuthenticated(false);
  };

  return (
    <AuthContext.Provider value={{ isAuthenticated, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}
