extends Node3D
## TEST SCRIPT - Spawns ONE large apple right in front of player
## This verifies that: 1) asset is imported, 2) spawning works, 3) fruit is visible

func _ready():
	call_deferred("spawn_test_fruit")


func spawn_test_fruit():
	print("\n🍎 SPAWNING TEST FRUIT...")

	var apple_path = "res://models/collectibles/fruits/apple.glb"

	# Check if apple exists
	if not ResourceLoader.exists(apple_path):
		print("❌ TEST FAILED: Apple model not found at " + apple_path)
		print("   → Asset not imported! Follow ASSET_IMPORT_FIX.md")
		spawn_fallback_box()
		return

	# Try to load apple
	var loaded = load(apple_path)
	if not loaded:
		print("❌ TEST FAILED: Apple model exists but won't load")
		spawn_fallback_box()
		return

	# Create test fruit node
	var fruit = Node3D.new()
	fruit.name = "TEST_APPLE"
	fruit.position = Vector3(-3, 2, 0)  # Right in front of starting position

	# Add the 3D model
	var model_instance = null
	if loaded is PackedScene:
		model_instance = loaded.instantiate()
		print("✅ Apple loaded as PackedScene")
	elif loaded is Mesh:
		var mesh_inst = MeshInstance3D.new()
		mesh_inst.mesh = loaded
		model_instance = mesh_inst
		print("✅ Apple loaded as Mesh")

	if model_instance:
		fruit.add_child(model_instance)
		# Make it LARGE and obvious for testing
		fruit.scale = Vector3(2, 2, 2)
		add_child(fruit)

		# Add rotation animation
		var script_code = """
extends Node3D
func _process(delta):
	rotation.y += delta * 2.0
"""
		var anim_script = GDScript.new()
		anim_script.source_code = script_code
		anim_script.reload()
		fruit.set_script(anim_script)

		print("🎉 TEST SUCCESS! Large spinning apple spawned at ", fruit.position)
		print("   → Look for a BIG red apple in front of you!")
		print("   → If you see it, assets are working correctly! 🎮")
	else:
		print("❌ TEST FAILED: Couldn't create model instance")
		spawn_fallback_box()


func spawn_fallback_box():
	"""Spawn a bright red box as fallback"""
	print("   → Spawning BRIGHT RED BOX as fallback test...")

	var box = MeshInstance3D.new()
	box.name = "TEST_FALLBACK_BOX"
	box.position = Vector3(-3, 2, 0)

	var mesh = BoxMesh.new()
	mesh.size = Vector3(2, 2, 2)
	box.mesh = mesh

	var material = StandardMaterial3D.new()
	material.albedo_color = Color(1, 0, 0, 1)  # Bright red
	material.emission_enabled = true
	material.emission = Color(1, 0, 0)
	box.material_override = material

	add_child(box)

	print("🟥 FALLBACK: Bright red box spawned at ", box.position)
	print("   → If you see red box: Spawning works but assets not imported")
	print("   → Follow ASSET_IMPORT_FIX.md to fix imports")
