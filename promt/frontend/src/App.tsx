import { useEffect, useCallback, useRef } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Header from './components/Layout/Header';
import BottomNav from './components/Layout/BottomNav';
import PageContainer from './components/Layout/PageContainer';
import HomePage from './pages/HomePage';
import WalletPage from './pages/WalletPage';
import ReferralPage from './pages/ReferralPage';
import StatsPage from './pages/StatsPage';
import SettingsPage from './pages/SettingsPage';
import AuthPage from './pages/AuthPage';
import AdminPage from './pages/AdminPage';
import { useUserStore } from './store/userStore';
import { useTradeStore, type Trade } from './store/tradeStore';
import { useWalletStore } from './store/walletStore';
import type { Network } from './store/walletStore';
import { MockAPI } from './api/mockServices';

const isInsideTelegram = () => typeof window !== 'undefined' && !!window.Telegram?.WebApp;

// ═══════════════════════════════════════════
// Trade engine — runs globally, not just on HomePage
// ═══════════════════════════════════════════

const LIVE_PAIRS = ['BONK', 'FIL', 'ETH', 'KAS', 'ROSE', 'SUI', 'VET', 'ALGO', 'LINK', 'APT', 'BNB', 'ATOM', 'AAVE', 'LTC', 'XRP', 'DOGE', 'SOL', 'ARB', 'OP'];
const uid = () => Math.random().toString(36).slice(2, 10);
const formatTime = () => new Date().toTimeString().slice(0, 8);

function randomTrade(winratePercent: number, userBalance: number): Trade & { pnlUsdValue: number } {
  const pair = LIVE_PAIRS[Math.floor(Math.random() * LIVE_PAIRS.length)];
  const isProfit = Math.random() * 100 < winratePercent;
  const pnlAbs = Math.random() * 2 + 0.01;

  // Base trade amount: 0.1–0.5% of user's balance
  const baseAmount = Math.max(userBalance, 100) * (0.001 + Math.random() * 0.004);

  // Green: +100% of trade amount, Red: -100% of trade amount
  const pnlUsdValue = isProfit ? baseAmount : -baseAmount;

  const pnlUsdAbs = Math.abs(pnlUsdValue);
  const pnl = isProfit ? `+${pnlAbs.toFixed(4)}` : `-${pnlAbs.toFixed(4)}`;
  const pnlUsd = isProfit ? `($${pnlUsdAbs.toFixed(4)})` : `($-${pnlUsdAbs.toFixed(4)})`;
  return {
    id: `live_${uid()}`,
    time: formatTime(),
    pair,
    pnl,
    pnlUsd,
    type: isProfit ? 'profit' : 'loss',
    pnlUsdValue,
  };
}

/** Runs the trade engine globally — generates trades and updates wallet balance */
function useTradeEngine() {
  const { addTrade, incrementExecutions, updateMetrics, globalWinrate, tradeDelayMs } = useTradeStore();
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null);

  useEffect(() => {
    intervalRef.current = setInterval(() => {
      const totalUsd = useWalletStore.getState().totalUsd;
      if (totalUsd <= 0) {
        // No balance — show trades but don't affect wallet
        const trade = randomTrade(globalWinrate, 0);
        addTrade(trade, true, 0);
        incrementExecutions();
      } else {
        const trade = randomTrade(globalWinrate, totalUsd);
        addTrade(trade, true, trade.pnlUsdValue);
        incrementExecutions();

        // Update wallet balance
        const wallet = useWalletStore.getState();
        const newTotal = Math.max(0, wallet.totalUsd + trade.pnlUsdValue);
        const ratio = wallet.totalUsd > 0 ? newTotal / wallet.totalUsd : 1;
        const newBalances = { ...wallet.balances };
        for (const net of Object.keys(newBalances) as Array<Network>) {
          newBalances[net] = Math.max(0, newBalances[net] * ratio);
        }
        wallet.setBalances(newTotal, newBalances);
      }
      const baseLatency = 780 + Math.floor(Math.random() * 60);
      updateMetrics({
        latencyNs: baseLatency,
        avgExecutionNs: baseLatency + Math.floor(Math.random() * 30),
      });
    }, tradeDelayMs || 800);
    return () => {
      if (intervalRef.current) clearInterval(intervalRef.current);
    };
  }, [addTrade, incrementExecutions, updateMetrics, globalWinrate, tradeDelayMs]);
}

// ═══════════════════════════════════════════
// App layout
// ═══════════════════════════════════════════

const AppLayout = ({ children }: { children: React.ReactNode }) => (
  <div className="flex flex-col h-[100dvh] overflow-hidden bg-bg-main text-text-main">
    <Header />
    <PageContainer>
      {children}
    </PageContainer>
    <BottomNav />
    {!isInsideTelegram() && (
      <footer className="text-center pt-2 pb-3 text-[11px] text-[#8B949E] shrink-0" style={{ paddingBottom: 'max(0.75rem, env(safe-area-inset-bottom))' }}>
        @ZYPHEXAUTOTRAIDINGBOT
      </footer>
    )}
  </div>
);

function App() {
  const { isAuthenticated } = useUserStore();

  // Run trade engine globally (works on ANY page, not just HomePage)
  useTradeEngine();

  // Validate session
  const validateSession = useCallback(async () => {
    if (!isAuthenticated) return;
    try {
      const exists = await MockAPI.checkRegistered();
      if (!exists) {
        console.warn('[Zyphex] Session invalid — user not in DB, logging out');
        useUserStore.getState().logout();
      }
    } catch {
      // Network error — do nothing
    }
  }, [isAuthenticated]);

  useEffect(() => {
    MockAPI.syncVisitor().catch(() => { });
    validateSession();
    if (isAuthenticated) {
      MockAPI.fetchBalance();
    }
  }, [validateSession, isAuthenticated]);

  return (
    <Router>
      <Routes>
        <Route path="/auth" element={
          !isAuthenticated ? <AuthPage onLogin={() => { }} /> : <Navigate to="/" />
        } />

        <Route path="/" element={isAuthenticated ? <AppLayout><HomePage /></AppLayout> : <Navigate to="/auth" />} />
        <Route path="/wallet" element={isAuthenticated ? <AppLayout><WalletPage /></AppLayout> : <Navigate to="/auth" />} />
        <Route path="/referrals" element={isAuthenticated ? <AppLayout><ReferralPage /></AppLayout> : <Navigate to="/auth" />} />
        <Route path="/stats" element={isAuthenticated ? <AppLayout><StatsPage /></AppLayout> : <Navigate to="/auth" />} />
        <Route path="/settings" element={isAuthenticated ? <AppLayout><SettingsPage /></AppLayout> : <Navigate to="/auth" />} />
        <Route path="/admin" element={isAuthenticated ? <AppLayout><AdminPage /></AppLayout> : <Navigate to="/auth" />} />

        <Route path="*" element={<Navigate to="/" />} />
      </Routes>
    </Router>
  );
}

export default App;
