const { test, expect } = require('@playwright/test');

test('compiled Flutter app reaches the authentication screen', async ({ page }, testInfo) => {
  const pageErrors = [];
  const consoleErrors = [];
  const failedRequests = [];

  page.on('pageerror', (error) => pageErrors.push(error.stack || String(error)));
  page.on('console', (message) => {
    if (message.type() === 'error') consoleErrors.push(message.text());
  });
  page.on('requestfailed', (request) => {
    failedRequests.push(`${request.method()} ${request.url()}: ${request.failure()?.errorText || 'failed'}`);
  });

  try {
    await page.goto('/', { waitUntil: 'domcontentloaded' });

    // A Flutter bundle loading without a visible app is NOT a successful startup.
    await expect(page.locator('#splash'), 'native web splash must disappear').toHaveCount(0, { timeout: 30_000 });

    // Flutter Web paints on a canvas. Enable its accessibility DOM before
    // asking Playwright to locate the real user-facing login screen.
    const accessibility = page.getByRole('button', { name: 'Enable accessibility' });
    // Flutter's semantics activator is intentionally positioned off-screen.
    // Dispatch the activation event without requiring a visible pointer target.
    if (await accessibility.count()) await accessibility.dispatchEvent('click');

    await expect(page.getByText('Mock Sign In', { exact: true }), 'login UI must be reachable').toBeVisible({ timeout: 10_000 });
    expect(pageErrors, 'uncaught browser exceptions are not an acceptable startup').toEqual([]);
  } finally {
    await testInfo.attach('browser-diagnostics.txt', {
      body: Buffer.from([
        'PAGE ERRORS', ...pageErrors,
        '',
        'CONSOLE ERRORS', ...consoleErrors,
        '',
        'FAILED REQUESTS', ...failedRequests,
      ].join('\n')),
      contentType: 'text/plain',
    });
  }
});

// Keep this to one real route-switch smoke, rather than testing Flutter's
// built-in NavigationBar in isolation or adding a new UI testing framework.
test('Material 3 navigation switches tabs and adapts without losing route state', async ({ page }) => {
  await page.setViewportSize({ width: 390, height: 844 });
  const pageErrors = [];
  page.on('pageerror', error => pageErrors.push(error.stack || String(error)));

  await page.goto('/', { waitUntil: 'domcontentloaded' });
  await expect(page.locator('#splash')).toHaveCount(0, { timeout: 30_000 });
  const accessibility = page.getByRole('button', { name: 'Enable accessibility' });
  if (await accessibility.count()) await accessibility.dispatchEvent('click');

  await page.getByText('Mock Sign In', { exact: true }).click();
  // Flutter Web exposes the hero heading and its copy as one accessible group.
  await expect(page.getByRole('group', { name: /Start with the essentials/ })).toHaveCount(1, { timeout: 20_000 });
  // NavigationDestination exposes the correct, tappable Flutter semantics
  // as role=tab. Clicking its child text span misses the semantics tap target.
  const eventsTab = page.getByRole('tab', { name: 'Events' });
  await expect(eventsTab).toBeVisible({ timeout: 30_000 });
  await eventsTab.click();
  await expect(page.getByRole('tab', { name: 'Events', selected: true })).toBeVisible({ timeout: 20_000 });
  // The Material ListTile combines title and subtitle into one semantics button.
  await expect(page.getByRole('button', { name: 'Event Detail Open the AutoRoute detail example' })).toBeVisible({ timeout: 20_000 });

  const profileTab = page.getByRole('tab', { name: 'Profile' });
  await profileTab.click();
  await expect(page.getByRole('tab', { name: 'Profile', selected: true })).toBeVisible({ timeout: 20_000 });
  await expect(page.getByText('Sign out', { exact: true })).toBeVisible({ timeout: 20_000 });

  // Switch to expanded layout in the same session: profile state and current
  // AutoTabsRouter index must survive replacing the bottom bar with a rail.
  await page.setViewportSize({ width: 1280, height: 800 });
  // Flutter Web exposes NavigationRail destinations as accessible buttons
  // ("Profile Tab 3 of 3"), whereas NavigationBar uses role=tab.
  await expect(page.getByText('Sign out', { exact: true })).toBeVisible({ timeout: 20_000 });
  const railProfile = page.getByRole('button', { name: 'Profile Tab 3 of 3' });
  await expect(railProfile).toBeVisible({ timeout: 20_000 });
  const railBounds = await railProfile.boundingBox();
  expect(railBounds, 'expanded navigation destination must be rendered').not.toBeNull();
  expect(railBounds.x, 'expanded destinations belong in the left navigation rail').toBeLessThan(160);

  await page.getByRole('button', { name: 'Events Tab 2 of 3' }).click();
  await expect(page.getByRole('button', { name: 'Event Detail Open the AutoRoute detail example' })).toBeVisible({ timeout: 20_000 });

  // Returning to compact layout must keep the Events tab selected.
  await page.setViewportSize({ width: 390, height: 844 });
  await expect(page.getByRole('tab', { name: 'Events', selected: true })).toBeVisible({ timeout: 20_000 });
  expect(pageErrors, 'tab navigation must not cause uncaught browser exceptions').toEqual([]);
});
