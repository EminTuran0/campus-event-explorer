"""Generates the original category images in assets/images/.

Pure Python (no external libraries). The images are simple illustrations
created for this project, so no third-party license applies.

Usage:  python tool/generate_images.py
"""
import math
import os
import struct
import zlib

W, H = 800, 450
OUT = os.path.join(os.path.dirname(__file__), '..', 'assets', 'images')


class Canvas:
    def __init__(self, top, bottom):
        self.px = bytearray(W * H * 3)
        for y in range(H):
            t = y / (H - 1)
            c = [round(top[i] + (bottom[i] - top[i]) * t) for i in range(3)]
            row = bytes(c) * W
            self.px[y * W * 3:(y + 1) * W * 3] = row

    def blend(self, x, y, color, a=1.0):
        if 0 <= x < W and 0 <= y < H:
            i = (y * W + x) * 3
            for k in range(3):
                self.px[i + k] = round(self.px[i + k] * (1 - a) + color[k] * a)

    def rect(self, x0, y0, x1, y1, color, a=1.0, radius=0):
        for y in range(max(0, y0), min(H, y1)):
            for x in range(max(0, x0), min(W, x1)):
                if radius:
                    cx = min(max(x, x0 + radius), x1 - radius - 1)
                    cy = min(max(y, y0 + radius), y1 - radius - 1)
                    if (x - cx) ** 2 + (y - cy) ** 2 > radius ** 2:
                        continue
                self.blend(x, y, color, a)

    def circle(self, cx, cy, r, color, a=1.0, inner=0):
        for y in range(max(0, cy - r), min(H, cy + r + 1)):
            for x in range(max(0, cx - r), min(W, cx + r + 1)):
                d = (x - cx) ** 2 + (y - cy) ** 2
                if inner ** 2 <= d <= r ** 2:
                    self.blend(x, y, color, a)

    def line(self, x0, y0, x1, y1, color, width=4, a=1.0):
        steps = int(max(abs(x1 - x0), abs(y1 - y0))) + 1
        half = width // 2
        drawn = set()
        for s in range(steps + 1):
            t = s / steps
            x = round(x0 + (x1 - x0) * t)
            y = round(y0 + (y1 - y0) * t)
            for dy in range(-half, half + 1):
                for dx in range(-half, half + 1):
                    p = (x + dx, y + dy)
                    if p not in drawn:
                        drawn.add(p)
                        self.blend(p[0], p[1], color, a)

    def save(self, name):
        raw = bytearray()
        for y in range(H):
            raw.append(0)
            raw.extend(self.px[y * W * 3:(y + 1) * W * 3])

        def chunk(tag, data):
            c = struct.pack('>I', len(data)) + tag + data
            return c + struct.pack('>I', zlib.crc32(tag + data) & 0xFFFFFFFF)

        png = b'\x89PNG\r\n\x1a\n'
        png += chunk(b'IHDR', struct.pack('>IIBBBBB', W, H, 8, 2, 0, 0, 0))
        png += chunk(b'IDAT', zlib.compress(bytes(raw), 9))
        png += chunk(b'IEND', b'')
        os.makedirs(OUT, exist_ok=True)
        with open(os.path.join(OUT, name), 'wb') as f:
            f.write(png)
        print('wrote', name)


WHITE = (255, 255, 255)


