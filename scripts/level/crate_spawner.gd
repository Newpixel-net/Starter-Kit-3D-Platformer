extends Node3D
## Crate Spawner - Uses Kenney 3D crate models
## Breakable crates that can contain fruits

@export var spawn_count: int = 5
@export var use_fallback_boxes: bool = false
@export var crate_scale: float = 1.0

# Available crate models
var crate_models = [
	"res://models/obstacles/crate.glb",
	"res://models/obstacles/crate_item.glb",
	"res://models/obstacles/crate_stack.glb",
]

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
	var failed = 0

	for i in range(min(spawn_count, positions.size())):
		# Use different crate model for variety
		var model_index = i % crate_models.size()
		var crate = create_crate(model_index)

		if crate:
			crate.position = positions[i]
			add_child(crate)
			spawned += 1
		else:
			failed += 1

	if spawned > 0:
		print("✅ CrateSpawner: Spawned ", spawned, " crates!")
	if failed > 0:
		print("⚠️  CrateSpawner: ", failed, " crates failed (check if models imported)")


func create_crate(model_index: int = 0) -> StaticBody3D:
	var crate = StaticBody3D.new()
	crate.name = "Crate"

	# Create mesh instance
	var mesh_inst = MeshInstance3D.new()
	var model_loaded = false

	# Try to load the 3D crate model (if not using fallback)
	if not use_fallback_boxes:
		var crate_model_path = crate_models[model_index % crate_models.size()]

		if ResourceLoader.exists(crate_model_path):
			var loaded = load(crate_model_path)
			if loaded:
				if loaded is PackedScene:
					var model = loaded.instantiate()
					mesh_inst.add_child(model)
					model_loaded = true
				elif loaded is Mesh:
					mesh_inst.mesh = loaded
					model_loaded = true

	# Fallback to simple brown box if model fails to load
	if not model_loaded:
		var box_mesh = BoxMesh.new()
		box_mesh.size = Vector3(1, 1, 1)
		mesh_inst.mesh = box_mesh

		var material = StandardMaterial3D.new()
		material.albedo_color = Color(0.6, 0.4, 0.2)  # Brown wood color
		mesh_inst.material_override = material

	mesh_inst.scale = Vector3(crate_scale, crate_scale, crate_scale)
	crate.add_child(mesh_inst)

	# Add collision shape
	var collision = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(1.0, 1.0, 1.0) * crate_scale
	collision.shape = box_shape
	crate.add_child(collision)

	# Try to attach crate behavior script
	var crate_script_path = "res://scripts/crate.gd"
	if ResourceLoader.exists(crate_script_path):
		var script = load(crate_script_path)
		if script:
			crate.set_script(script)
			# Set properties if script loaded
			if crate.has_method("set"):
				crate.set("contains_fruit", true)
				crate.set("fruit_count", randi_range(2, 4))  # Random fruit count

	# Add to breakable group for spin attack detection
	crate.add_to_group("breakable")

	return crate
