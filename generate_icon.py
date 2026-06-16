"""
Script untuk generate icon aplikasi sepatu_produksi_app
Berdasarkan desain: rumah/bangunan dengan sepatu, warna coklat/gold dan navy
"""
from PIL import Image, ImageDraw, ImageFont
import os

# === KONFIGURASI WARNA ===
BG_COLOR = (20, 25, 55)          # Dark navy background
HOUSE_COLOR = (184, 134, 11)     # Brown/gold (dark goldenrod)
HOUSE_DARK = (150, 108, 8)       # Darker brown for depth
WINDOW_COLOR = (184, 134, 11)    # Same as house for windows
SHOE_WHITE = (255, 255, 255)     # White for shoe
SHOE_DARK = (200, 200, 200)      # Light gray for shoe details
SHOE_LINE = (184, 134, 11)       # Brown lines on shoe
CURVE_COLOR = (20, 25, 55)       # Dark curve (same as bg)
CHIMNEY_COLOR = (184, 134, 11)   # Chimney color

# === UKURAN ICON ANDROID ===
ICON_SIZES = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
}

# Base path
BASE_PATH = os.path.dirname(os.path.abspath(__file__))
RES_PATH = os.path.join(BASE_PATH, 'android', 'app', 'src', 'main', 'res')


