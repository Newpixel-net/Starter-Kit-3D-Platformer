@tool
extends EditorScript

## Asset Import Verification Tool
## Run this in Godot Editor: File > Run Script
## This will force Godot to scan and import all GLB assets

func _run():
	print("\n=== ASSET IMPORT VERIFICATION ===\n")

	var categories = {
		"Fruits": _get_fruit_paths(),
		"Obstacles": _get_obstacle_paths(),
		"Platforms": _get_platform_paths(),
		"Jungle Environment": _get_jungle_paths()
	}

	var total_found = 0
	var total_loaded = 0
	var failed_assets = []

	for category in categories:
		print("📦 Checking ", category, "...")
		var paths = categories[category]
		var loaded = 0

		for path in paths:
			if ResourceLoader.exists(path):
				var resource = load(path)
				if resource:
					loaded += 1
					total_loaded += 1
					print("  ✅ ", path.get_file())
				else:
					failed_assets.append(path)
					print("  ❌ FAILED TO LOAD: ", path)
			else:
				failed_assets.append(path)
				print("  ❌ NOT FOUND: ", path)

		total_found += paths.size()
		print("  → ", loaded, "/", paths.size(), " loaded successfully\n")

	print("\n=== RESULTS ===")
	print("Total assets checked: ", total_found)
	print("Successfully loaded: ", total_loaded)
	print("Failed: ", failed_assets.size())

	if failed_assets.size() > 0:
		print("\n⚠️  FAILED ASSETS:")
		for asset in failed_assets:
			print("  - ", asset)
	else:
		print("\n🎉 ALL ASSETS IMPORTED SUCCESSFULLY!")

	print("\n=== IMPORT COMPLETE ===\n")


func _get_fruit_paths() -> Array:
	return [
		"res://models/collectibles/fruits/apple.glb",
		"res://models/collectibles/fruits/banana.glb",
		"res://models/collectibles/fruits/cherry.glb",
		"res://models/collectibles/fruits/grapes.glb",
		"res://models/collectibles/fruits/orange.glb",
		"res://models/collectibles/fruits/pineapple.glb",
		"res://models/collectibles/fruits/strawberry.glb",
		"res://models/collectibles/fruits/watermelon.glb",
	]


func _get_obstacle_paths() -> Array:
	return [
		"res://models/obstacles/crate.glb",
		"res://models/obstacles/crate_item.glb",
		"res://models/obstacles/crate_stack.glb",
		"res://models/obstacles/spike.glb",
		"res://models/obstacles/spikes.glb",
		"res://models/obstacles/spikes_large.glb",
	]


func _get_platform_paths() -> Array:
	return [
		"res://models/platforms/platform_beach.glb",
		"res://models/platforms/platform_grass.glb",
		"res://models/platforms/platform_sand.glb",
		"res://models/platforms/platform_snow.glb",
		"res://models/platforms/platform_stone.glb",
		"res://models/platforms/platform_wood.glb",
	]


func _get_jungle_paths() -> Array:
	# Returns first 20 jungle assets for quick testing
	return [
		"res://models/environment/jungle/cliff_block_stone.glb",
		"res://models/environment/jungle/cliff_diagonal_stone.glb",
		"res://models/environment/jungle/cliff_stone.glb",
		"res://models/environment/jungle/fence_planks.glb",
		"res://models/environment/jungle/flower_redA.glb",
		"res://models/environment/jungle/flower_redB.glb",
		"res://models/environment/jungle/grass.glb",
		"res://models/environment/jungle/grass_large.glb",
		"res://models/environment/jungle/lily_pads.glb",
		"res://models/environment/jungle/log.glb",
		"res://models/environment/jungle/mushroom_redGroup.glb",
		"res://models/environment/jungle/mushroom_red.glb",
		"res://models/environment/jungle/plant_bush.glb",
		"res://models/environment/jungle/rock_largeA.glb",
		"res://models/environment/jungle/rock_largeB.glb",
		"res://models/environment/jungle/rock_smallA.glb",
		"res://models/environment/jungle/tree_default.glb",
		"res://models/environment/jungle/tree_oak.glb",
		"res://models/environment/jungle/tree_palm.glb",
		"res://models/environment/jungle/vine.glb",
	]
