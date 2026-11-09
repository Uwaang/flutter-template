"""Create synthetic native build fixtures, never production credentials."""

import argparse
from pathlib import Path


def write_fixture(path, data):
    if path.exists() and path.read_bytes() != data:
        raise RuntimeError(f'Refusing to overwrite existing configuration: {path.name}')
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(data)


def prepare(root, target):
    if target == 'android':
        debug = root / 'android/extras/keystores/debug.properties'
        write_fixture(debug.with_name('release.properties'), debug.read_bytes())
    elif target == 'apple':
        # Flavor Xcode build settings include these generated, non-secret files.
        xcconfig = b'// Synthetic compile-only configuration; no credentials.\n'
        write_fixture(root / 'ios/Flutter/.env.xcconfig', xcconfig)
        for flavor in ['develop', 'staging', 'production']:
            write_fixture(root / f'ios/Flutter/.env.{flavor}.xcconfig', xcconfig)
    else:
        raise ValueError(f'Unsupported target: {target}')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('target', choices=['android', 'apple'])
    args = parser.parse_args()
    prepare(Path(__file__).resolve().parents[1], args.target)
    print(f'Created synthetic {args.target} compile-only fixtures.')
