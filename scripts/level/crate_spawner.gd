extends Node3D
## Crate Spawner - Automatically spawns breakable crates
## Usage: Add this as a child node to your main scene

@export var crate_model_path: String = "res://models/obstacles/crate.glb"
@export var crate_positions: Array[Vector3] = [
	Vector3(3, 0.5, -1),
	Vector3(8, 1.5, -6),
	Vector3(13, 2.5, -9),
	Vector3(18, 3.5, -7),
	Vector3(22, 4.5, -3),
]

func _ready():
	await get_tree().process_frame
	spawn_crates()


func spawn_crates():
	for pos in crate_positions:
		var crate = create_crate()
		if crate:
			crate.position = pos
			add_child(crate)
			print("📦 Spawned crate at ", pos)

	print("✅ Spawned ", crate_positions.size(), " crates!")


func create_crate() -> StaticBody3D:
	var crate = StaticBody3D.new()
	crate.name = "Crate"

	# Load crate model
	var mesh_inst = MeshInstance3D.new()
	if ResourceLoader.exists(crate_model_path):
		var loaded_resource = load(crate_model_path)
		if loaded_resource is PackedScene:
			var model = loaded_resource.instantiate()
			mesh_inst.add_child(model)
		elif loaded_resource is Mesh:
			mesh_inst.mesh = loaded_resource
	else:
		# Fallback: create simple box
		print("⚠️ Crate model not found, using fallback box")
		var box_mesh = BoxMesh.new()
		box_mesh.size = Vector3(1, 1, 1)
		mesh_inst.mesh = box_mesh

		var material = StandardMaterial3D.new()
		material.albedo_color = Color(0.6, 0.4, 0.2)  # Brown color
		mesh_inst.material_override = material

	crate.add_child(mesh_inst)

	# Add collision
	var collision = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(1, 1, 1)
	collision.shape = box_shape
	crate.add_child(collision)

	# Attach crate script
	var crate_script = load("res://scripts/crate.gd")
	if crate_script:
		crate.set_script(crate_script)
		crate.contains_fruit = true  # Crates contain fruit!
		crate.fruit_count = 3

	return crate
