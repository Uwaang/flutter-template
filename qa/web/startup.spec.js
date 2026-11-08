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
