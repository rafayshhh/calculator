import os
import glob
from PIL import Image, ImageDraw, ImageFilter, ImageFont

RAW_DIR = r"Calculator With Math Tools\docs\screenshots\raw"
OUT_DIR = r"Calculator With Math Tools\docs\screenshots"
os.makedirs(OUT_DIR, exist_ok=True)

# 1. Crop box for Pixel 8:
# Screen: 1080 x 2400
# Status bar: 0..136 (removes clock, battery, wifi, app notifications)
# Navigation gesture bar: 2336..2400 (removes android gesture pill)
CROP_BOX = (0, 136, 1080, 2336)
TARGET_WIDTH = 540
TARGET_HEIGHT = 1100
CORNER_RADIUS = 28

def round_corners(image, radius, border_color=(40, 50, 75, 255), border_width=2):
    """Applies clean rounded corners and a subtle outer border."""
    mask = Image.new('L', image.size, 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle([(0, 0), (image.size[0] - 1, image.size[1] - 1)], radius=radius, fill=255)
    
    rounded = Image.new('RGBA', image.size, (0, 0, 0, 0))
    rounded.paste(image.convert('RGBA'), (0, 0), mask=mask)
    
    # Draw border
    border_draw = ImageDraw.Draw(rounded)
    border_draw.rounded_rectangle([(0, 0), (image.size[0] - 1, image.size[1] - 1)], radius=radius, outline=border_color, width=border_width)
    return rounded

def process_single(input_path, output_name):
    img = Image.open(input_path)
    cropped = img.crop(CROP_BOX)
    resized = cropped.resize((TARGET_WIDTH, TARGET_HEIGHT), Image.Resampling.LANCZOS)
    framed = round_corners(resized, CORNER_RADIUS)
    out_path = os.path.join(OUT_DIR, output_name)
    framed.save(out_path, format="PNG", optimize=True)
    print(f"Processed {output_name} ({TARGET_WIDTH}x{TARGET_HEIGHT})")
    return framed

def main():
    screen_map = {
        "01_calculator_dark.png": "screen_calculator.png",
        "02_scientific_keypad.png": "screen_scientific.png",
        "03_equation_solver.png": "screen_equation_solver.png",
        "04_graphing_canvas.png": "screen_graphing.png",
        "05_function_table.png": "screen_table.png",
        "06_toolbox_hub.png": "screen_toolbox_hub.png",
        "07_all_tools_directory.png": "screen_tools_directory.png",
        "08_tip_calculator.png": "screen_tip_calculator.png",
        "09_compound_interest.png": "screen_compound_interest.png",
        "10_settings_top.png": "screen_settings.png",
        "11_settings_branding.png": "screen_branding.png",
        "12_calculator_light.png": "screen_calculator_light.png",
        "13_palette_mint.png": "screen_palette_mint.png",
    }
    
    processed = {}
    for raw_name, clean_name in screen_map.items():
        raw_path = os.path.join(RAW_DIR, raw_name)
        if os.path.exists(raw_path):
            processed[clean_name] = process_single(raw_path, clean_name)
        else:
            print(f"Warning: {raw_name} not found")

    # Generate Hero Showcase Banner
    # Three phones side-by-side: Calculator, 2D Grapher, Toolbox Hub
    hero_w = 1200
    hero_h = 680
    hero_bg = Image.new("RGBA", (hero_w, hero_h), (11, 15, 25, 255))
    
    # Scale cards for hero display: width 320, height 651
    card_w, card_h = 320, 651
    
    if "screen_calculator.png" in processed and "screen_graphing.png" in processed and "screen_toolbox_hub.png" in processed:
        calc_card = processed["screen_calculator.png"].resize((card_w, card_h), Image.Resampling.LANCZOS)
        graph_card = processed["screen_graphing.png"].resize((card_w, card_h), Image.Resampling.LANCZOS)
        tools_card = processed["screen_toolbox_hub.png"].resize((card_w, card_h), Image.Resampling.LANCZOS)
        
        # Position with slight overlap or sleek spacing
        # Left card
        hero_bg.paste(calc_card, (60, 20), mask=calc_card)
        # Right card
        hero_bg.paste(tools_card, (hero_w - card_w - 60, 20), mask=tools_card)
        # Center card (prominent)
        hero_bg.paste(graph_card, ((hero_w - card_w) // 2, 10), mask=graph_card)
        
        hero_path = os.path.join(OUT_DIR, "hero_showcase.png")
        hero_bg.save(hero_path, format="PNG", optimize=True)
        print(f"Generated Hero Showcase Banner: {hero_path}")

if __name__ == "__main__":
    main()
