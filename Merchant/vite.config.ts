import path from 'path';
import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, '.', '');
  return {
    server: {
      port: 3000,
      host: '0.0.0.0',
      proxy: {
        // Dev: forward /api/* → Tomcat at localhost:8080/<context>/api/*
        '/api': {
          target: 'http://localhost:8080',
          changeOrigin: true,
          rewrite: (p) => `/ClickEat2-1.0-SNAPSHOT${p}`,
        },
      },
    },
    plugins: [react()],
    define: {
      'process.env.API_KEY': JSON.stringify(env.GEMINI_API_KEY),
      'process.env.GEMINI_API_KEY': JSON.stringify(env.GEMINI_API_KEY)
    },
    resolve: {
      alias: {
        '@': path.resolve(__dirname, '.'),
      }
    },
    // Relative base so the built index.html works regardless of context path
    base: './',
    build: {
      // Output stays inside Merchant/dist — NOT inside the Java webapp
      outDir: path.resolve(__dirname, './dist'),
      emptyOutDir: true,
    }
  };
});
