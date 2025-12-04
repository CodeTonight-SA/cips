---
name: e2e-test-generation
description: Automated E2E test infrastructure setup with Playwright, Vitest, MSW, and GitHub Actions. Generates 80%+ coverage tests based on REDR-prototype patterns.
command: /generate-e2e-tests
---

# E2E Test Generation Skill

**Purpose**: Automate complete end-to-end testing infrastructure setup with production-ready patterns from proven implementations (REDR-prototype: 366 tests, 80%+ coverage).

**Token Budget**: ≤15,000 tokens per full implementation

**Activation**: User mentions "add E2E tests", "setup testing", "test automation", or invokes `/generate-e2e-tests`

---

## What It Does

Generates a complete, production-ready testing infrastructure including:

1. **Test Frameworks**: Playwright (E2E) + Vitest (unit/integration) + React Testing Library
2. **API Mocking**: Mock Service Worker (MSW) for network-level mocking
3. **Configuration**: Cross-browser testing, mobile responsiveness, 80% coverage thresholds
4. **Test Files**: Auth flows, feature workflows, edge cases, unit tests
5. **CI/CD**: GitHub Actions workflow with test reports and coverage uploads
6. **Documentation**: Comprehensive TESTING.md with project-specific examples

---

## Trigger Conditions

### Auto-activate when:

- User says "add E2E tests", "setup Playwright", "generate tests", "test automation"
- Detects frontend framework without test infrastructure
- Pull request requires test coverage
- User explicitly invokes `/generate-e2e-tests`

### Do NOT activate when:

- Tests already exist (playwright.config.ts or vitest.config.ts present)
- Backend-only project (no frontend framework detected)
- User explicitly declines testing setup

---

## Supported Frameworks

| Framework | Detection | Test Strategy |
|-----------|-----------|---------------|
| **Next.js** | `next` in package.json | App Router + Pages Router support |
| **React** | `react` without Next | Vite/CRA detection |
| **Vue** | `vue` in package.json | Vue Test Utils integration |
| **Svelte** | `svelte` in package.json | Vitest + Testing Library |
| **Remix** | `@remix-run` in package.json | Remix-specific fixtures |

---

## Dependencies Matrix

### Core Dependencies (All Frameworks)

```json
{
  "@playwright/test": "^1.40.0",
  "vitest": "^1.0.4",
  "@vitest/ui": "^1.0.4",
  "msw": "^2.0.11"
}
```text

### React/Next.js Additional
```json
{
  "@testing-library/react": "^14.1.2",
  "@testing-library/jest-dom": "^6.1.5",
  "@testing-library/user-event": "^14.5.1"
}
```text

### Vue Additional
```json
{
  "@vue/test-utils": "^2.4.3",
  "@testing-library/vue": "^8.0.0"
}
```text

### Svelte Additional
```json
{
  "@testing-library/svelte": "^4.0.5"
}
```text

---

## Workflow

### Step 1: Framework Detection

```typescript
async function detectFramework(): Promise<FrameworkInfo> {
  const packageJson = JSON.parse(await readFile('package.json', 'utf-8'));
  const deps = { ...packageJson.dependencies, ...packageJson.devDependencies };

  if (deps.next) return { name: 'Next.js', type: 'react', router: 'app' };
  if (deps.react) return { name: 'React', type: 'react', bundler: 'vite' };
  if (deps.vue) return { name: 'Vue', type: 'vue', version: 3 };
  if (deps.svelte) return { name: 'Svelte', type: 'svelte' };
  if (deps['@remix-run/react']) return { name: 'Remix', type: 'react', router: 'remix' };

  throw new Error('No supported framework detected');
}
```text

### Detection Priority:
1. Check package.json dependencies
2. Detect app structure (app/, pages/, src/)
3. Identify auth system (NextAuth, Clerk, Supabase)
4. Find API routes
5. Detect component libraries (shadcn, MUI, etc.)

---

### Step 2: Dependency Installation

```bash
# Check for existing test setup
if [ -f "playwright.config.ts" ] || [ -f "vitest.config.ts" ]; then
  echo "⚠️ Tests already exist. Continue? (y/n)"
  # Prompt user, exit if declined
fi

# Install dependencies based on framework
npm install -D @playwright/test vitest @vitest/ui msw @testing-library/react @testing-library/jest-dom @testing-library/user-event

# Install Playwright browsers
npx playwright install --with-deps

# Verify installation
npx playwright --version
npx vitest --version
```text

**Token Optimization**: Batch all installations in single command

---

### Step 3: Configuration Files

#### `playwright.config.ts`
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
```text

### Placeholders
- `{{BASE_URL}}` → From package.json scripts or default `http://localhost:3000`
- `{{DEV_COMMAND}}` → From package.json `dev` script

#### `vitest.config.ts`
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
        lines: {{COVERAGE_THRESHOLD}},
        functions: {{COVERAGE_THRESHOLD}},
        branches: {{COVERAGE_THRESHOLD}},
        statements: {{COVERAGE_THRESHOLD}},
      },
    },
  },
});
```text

### Placeholders
- `{{COVERAGE_THRESHOLD}}` → Default 80, user-configurable

#### `vitest.setup.ts`
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
```text

