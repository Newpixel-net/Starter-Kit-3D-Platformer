extends Node3D
## Fruit Spawner - Uses actual 3D fruit models from Kenney Food Kit
## Spawns variety of fruits (apples, bananas, oranges, etc.)

## Edit these positions to place fruits where you want
@export var spawn_count: int = 15
@export var spawn_in_grid: bool = true
@export var grid_spacing: float = 3.0
@export var use_variety: bool = true  # Mix different fruit types
@export var hover_height: float = 1.5
@export var rotation_speed: float = 2.0

# Available fruit models
var fruit_models = [
	"res://models/collectibles/fruits/apple.glb",
	"res://models/collectibles/fruits/orange.glb",
	"res://models/collectibles/fruits/banana.glb",
	"res://models/collectibles/fruits/cherry.glb",
	"res://models/collectibles/fruits/strawberry.glb",
	"res://models/collectibles/fruits/grapes.glb",
	"res://models/collectibles/fruits/pineapple.glb",
	"res://models/collectibles/fruits/watermelon.glb",
]

func _ready():
	call_deferred("spawn_fruits")


func spawn_fruits():
	var positions = []

	if spawn_in_grid:
		# Create a simple grid of fruits
		for i in range(spawn_count):
			var x = (i % 5) * grid_spacing
			var z = -(i / 5) * grid_spacing
			positions.append(Vector3(x, hover_height, z))
	else:
		# Manual positions (edit these!)
		positions = [
			Vector3(2, hover_height, 0),
			Vector3(4, hover_height, 0),
			Vector3(6, hover_height, -3),
			Vector3(8, hover_height, -3),
			Vector3(10, hover_height, -6),
			Vector3(12, hover_height, -6),
			Vector3(14, hover_height, -9),
			Vector3(16, hover_height, -9),
		]

	var spawned = 0
	var failed = 0
	var fruit_type_index = 0

	for pos in positions:
		var fruit = create_fruit(fruit_type_index)
		if fruit:
			fruit.position = pos
			add_child(fruit)
			spawned += 1
		else:
			failed += 1

		# Cycle through fruit types if variety is enabled
		if use_variety:
			fruit_type_index = (fruit_type_index + 1) % fruit_models.size()

	if spawned > 0:
		print("✅ FruitSpawner: Spawned ", spawned, " fruits!")
	if failed > 0:
		print("⚠️  FruitSpawner: ", failed, " fruits failed to load (trying fallback...)")
		spawn_fallback_fruits(failed)


func create_fruit(type_index: int = 0) -> Node3D:
	var model_path = fruit_models[type_index % fruit_models.size()]

	# Check if model exists
	if not ResourceLoader.exists(model_path):
		return null

	# Try to load the GLB model
	var loaded = load(model_path)
	if not loaded:
		return null

	# Create fruit node
	var fruit = Node3D.new()
	fruit.name = "Fruit_" + model_path.get_file().get_basename()

	# Add 3D model
	var model_instance = null
	if loaded is PackedScene:
		model_instance = loaded.instantiate()
	elif loaded is Mesh:
		var mesh_inst = MeshInstance3D.new()
		mesh_inst.mesh = loaded
		model_instance = mesh_inst

	if model_instance:
		fruit.add_child(model_instance)
		# Scale fruits to reasonable size
		fruit.scale = Vector3(0.5, 0.5, 0.5)

	# Add Area3D for collection
	var area = Area3D.new()
	area.name = "CollectionArea"
	fruit.add_child(area)

	# Add collision shape
	var collision = CollisionShape3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = 0.5
	collision.shape = sphere
	area.add_child(collision)

	# Connect collection signal
	area.body_entered.connect(_on_fruit_collected.bind(fruit))

	# Add rotation script
	var script_code = """
extends Node3D

var rotation_speed = %f
var bob_height = 0.3
var bob_speed = 2.0
var start_y = 0.0

func _ready():
	start_y = position.y

func _process(delta):
	rotation.y += delta * rotation_speed
	position.y = start_y + sin(Time.get_ticks_msec() / 1000.0 * bob_speed) * bob_height
""" % rotation_speed

	var script = GDScript.new()
	script.source_code = script_code
	script.reload()
	fruit.set_script(script)

	return fruit


func _on_fruit_collected(body: Node3D, fruit: Node3D):
	if body.has_method("collect_fruit"):
		body.collect_fruit(1)
		Audio.play("res://sounds/coin.ogg", randf_range(0.9, 1.1), 0.0)
		fruit.queue_free()


func spawn_fallback_fruits(count: int):
	# Fallback to coin scene if models don't load
	var coin_scene_path = "res://objects/coin.tscn"
	if not ResourceLoader.exists(coin_scene_path):
		return

	var coin_scene = load(coin_scene_path)
	if not coin_scene:
		return

	print("   → Using coin fallback for ", count, " fruits")

	# Spawn coins at remaining positions
	for i in range(count):
		var x = ((spawn_count - count + i) % 5) * grid_spacing
		var z = -((spawn_count - count + i) / 5) * grid_spacing
		var coin = coin_scene.instantiate()
		if coin:
			coin.position = Vector3(x, hover_height, z)
			add_child(coin)
