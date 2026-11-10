const path = require('node:path');
const { defineConfig } = require('@playwright/test');


module.exports = defineConfig({
  testDir: __dirname,
  testMatch: '*.spec.js',
  timeout: 45_000,
  expect: { timeout: 30_000 },
  retries: 0,
  workers: 1,
  reporter: [
    ['list'],
    ['html', { outputFolder: path.join(__dirname, 'playwright-report'), open: 'never' }],
  ],
  outputDir: path.join(__dirname, 'test-results'),
  use: {
    baseURL: 'http://127.0.0.1:8765',
    browserName: 'chromium',
    headless: true,
    // Live Auth sessions must never write session tokens into a public CI trace.
    screenshot: process.env.RUN_SUPABASE_WEB_LIVE === '1' ? 'off' : 'only-on-failure',
    trace: process.env.RUN_SUPABASE_WEB_LIVE === '1' ? 'off' : 'retain-on-failure',
  },
  webServer: {
    // Launch from qa/web no matter which directory invoked Playwright.
    cwd: __dirname,
    command: 'python3 spa_server.py',
    url: 'http://127.0.0.1:8765/index.html',
    reuseExistingServer: false,
    timeout: 30_000,
  },
});
