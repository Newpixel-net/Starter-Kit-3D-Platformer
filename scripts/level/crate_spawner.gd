extends Node3D
## Simple Crate Spawner - Error-proof version

@export var spawn_count: int = 5
@export var use_fallback_boxes: bool = false

func _ready():
	call_deferred("spawn_crates")


func spawn_crates():
	var positions = [
		Vector3(3, 0.5, -1),
		Vector3(8, 1.5, -6),
		Vector3(13, 2.5, -9),
		Vector3(18, 3.5, -7),
		Vector3(22, 4.5, -3),
	]

	var spawned = 0
	for i in range(min(spawn_count, positions.size())):
		var crate = create_crate()
		if crate:
			crate.position = positions[i]
			add_child(crate)
			spawned += 1

	print("✅ CrateSpawner: Spawned ", spawned, " crates!")


func create_crate() -> StaticBody3D:
	var crate = StaticBody3D.new()
	crate.name = "Crate"

	# Create mesh
	var mesh_inst = MeshInstance3D.new()

	# Try to load crate model
	var crate_model_path = "res://models/obstacles/crate.glb"
	var model_loaded = false

	if not use_fallback_boxes and ResourceLoader.exists(crate_model_path):
		var loaded = load(crate_model_path)
		if loaded:
			if loaded is PackedScene:
				var model = loaded.instantiate()
				mesh_inst.add_child(model)
				model_loaded = true
			elif loaded is Mesh:
				mesh_inst.mesh = loaded
				model_loaded = true

	# Fallback to simple box if model fails
	if not model_loaded:
		var box_mesh = BoxMesh.new()
		box_mesh.size = Vector3(1, 1, 1)
		mesh_inst.mesh = box_mesh

		var material = StandardMaterial3D.new()
		material.albedo_color = Color(0.6, 0.4, 0.2)  # Brown
		mesh_inst.material_override = material

	crate.add_child(mesh_inst)

	# Add collision
	var collision = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(1, 1, 1)
	collision.shape = box_shape
	crate.add_child(collision)

	# Try to attach crate script
	var crate_script_path = "res://scripts/crate.gd"
	if ResourceLoader.exists(crate_script_path):
		var script = load(crate_script_path)
		if script:
			crate.set_script(script)
			# Set properties if script loaded
			if crate.has_method("set"):
				crate.set("contains_fruit", true)
				crate.set("fruit_count", 3)

	return crate
