"""Package Windows runtime files without intermediate libraries or symbols."""

from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile


def package(root):
    source = root / 'build/windows/x64/runner/Release'
    if not list(source.glob('*.exe')) or not (source / 'data').is_dir():
        raise RuntimeError('Missing Windows executable or runtime data')
    output = root / 'ci-artifacts/windows.zip'
    output.parent.mkdir(parents=True, exist_ok=True)
    with ZipFile(output, 'w', ZIP_DEFLATED) as archive:
        for path in sorted(source.rglob('*')):
            if path.is_file() and path.suffix.lower() not in {'.lib', '.exp', '.pdb'}:
                archive.write(path, path.relative_to(source).as_posix())
    return output


if __name__ == '__main__':
    print(package(Path(__file__).resolve().parents[1]).name)
