const { test, expect } = require('@playwright/test');

// Deliberately skipped in regular CI: a live run creates a real Supabase
// anonymous Auth user. This is a one-off, opt-in, disposable-project check.
test('live Supabase anonymous login survives reload and sign-out persists', async ({ page }, testInfo) => {
  test.skip(process.env.RUN_SUPABASE_WEB_LIVE !== '1', 'Requires explicit one-time live Supabase QA opt-in');

  const pageErrors = [];
  page.on('pageerror', error => pageErrors.push(error.stack || String(error)));

  async function activateFlutterAccessibility() {
    await expect(page.locator('#splash'), 'Flutter web splash must disappear').toHaveCount(0, { timeout: 35_000 });
    const activator = page.getByRole('button', { name: 'Enable accessibility' });
    if (await activator.count()) await activator.dispatchEvent('click');
  }

  try {
    await page.goto('/', { waitUntil: 'domcontentloaded' });
    await activateFlutterAccessibility();

    const loginButton = page.getByText('Sign in Anonymously', { exact: true });
    await expect(loginButton, 'real auth action should be present with configured SDK').toBeVisible({ timeout: 25_000 });
    await expect(page.getByText('Mock Sign In', { exact: true })).toHaveCount(0);

    const signupResponse = page.waitForResponse(response =>
      response.url().startsWith(process.env.SUPABASE_URL + '/auth/v1/signup') &&
      response.request().method() === 'POST',
      { timeout: 45_000 },
    );
    await loginButton.click();
    const response = await signupResponse;
    expect(response.status(), 'Supabase Auth anonymous sign-up HTTP status').toBeGreaterThanOrEqual(200);
    expect(response.status(), 'Supabase Auth anonymous sign-up HTTP status').toBeLessThan(300);

    // Only a real Supabase Auth user can reach the root in configured mode.
    await expect(page.getByText('Profile', { exact: true }).first(), 'root tabs after login').toBeVisible({ timeout: 30_000 });
    await expect(loginButton).toHaveCount(0);

    await page.reload({ waitUntil: 'domcontentloaded' });
    await activateFlutterAccessibility();
    await expect(page.getByText('Profile', { exact: true }).first(), 'session persists across full web reload').toBeVisible({ timeout: 30_000 });
    await expect(page.getByText('Sign in Anonymously', { exact: true })).toHaveCount(0);

    await page.getByText('Profile', { exact: true }).first().click();
    const signOut = page.getByText('Sign out', { exact: true });
    await expect(signOut).toBeVisible({ timeout: 20_000 });
    await signOut.click();
    await expect(page.getByText('Sign in Anonymously', { exact: true }), 'auth screen after sign-out').toBeVisible({ timeout: 25_000 });

    await page.reload({ waitUntil: 'domcontentloaded' });
    await activateFlutterAccessibility();
    await expect(page.getByText('Sign in Anonymously', { exact: true }), 'signed out across reload').toBeVisible({ timeout: 30_000 });
    await expect(page.getByText('Mock Sign In', { exact: true })).toHaveCount(0);

    expect(pageErrors, 'no uncaught Flutter/browser errors').toEqual([]);
  } finally {
    // Store only error diagnostics, never a session JWT or refresh token.
    await testInfo.attach('browser-page-errors.txt', {
      body: Buffer.from(pageErrors.join('\n') || '(none)'),
      contentType: 'text/plain',
    });
  }
});
