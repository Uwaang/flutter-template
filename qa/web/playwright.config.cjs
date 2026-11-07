const path = require('node:path');
const { defineConfig } = require('@playwright/test');

const root = path.resolve(__dirname, '../..');
const webOutput = path.join(root, 'build', 'web');

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
    screenshot: 'only-on-failure',
    trace: 'retain-on-failure',
  },
  webServer: {
    command: `python3 -m http.server 8765 --bind 127.0.0.1 --directory "${webOutput}"`,
    url: 'http://127.0.0.1:8765/index.html',
    reuseExistingServer: false,
    timeout: 30_000,
  },
});
