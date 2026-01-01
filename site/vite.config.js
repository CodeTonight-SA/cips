import { defineConfig } from 'vite'

export default defineConfig({
  build: {
    // Inline CSS for fastest initial paint
    cssCodeSplit: false,
    // Minify with esbuild (built-in, no extra deps)
    minify: 'esbuild',
    // Optimize chunk size
    rollupOptions: {
      output: {
        manualChunks: undefined
      }
    }
  },
  // No external deps = fastest load
  optimizeDeps: {
    include: []
  }
})
