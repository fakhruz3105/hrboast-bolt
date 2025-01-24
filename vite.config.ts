import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  optimizeDeps: {
    exclude: ['lucide-react'],
  },
  server: {
    // Handle client-side routing
    historyApiFallback: true,
  },
  build: {
    // Generate 200.html for Netlify
    rollupOptions: {
      output: {
        manualChunks: undefined,
      },
    },
  },
});