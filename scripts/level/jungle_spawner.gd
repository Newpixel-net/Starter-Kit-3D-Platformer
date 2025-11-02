extends Node3D
## Jungle Environment Spawner - Kenney Nature Kit assets
## Creates lush jungle atmosphere with trees, rocks, flowers, and plants

@export var spawn_trees: bool = true
@export var spawn_rocks: bool = true
@export var spawn_plants: bool = true
@export var spawn_flowers: bool = true
@export var tree_density: int = 10  # Number of trees to spawn
@export var rock_density: int = 15  # Number of rocks to spawn
@export var plant_density: int = 20  # Number of plants/flowers to spawn

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

	if spawn_flowers:
		total_spawned += spawn_category("Flowers", get_flower_data())

	print("✅ JungleSpawner: Spawned ", total_spawned, " decorations total!")


func spawn_category(category_name: String, items: Array) -> int:
	var spawned = 0
	var failed = 0

	for item in items:
		var decoration = create_decoration(item)
		if decoration:
			add_child(decoration)
			spawned += 1
		else:
			failed += 1

	if spawned > 0:
		print("   🌴 ", category_name, ": ", spawned, " items")
	if failed > 0 and failed < items.size():
		print("   ⚠️  ", category_name, ": ", failed, " failed to load")

	return spawned


func create_decoration(data: Dictionary) -> Node3D:
	var model_path = data.get("model", "")

	# Check if model exists
	if not ResourceLoader.exists(model_path):
		return null

	# Try to load model
	var loaded = load(model_path)
	if not loaded:
		return null

	# Create node
	var decoration = Node3D.new()
	decoration.position = data.get("pos", Vector3.ZERO)
	decoration.name = model_path.get_file().get_basename()

	# Add 3D model
	if loaded is PackedScene:
		var model = loaded.instantiate()
		decoration.add_child(model)
	elif loaded is Mesh:
		var mesh_inst = MeshInstance3D.new()
		mesh_inst.mesh = loaded
		decoration.add_child(mesh_inst)
	else:
		return null

	# Apply scale
	var scale_val = data.get("scale", 1.0)
	decoration.scale = Vector3(scale_val, scale_val, scale_val)

	# Apply rotation if specified
	if data.has("rotation"):
		decoration.rotation.y = data.get("rotation")

	return decoration


func get_tree_data() -> Array:
	var trees = []

	# Variety of trees for jungle atmosphere
	var tree_models = [
		"res://models/environment/jungle/tree_palm.glb",
		"res://models/environment/jungle/tree_oak.glb",
		"res://models/environment/jungle/tree_default.glb",
		"res://models/environment/jungle/tree_pineDefaultA.glb",
		"res://models/environment/jungle/tree_pineRoundA.glb",
	]

	# Place trees in strategic positions (background/sides)
	var tree_positions = [
		Vector3(-5, 0, 3),
		Vector3(-8, 0, -2),
		Vector3(-6, 0, -8),
		Vector3(20, 0, 2),
		Vector3(25, 0, -5),
		Vector3(18, 0, -12),
		Vector3(-4, 0, -15),
		Vector3(22, 0, -15),
		Vector3(12, 0, 5),
		Vector3(-10, 0, -12),
	]

	for i in range(min(tree_density, tree_positions.size())):
		var model = tree_models[i % tree_models.size()]
		trees.append({
			"pos": tree_positions[i],
			"model": model,
			"scale": randf_range(1.8, 2.5),
			"rotation": randf_range(0, TAU)
		})

	return trees


func get_rock_data() -> Array:
	var rocks = []

	# Variety of rock sizes
	var rock_models_large = [
		"res://models/environment/jungle/rock_largeA.glb",
		"res://models/environment/jungle/rock_largeB.glb",
		"res://models/environment/jungle/rock_largeC.glb",
	]

	var rock_models_small = [
		"res://models/environment/jungle/rock_smallA.glb",
		"res://models/environment/jungle/rock_smallB.glb",
		"res://models/environment/jungle/rock_smallC.glb",
		"res://models/environment/jungle/rock_smallFlatA.glb",
	]

	# Scattered rocks around the level
	var rock_positions = [
		Vector3(-2, 0, 0),
		Vector3(4, 0, -2),
		Vector3(1, 0, -5),
		Vector3(7, 0, -8),
		Vector3(11, 0, -4),
		Vector3(15, 0, -10),
		Vector3(-3, 0, -7),
		Vector3(17, 0, -3),
		Vector3(5, 0, -11),
		Vector3(20, 0, -8),
		Vector3(-1, 0, -12),
		Vector3(24, 0, -6),
		Vector3(9, 0, 1),
		Vector3(13, 0, -14),
		Vector3(-5, 0, -10),
	]

	for i in range(min(rock_density, rock_positions.size())):
		var is_large = (i % 3 == 0)  # Every 3rd rock is large
		var model_array = rock_models_large if is_large else rock_models_small
		var model = model_array[i % model_array.size()]

		rocks.append({
			"pos": rock_positions[i],
			"model": model,
			"scale": randf_range(0.8, 1.5) if is_large else randf_range(0.6, 1.0),
			"rotation": randf_range(0, TAU)
		})

	return rocks


func get_plant_data() -> Array:
	var plants = []

	# Bushes and grass
	var plant_models = [
		"res://models/environment/jungle/plant_bush.glb",
		"res://models/environment/jungle/grass_large.glb",
		"res://models/environment/jungle/grass.glb",
		"res://models/environment/jungle/mushroom_red.glb",
	]

	# Dense plant coverage
	for i in range(plant_density):
		# Distribute along the level path
		var x = randf_range(-4, 26)
		var z = randf_range(-16, 4)
		var model = plant_models[i % plant_models.size()]

		plants.append({
			"pos": Vector3(x, 0, z),
			"model": model,
			"scale": randf_range(0.7, 1.3),
			"rotation": randf_range(0, TAU)
		})

	return plants


func get_flower_data() -> Array:
	var flowers = []

	# Colorful flowers for visual interest
	var flower_models = [
		"res://models/environment/jungle/flower_redA.glb",
		"res://models/environment/jungle/flower_redB.glb",
		"res://models/environment/jungle/flower_purpleA.glb",
		"res://models/environment/jungle/flower_purpleB.glb",
		"res://models/environment/jungle/flower_yellowA.glb",
		"res://models/environment/jungle/flower_yellowB.glb",
	]

	# Scatter colorful flowers
	for i in range(15):  # Fixed flower count
		var x = randf_range(-3, 24)
		var z = randf_range(-15, 3)
		var model = flower_models[i % flower_models.size()]

		flowers.append({
			"pos": Vector3(x, 0, z),
			"model": model,
			"scale": randf_range(0.8, 1.2),
			"rotation": randf_range(0, TAU)
		})

	return flowers
