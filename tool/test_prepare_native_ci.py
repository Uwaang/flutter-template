import json
import plistlib
import tempfile
import unittest
from pathlib import Path

from prepare_native_ci import prepare


class NativeFixturesTest(unittest.TestCase):
    def test_android_uses_debug_signing_and_synthetic_packages(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            debug = root / 'android/extras/keystores/debug.properties'
            debug.parent.mkdir(parents=True)
            debug.write_text('storePassword=android\n')
            prepare(root, 'android')
            self.assertEqual(debug.read_bytes(), debug.with_name('release.properties').read_bytes())
            config = json.loads((root / 'android/app/google-services.json').read_text())
            packages = {c['client_info']['android_client_info']['package_name'] for c in config['client']}
            self.assertIn('com.strv.flutter.template', packages)
            self.assertIn('com.strv.flutter.template.debug', packages)
            prepare(root, 'android')

    def test_apple_configs_are_valid_and_telemetry_is_disabled(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            prepare(root, 'apple')
            files = list(root.rglob('*.plist'))
            self.assertEqual(len(files), 4)
            for path in files:
                config = plistlib.loads(path.read_bytes())
                self.assertFalse(config['IS_ANALYTICS_ENABLED'])
                self.assertEqual(config['API_KEY'], 'ci-placeholder-not-a-credential')
            for suffix in ['', '.develop', '.staging', '.production']:
                path = root / f'ios/Flutter/.env{suffix}.xcconfig'
                self.assertTrue(path.is_file())
                self.assertIn(b'no credentials', path.read_bytes())

    def test_existing_config_is_not_overwritten(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            target = root / 'ios/config/develop/GoogleService-Info.plist'
            target.parent.mkdir(parents=True)
            target.write_text('real-config-placeholder')
            with self.assertRaises(RuntimeError):
                prepare(root, 'apple')
            self.assertEqual(target.read_text(), 'real-config-placeholder')


if __name__ == '__main__':
    unittest.main()
