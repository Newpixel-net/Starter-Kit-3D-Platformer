#!/usr/bin/env python3
"""
Automated Asset Organization Script
Organizes Kenney assets from mixassets/ into proper project structure
"""

import os
import shutil
from pathlib import Path

# Base paths
BASE_DIR = Path(__file__).parent
MIXASSETS = BASE_DIR / "mixassets"

# Asset mappings: (source_path, destination_path, new_name)
# Format: [("source_file_pattern", "destination_folder", "new_filename_or_None")]

def copy_asset(source, dest, new_name=None):
    """Copy an asset file, optionally renaming it"""
    if not source.exists():
        print(f"⚠️  Source not found: {source}")
        return False

    dest_dir = dest.parent if dest.suffix else dest
    dest_dir.mkdir(parents=True, exist_ok=True)

    if new_name:
        dest_file = dest_dir / new_name
    else:
        dest_file = dest_dir / source.name

    try:
        shutil.copy2(source, dest_file)
        print(f"✅ {source.name} → {dest_file.relative_to(BASE_DIR)}")
        return True
    except Exception as e:
        print(f"❌ Error copying {source.name}: {e}")
        return False

def organize_assets():
    """Main organization function"""
    print("=" * 70)
    print("🎮 KENNEY ASSET ORGANIZATION SCRIPT")
    print("=" * 70)

    copied = 0
    failed = 0

    # ============================================================================
    # 1. FOOD KIT - Collectible Fruits
    # ============================================================================
    print("\n📦 FOOD KIT → Collectible Fruits")
    print("-" * 70)

    food_kit_glb = MIXASSETS / "kenney_food-kit/Models/GLB format"
    fruits_dest = BASE_DIR / "models/collectibles/fruits"

    fruits_to_copy = [
        ("apple.glb", "apple.glb"),
        ("orange.glb", "orange.glb"),
        ("banana.glb", "banana.glb"),
        ("cherries.glb", "cherry.glb"),
        ("strawberry.glb", "strawberry.glb"),
        ("watermelon.glb", "watermelon.glb"),
        ("grapes.glb", "grapes.glb"),
        ("pineapple.glb", "pineapple.glb"),
    ]

    for src_name, dest_name in fruits_to_copy:
        source = food_kit_glb / src_name
        if copy_asset(source, fruits_dest, dest_name):
            copied += 1
        else:
            failed += 1

    # ============================================================================
    # 2. PLATFORMER KIT - Obstacles (Crates, Spikes, Traps)
    # ============================================================================
    print("\n📦 PLATFORMER KIT → Obstacles")
    print("-" * 70)

    platformer_glb = MIXASSETS / "kenney_platformer-kit/Models/GLB format"
    obstacles_dest = BASE_DIR / "models/obstacles"

    obstacles_to_copy = [
        ("crate.glb", "crate.glb"),
        ("crate-strong.glb", "crate_metal.glb"),
        ("crate-item.glb", "crate_item.glb"),
        ("spike-block.glb", "spike_block.glb"),
        ("trap-spikes.glb", "spike_trap.glb"),
        ("trap-spikes-large.glb", "spike_trap_large.glb"),
    ]

    for src_name, dest_name in obstacles_to_copy:
        source = platformer_glb / src_name
        if copy_asset(source, obstacles_dest, dest_name):
            copied += 1
        else:
            failed += 1

    # ============================================================================
    # 3. PLATFORMER KIT - Platforms
    # ============================================================================
    print("\n📦 PLATFORMER KIT → Additional Platforms")
    print("-" * 70)

    platforms_dest = BASE_DIR / "models/platforms"

    platforms_to_copy = [
        ("block-grass-large.glb", "platform_grass_large.glb"),
        ("block-grass-long.glb", "platform_grass_long.glb"),
        ("block-grass-low.glb", "platform_grass_low.glb"),
        ("block-grass-narrow.glb", "platform_grass_narrow.glb"),
        ("block-grass-corner.glb", "platform_grass_corner.glb"),
        ("block-grass-hexagon.glb", "platform_grass_hexagon.glb"),
    ]

    for src_name, dest_name in platforms_to_copy:
        source = platformer_glb / src_name
        if copy_asset(source, platforms_dest, dest_name):
            copied += 1
        else:
            failed += 1

    # ============================================================================
    # 4. PLATFORMER KIT - Props (Checkpoint, Flag, Coins)
    # ============================================================================
    print("\n📦 PLATFORMER KIT → Props & Collectibles")
    print("-" * 70)

    props_dest = BASE_DIR / "models/environment/props"

    # Checkpoint flag
    source = platformer_glb / "flag.glb"
    if copy_asset(source, props_dest, "checkpoint.glb"):
        copied += 1
    else:
        failed += 1

    # ============================================================================
    # 5. ANIMATED CHARACTERS - Enemies
    # ============================================================================
    print("\n📦 ANIMATED CHARACTERS → Enemies")
    print("-" * 70)

    # Note: Kenney animated characters use FBX, we'll need to handle this differently
    # For now, let's check if there are GLB versions
    char_model = MIXASSETS / "kenney_animated-characters-1/Model"
    enemies_dest = BASE_DIR / "models/characters/enemies"

    # Check for FBX files (will need conversion in Godot)
    char_fbx = char_model / "characterMedium.fbx"
    if char_fbx.exists():
        print(f"ℹ️  Found character FBX: {char_fbx.name}")
        print(f"   → Will copy to enemies folder (Godot will import FBX)")
        if copy_asset(char_fbx, enemies_dest, "enemy_character.fbx"):
            copied += 1
        else:
            failed += 1

    # ============================================================================
    # 6. NATURE KIT - Environment (Jungle Theme)
    # ============================================================================
    print("\n📦 NATURE KIT → Jungle Environment")
    print("-" * 70)

    nature_glb = MIXASSETS / "kenney_nature-kit/Models/GLB format"
    jungle_dest = BASE_DIR / "models/environment/jungle"

    nature_assets = [
        ("tree-pine.glb", "tree_pine.glb"),
        ("tree-oak.glb", "tree_oak.glb"),
        ("rock.glb", "rock_large.glb"),
        ("rock-largeA.glb", "rock_large_a.glb"),
        ("rock-largeB.glb", "rock_large_b.glb"),
        ("rock-smallA.glb", "rock_small_a.glb"),
        ("rock-smallB.glb", "rock_small_b.glb"),
        ("flower-pink.glb", "flower_pink.glb"),
        ("mushroom-red.glb", "mushroom_red.glb"),
        ("grass.glb", "grass_patch.glb"),
    ]

    for src_name, dest_name in nature_assets:
        source = nature_glb / src_name
        if copy_asset(source, jungle_dest, dest_name):
            copied += 1
        else:
            failed += 1

    # ============================================================================
    # 7. GAME ICONS - UI Sprites
    # ============================================================================
    print("\n📦 GAME ICONS → UI Icons")
    print("-" * 70)

    # Use 2x (high res) white icons for UI
    icons_src = MIXASSETS / "kenney_game-icons/PNG/White/2x"
    icons_dest = BASE_DIR / "sprites/ui/icons"

    ui_icons = [
        ("star.png", "icon_star.png"),
        ("pause.png", "button_pause.png"),
        ("buttonStart.png", "button_play.png"),
        ("home.png", "button_home.png"),
        ("return.png", "button_restart.png"),
        ("checkmark.png", "icon_checkmark.png"),
        ("cross.png", "icon_cross.png"),
        ("buttonA.png", "button_jump.png"),
        ("buttonB.png", "button_spin.png"),
    ]

    for src_name, dest_name in ui_icons:
        source = icons_src / src_name
        if copy_asset(source, icons_dest, dest_name):
            copied += 1
        else:
            failed += 1

    # Check expansion pack for heart/life icon
    icons_exp_src = MIXASSETS / "kenney_game-icons-expansion/PNG/White/2x"

    # Look for heart icon
    heart_candidates = ["heart.png", "heartFull.png"]
    for heart_name in heart_candidates:
        source = icons_exp_src / heart_name
        if source.exists():
            if copy_asset(source, icons_dest, "icon_life.png"):
                copied += 1
            else:
                failed += 1
            break

    # ============================================================================
    # 8. PARTICLE PACK - Effects
    # ============================================================================
    print("\n📦 PARTICLE PACK → Effect Sprites")
    print("-" * 70)

    particles_src = MIXASSETS / "kenney_particle-pack/PNG (Transparent)"
    effects_dest = BASE_DIR / "sprites/effects"

    particle_files = [
        ("star_01.png", "star_particle.png"),
        ("star_02.png", "star_particle_02.png"),
        ("circle_01.png", "circle_particle.png"),
        ("spark_01.png", "spark_particle.png"),
        ("smoke_01.png", "smoke_particle.png"),
    ]

    for src_name, dest_name in particle_files:
        source = particles_src / src_name
        if copy_asset(source, effects_dest, dest_name):
            copied += 1
        else:
            failed += 1

    # ============================================================================
    # SUMMARY
    # ============================================================================
    print("\n" + "=" * 70)
    print("📊 ORGANIZATION COMPLETE!")
    print("=" * 70)
    print(f"✅ Successfully copied: {copied} files")
    print(f"❌ Failed/Not found: {failed} files")
    print(f"📁 Assets organized into proper folders")
    print("\n💡 Next steps:")
    print("   1. Open Godot and let it import the assets")
    print("   2. Check import settings for 3D models and textures")
    print("   3. Run: git add models/ sprites/")
    print("   4. Run: git commit -m 'Organize Kenney assets into proper structure'")
    print("=" * 70)

if __name__ == "__main__":
    organize_assets()
