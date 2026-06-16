"""
Script untuk generate Android app icons dari logo_splash.png
Menghasilkan ic_launcher.png dan ic_launcher_round.png untuk semua density
Serta ic_launcher_foreground.png dan ic_launcher_background.png untuk adaptive icon
"""
from PIL import Image, ImageDraw
import os

# Source image
SOURCE = "assets/images/logo_splash.png"
RES_DIR = "android/app/src/main/res"

# Android icon sizes per density
ICON_SIZES = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}

# Adaptive icon foreground sizes (108dp * density multiplier)
FOREGROUND_SIZES = {
    "mipmap-mdpi": 108,
    "mipmap-hdpi": 162,
    "mipmap-xhdpi": 216,
    "mipmap-xxhdpi": 324,
    "mipmap-xxxhdpi": 432,
}

def make_circle_mask(size):
    """Create a circular mask for round icons"""
    mask = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(mask)
    draw.ellipse((0, 0, size - 1, size - 1), fill=255)
    return mask

def make_square_with_padding(img, size, padding_pct=0.15):
    """Place image centered on a white background with padding"""
    canvas = Image.new("RGBA", (size, size), (255, 255, 255, 255))
    pad = int(size * padding_pct)
    inner_size = size - (pad * 2)
    
    # Resize source to fit within inner area maintaining aspect ratio
    src_w, src_h = img.size
    ratio = min(inner_size / src_w, inner_size / src_h)
    new_w = int(src_w * ratio)
    new_h = int(src_h * ratio)
    resized = img.resize((new_w, new_h), Image.LANCZOS)
    
    # Center on canvas
    x = (size - new_w) // 2
    y = (size - new_h) // 2
    canvas.paste(resized, (x, y), resized if resized.mode == "RGBA" else None)
    return canvas

def make_round_icon(img, size, padding_pct=0.15):
    """Create a round icon with circular mask"""
    canvas = make_square_with_padding(img, size, padding_pct)
    mask = make_circle_mask(size)
    
    # Apply circular mask
    output = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    output.paste(canvas, mask=mask)
    return output

def make_foreground(img, size):
    """Create adaptive icon foreground (image centered in 108dp canvas)"""
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    
    # For adaptive icons, the visible area is the inner 66% (center 72dp of 108dp)
    visible_size = int(size * 0.667)
    offset = (size - visible_size) // 2
    
    src_w, src_h = img.size
    ratio = min(visible_size / src_w, visible_size / src_h)
    new_w = int(src_w * ratio)
    new_h = int(src_h * ratio)
    resized = img.resize((new_w, new_h), Image.LANCZOS)
    
    x = offset + (visible_size - new_w) // 2
    y = offset + (visible_size - new_h) // 2
    canvas.paste(resized, (x, y), resized if resized.mode == "RGBA" else None)
    return canvas

def make_background(size, color=(255, 255, 255, 255)):
    """Create adaptive icon background (solid color)"""
    return Image.new("RGBA", (size, size), color)

def main():
    # Load source image
    src = Image.open(SOURCE)
    if src.mode != "RGBA":
        src = src.convert("RGBA")
    print(f"Source image: {src.size[0]}x{src.size[1]}")
    
    for density, size in ICON_SIZES.items():
        folder = os.path.join(RES_DIR, density)
        os.makedirs(folder, exist_ok=True)
        
        # ic_launcher.png (standard)
        icon = make_square_with_padding(src, size)
        icon_path = os.path.join(folder, "ic_launcher.png")
        icon.save(icon_path, "PNG")
        print(f"[{density}] ic_launcher.png -> {size}x{size}")
        
        # ic_launcher_round.png
        round_icon = make_round_icon(src, size)
        round_path = os.path.join(folder, "ic_launcher_round.png")
        round_icon.save(round_path, "PNG")
        print(f"[{density}] ic_launcher_round.png -> {size}x{size}")
        
        # ic_launcher_foreground.png (for adaptive icon)
        fg_size = FOREGROUND_SIZES[density]
        foreground = make_foreground(src, fg_size)
        fg_path = os.path.join(folder, "ic_launcher_foreground.png")
        foreground.save(fg_path, "PNG")
        print(f"[{density}] ic_launcher_foreground.png -> {fg_size}x{fg_size}")
        
        # ic_launcher_background.png (white background)
        background = make_background(fg_size)
        bg_path = os.path.join(folder, "ic_launcher_background.png")
        background.save(bg_path, "PNG")
        print(f"[{density}] ic_launcher_background.png -> {fg_size}x{fg_size}")
    
    print("\n✅ Semua icon berhasil di-generate dari logo_splash.png!")

if __name__ == "__main__":
    main()