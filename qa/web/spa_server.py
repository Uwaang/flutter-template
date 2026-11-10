"""Minimal local HTTP server for Flutter Web path-based client routes.

If an extensionless client route such as /root-route is refreshed, serve the
compiled index.html, just as a production SPA host must do. Missing assets
remain real 404s. Binds only to loopback for Playwright CI.
"""

from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import unquote, urlsplit

WEB_ROOT = Path(__file__).resolve().parents[2] / "build" / "web"


class FlutterSPAHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(WEB_ROOT), **kwargs)

    def do_GET(self):
        path = unquote(urlsplit(self.path).path)
        candidate = WEB_ROOT / path.lstrip("/")
        if path != "/" and not candidate.exists() and "." not in Path(path).name:
            self.path = "/index.html"
        super().do_GET()


if __name__ == "__main__":
    if not WEB_ROOT.is_dir():
        raise SystemExit(f"Missing compiled web output: {WEB_ROOT}")
    with ThreadingHTTPServer(("127.0.0.1", 8765), FlutterSPAHandler) as server:
        print("Serving compiled Flutter SPA on http://127.0.0.1:8765", flush=True)
        server.serve_forever()
