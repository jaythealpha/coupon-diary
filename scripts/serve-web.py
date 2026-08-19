#!/usr/bin/env python3
"""build/web를 로컬에서 띄운다.

`python3 -m http.server`를 그냥 쓰면 안 되는 이유가 둘 있다.

1. **딥링크가 404다.** go_router 경로(`/coupon/<id>`)에 대응하는 파일이 없으니
   기본 핸들러는 404를 낸다. 없는 경로는 index.html로 넘겨야 앱이 뜬다.
2. **브라우저가 옛 번들을 붙든다.** 고친 내용이 화면에 안 나와서 한참 헤매게
   된다. 로컬에서는 항상 no-store로 준다.

포트는 PORT 환경변수를 따른다(하네스가 정해준다). 없으면 5321.
0.0.0.0에 붙으므로 같은 와이파이의 폰에서도 열린다.
"""

import os
import sys
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "build", "web")
ROOT = os.path.normpath(ROOT)


class Handler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=ROOT, **kwargs)

    def do_GET(self):
        if not os.path.exists(self.translate_path(self.path)):
            self.path = "/index.html"  # SPA 폴백
        return super().do_GET()

    def end_headers(self):
        self.send_header("Cache-Control", "no-store")
        super().end_headers()

    def log_message(self, fmt, *args):
        sys.stderr.write("%s\n" % (fmt % args))


def main() -> int:
    if not os.path.isdir(ROOT):
        print(f"build/web이 없다. 먼저 빌드하라: flutter build web", file=sys.stderr)
        return 1

    port = int(os.environ.get("PORT", "5321"))
    server = ThreadingHTTPServer(("0.0.0.0", port), Handler)
    print(f"서빙: {ROOT}")
    print(f"http://localhost:{port}/", flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
