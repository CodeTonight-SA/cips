# E2E Test Generation - Reference Material

**Parent:** [SKILL.md](./SKILL.md)

---

## Configuration Templates

### playwright.config.ts

```typescript
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [
    ['html'],
    ['json', { outputFile: 'playwright-report/results.json' }],
  ],
  use: {
    baseURL: '{{BASE_URL}}',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
    { name: 'webkit', use: { ...devices['Desktop Safari'] } },
    { name: 'Mobile Chrome', use: { ...devices['Pixel 5'] } },
    { name: 'Mobile Safari', use: { ...devices['iPhone 12'] } },
  ],
  webServer: {
    command: '{{DEV_COMMAND}}',
    url: '{{BASE_URL}}',
    reuseExistingServer: !process.env.CI,
    timeout: 120 * 1000,
  },
});
```

### vitest.config.ts

```typescript
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
import tsconfigPaths from 'vite-tsconfig-paths';

export default defineConfig({
  plugins: [react(), tsconfigPaths()],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: './vitest.setup.ts',
    css: true,
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html', 'lcov'],
      exclude: [
        'node_modules/', '.next/', 'dist/', 'build/',
        '**/*.config.{js,ts}', '**/test-utils/**',
        '**/mocks/**', '**/*.test.{ts,tsx}', '**/*.spec.{ts,tsx}',
      ],
      thresholds: {
        lines: 80,
        functions: 80,
        branches: 80,
        statements: 80,
      },
    },
  },
});
```

### vitest.setup.ts

```typescript
import '@testing-library/jest-dom';
import { expect, afterEach, beforeAll, afterAll } from 'vitest';
import { cleanup } from '@testing-library/react';
import { server } from './src/mocks/server';

beforeAll(() => {
  server.listen({ onUnhandledRequest: 'warn' });
});

afterEach(() => {
  cleanup();
  server.resetHandlers();
});

afterAll(() => {
  server.close();
});
```

---

## Test Infrastructure

### src/test-utils/index.tsx

```typescript
import { ReactElement, ReactNode } from 'react';
import { render } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

export function createTestQueryClient() {
  return new QueryClient({
    defaultOptions: {
      queries: { retry: false, gcTime: 0, staleTime: 0 },
      mutations: { retry: false },
    },
  });
}

export function renderWithProviders(ui: ReactElement) {
  const queryClient = createTestQueryClient();
  function Wrapper({ children }: { children: ReactNode }) {
    return (
      <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
    );
  }
  return { ...render(ui, { wrapper: Wrapper }), queryClient };
}
```

### src/mocks/handlers.ts

```typescript
import { http, HttpResponse } from 'msw';

export const handlers = [
  http.post('/api/auth/callback/credentials', async ({ request }) => {
    const { email, password } = await request.json();
    if (email === 'test@example.com' && password === 'password123') {
      return HttpResponse.json({
        user: { email, name: 'Test User', role: 'USER' },
      });
    }
    return HttpResponse.json({ error: 'Invalid credentials' }, { status: 401 });
  }),
  // Add handlers for detected API routes
];
```

### src/mocks/server.ts

```typescript
import { setupServer } from 'msw/node';
import { handlers } from './handlers';

export const server = setupServer(...handlers);
```

---

## E2E Test Templates

### e2e/auth.spec.ts

```typescript
import { test, expect } from '@playwright/test';

test.describe('Authentication', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('{{BASE_URL}}/login');
  });

  test('should login with valid credentials', async ({ page }) => {
    await page.fill('input[type="email"]', 'test@example.com');
    await page.fill('input[type="password"]', 'password123');
    await page.click('button[type="submit"]');

    await page.waitForURL('**/dashboard**');
    await expect(page).toHaveURL(/\/dashboard/);
  });

  test('should show error for invalid credentials', async ({ page }) => {
    await page.fill('input[type="email"]', 'invalid@example.com');
    await page.fill('input[type="password"]', 'wrongpassword');
    await page.click('button[type="submit"]');

    await expect(page.getByText(/invalid.*credentials/i)).toBeVisible({ timeout: 5000 });
  });

  test('should redirect to login for protected routes', async ({ page }) => {
    await page.goto('{{BASE_URL}}/dashboard');
    await page.waitForURL('**/login**');
    await expect(page).toHaveURL(/\/login/);
  });
});
```

### e2e/edge-cases.spec.ts

```typescript
import { test, expect } from '@playwright/test';

test.describe('Edge Cases & Error Handling', () => {
  test('should handle network errors gracefully', async ({ page }) => {
    await page.route('**/api/**', route => route.abort());
    await page.goto('{{BASE_URL}}');
    const errorMessage = page.getByText(/error|failed|try again/i);
    await expect(errorMessage).toBeVisible();
    await page.unroute('**/api/**');
  });

  test('should prevent XSS attacks', async ({ page }) => {
    await page.goto('{{BASE_URL}}');
    const input = page.locator('input').first();
    await input.fill('<script>alert("XSS")</script>');
    const scripts = await page.evaluate(() => {
      const scripts = document.querySelectorAll('script');
      return Array.from(scripts).some(s => s.textContent?.includes('alert'));
    });
    expect(scripts).toBe(false);
  });

  test('should be keyboard navigable', async ({ page }) => {
    await page.goto('{{BASE_URL}}');
    await page.keyboard.press('Tab');
    const focusedElement = await page.evaluate(() => document.activeElement?.tagName);
    expect(focusedElement).toMatch(/BUTTON|A|INPUT/);
  });

  test('should load within performance budget', async ({ page }) => {
    const startTime = Date.now();
    await page.goto('{{BASE_URL}}');
    const loadTime = Date.now() - startTime;
    expect(loadTime).toBeLessThan(5000);
  });
});

test.describe('Mobile Responsiveness', () => {
  test.use({ viewport: { width: 375, height: 667 } });

  test('should render mobile navigation', async ({ page }) => {
    await page.goto('{{BASE_URL}}');
    const mobileMenu = page.getByRole('button', { name: /menu|navigation/i });
    await expect(mobileMenu).toBeVisible();
  });
});

test.describe('Accessibility', () => {
  test('should have valid ARIA labels', async ({ page }) => {
    await page.goto('{{BASE_URL}}');
    const buttons = await page.getByRole('button').all();
    for (const button of buttons) {
      const ariaLabel = await button.getAttribute('aria-label');
      const text = await button.textContent();
      expect(ariaLabel || text).toBeTruthy();
    }
  });

  test('should have proper heading hierarchy', async ({ page }) => {
    await page.goto('{{BASE_URL}}');
    const h1Count = await page.locator('h1').count();
    expect(h1Count).toBe(1);
  });
});
```

