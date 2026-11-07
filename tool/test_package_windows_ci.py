import tempfile
import unittest
from pathlib import Path
from zipfile import ZipFile

from package_windows_ci import package


class WindowsPackageTest(unittest.TestCase):
    def test_runtime_is_preserved_and_intermediates_excluded(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / 'build/windows/x64/runner/Release'
            (source / 'data').mkdir(parents=True)
            for name in ['template.exe', 'plugin.dll', 'plugin.lib', 'template.exp', 'template.pdb', 'data/app.so']:
                (source / name).write_bytes(b'test')
            with ZipFile(package(root)) as archive:
                self.assertEqual(set(archive.namelist()), {'template.exe', 'plugin.dll', 'data/app.so'})

    def test_missing_build_fails(self):
        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaises(RuntimeError):
                package(Path(directory))


if __name__ == '__main__':
    unittest.main()