def technology():
    c = Canvas((12, 35, 74), (16, 120, 130))
    cyan = (110, 230, 240)
    # Circuit traces with nodes.
    for i, y in enumerate(range(60, 420, 60)):
        x_end = 180 + (i * 37) % 120
        c.line(0, y, x_end, y, cyan, 3, 0.55)
        c.circle(x_end, y, 8, cyan, 0.8)
        c.line(W, y + 20, W - x_end, y + 20, cyan, 3, 0.55)
        c.circle(W - x_end, y + 20, 8, cyan, 0.8)
    # Central chip with pins.
    c.rect(300, 125, 500, 325, (20, 40, 60), 0.95, radius=18)
    c.rect(330, 155, 470, 295, (40, 170, 180), 0.9, radius=10)
    for k in range(6):
        p = 145 + k * 32
        c.rect(p, 100, p + 14, 125, WHITE, 0.85)
        c.rect(p, 325, p + 14, 350, WHITE, 0.85)
        c.rect(275, p, 300, p + 14, WHITE, 0.85)
        c.rect(500, p, 525, p + 14, WHITE, 0.85)
    c.circle(400, 225, 28, WHITE, 0.9, inner=18)
    c.save('technology.png')


def arts():
    c = Canvas((88, 34, 120), (232, 96, 130))
    blobs = [
        (170, 140, 90, (255, 214, 102)),
        (300, 300, 110, (80, 200, 220)),
        (520, 150, 100, (255, 120, 90)),
        (640, 320, 90, (140, 230, 140)),
        (420, 230, 70, WHITE),
    ]
    for x, y, r, col in blobs:
        c.circle(x, y, r, col, 0.55)
    # Paint brush.
    c.line(560, 420, 760, 60, (90, 55, 30), 14, 1.0)
    c.line(545, 446, 575, 395, (200, 200, 210), 18, 1.0)
    c.circle(548, 440, 14, (40, 40, 60), 1.0)
    c.save('arts.png')


def sports():
    c = Canvas((24, 120, 60), (110, 190, 70))
    # Grass stripes.
    for x in range(0, W, 100):
        c.rect(x, 0, x + 50, H, WHITE, 0.06)
    # Field lines.
    c.rect(0, 20, W, 26, WHITE, 0.8)
    c.rect(0, H - 26, W, H - 20, WHITE, 0.8)
    c.rect(397, 20, 403, H - 20, WHITE, 0.8)
    c.circle(400, 225, 95, WHITE, 0.8, inner=89)
    c.rect(0, 130, 90, 320, WHITE, 0.8)
    c.rect(0, 136, 84, 314, (60, 150, 65), 1.0)
    c.rect(W - 90, 130, W, 320, WHITE, 0.8)
    c.rect(W - 84, 136, W, 314, (75, 160, 68), 1.0)
    # Ball.
    c.circle(560, 300, 62, (30, 30, 30), 0.35)  # shadow
    c.circle(550, 285, 60, WHITE, 1.0)
    c.circle(550, 285, 20, (30, 30, 30), 1.0)
    for k in range(5):
        ang = -math.pi / 2 + k * 2 * math.pi / 5
        x = round(550 + math.cos(ang) * 46)
        y = round(285 + math.sin(ang) * 46)
        c.line(550 + round(math.cos(ang) * 20), 285 + round(math.sin(ang) * 20),
               x, y, (30, 30, 30), 3)
        c.circle(x, y, 9, (30, 30, 30), 1.0)
    c.save('sports.png')


def career():
    c = Canvas((20, 40, 80), (220, 150, 60))
    # Rising bar chart.
    for i, h in enumerate([80, 130, 180, 240]):
        x = 70 + i * 60
        c.rect(x, 400 - h, x + 40, 400, WHITE, 0.35, radius=6)
    c.line(60, 330, 320, 140, (255, 230, 150), 6, 0.9)
    # Briefcase.
    c.rect(455, 120, 605, 190, (60, 40, 25), 1.0, radius=22)
    c.rect(475, 140, 585, 190, (220, 150, 60), 1.0, radius=10)
    c.rect(400, 170, 660, 370, (95, 60, 35), 1.0, radius=24)
    c.rect(400, 245, 660, 260, (60, 40, 25), 1.0)
    c.rect(510, 230, 550, 280, (240, 200, 90), 1.0, radius=6)
    c.save('career.png')


if __name__ == '__main__':
    technology()
    arts()
    sports()
    career()
