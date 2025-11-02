extends Node3D


func _ready() -> void:
	if RenderingServer.get_current_rendering_method() == "gl_compatibility":
		# Reduce background and sun brightness when using the Compatibility renderer;
		# this tries to roughly match the appearance of Forward+.
		# This compensates for the different color space and light rendering for lights with shadows enabled.
		$Sun.light_energy = 0.24
		$Sun.shadow_opacity = 0.85
		$Environment.environment.background_energy_multiplier = 0.25

	# TEST: Spawn one large visible fruit to verify assets work
	setup_test_fruit()

	# CRITICAL: Setup jungle environment and collectibles
	setup_level_spawners()


func setup_level_spawners():
	"""Automatically adds fruit, crate, and jungle spawners to the level"""

	print("\n🌴 SETTING UP JUNGLE LEVEL...")

	# Get or create World node (where all level objects go)
	var world = get_node_or_null("World")
	if not world:
		print("❌ ERROR: World node not found!")
		return

	# 1. Add Fruit Spawner
	var fruit_spawner = Node3D.new()
	fruit_spawner.name = "FruitSpawner"
	var fruit_script = load("res://scripts/level/fruit_spawner.gd")
	if fruit_script:
		fruit_spawner.set_script(fruit_script)
		world.add_child(fruit_spawner)
		print("✅ Added FruitSpawner to scene")
	else:
		print("❌ Failed to load fruit_spawner.gd")

	# 2. Add Crate Spawner
	var crate_spawner = Node3D.new()
	crate_spawner.name = "CrateSpawner"
	var crate_script = load("res://scripts/level/crate_spawner.gd")
	if crate_script:
		crate_spawner.set_script(crate_script)
		world.add_child(crate_spawner)
		print("✅ Added CrateSpawner to scene")
	else:
		print("❌ Failed to load crate_spawner.gd")

	# 3. Add Jungle Environment Spawner
	var jungle_spawner = Node3D.new()
	jungle_spawner.name = "JungleSpawner"
	var jungle_script = load("res://scripts/level/jungle_spawner.gd")
	if jungle_script:
		jungle_spawner.set_script(jungle_script)
		world.add_child(jungle_spawner)
		print("✅ Added JungleSpawner to scene")
	else:
		print("❌ Failed to load jungle_spawner.gd")

	print("🎮 Level spawners setup complete!\n")


func setup_test_fruit():
	"""Spawns ONE large obvious fruit for testing"""
	var test = Node3D.new()
	test.name = "TestFruit"
	var test_script = load("res://scripts/test_single_fruit.gd")
	if test_script:
		test.set_script(test_script)
		add_child(test)
