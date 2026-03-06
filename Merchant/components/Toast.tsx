import React, { useState, useEffect } from 'react';

interface ToastItem {
    id: number;
    message: string;
    type: 'success' | 'error' | 'info' | 'warning';
}

let _id = 0;

/** Dispatch a toast from anywhere:
 *  window.dispatchEvent(new CustomEvent('ce:toast', { detail: { message: '...', type: 'success' } }))
 *  Or use the helper: toast('msg', 'success')
 */
export function toast(message: string, type: ToastItem['type'] = 'info') {
    window.dispatchEvent(new CustomEvent('ce:toast', { detail: { message, type } }));
}

const COLORS: Record<string, string> = {
    success: 'bg-green-50 border-green-200 text-green-800',
    error: 'bg-red-50 border-red-200 text-red-800',
    info: 'bg-blue-50 border-blue-200 text-blue-800',
    warning: 'bg-yellow-50 border-yellow-200 text-yellow-800',
};
const ICON_COLORS: Record<string, string> = {
    success: 'text-green-500',
    error: 'text-red-500',
    info: 'text-blue-500',
    warning: 'text-yellow-500',
};
const ICONS: Record<string, string> = {
    success: 'check_circle',
    error: 'error',
    info: 'info',
    warning: 'warning',
};

export const Toast: React.FC = () => {
    const [items, setItems] = useState<ToastItem[]>([]);

    useEffect(() => {
        const handler = (e: Event) => {
            const { message, type = 'info' } = (e as CustomEvent).detail ?? {};
            if (!message) return;
            const id = ++_id;
            setItems(prev => [...prev, { id, message, type }]);
            setTimeout(() => setItems(prev => prev.filter(t => t.id !== id)), 3500);
        };
        window.addEventListener('ce:toast', handler);
        return () => window.removeEventListener('ce:toast', handler);
    }, []);

    if (!items.length) return null;

    return (
        <div className= "fixed bottom-20 md:bottom-6 right-4 z-[9999] flex flex-col gap-2 items-end pointer-events-none" >
        {
            items.map(item => (
                <div
          key= { item.id }
          className = {`flex items-center gap-3 px-4 py-3 rounded-xl border shadow-xl text-sm font-medium max-w-sm w-full pointer-events-auto ${COLORS[item.type]}`}
        >
        <span className={ `material-symbols-outlined text-base shrink-0 ${ICON_COLORS[item.type]}` }>
            { ICONS[item.type]}
            </span>
            < span className = "flex-1" > { item.message } </span>
                < button
    onClick = {() => setItems(prev => prev.filter(t => t.id !== item.id))}
className = "opacity-50 hover:opacity-100 transition-opacity shrink-0"
    >
    <span className="material-symbols-outlined text-base" > close </span>
        </button>
        </div>
      ))}
</div>
  );
};
