import { NavLink, Outlet } from 'react-router-dom';
import { useAuth } from '../lib/auth';
import { LayoutDashboard, Dumbbell, History, TrendingUp, LogOut } from 'lucide-react';

const navItems = [
  { to: '/', icon: LayoutDashboard, label: 'Home' },
  { to: '/workout', icon: Dumbbell, label: 'Workout' },
  { to: '/history', icon: History, label: 'History' },
  { to: '/progress', icon: TrendingUp, label: 'Progress' },
];

export default function Layout() {
  const { logout } = useAuth();

  return (
    <div className="min-h-dvh flex flex-col bg-[#0f0f1a]">
      {/* Header */}
      <header className="bg-surface border-b border-border px-4 py-3 flex items-center justify-between sticky top-0 z-50">
        <h1 className="text-lg font-bold text-text-primary">
          🏏 Track My Workout
        </h1>
        <button
          onClick={logout}
          className="p-2.5 text-text-muted hover:text-accent-red transition-colors"
          title="Logout"
        >
          <LogOut className="w-5 h-5" />
        </button>
      </header>

      {/* Main content */}
      <main className="flex-1 px-3 py-4 pb-20 max-w-2xl mx-auto w-full overflow-x-hidden">
        <Outlet />
      </main>

      {/* Bottom nav */}
      <nav className="fixed bottom-0 left-0 right-0 bg-surface border-t border-border px-2 py-2 z-50">
        <div className="flex justify-around max-w-2xl mx-auto">
          {navItems.map(({ to, icon: Icon, label }) => (
            <NavLink
              key={to}
              to={to}
              className={({ isActive }) =>
                `flex flex-col items-center gap-1 px-3 py-1.5 rounded-lg transition-colors ${
                  isActive
                    ? 'text-primary'
                    : 'text-text-muted hover:text-text-secondary'
                }`
              }
            >
              <Icon className="w-5 h-5" />
              <span className="text-xs">{label}</span>
            </NavLink>
          ))}
        </div>
      </nav>
    </div>
  );
}
