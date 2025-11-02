extends Node3D
## Simple Fruit Spawner - Error-proof version
## Spawns coins as fruits (temporary until we create fruit scenes)

## Edit these positions to place fruits where you want
@export var spawn_count: int = 15
@export var spawn_in_grid: bool = true
@export var grid_spacing: float = 3.0

func _ready():
	call_deferred("spawn_fruits")


func spawn_fruits():
	var coin_scene_path = "res://objects/coin.tscn"

	# Check if coin scene exists
	if not ResourceLoader.exists(coin_scene_path):
		push_error("❌ Coin scene not found at: " + coin_scene_path)
		return

	var coin_scene = load(coin_scene_path)
	if not coin_scene:
		push_error("❌ Failed to load coin scene")
		return

	var positions = []

	if spawn_in_grid:
		# Create a simple grid of fruits
		for i in range(spawn_count):
			var x = (i % 5) * grid_spacing
			var z = -(i / 5) * grid_spacing
			positions.append(Vector3(x, 1.5, z))
	else:
		# Manual positions (edit these!)
		positions = [
			Vector3(2, 1.5, 0),
			Vector3(4, 1.5, 0),
			Vector3(6, 1.5, -3),
			Vector3(8, 1.5, -3),
			Vector3(10, 1.5, -6),
			Vector3(12, 1.5, -6),
			Vector3(14, 1.5, -9),
			Vector3(16, 1.5, -9),
		]

	var spawned = 0
	for pos in positions:
		var fruit = coin_scene.instantiate()
		if fruit:
			fruit.position = pos
			add_child(fruit)
			spawned += 1

	print("✅ FruitSpawner: Spawned ", spawned, " fruits!")