---

### Step 4: Test Infrastructure

#### `src/test-utils/index.tsx`
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
```text

#### `src/mocks/handlers.ts`
```typescript
import { http, HttpResponse } from 'msw';

export const handlers = [
  // Auth endpoints (if NextAuth detected)
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
  {{API_HANDLERS}}
];
```text

### Placeholder
- `{{API_HANDLERS}}` → Generated from detected API routes in app/ or pages/api/

#### `src/mocks/server.ts`
```typescript
import { setupServer } from 'msw/node';
import { handlers } from './handlers';

export const server = setupServer(...handlers);
```text

---

### Step 5: E2E Test Generation

#### `e2e/auth.spec.ts` (if auth detected)
```typescript
import { test, expect } from '@playwright/test';

test.describe('Authentication', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('{{BASE_URL}}/login');
  });

  test('should login with valid credentials and redirect to dashboard', async ({ page }) => {
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

  test('should redirect to login when accessing protected route', async ({ page }) => {
    await page.goto('{{BASE_URL}}/dashboard');
    await page.waitForURL('**/login**');
    await expect(page).toHaveURL(/\/login/);
  });
});
```text

#### `e2e/edge-cases.spec.ts`
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

  test('should prevent XSS attacks in inputs', async ({ page }) => {
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

  test('should load homepage within performance budget', async ({ page }) => {
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

  test('should handle touch events', async ({ page }) => {
    await page.goto('{{BASE_URL}}');
    const button = page.getByRole('button').first();
    await button.tap();

    // Verify touch interaction worked
    await expect(page).not.toHaveURL('{{BASE_URL}}');
  });
});

test.describe('Accessibility', () => {
  test('should have valid ARIA labels on interactive elements', async ({ page }) => {
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
```text

---

### Step 6: Unit Test Generation

#### Service Test Template
```typescript
import { describe, it, expect } from 'vitest';
import { {{SERVICE_NAME}} } from './{{SERVICE_FILE}}';

describe('{{SERVICE_NAME}}', () => {
  describe('{{METHOD_NAME}}', () => {
    it('handles success case', async () => {
      const result = await {{SERVICE_NAME}}.{{METHOD_NAME}}({{PARAMS}});
      expect(result.data).toBeDefined();
    });

    it('handles error case', async () => {
      await expect({{SERVICE_NAME}}.{{METHOD_NAME}}({{INVALID_PARAMS}})).rejects.toThrow();
    });
  });
});
```text

#### Component Test Template
```typescript
import { render, screen, fireEvent } from '@testing-library/react';
import { {{COMPONENT_NAME}} } from './{{COMPONENT_FILE}}';

describe('{{COMPONENT_NAME}}', () => {
  it('renders correctly', () => {
    render(<{{COMPONENT_NAME}} {{PROPS}} />);
    expect(screen.getByText('{{EXPECTED_TEXT}}')).toBeInTheDocument();
  });

  it('handles user interaction', async () => {
    const handleClick = vi.fn();
    render(<{{COMPONENT_NAME}} onClick={handleClick} />);

    fireEvent.click(screen.getByRole('button'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });
});
```text

---

### Step 7: GitHub Actions Workflow

#### `.github/workflows/test.yml`
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
      - name: Upload coverage to Codecov (optional)
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
```text

---

### Step 8: NPM Scripts

Add to `package.json`:
```json
{
  "scripts": {
    "test": "vitest",
    "test:watch": "vitest --ui",
    "test:coverage": "vitest --coverage",
    "test:e2e": "playwright test",
    "test:e2e:ui": "playwright test --ui",
    "test:e2e:codegen": "playwright codegen {{BASE_URL}}",
    "test:e2e:debug": "playwright test --debug"
  }
}
```text

---

### Step 9: Documentation (TESTING.md)

Generate comprehensive documentation with:
- Overview of test stack
- Quick start commands
- Project structure
- Testing layers (service, hook, component, E2E)
- MSW setup
- Coverage thresholds
- CI/CD pipeline
- Writing new tests (templates)
- Best practices
- Common pitfalls
- Debugging guide
- Troubleshooting

**Length**: ≈600 lines (based on REDR-prototype TESTING.md)

---

## Best Practices (From REDR-Prototype)

### 1. Test Independence
- Each test fully isolated
- Use `beforeEach` for clean slate
- No shared state between tests
- MSW handlers reset after each test

### 2. AAA Pattern (Arrange-Act-Assert)
```typescript
it('increments counter when button clicked', () => {
  // Arrange
  render(<Counter />);

  // Act
  fireEvent.click(screen.getByRole('button'));

  // Assert
  expect(screen.getByText('Count: 1')).toBeInTheDocument();
});
```text

### 3. Avoid Flaky Tests
- Use `waitFor` instead of hardcoded timeouts
- Use `page.waitForURL` for navigation
- Use `toBeVisible()` with explicit timeouts
- Proper async/await usage throughout

### 4. Test User Behavior, Not Implementation
```typescript
// ❌ Bad - Testing implementation details
expect(component.state.count).toBe(5);

