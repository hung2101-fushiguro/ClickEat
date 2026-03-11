/** @type {import('tailwindcss').Config} */
export default {
    content: [
        './index.html',
        './index.tsx',
        './App.tsx',
        './components/**/*.{ts,tsx}',
        './screens/**/*.{ts,tsx}',
    ],
    darkMode: 'class',
    theme: {
        extend: {
            fontFamily: {
                sans: ['Inter', 'sans-serif'],
            },
            colors: {
                primary: '#c86601',
                'primary-dark': '#a05201',
                'bg-light': '#f8f7f5',
                'bg-dark': '#23190f',
            },
        },
    },
    plugins: [],
};
