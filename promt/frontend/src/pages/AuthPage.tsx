import { useState, useEffect } from 'react';
import { Loader2 } from 'lucide-react';
import { MockAPI } from '../api/mockServices';
import { useTelegram } from '../hooks/useTelegram';
import { useTranslation } from '../hooks/useTranslation';

export default function AuthPage({ onLogin }: { onLogin: () => void }) {
    const [pin, setPin] = useState('');
    const [confirmPin, setConfirmPin] = useState('');
    const [error, setError] = useState('');
    const [loading, setLoading] = useState(false);
    const [checking, setChecking] = useState(true);
    const [isRegistration, setIsRegistration] = useState(false);

    const { hapticFeedback } = useTelegram();
    const { t } = useTranslation();

    useEffect(() => {
        MockAPI.checkRegistered()
            .then((exists) => {
                setIsRegistration(!exists);
            })
            .catch(() => setIsRegistration(true))
            .finally(() => setChecking(false));
    }, []);

    const handleLogin = async (e: React.FormEvent) => {
        e.preventDefault();
        if (isRegistration) {
            if (pin.length < 4 || pin.length > 6) {
                setError(t('auth.pinLength'));
                return;
            }
            if (pin !== confirmPin) {
                setError(t('auth.pinMismatch'));
                setConfirmPin('');
                return;
            }
        } else {
            if (pin.length < 4) return;
        }

        setLoading(true);
        setError('');

        try {
            const success = isRegistration
                ? await MockAPI.register(pin, confirmPin)
                : await MockAPI.login(pin);
            if (success) {
                hapticFeedback?.impactOccurred('medium');
                onLogin();
            } else {
                hapticFeedback?.notificationOccurred('error');
                setError(isRegistration ? t('auth.pinMismatch') : t('auth.wrongPin'));
                setPin('');
                setConfirmPin('');
            }
        } catch (e: any) {
            const msg = e?.message;
            setError(msg === 'pin_mismatch' ? t('auth.pinMismatch') : msg === 'pin_length' ? t('auth.pinLength') : t('auth.networkError'));
        } finally {
            setLoading(false);
        }
    };

    if (checking) {
        return (
            <div className="flex flex-col items-center justify-center min-h-[100dvh] bg-[#0D1117] text-white px-6 font-sans">
                <Loader2 className="w-10 h-10 text-[#00D26A] animate-spin" />
                <p className="mt-4 text-[#8B949E] text-sm">Загрузка...</p>
            </div>
        );
    }

    return (
        <div className="flex flex-col items-center justify-center min-h-[100dvh] bg-[#0D1117] text-white px-6 font-sans">
            <div className={`w-16 h-16 rounded-full flex items-center justify-center mb-6 transition-colors duration-500 overflow-hidden ${error ? 'bg-[#FF4444]/20' : 'bg-[#00D26A]/20'}`}>
                <img src="/logo.svg" alt="Zyphex Logo" className={`w-10 h-10 object-contain transition-transform duration-500 ${error ? 'scale-110' : 'scale-100'}`} />
            </div>

            <h1 className="text-2xl font-semibold mb-2">
                {isRegistration ? t('auth.createPin') : t('auth.enterPin')}
            </h1>
            <p className="text-[#8B949E] text-sm mb-8 text-center max-w-xs leading-relaxed">
                {error ? <span className="text-[#FF4444]">{error}</span> : (isRegistration ? t('auth.createPinDesc') : t('auth.enterPinDesc'))}
            </p>

            <form onSubmit={handleLogin} className="w-full max-w-[280px]">
                <input
                    type="password"
                    placeholder={t('auth.pinPlaceholder')}
                    className={`w-full bg-[#1C2333] border ${error ? 'border-[#FF4444]' : 'border-[#30363D] focus:border-[#00D26A]'} rounded-xl px-4 py-4 text-center text-3xl font-mono tracking-[1em] text-white placeholder:text-[#8B949E]/30 focus:outline-none transition-colors mb-3 disabled:opacity-50`}
                    value={pin}
                    onChange={(e) => {
                        if (/^\d*$/.test(e.target.value)) {
                            setPin(e.target.value);
                            setError('');
                        }
                    }}
                    maxLength={6}
                    inputMode="numeric"
                    pattern="[0-9]*"
                    autoFocus
                    disabled={loading}
                />
                {isRegistration && (
                    <input
                        type="password"
                        placeholder={t('auth.confirmPin')}
                        className={`w-full bg-[#1C2333] border ${error ? 'border-[#FF4444]' : 'border-[#30363D] focus:border-[#00D26A]'} rounded-xl px-4 py-4 text-center text-3xl font-mono tracking-[1em] text-white placeholder:text-[#8B949E]/30 focus:outline-none transition-colors mb-6 disabled:opacity-50`}
                        value={confirmPin}
                        onChange={(e) => {
                            if (/^\d*$/.test(e.target.value)) {
                                setConfirmPin(e.target.value);
                                setError('');
                            }
                        }}
                        maxLength={6}
                        inputMode="numeric"
                        pattern="[0-9]*"
                        disabled={loading}
                    />
                )}
                {!isRegistration && <div className="mb-6" />}
                <button
                    type="submit"
                    disabled={loading || (isRegistration ? pin.length < 4 || confirmPin.length < 4 : pin.length < 4)}
                    className="w-full bg-[#00D26A] text-black font-bold uppercase tracking-wide rounded-xl py-4 transition-all active:scale-95 disabled:opacity-50 disabled:active:scale-100 flex justify-center items-center"
                >
                    {loading ? <Loader2 className="animate-spin" size={20} /> : (isRegistration ? t('auth.createAccount') : t('auth.login'))}
                </button>
            </form>
        </div>
    );
}