// ✅ Good - Testing user-facing behavior
expect(screen.getByText('Count: 5')).toBeInTheDocument();
```text

### 5. Selector Priority
1. `getByRole` (accessibility-first)
2. `getByLabel` (form inputs)
3. `getByText` (user-visible text)
4. `getByTestId` (last resort)

### 6. Async Handling
Always use:
- `await page.waitForURL()` after navigation
- `await expect().toBeVisible({ timeout })` with explicit timeouts
- `await page.waitForLoadState('networkidle')` for SPAs
- NEVER use hardcoded `setTimeout()`

### 7. Cross-Browser Testing
Test on:
- Chromium (primary)
- Firefox (CSS compatibility)
- WebKit (Safari issues)
- Mobile Chrome (Android)
- Mobile Safari (iOS)

---

## Efficiency Rules

### Token Optimization
1. **Batch operations**: Install all dependencies in single command
2. **Template reuse**: Use placeholders, not code generation
3. **Parallel file creation**: Write multiple files in single response
4. **Skip unnecessary reads**: Trust framework detection, don't re-read package.json

### Time Optimization
1. **Auto-detect**: No user prompts for obvious choices
2. **Smart defaults**: 80% coverage, cross-browser, mobile
3. **Validate after**: Run tests after generation, fix if needed

### Quality Gates
1. **Verify installation**: Check `npx playwright --version`
2. **Run initial test**: Execute `npm run test` to verify setup
3. **TypeScript check**: Ensure no type errors in generated files
4. **Lint check**: Ensure generated code passes ESLint

---

## Success Metrics

### Coverage
- **Target**: 80%+ coverage on all metrics
- **Files**: 5+ E2E specs, 10+ unit tests
- **Tests**: 50+ total tests generated

### CI/CD
- **Workflow**: Valid GitHub Actions YAML
- **Jobs**: Unit tests, E2E tests, lint
- **Artifacts**: Coverage reports, Playwright reports

### Documentation
- **TESTING.md**: Comprehensive guide (≈600 lines)
- **Examples**: Project-specific code samples
- **Commands**: All npm scripts documented

### Token Budget
- **Target**: ≤15,000 tokens
- **Breakdown**:
  - Detection: 1k
  - Installation: 1k
  - Config files: 2k
  - Test files: 6k
  - CI/CD: 2k
  - Documentation: 3k

---

## Command Options

```bash
# Basic usage
/generate-e2e-tests

# With options
/generate-e2e-tests --framework=nextjs --coverage=90

# Skip certain steps
/generate-e2e-tests --skip-e2e  # Only unit tests
/generate-e2e-tests --skip-github-actions  # No CI/CD

# Dry run (show what would be created)
/generate-e2e-tests --dry-run
```text

---

## Error Handling

### No Framework Detected
```text
❌ Error: No supported framework detected
Checked: package.json dependencies
Supported: Next.js, React, Vue, Svelte, Remix

Please install a supported framework first:
  npm install next react react-dom
```text

### Tests Already Exist
```text
⚠️ Warning: Test infrastructure already exists
Found: playwright.config.ts, vitest.config.ts

Options:
1. Skip generation (exit)
2. Update existing (merge configs)
3. Overwrite (replace all)

Choice: _
```text

### Dependency Installation Failed
```text
❌ Error: Failed to install dependencies
Command: npm install -D @playwright/test

Troubleshooting:
1. Check Node version (requires 18+)
2. Clear npm cache: npm cache clean --force
3. Delete node_modules and reinstall
4. Check network connection
```text

---

## Integration with Other Skills

### mobile-responsive-ui
- Auto-adds mobile E2E tests to generated suite
- Includes viewport tests (iOS, Android)

### pr-automation
- Mentions test coverage in PR descriptions
- Links to coverage reports

### github-actions-setup
- Integrates test workflow with existing CI/CD
- Adds test badges to README

### self-improvement-engine
- Tracks skill usage patterns
- Monitors token efficiency
- Generates improvements from failures

---

## Maintenance

### Updating Templates
Edit templates in `~/.claude/skills/e2e-test-generation/templates/`

### Adding Framework Support
1. Add detection logic in `detectFramework()`
2. Create framework-specific templates
3. Update dependency matrix
4. Add to SKILL.md documentation

### Improving Test Coverage
1. Analyze generated test failures
2. Identify missing patterns
3. Update templates with new patterns
4. Regenerate tests

---

## Resources

- [Playwright Documentation](https://playwright.dev/)
- [Vitest Documentation](https://vitest.dev/)
- [React Testing Library](https://testing-library.com/react)
- [Mock Service Worker](https://mswjs.io/)
- [REDR-Prototype TESTING.md](/Users/lauriescheepers/CodeTonight/REDR-prototype/TESTING.md)

---

**Created**: 2025-11-14
**Based on**: REDR-prototype (366 tests, 80%+ coverage)
**Token Budget**: ≤15,000 tokens per implementation
**Maintainer**: LC Scheepers