---

## Unit Test Templates

### Service Test

```typescript
import { describe, it, expect } from 'vitest';
import { ServiceName } from './service-file';

describe('ServiceName', () => {
  describe('methodName', () => {
    it('handles success case', async () => {
      const result = await ServiceName.methodName(params);
      expect(result.data).toBeDefined();
    });

    it('handles error case', async () => {
      await expect(ServiceName.methodName(invalidParams)).rejects.toThrow();
    });
  });
});
```

### Component Test

```typescript
import { render, screen, fireEvent } from '@testing-library/react';
import { ComponentName } from './component-file';

describe('ComponentName', () => {
  it('renders correctly', () => {
    render(<ComponentName />);
    expect(screen.getByText('Expected Text')).toBeInTheDocument();
  });

  it('handles user interaction', async () => {
    const handleClick = vi.fn();
    render(<ComponentName onClick={handleClick} />);
    fireEvent.click(screen.getByRole('button'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });
});
```

---

## GitHub Actions Workflow

### .github/workflows/test.yml

```yaml
name: Test Suite

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [20.x]
    steps:
      - uses: actions/checkout@v4
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'
      - name: Install dependencies
        run: npm ci
      - name: Run unit tests with coverage
        run: npm run test:coverage
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v4
        if: env.CODECOV_TOKEN
        with:
          files: ./coverage/coverage-final.json
      - name: Upload coverage artifact
        uses: actions/upload-artifact@v4
        with:
          name: coverage-report
          path: coverage/
          retention-days: 30

  e2e-tests:
    runs-on: ubuntu-latest
    needs: unit-tests
    steps:
      - uses: actions/checkout@v4
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 20.x
          cache: 'npm'
      - name: Install dependencies
        run: npm ci
      - name: Install Playwright Browsers
        run: npx playwright install --with-deps
      - name: Build application
        run: npm run build
      - name: Run E2E tests
        run: npm run test:e2e
      - name: Upload Playwright report
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: playwright-report
          path: playwright-report/
          retention-days: 30

  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 20.x
          cache: 'npm'
      - name: Install dependencies
        run: npm ci
      - name: Run ESLint
        run: npm run lint
      - name: Run TypeScript type check
        run: npx tsc --noEmit
```

---

## NPM Scripts

```json
{
  "scripts": {
    "test": "vitest",
    "test:watch": "vitest --ui",
    "test:coverage": "vitest --coverage",
    "test:e2e": "playwright test",
    "test:e2e:ui": "playwright test --ui",
    "test:e2e:codegen": "playwright codegen",
    "test:e2e:debug": "playwright test --debug"
  }
}
```

---

## Best Practices

### 1. Test Independence
- Each test fully isolated
- Use `beforeEach` for clean slate
- MSW handlers reset after each test

### 2. AAA Pattern
```typescript
it('increments counter', () => {
  // Arrange
  render(<Counter />);
  // Act
  fireEvent.click(screen.getByRole('button'));
  // Assert
  expect(screen.getByText('Count: 1')).toBeInTheDocument();
});
```

### 3. Avoid Flaky Tests
- Use `waitFor` instead of hardcoded timeouts
- Use `page.waitForURL` for navigation
- Use `toBeVisible()` with explicit timeouts

### 4. Test User Behavior
```typescript
// ❌ Bad - implementation details
expect(component.state.count).toBe(5);

// ✅ Good - user-facing behavior
expect(screen.getByText('Count: 5')).toBeInTheDocument();
```

### 5. Selector Priority
1. `getByRole` (accessibility-first)
2. `getByLabel` (form inputs)
3. `getByText` (user-visible text)
4. `getByTestId` (last resort)

---

## Error Handling

### No Framework Detected
```text
❌ Error: No supported framework detected
Supported: Next.js, React, Vue, Svelte, Remix

Please install a supported framework first:
  npm install next react react-dom
```

### Tests Already Exist
```text
⚠️ Warning: Test infrastructure already exists
Found: playwright.config.ts, vitest.config.ts

Options:
1. Skip generation (exit)
2. Update existing (merge configs)
3. Overwrite (replace all)
```

### Dependency Installation Failed
```text
❌ Error: Failed to install dependencies

Troubleshooting:
1. Check Node version (requires 18+)
2. Clear npm cache: npm cache clean --force
3. Delete node_modules and reinstall
```

---

## Resources

- [Playwright Documentation](https://playwright.dev/)
- [Vitest Documentation](https://vitest.dev/)
- [React Testing Library](https://testing-library.com/react)
- [Mock Service Worker](https://mswjs.io/)