def draw_icon(size):
    """Generate icon dengan ukuran tertentu"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Scale factor
    s = size / 512.0
    
    # === BACKGROUND - Rounded rectangle ===
    # Draw rounded rectangle background
    margin = int(10 * s)
    radius = int(80 * s)
    draw.rounded_rectangle(
        [margin, margin, size - margin, size - margin],
        radius=radius,
        fill=BG_COLOR
    )
    
    # === HOUSE BODY ===
    # House body (rectangle)
    house_left = int(100 * s)
    house_right = int(412 * s)
    house_top = int(140 * s)
    house_bottom = int(340 * s)
    
    # House roof (triangle)
    roof_top = int(60 * s)
    roof_left = int(70 * s)
    roof_right = int(442 * s)
    roof_bottom = int(160 * s)
    
    # Draw roof (triangle)
    draw.polygon([
        (int(256 * s), roof_top),
        (roof_left, roof_bottom),
        (roof_right, roof_bottom)
    ], fill=HOUSE_COLOR)
    
    # Draw house body
    draw.rectangle(
        [house_left, house_top, house_right, house_bottom],
        fill=HOUSE_COLOR
    )
    
    # === CHIMNEY ===
    chimney_left = int(340 * s)
    chimney_right = int(380 * s)
    chimney_top = int(40 * s)
    chimney_bottom = int(120 * s)
    draw.rectangle(
        [chimney_left, chimney_top, chimney_right, chimney_bottom],
        fill=CHIMNEY_COLOR
    )
    
    # === WINDOWS (4 small squares) ===
    window_size = int(36 * s)
    window_gap = int(12 * s)
    window_start_x = int(200 * s)
    window_start_y = int(165 * s)
    
    for row in range(2):
        for col in range(2):
            wx = window_start_x + col * (window_size + window_gap)
            wy = window_start_y + row * (window_size + window_gap)
            draw.rectangle(
                [wx, wy, wx + window_size, wy + window_size],
                fill=BG_COLOR
            )
    
    # === DOOR (white rectangle) ===
    door_left = int(210 * s)
    door_right = int(302 * s)
    door_top = int(250 * s)
    door_bottom = int(335 * s)
    draw.rectangle(
        [door_left, door_top, door_right, door_bottom],
        fill=SHOE_WHITE
    )
    
    # === CURVE / S-SHAPE (dark, like the image) ===
    # Draw a curved S-shape using thick lines
    curve_width = int(28 * s)
    
    # Upper curve of S
    draw.arc(
        [int(160 * s), int(240 * s), int(320 * s), int(340 * s)],
        start=180, end=0,
        fill=BG_COLOR, width=curve_width
    )
    
    # Lower curve of S
    draw.arc(
        [int(160 * s), int(290 * s), int(320 * s), int(390 * s)],
        start=0, end=180,
        fill=BG_COLOR, width=curve_width
    )
    
    # === SHOE / SNEAKER ===
    # Shoe sole (bottom)
    shoe_left = int(80 * s)
    shoe_right = int(432 * s)
    shoe_top = int(330 * s)
    shoe_bottom = int(420 * s)
    
    # Shoe body (rounded rectangle)
    draw.rounded_rectangle(
        [shoe_left, shoe_top, shoe_right, shoe_bottom],
        radius=int(20 * s),
        fill=SHOE_WHITE
    )
    
    # Shoe sole line (brown)
    sole_y = int(400 * s)
    draw.line(
        [(shoe_left + int(10 * s), sole_y), (shoe_right - int(10 * s), sole_y)],
        fill=SHOE_LINE, width=int(6 * s)
    )
    
    # Shoe upper line
    upper_y = int(350 * s)
    draw.line(
        [(shoe_left + int(10 * s), upper_y), (shoe_right - int(10 * s), upper_y)],
        fill=SHOE_LINE, width=int(4 * s)
    )
    
    # Shoe laces (small lines)
    lace_start_x = int(200 * s)
    lace_end_x = int(350 * s)
    lace_y_start = int(355 * s)
    lace_spacing = int(18 * s)
    
    for i in range(4):
        ly = lace_y_start + i * lace_spacing
        draw.line(
            [(lace_start_x + i * int(10 * s), ly), (lace_end_x - i * int(10 * s), ly)],
            fill=SHOE_LINE, width=int(3 * s)
        )
    
    # Shoe toe (curved front)
    toe_x = int(400 * s)
    toe_y = int(370 * s)
    draw.arc(
        [int(360 * s), int(340 * s), int(440 * s), int(410 * s)],
        start=270, end=90,
        fill=SHOE_WHITE, width=int(15 * s)
    )
    
    # Shoe heel
    heel_x = int(100 * s)
    draw.arc(
        [int(70 * s), int(340 * s), int(140 * s), int(410 * s)],
        start=90, end=270,
        fill=SHOE_WHITE, width=int(15 * s)
    )
    
    return img


def generate_all_icons():
    """Generate semua ukuran icon untuk Android"""
    for folder, size in ICON_SIZES.items():
        folder_path = os.path.join(RES_PATH, folder)
        os.makedirs(folder_path, exist_ok=True)
        
        icon = draw_icon(size)
        icon_path = os.path.join(folder_path, 'ic_launcher.png')
        icon.save(icon_path, 'PNG')
        print(f"Generated: {icon_path} ({size}x{size})")
        
        # Also generate round icon
        round_icon = draw_round_icon(size)
        round_path = os.path.join(folder_path, 'ic_launcher_round.png')
        round_icon.save(round_path, 'PNG')
        print(f"Generated: {round_path} ({size}x{size})")
    
    # Generate adaptive icon foreground (108x108dp = 432px at xxxhdpi)
    generate_adaptive_icon()
    
    # Generate web icons
    generate_web_icons()
    
    print("\nAll icons generated successfully!")


def draw_round_icon(size):
    """Generate round icon dengan circular mask"""
    icon = draw_icon(size)
    
    # Create circular mask
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.ellipse([0, 0, size - 1, size - 1], fill=255)
    
    # Apply mask
    result = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    result.paste(icon, (0, 0), mask)
    
    return result


def generate_adaptive_icon():
    """Generate adaptive icon files for Android 8.0+"""
    # Adaptive icon foreground (108dp at xxxhdpi = 432px)
    fg_size = 432
    fg = draw_icon(fg_size)
    fg_path = os.path.join(RES_PATH, 'mipmap-xxxhdpi', 'ic_launcher_foreground.png')
    fg.save(fg_path, 'PNG')
    print(f"Generated adaptive foreground: {fg_path}")
    
    # Also generate for other densities
    densities = {
        'mipmap-mdpi': 108,
        'mipmap-hdpi': 162,
        'mipmap-xhdpi': 216,
        'mipmap-xxhdpi': 324,
        'mipmap-xxxhdpi': 432,
    }
    
    for folder, size in densities.items():
        fg = draw_icon(size)
        fg_path = os.path.join(RES_PATH, folder, 'ic_launcher_foreground.png')
        fg.save(fg_path, 'PNG')
        print(f"Generated adaptive foreground: {fg_path} ({size}x{size})")
    
    # Generate adaptive icon background (solid color)
    for folder, size in densities.items():
        bg = Image.new('RGBA', (size, size), BG_COLOR + (255,))
        bg_path = os.path.join(RES_PATH, folder, 'ic_launcher_background.png')
        bg.save(bg_path, 'PNG')
        print(f"Generated adaptive background: {bg_path} ({size}x{size})")


def generate_web_icons():
    """Generate web icons"""
    web_path = os.path.join(BASE_PATH, 'web', 'icons')
    os.makedirs(web_path, exist_ok=True)
    
    # Generate various sizes for web
    web_sizes = [192, 512]
    for size in web_sizes:
        icon = draw_icon(size)
        icon_path = os.path.join(web_path, f'Icon-{size}x{size}.png')
        icon.save(icon_path, 'PNG')
        print(f"Generated web icon: {icon_path} ({size}x{size})")
    
    # Generate favicon
    favicon = draw_icon(64)
    favicon_path = os.path.join(BASE_PATH, 'web', 'favicon.png')
    favicon.save(favicon_path, 'PNG')
    print(f"Generated favicon: {favicon_path}")


if __name__ == '__main__':
    generate_all_icons()