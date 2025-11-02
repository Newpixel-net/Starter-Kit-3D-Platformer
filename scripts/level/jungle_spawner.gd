extends Node3D
## Jungle Environment Spawner - Creates jungle atmosphere with trees, rocks, and plants
## Usage: Add this as a child node to your main scene

## Enable/disable specific decoration types
@export var spawn_trees: bool = true
@export var spawn_rocks: bool = true
@export var spawn_plants: bool = true

var decorations = []

func _ready():
	await get_tree().process_frame
	setup_decorations()
	spawn_environment()


func setup_decorations():
	# Define all decoration positions and models
	decorations = []

	# Trees
	if spawn_trees:
		decorations.append_array([
			{"pos": Vector3(-3, 0, 2), "model": "res://models/environment/jungle/tree_palm.glb", "scale": 2.0},
			{"pos": Vector3(7, 0, -8), "model": "res://models/environment/jungle/tree_oak.glb", "scale": 2.0},
			{"pos": Vector3(-5, 0, -5), "model": "res://models/environment/jungle/tree_default.glb", "scale": 2.0},
			{"pos": Vector3(12, 0, 3), "model": "res://models/environment/jungle/tree_palm.glb", "scale": 2.0},
			{"pos": Vector3(25, 0, -8), "model": "res://models/environment/jungle/tree_oak.glb", "scale": 2.0},
		])

	# Rocks
	if spawn_rocks:
		decorations.append_array([
			{"pos": Vector3(-2, 0, -2), "model": "res://models/environment/jungle/rock_largeA.glb", "scale": 1.5},
			{"pos": Vector3(4, 0, 2), "model": "res://models/environment/jungle/rock_largeB.glb", "scale": 1.2},
			{"pos": Vector3(10, 0, -10), "model": "res://models/environment/jungle/rock_smallA.glb", "scale": 0.8},
			{"pos": Vector3(16, 0, -3), "model": "res://models/environment/jungle/rock_largeC.glb", "scale": 1.3},
			{"pos": Vector3(23, 0, -10), "model": "res://models/environment/jungle/rock_smallB.glb", "scale": 0.9},
		])

	# Plants and flowers
	if spawn_plants:
		decorations.append_array([
			{"pos": Vector3(1, 0, 1), "model": "res://models/environment/jungle/flower_redA.glb", "scale": 1.0},
			{"pos": Vector3(6, 0, -1), "model": "res://models/environment/jungle/flower_yellowB.glb", "scale": 1.0},
			{"pos": Vector3(9, 0, -4), "model": "res://models/environment/jungle/grass_large.glb", "scale": 1.0},
			{"pos": Vector3(14, 0, -8), "model": "res://models/environment/jungle/mushroom_red.glb", "scale": 1.0},
			{"pos": Vector3(19, 0, -6), "model": "res://models/environment/jungle/plant_bush.glb", "scale": 1.0},
			{"pos": Vector3(21, 0, -2), "model": "res://models/environment/jungle/flower_purpleA.glb", "scale": 1.0},
			{"pos": Vector3(2, 0, -3), "model": "res://models/environment/jungle/flower_redB.glb", "scale": 1.0},
			{"pos": Vector3(11, 0, -2), "model": "res://models/environment/jungle/grass.glb", "scale": 0.8},
		])


func spawn_environment():
	var spawned_count = 0

	for decoration_data in decorations:
		var decoration = spawn_decoration(decoration_data)
		if decoration:
			add_child(decoration)
			spawned_count += 1

	print("✅ Spawned ", spawned_count, " jungle decorations!")


func spawn_decoration(data: Dictionary) -> Node3D:
	var mesh_inst = MeshInstance3D.new()
	mesh_inst.position = data["pos"]
	mesh_inst.name = data["model"].get_file().get_basename()

	var model_path = data["model"]

	# Try to load the model
	if ResourceLoader.exists(model_path):
		var loaded_resource = load(model_path)

		if loaded_resource is PackedScene:
			# If it's a scene, instantiate it as a child
			var model = loaded_resource.instantiate()
			mesh_inst.add_child(model)
		elif loaded_resource is Mesh:
			# If it's a mesh, assign it directly
			mesh_inst.mesh = loaded_resource
		else:
			print("⚠️ Unknown resource type for: ", model_path)
			return null
	else:
		print("⚠️ Model not found: ", model_path)
		return null

	# Apply scale
	var scale_val = data.get("scale", 1.0)
	mesh_inst.scale = Vector3(scale_val, scale_val, scale_val)

	print("🌴 Spawned: ", mesh_inst.name, " at ", data["pos"])

	return mesh_inst
