extends Node
## Auto-loaded diagnostic to verify asset imports on game start

func _ready():
	call_deferred("check_asset_imports")


func check_asset_imports():
	var separator = "=================================================="
	print("\n" + separator)
	print("🔍 ASSET IMPORT DIAGNOSTIC")
	print(separator)

	var test_assets = {
		"Fruit (Apple)": "res://models/collectibles/fruits/apple.glb",
		"Crate": "res://models/obstacles/crate.glb",
		"Tree (Palm)": "res://models/environment/jungle/tree_palm.glb",
		"Rock": "res://models/environment/jungle/rock_largeA.glb",
	}

	var all_imported = true

	for asset_name in test_assets:
		var path = test_assets[asset_name]
		var exists = ResourceLoader.exists(path)
		var can_load = false

		if exists:
			var loaded = load(path)
			can_load = loaded != null

		if exists and can_load:
			print("✅ ", asset_name, " - IMPORTED & LOADABLE")
		elif exists:
			print("⚠️  ", asset_name, " - EXISTS but FAILED TO LOAD")
			all_imported = false
		else:
			print("❌ ", asset_name, " - NOT FOUND OR NOT IMPORTED")
			all_imported = false

	print(separator)

	if all_imported:
		print("🎉 ALL ASSETS IMPORTED SUCCESSFULLY!")
		print("   → You should see colorful fruits and jungle!")
	else:
		print("⚠️  SOME ASSETS NOT IMPORTED!")
		print("   → ACTION REQUIRED:")
		print("   1. Open Godot Editor")
		print("   2. Right-click 'models' folder in FileSystem")
		print("   3. Select 'Reimport'")
		print("   4. Wait 30 seconds for import to complete")
		print("   5. Run game again")
		print("\n   → OR read ASSET_IMPORT_FIX.md for full instructions")

	print(separator + "\n")
