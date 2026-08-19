"""쿠폰다이어리 앱 아이콘 생성.

외부 이미지 라이브러리 없이 순수 파이썬으로 PNG를 쓴다.
모티프는 '티켓' — 양옆이 반원으로 파인 쿠폰 모양.
"""

import math
import struct
import zlib
import os

SIZE = 1024
BRAND = (29, 78, 216)      # #1D4ED8 라이트 프라이머리
BRAND_DEEP = (16, 42, 107)  # #102A6B 아래쪽 그라데이션용
WHITE = (255, 255, 255)


def rounded_rect_sdf(x, y, cx, cy, hw, hh, r):
    """둥근 사각형의 부호 있는 거리. 음수면 내부."""
    dx = abs(x - cx) - (hw - r)
    dy = abs(y - cy) - (hh - r)
    ax, ay = max(dx, 0.0), max(dy, 0.0)
    return math.hypot(ax, ay) + min(max(dx, dy), 0.0) - r


def circle_sdf(x, y, cx, cy, r):
    return math.hypot(x - cx, y - cy) - r


def coverage(sdf_value, aa=1.2):
    """거리값을 0~1 알파로. 경계에서 부드럽게 떨어뜨려 계단을 없앤다."""
    return min(max(0.5 - sdf_value / aa, 0.0), 1.0)


def blend(base, top, alpha):
    return tuple(round(b + (t - b) * alpha) for b, t in zip(base, top))


def build_pixels(transparent=False, scale=1.0):
    """티켓 아이콘 픽셀을 만든다.

    transparent=True면 배경 없이 티켓만 남긴 RGBA를 낸다 (Android 적응형 아이콘
    전경용). scale로 티켓을 줄여 런처가 잘라내는 영역 밖으로 나가지 않게 한다.
    """
    cx = cy = SIZE / 2

    # 티켓 본체
    t_hw, t_hh, t_r = (
        SIZE * 0.30 * scale,
        SIZE * 0.205 * scale,
        SIZE * 0.055 * scale,
    )
    # 좌우 노치
    notch_r = SIZE * 0.055 * scale
    notch_y = cy
    notch_lx = cx - t_hw
    notch_rx = cx + t_hw

    # 점선 (티켓을 가르는 세로선)
    dash_x = cx + SIZE * 0.085 * scale
    dash_hw = SIZE * 0.011 * scale
    dash_len = SIZE * 0.052 * scale
    dash_gap = SIZE * 0.036 * scale
    # 점선을 티켓 안에 딱 떨어지게 배치한다. 위아래 끝에서 반쯤 잘린 조각이
    # 남으면 의도한 형태가 아니라 렌더링 사고처럼 보인다.
    dash_span = (t_hh - SIZE * 0.045 * scale) * 2
    dash_count = max(1, int((dash_span + dash_gap) // (dash_len + dash_gap)))
    dash_total = dash_count * dash_len + (dash_count - 1) * dash_gap
    dash_top = cy - dash_total / 2

    rows = []
    for py in range(SIZE):
        row = bytearray()
        y = py + 0.5
        # 배경: 위에서 아래로 미세한 그라데이션. 단색보다 아이콘이 덜 납작해 보인다.
        t = py / (SIZE - 1)
        bg = tuple(
            round(a + (b - a) * (t ** 1.3)) for a, b in zip(BRAND, BRAND_DEEP)
        )
        for px in range(SIZE):
            x = px + 0.5
            color = bg
            alpha_out = 255

            ticket = rounded_rect_sdf(x, y, cx, cy, t_hw, t_hh, t_r)
            # 노치는 티켓에서 파낸다 → 거리값의 최대(차집합)
            ticket = max(ticket, -circle_sdf(x, y, notch_lx, notch_y, notch_r))
            ticket = max(ticket, -circle_sdf(x, y, notch_rx, notch_y, notch_r))

            a = coverage(ticket)
            if transparent:
                # 전경 이미지에서는 티켓 바깥이 완전히 투명해야 한다.
                alpha_out = round(a * 255)
                color = WHITE
            elif a > 0:
                color = blend(color, WHITE, a)

            if a > 0:

                # 점선은 티켓 안쪽에만 그린다.
                if abs(x - dash_x) <= dash_hw + 1 and dash_top <= y <= dash_top + dash_total:
                    seg = (y - dash_top) % (dash_len + dash_gap)
                    if seg < dash_len:
                        d = abs(x - dash_x) - dash_hw
                        da = coverage(d) * min(a, 1.0)
                        if transparent:
                            # 점선 자리는 배경색이 아니라 구멍으로 뚫는다.
                            alpha_out = round(alpha_out * (1 - da))
                        else:
                            color = blend(color, bg, da)

            row += bytes(color)
            if transparent:
                row.append(alpha_out)
        rows.append(bytes(row))
    return rows


def write_png(path, rows, rgba=False):
    raw = b"".join(b"\x00" + r for r in rows)
    compressed = zlib.compress(raw, 9)

    def chunk(tag, data):
        payload = tag + data
        return (
            struct.pack(">I", len(data))
            + payload
            + struct.pack(">I", zlib.crc32(payload) & 0xFFFFFFFF)
        )

    color_type = 6 if rgba else 2
    header = struct.pack(">IIBBBBB", SIZE, SIZE, 8, color_type, 0, 0, 0)
    png = (
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", header)
        + chunk(b"IDAT", compressed)
        + chunk(b"IEND", b"")
    )
    with open(path, "wb") as f:
        f.write(png)


if __name__ == "__main__":
    target_dir = os.path.join(os.path.dirname(__file__), "out")
    os.makedirs(target_dir, exist_ok=True)
    write_png(os.path.join(target_dir, "app_icon.png"), build_pixels())

    # Android 적응형 아이콘 전경. 런처가 원형·둥근사각 등으로 잘라내므로
    # 안전 영역(중앙 66%) 안에 들어오도록 0.72배로 줄인다.
    write_png(
        os.path.join(target_dir, "app_icon_foreground.png"),
        build_pixels(transparent=True, scale=0.72),
        rgba=True,
    )
    print("wrote app_icon.png, app_icon_foreground.png ->", target_dir)
