# Generate E2E Tests

Automatically generate a complete, production-ready E2E testing infrastructure based on proven production patterns (366 tests, 80%+ coverage).

## What This Command Does

1. **Detects Framework**: Identifies your frontend framework (Next.js, React, Vue, Svelte, Remix)
2. **Installs Dependencies**: Adds Playwright, Vitest, MSW, React Testing Library
3. **Creates Configuration**: Generates playwright.config.ts, vitest.config.ts, vitest.setup.ts
4. **Sets Up Mocking**: Creates MSW handlers and server setup
5. **Generates Tests**: Creates E2E tests (auth, features, edge cases) and unit tests
6. **Adds CI/CD**: Creates GitHub Actions workflow for automated testing
7. **Generates Documentation**: Creates comprehensive TESTING.md guide
8. **Updates package.json**: Adds test scripts

## Generated Artifacts

- ✅ 3 config files (playwright, vitest, setup)
- ✅ 2 infrastructure files (test-utils, MSW handlers/server)
- ✅ 5+ E2E test files (auth.spec.ts, edge-cases.spec.ts, etc.)
- ✅ Test templates (service, component, hook)
- ✅ 1 GitHub Actions workflow (.github/workflows/test.yml)
- ✅ 1 comprehensive TESTING.md (≈600 lines)
- ✅ NPM scripts in package.json

## Test Coverage

- **Target**: 80%+ coverage enforced via vitest.config.ts
- **Cross-Browser**: Chrome, Firefox, Safari
- **Mobile**: iOS (iPhone 12), Android (Pixel 5)
- **Accessibility**: ARIA labels, keyboard navigation, heading hierarchy
- **Performance**: Load time budgets, network error handling
- **Security**: XSS prevention testing

## Usage

```bash
# Basic usage (auto-detects framework)
/generate-e2e-tests

# With options
/generate-e2e-tests --coverage=90
/generate-e2e-tests --skip-e2e  # Only unit tests
/generate-e2e-tests --skip-github-actions  # No CI/CD
/generate-e2e-tests --dry-run  # Preview without creating files
```text

## Options

| Option | Description | Default |
|--------|-------------|---------|
| `--framework` | Specify framework (nextjs, react, vue, svelte) | Auto-detect |
| `--coverage` | Coverage threshold (0-100) | 80 |
| `--skip-e2e` | Skip E2E tests, only unit tests | false |
| `--skip-github-actions` | Skip GitHub Actions workflow | false |
| `--dry-run` | Show what would be created without creating files | false |

## Example Output

```text
Detecting framework... Next.js 14 with App Router ✓
Installing dependencies (Playwright, Vitest, MSW, RTL)... ✓
Creating config files (playwright.config.ts, vitest.config.ts)... ✓
Setting up MSW (handlers, server)... ✓
Generating E2E tests:
  - auth.spec.ts (11 tests) ✓
  - edge-cases.spec.ts (25 tests) ✓
Generating test templates... ✓
Creating GitHub Actions workflow... ✓
Generating TESTING.md documentation... ✓

Summary:
- 36+ tests created across 7 files
- 80% coverage threshold configured
- CI/CD pipeline ready
- Token usage: 12,847 / 15,000 target

Next steps:
1. Run: npm run test:coverage
2. Run: npm run test:e2e
3. Review: TESTING.md for guidelines
```text

## Prerequisites

- Node.js 18+ installed
- Frontend framework (Next.js, React, Vue, Svelte, or Remix)
- package.json in project root

## After Generation

Run these commands to verify setup:

```bash
# Install dependencies
npm install

# Run unit tests
npm run test

# Run unit tests with coverage
npm run test:coverage

# Run E2E tests
npm run test:e2e

# Run E2E tests in UI mode
npm run test:e2e:ui

# Generate E2E test code
npm run test:e2e:codegen
```text

## Based On

This skill codifies patterns from production experience:
- 366 total tests (78 E2E + 288 unit/integration)
- 80%+ code coverage achieved
- Cross-browser testing (5 browsers/devices)
- Comprehensive error handling and edge cases
- Production-ready CI/CD pipeline

## Token Budget

≤15,000 tokens per full implementation

## Learn More

After generation, see the created `TESTING.md` file for:
- Test writing guidelines
- Best practices
- Debugging tips
- Common pitfalls
- Troubleshooting guide
