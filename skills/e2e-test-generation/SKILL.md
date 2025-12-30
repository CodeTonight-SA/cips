---
name: generating-e2e-tests
description: Automated E2E test infrastructure setup with Playwright, Vitest, MSW, and GitHub Actions. Use when user mentions add E2E tests, setup testing, or invokes /generate-e2e-tests.
status: Active
version: 1.0.0
triggers:
  - /generate-e2e-tests
  - "add E2E tests"
  - "setup testing"
---

# E2E Test Generation Skill

**Purpose:** Automate complete end-to-end testing infrastructure setup with production-ready patterns (REDR-prototype: 366 tests, 80%+ coverage).

**Token Budget:** ≤15,000 tokens per full implementation

**Reference:** See [reference.md](./reference.md) for full config templates, test examples, and GitHub Actions workflow.

---

## What It Does

Generates a complete, production-ready testing infrastructure:

1. **Test Frameworks**: Playwright (E2E) + Vitest (unit/integration) + React Testing Library
2. **API Mocking**: Mock Service Worker (MSW) for network-level mocking
3. **Configuration**: Cross-browser testing, mobile responsiveness, 80% coverage thresholds
4. **Test Files**: Auth flows, feature workflows, edge cases, unit tests
5. **CI/CD**: GitHub Actions workflow with test reports
6. **Documentation**: Comprehensive TESTING.md

---

## Trigger Conditions

### Auto-activate when:
- User says "add E2E tests", "setup Playwright", "generate tests"
- Detects frontend framework without test infrastructure
- User explicitly invokes `/generate-e2e-tests`

### Do NOT activate when:
- Tests already exist (playwright.config.ts or vitest.config.ts present)
- Backend-only project
- User explicitly declines

---

## Supported Frameworks

| Framework | Detection | Test Strategy |
|-----------|-----------|---------------|
| **Next.js** | `next` in package.json | App Router + Pages Router |
| **React** | `react` without Next | Vite/CRA detection |
| **Vue** | `vue` in package.json | Vue Test Utils |
| **Svelte** | `svelte` in package.json | Vitest + Testing Library |
| **Remix** | `@remix-run` in package.json | Remix-specific fixtures |

---

## Dependencies

### Core (All Frameworks)
```json
{
  "@playwright/test": "^1.40.0",
  "vitest": "^1.0.4",
  "@vitest/ui": "^1.0.4",
  "msw": "^2.0.11"
}
```

### React/Next.js Additional
```json
{
  "@testing-library/react": "^14.1.2",
  "@testing-library/jest-dom": "^6.1.5",
  "@testing-library/user-event": "^14.5.1"
}
```

---

## Workflow

### Step 1: Framework Detection
- Check package.json dependencies
- Detect app structure (app/, pages/, src/)
- Identify auth system (NextAuth, Clerk, Supabase)

### Step 2: Dependency Installation
```bash
npm install -D @playwright/test vitest @vitest/ui msw @testing-library/react @testing-library/jest-dom @testing-library/user-event
npx playwright install --with-deps
```

### Step 3: Configuration Files
- `playwright.config.ts` - Cross-browser, mobile, CI settings
- `vitest.config.ts` - Coverage thresholds (80%)
- `vitest.setup.ts` - MSW integration

### Step 4: Test Infrastructure
- `src/test-utils/index.tsx` - Render with providers
- `src/mocks/handlers.ts` - API route handlers
- `src/mocks/server.ts` - MSW setup

### Step 5: Test Generation
- `e2e/auth.spec.ts` - Authentication flows
- `e2e/edge-cases.spec.ts` - Error handling, accessibility

### Step 6: GitHub Actions
- `.github/workflows/test.yml` - Unit + E2E + lint jobs

### Step 7: NPM Scripts
```json
{
  "test": "vitest",
  "test:coverage": "vitest --coverage",
  "test:e2e": "playwright test",
  "test:e2e:ui": "playwright test --ui"
}
```

---

## Best Practices

### 1. Test Independence
Each test fully isolated, MSW handlers reset after each test.

### 2. AAA Pattern
Arrange → Act → Assert

### 3. Avoid Flaky Tests
- Use `waitFor` instead of hardcoded timeouts
- Use `page.waitForURL` for navigation
- Use `toBeVisible()` with explicit timeouts

### 4. Test User Behavior
```typescript
// ❌ Bad
expect(component.state.count).toBe(5);

// ✅ Good
expect(screen.getByText('Count: 5')).toBeInTheDocument();
```

### 5. Selector Priority
1. `getByRole` (accessibility-first)
2. `getByLabel` (form inputs)
3. `getByText` (user-visible text)
4. `getByTestId` (last resort)

---

## Efficiency Rules

### Token Optimization
- Batch operations: Install all dependencies in single command
- Template reuse: Use placeholders, not code generation
- Parallel file creation: Write multiple files in single response

### Quality Gates
1. Verify installation: `npx playwright --version`
2. Run initial test: `npm run test`
3. TypeScript check: No type errors
4. Lint check: ESLint passes

---

## Success Metrics

| Metric | Target |
|--------|--------|
| Coverage | 80%+ on all metrics |
| E2E Specs | 5+ files |
| Total Tests | 50+ tests |
| Token Budget | ≤15,000 |

---

## Command Options

```bash
/generate-e2e-tests                     # Basic usage
/generate-e2e-tests --coverage=90       # Custom threshold
/generate-e2e-tests --skip-e2e          # Only unit tests
/generate-e2e-tests --dry-run           # Preview
```

---

## Integration

| Skill | Usage |
|-------|-------|
| `mobile-responsive-ui` | Auto-adds mobile E2E tests |
| `pr-automation` | Mentions coverage in PRs |
| `github-actions-setup` | Integrates with CI/CD |

---

**Skill Status:** ✅ Active
**Maintainer:** LC Scheepers
**Last Updated:** 2025-11-14
**Based on:** REDR-prototype (366 tests, 80%+ coverage)

⛓⟿∞
