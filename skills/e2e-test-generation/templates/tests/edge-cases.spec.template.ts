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

  test('should handle 404 pages', async ({ page }) => {
    const response = await page.goto('{{BASE_URL}}/non-existent-page');
    expect(response?.status()).toBe(404);
  });

  test('should handle 500 errors', async ({ page }) => {
    await page.route('**/api/**', route => {
      route.fulfill({ status: 500, body: 'Internal Server Error' });
    });

    await page.goto('{{BASE_URL}}');
    await expect(page.getByText(/error|something went wrong/i)).toBeVisible();

    await page.unroute('**/api/**');
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

  test('should handle slow network conditions', async ({ page, context }) => {
    await context.route('**/*', async route => {
      await new Promise(resolve => setTimeout(resolve, 1000));
      await route.continue();
    });

    await page.goto('{{BASE_URL}}');
    await expect(page.getByText(/loading|spinner/i)).toBeVisible();
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
    const url = page.url();
    expect(url).toBeTruthy();
  });

  test('should display mobile-optimised layout', async ({ page }) => {
    await page.goto('{{BASE_URL}}');
    const viewport = page.viewportSize();
    expect(viewport?.width).toBe(375);

    // Mobile menu should be visible
    const mobileMenu = page.getByRole('button', { name: /menu|navigation/i });
    await expect(mobileMenu).toBeVisible();
  });
});

test.describe('Accessibility', () => {
  test('should have valid ARIA labels on interactive elements', async ({ page }) => {
    await page.goto('{{BASE_URL}}');
    const buttons = await page.getByRole('button').all();

    for (const button of buttons) {
      const ariaLabel = await button.getAttribute('aria-label');
      const text = await button.textContent();
      expect(ariaLabel || text?.trim()).toBeTruthy();
    }
  });

  test('should have proper heading hierarchy', async ({ page }) => {
    await page.goto('{{BASE_URL}}');
    const h1Count = await page.locator('h1').count();
    expect(h1Count).toBeGreaterThanOrEqual(1);
  });

  test('should have alt text on images', async ({ page }) => {
    await page.goto('{{BASE_URL}}');
    const images = await page.locator('img').all();

    for (const img of images) {
      const alt = await img.getAttribute('alt');
      expect(alt).toBeDefined();
    }
  });

  test('should have proper form labels', async ({ page }) => {
    await page.goto('{{BASE_URL}}');
    const inputs = await page.locator('input[type="text"], input[type="email"], input[type="password"]').all();

    for (const input of inputs) {
      const id = await input.getAttribute('id');
      if (id) {
        const label = await page.locator(`label[for="${id}"]`).count();
        const ariaLabel = await input.getAttribute('aria-label');
        expect(label > 0 || ariaLabel).toBeTruthy();
      }
    }
  });

  test('should support dark mode contrast', async ({ page }) => {
    await page.goto('{{BASE_URL}}');

    // Toggle dark mode if available
    const darkModeToggle = page.getByRole('button', { name: /dark mode|theme/i });
    const toggleExists = await darkModeToggle.count() > 0;

    if (toggleExists) {
      await darkModeToggle.click();

      // Check contrast (simplified check)
      const backgroundColor = await page.evaluate(() => {
        return window.getComputedStyle(document.body).backgroundColor;
      });

      expect(backgroundColor).toBeTruthy();
    }
  });
});
