extends Node3D
## Fruit Spawner - Automatically spawns fruit collectibles in the level
## Usage: Add this as a child node to your main scene

const FRUIT_SCENE = preload("res://objects/coin.tscn")  # Using coin scene temporarily

## Fruit spawn positions (edit these in the inspector or in code)
@export var fruit_positions: Array[Vector3] = [
	Vector3(2, 1.5, 0),
	Vector3(4, 1.5, 0),
	Vector3(6, 1.5, -3),
	Vector3(8, 1.5, -3),
	Vector3(12, 2.5, -6),
	Vector3(14, 2.5, -6),
	Vector3(16, 3.5, -9),
	Vector3(18, 3.5, -9),
	Vector3(22, 4.5, -5),
	Vector3(24, 4.5, -5),
	Vector3(3, 1.5, -1),
	Vector3(7, 1.5, -4),
	Vector3(11, 2.5, -7),
	Vector3(17, 3.5, -8),
	Vector3(23, 4.5, -6),
]

func _ready():
	# Small delay to ensure scene is fully loaded
	await get_tree().process_frame
	spawn_fruits()


func spawn_fruits():
	for pos in fruit_positions:
		var fruit = FRUIT_SCENE.instantiate()
		fruit.position = pos
		add_child(fruit)
		print("🍎 Spawned fruit at ", pos)

	print("✅ Spawned ", fruit_positions.size(), " fruits!")
