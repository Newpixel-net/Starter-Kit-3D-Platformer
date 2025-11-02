extends Node3D
## Simple Jungle Spawner - Error-proof version
## Only spawns decorations that successfully load

@export var spawn_trees: bool = true
@export var spawn_rocks: bool = true
@export var spawn_plants: bool = true

func _ready():
	call_deferred("spawn_environment")


func spawn_environment():
	var total_spawned = 0

	if spawn_trees:
		total_spawned += spawn_category("Trees", get_tree_data())

	if spawn_rocks:
		total_spawned += spawn_category("Rocks", get_rock_data())

	if spawn_plants:
		total_spawned += spawn_category("Plants", get_plant_data())

	print("✅ JungleSpawner: Spawned ", total_spawned, " decorations total!")


func spawn_category(category_name: String, items: Array) -> int:
	var spawned = 0

	for item in items:
		var decoration = create_decoration(item)
		if decoration:
			add_child(decoration)
			spawned += 1

	if spawned > 0:
		print("   🌴 ", category_name, ": ", spawned, " items")

	return spawned


func create_decoration(data: Dictionary) -> MeshInstance3D:
	var model_path = data.get("model", "")

	# Check if model exists
	if not ResourceLoader.exists(model_path):
		return null

	var mesh_inst = MeshInstance3D.new()
	mesh_inst.position = data.get("pos", Vector3.ZERO)
	mesh_inst.name = model_path.get_file().get_basename()

	# Try to load model
	var loaded = load(model_path)
	if not loaded:
		return null

	if loaded is PackedScene:
		var model = loaded.instantiate()
		mesh_inst.add_child(model)
	elif loaded is Mesh:
		mesh_inst.mesh = loaded
	else:
		return null

	# Apply scale
	var scale_val = data.get("scale", 1.0)
	mesh_inst.scale = Vector3(scale_val, scale_val, scale_val)

	return mesh_inst


func get_tree_data() -> Array:
	return [
		{"pos": Vector3(-3, 0, 2), "model": "res://models/environment/jungle/tree_palm.glb", "scale": 2.0},
		{"pos": Vector3(7, 0, -8), "model": "res://models/environment/jungle/tree_oak.glb", "scale": 2.0},
		{"pos": Vector3(12, 0, 3), "model": "res://models/environment/jungle/tree_default.glb", "scale": 2.0},
	]


func get_rock_data() -> Array:
	return [
		{"pos": Vector3(-2, 0, -2), "model": "res://models/environment/jungle/rock_largeA.glb", "scale": 1.5},
		{"pos": Vector3(4, 0, 2), "model": "res://models/environment/jungle/rock_largeB.glb", "scale": 1.2},
		{"pos": Vector3(10, 0, -10), "model": "res://models/environment/jungle/rock_smallA.glb", "scale": 0.8},
	]


func get_plant_data() -> Array:
	return [
		{"pos": Vector3(1, 0, 1), "model": "res://models/environment/jungle/flower_redA.glb", "scale": 1.0},
		{"pos": Vector3(6, 0, -1), "model": "res://models/environment/jungle/grass_large.glb", "scale": 1.0},
		{"pos": Vector3(9, 0, -4), "model": "res://models/environment/jungle/mushroom_red.glb", "scale": 1.0},
		{"pos": Vector3(14, 0, -8), "model": "res://models/environment/jungle/plant_bush.glb", "scale": 1.0},
	]
