"""生成慢慢的各平台图标,需要 Pillow,保留不透明背景以兼容 iOS。"""

import json
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]


def bezier(points, steps=80):
    """将三次贝塞尔曲线采样成平滑的绘制路径。"""
    result = []
    for index in range(steps + 1):
        t = index / steps
        weights = ((1 - t) ** 3, 3 * (1 - t) ** 2 * t, 3 * (1 - t) * t ** 2, t ** 3)
        result.append(tuple(sum(weight * point[axis] for weight, point in zip(weights, points))
                            for axis in range(2)))
    return result


def create_mark():
    """叶片与小太阳表达缓慢生长,图形位于可遮罩图标的安全区域内。"""
    canvas = Image.new('RGB', (1024, 1024), '#426B57')
    draw = ImageDraw.Draw(canvas)
    draw.ellipse((232, 232, 792, 792), outline='#6E8A74', width=3)
    draw.ellipse((645, 324, 719, 398), fill='#E8D0A0')
    draw.line(bezier(((512, 710), (516, 575), (507, 461), (563, 349))), fill='#F5F6F0', width=16)
    left = bezier(((520, 590), (391, 597), (334, 537), (335, 441)))
    left += bezier(((335, 441), (438, 435), (521, 486), (520, 590)))
    draw.polygon(left, fill='#F5F6F0')
    right = bezier(((524, 511), (524, 411), (585, 389), (641, 390)))
    right += bezier(((641, 390), (642, 467), (601, 518), (524, 511)))
    draw.polygon(right, fill='#CBDDC8')
    return canvas


def main():
    mark = create_mark()
    targets = {ROOT / 'web/favicon.png': 32}
    for size in (192, 512):
        targets[ROOT / f'web/icons/Icon-{size}.png'] = size
        targets[ROOT / f'web/icons/Icon-maskable-{size}.png'] = size
    for density, size in {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192}.items():
        targets[ROOT / f'android/app/src/main/res/mipmap-{density}/ic_launcher.png'] = size
    folder = ROOT / 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
    for item in json.loads((folder / 'Contents.json').read_text())['images']:
        targets[folder / item['filename']] = round(float(item['size'].split('x')[0]) * float(item['scale'][:-1]))
    for path, size in targets.items():
        mark.resize((size, size), Image.Resampling.LANCZOS).save(path)
    print(f'已生成 {len(targets)} 个平台图标')


if __name__ == '__main__':
    main()
