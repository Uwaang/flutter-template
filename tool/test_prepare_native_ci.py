import tempfile
import unittest
from pathlib import Path

from prepare_native_ci import prepare


class NativeFixturesTest(unittest.TestCase):
    def test_android_reuses_debug_signing_without_firebase_fixtures(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            debug = root / 'android/extras/keystores/debug.properties'
            debug.parent.mkdir(parents=True)
            debug.write_text('storePassword=android\n')
            prepare(root, 'android')
            self.assertEqual(debug.read_bytes(), debug.with_name('release.properties').read_bytes())
            self.assertFalse((root / 'android/app/google-services.json').exists())
            prepare(root, 'android')

    def test_apple_xcconfigs_are_secret_free_without_firebase_plists(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            prepare(root, 'apple')
            self.assertFalse(list(root.rglob('GoogleService-Info.plist')))
            for suffix in ['', '.develop', '.staging', '.production']:
                path = root / f'ios/Flutter/.env{suffix}.xcconfig'
                self.assertTrue(path.is_file())
                self.assertIn(b'no credentials', path.read_bytes())
            prepare(root, 'apple')

    def test_existing_config_is_not_overwritten(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            target = root / 'ios/Flutter/.env.develop.xcconfig'
            target.parent.mkdir(parents=True)
            target.write_text('existing-real-config')
            with self.assertRaises(RuntimeError):
                prepare(root, 'apple')
            self.assertEqual(target.read_text(), 'existing-real-config')


if __name__ == '__main__':
    unittest.main()
