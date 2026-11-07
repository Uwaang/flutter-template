"""Create synthetic native compile fixtures, never production credentials."""

import argparse
import json
import plistlib
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
        clients = []
        for suffix in ['', '.debug', '.develop', '.develop.debug', '.staging', '.staging.debug']:
            clients.append({
                'client_info': {
                    'mobilesdk_app_id': '1:000000000000:android:0000000000000000000000',
                    'android_client_info': {'package_name': 'com.strv.flutter.template' + suffix},
                },
                'oauth_client': [],
                'api_key': [{'current_key': 'ci-placeholder-not-a-credential'}],
                'services': {'appinvite_service': {'other_platform_oauth_client': []}},
            })
        config = {
            'project_info': {
                'project_number': '000000000000',
                'project_id': 'flutter-template-ci-smoke',
                'storage_bucket': 'flutter-template-ci-smoke.invalid',
            },
            'client': clients,
            'configuration_version': '1',
        }
        write_fixture(root / 'android/app/google-services.json', json.dumps(config, indent=2).encode())
    elif target == 'apple':
        for flavor in ['develop', 'staging', 'production']:
            suffix = '' if flavor == 'production' else '.' + flavor
            config = {
                'API_KEY': 'ci-placeholder-not-a-credential',
                'GCM_SENDER_ID': '000000000000',
                'PLIST_VERSION': '1',
                'BUNDLE_ID': 'com.strv.flutter.template' + suffix,
                'PROJECT_ID': 'flutter-template-ci-smoke',
                'GOOGLE_APP_ID': '1:000000000000:ios:0000000000000000000000',
                'IS_ANALYTICS_ENABLED': False,
                'IS_GCM_ENABLED': False,
                'IS_SIGNIN_ENABLED': False,
            }
            data = plistlib.dumps(config)
            write_fixture(root / f'ios/config/{flavor}/GoogleService-Info.plist', data)
            if flavor == 'production':
                write_fixture(root / 'macos/Runner/GoogleService-Info.plist', data)
    else:
        raise ValueError(f'Unsupported target: {target}')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('target', choices=['android', 'apple'])
    args = parser.parse_args()
    prepare(Path(__file__).resolve().parents[1], args.target)
    print(f'Created synthetic {args.target} compile-only fixtures.')
