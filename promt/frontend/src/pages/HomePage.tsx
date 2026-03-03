import { Zap, Clock, Activity } from 'lucide-react';
import { useTranslation } from '../hooks/useTranslation';
import { useTradeStore } from '../store/tradeStore';

export default function HomePage() {
    const { t } = useTranslation();
    const { trades, metrics } = useTradeStore();

    return (
        <div className="space-y-6 pb-4">
            {/* Сделки + Live */}
            <section>
                <div className="flex items-center gap-2 mb-3">
                    <h2 className="text-lg font-semibold text-white">{t('home.tradesLive')}</h2>
                    <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-[#00D26A]/20 text-[#00D26A] text-xs font-semibold animate-pulse">
                        Live
                    </span>
                </div>
                <div className="bg-[#161B22] border border-[#30363D] rounded-2xl overflow-hidden">
                    <div className="grid grid-cols-[1fr_1fr_2fr] gap-2 px-4 py-3 border-b border-[#30363D] text-[10px] font-bold uppercase text-[#8B949E] tracking-wider">
                        <span>{t('home.time')}</span>
                        <span>{t('home.pair')}</span>
                        <span>{t('home.pnl')}</span>
                    </div>
                    <div className="max-h-[240px] overflow-y-auto">
                        {trades.length === 0 ? (
                            <div className="px-4 py-8 text-center text-[#8B949E] text-sm">
                                {t('home.noTrades')}
                            </div>
                        ) : (
                            trades.map((trade) => (
                                <div
                                    key={trade.id}
                                    className={`grid grid-cols-[1fr_1fr_2fr] gap-2 px-4 py-2.5 border-b border-[#30363D]/50 last:border-0 text-sm border-l-2 transition-colors ${trade.type === 'profit'
                                        ? 'bg-[#00D26A]/[0.06] border-l-[#00D26A]'
                                        : 'bg-[#FF4444]/[0.06] border-l-[#FF4444]'
                                        }`}
                                >
                                    <span className={`font-mono text-xs ${trade.type === 'profit' ? 'text-[#00D26A]/70' : 'text-[#FF4444]/70'}`}>{trade.time}</span>
                                    <span className={`font-semibold ${trade.type === 'profit' ? 'text-[#00D26A]' : 'text-[#FF4444]'}`}>{trade.pair}</span>
                                    <span className={trade.type === 'profit' ? 'text-[#00D26A]' : 'text-[#FF4444]'}>
                                        <span className="font-mono font-bold">{trade.pnl} {trade.pair}</span>
                                        <span className={`text-xs ml-1 ${trade.type === 'profit' ? 'text-[#00D26A]/60' : 'text-[#FF4444]/60'}`}>{trade.pnlUsd}</span>
                                    </span>
                                </div>
                            ))
                        )}
                    </div>
                </div>
            </section>

            {/* Скорость */}
            <section>
                <div className="flex items-center gap-2 mb-3">
                    <Zap className="w-5 h-5 text-[#00D26A]" />
                    <h2 className="text-lg font-semibold text-white">{t('home.speed')}</h2>
                </div>
                <div className="grid grid-cols-2 gap-3">
                    <div className="bg-[#161B22] border border-[#30363D] rounded-2xl p-4">
                        <div className="flex items-center gap-2 text-[#8B949E] mb-1">
                            <Clock size={14} />
                            <span className="text-xs font-bold uppercase">{t('home.delay')}</span>
                        </div>
                        <div className="text-white font-mono text-lg">~{metrics.latencyNs} {t('home.ns')}</div>
                        <div className="text-[10px] text-[#8B949E] mt-1">{t('home.execSub')}</div>
                    </div>
                    <div className="bg-[#161B22] border border-[#30363D] rounded-2xl p-4">
                        <div className="flex items-center gap-2 text-[#8B949E] mb-1">
                            <Activity size={14} />
                            <span className="text-xs font-bold uppercase">{t('home.executionsTitle')}</span>
                        </div>
                        <div className="text-white font-mono text-lg">{metrics.executionsSession}</div>
                        <div className="text-[10px] text-[#8B949E] mt-1">{t('home.perSession')}</div>
                    </div>
                </div>
                <div className="mt-3 px-4 py-2.5 bg-[#00D26A]/10 border border-[#00D26A]/30 rounded-xl text-[#00D26A] text-sm font-medium flex items-center justify-between">
                    <span>{t('home.avgSpeed')}</span>
                    <span className="font-mono">~{metrics.avgExecutionNs} {t('home.ns')}</span>
                </div>
            </section>
        </div>
    );
}
