import { test, expect } from '@playwright/test';

test.describe('Static Pages Routing', () => {
  test('should load the home page and verify layout sections', async ({ page }) => {
    await page.goto('/');
    
    // Verify home page sections are rendered
    await expect(page.locator('app-carousel')).toBeVisible();
    await expect(page.locator('app-partners')).toBeVisible();
    await expect(page.locator('app-demo')).toBeVisible();
    await expect(page.locator('app-offering')).toBeVisible();
  });

  test('should navigate to Privacy Policy via footer link', async ({ page }) => {
    await page.goto('/');
    
    // Click the Privacy Policy link in the footer
    await page.click('footer a:has-text("Privacy Policy")');
    
    // Verify the URL changed
    await expect(page).toHaveURL(/.*\/privacy-policy/);
    
    // Verify the Privacy Policy content is rendered
    await expect(page.locator('h1', { hasText: 'Privacy Policy' })).toBeVisible();
    
    // Verify home sections are no longer visible
    await expect(page.locator('app-carousel')).not.toBeVisible();
  });

  test('should navigate to Terms of Service via footer link', async ({ page }) => {
    await page.goto('/');
    
    // Click the Terms of Service link in the footer
    await page.click('footer a:has-text("Terms of Service")');
    
    // Verify the URL changed
    await expect(page).toHaveURL(/.*\/terms-of-service/);
    
    // Verify the Terms of Service content is rendered
    await expect(page.locator('h1', { hasText: 'Terms of Service' })).toBeVisible();
  });

  test('should navigate to 404 for unknown routes', async ({ page }) => {
    const response = await page.goto('/unknown-page-123xyz');
    
    // Angular router handles 404 client-side, so HTTP status might be 200, 
    // but we can verify the 404 component is rendered.
    await expect(page.locator('h1', { hasText: '404 - Page Not Found' })).toBeVisible();
  });
});
