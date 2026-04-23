---
trigger: always_on
---

# Vite Configuration Rules

This project uses Vite as the build tool. Follow these configuration patterns.

<project_setup>
- Use Vite for React 18 + TypeScript projects
- Configure path aliases in vite.config.ts for clean imports
- Use @/ alias for src directory imports
- Configure environment variables with VITE_ prefix
</project_setup>

<configuration_structure>

```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  server: {
    port: 3000,
    proxy: {
      '/api': {
        target: 'http://localhost:8000',
        changeOrigin: true,
      },
    },
  },
  build: {
    outDir: 'dist',
    sourcemap: true,
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          ui: ['@radix-ui/react-dialog', '@radix-ui/react-dropdown-menu'],
        },
      },
    },
  },
});
```

</configuration_structure>

<tsconfig_paths>

```json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  }
}
```

</tsconfig_paths>

<environment_variables>
- Use VITE_ prefix for all environment variables
- Access via import.meta.env.VITE_VARIABLE_NAME
- Define in .env.local for local development
- Never commit .env.local files
- Use .env.example as template
</environment_variables>

<proxy_configuration>
- Configure proxy for API calls to http://localhost:8000
- Use /api prefix for all API routes
- Enable changeOrigin for proper CORS handling
- Proxy only in development mode
</proxy_configuration>

<build_optimization>
- Enable source maps for debugging (hidden in production)
- Configure manual chunks for vendor libraries
- Tree-shake unused code automatically
- Use dynamic imports for code splitting
- Optimize bundle size with rollup options
- Consider adding compression plugins (gzip/brotli) for production
- Use terser for minification with drop_console in production
- Configure asset naming for better caching (images, fonts, chunks)
- Set chunkSizeWarningLimit appropriately (default: 500kb)
- Enable reportCompressedSize for accurate bundle analysis
</build_optimization>

<dev_server>
- Run on port 3000 by default
- Enable HMR (Hot Module Replacement)
- Configure proper CORS headers
- Use proxy for API calls during development
</dev_server>

<strict_constraints>
- Do NOT use Next.js, Remix, or any SSR framework
- Do NOT configure server-side rendering
- Do NOT use Vercel-specific build configurations
- All builds must be static SPA bundles
- No server-side environment variables at runtime
</strict_constraints>
