extends CharacterBody3D
## Player Controller with movement, jumping, and spin attack

signal coin_collected  # Keep for compatibility
signal fruit_collected(value: int)
signal enemy_hit
signal crate_broken

@export_subgroup("Components")
@export var view: Node3D

@export_subgroup("Properties")
@export var movement_speed = 250
@export var jump_strength = 7
@export var spin_attack_duration = 0.5
@export var spin_attack_cooldown = 0.3

var movement_velocity: Vector3
var rotation_direction: float
var gravity = 0

var previously_floored = false

var jump_single = true
var jump_double = true

# Spin attack variables
var is_spinning = false
var spin_timer = 0.0
var spin_cooldown_timer = 0.0

@onready var particles_trail = $ParticlesTrail
@onready var sound_footsteps = $SoundFootsteps
@onready var model = $Character
@onready var animation = $Character/PlayerAnimations

# Spin attack area - will be created in _ready()
var spin_attack_area: Area3D


func _ready() -> void:
	# Create spin attack area
	create_spin_attack_area()

	# Start level timer when player spawns
	PlayerStats.start_timer()


# Create Area3D for spin attack detection
func create_spin_attack_area() -> void:
	spin_attack_area = Area3D.new()
	spin_attack_area.name = "SpinAttackArea"

	var collision_shape = CollisionShape3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = 2.0  # Attack radius
	collision_shape.shape = sphere

	spin_attack_area.add_child(collision_shape)
	add_child(spin_attack_area)

	# Connect to area detection
	spin_attack_area.body_entered.connect(_on_spin_attack_hit)
	spin_attack_area.area_entered.connect(_on_spin_attack_hit_area)

	# Disable by default
	spin_attack_area.monitoring = false


func _physics_process(delta):
	# Handle functions
	handle_controls(delta)
	handle_gravity(delta)
	handle_spin_attack(delta)
	handle_effects(delta)

	# Movement
	var applied_velocity: Vector3
	applied_velocity = velocity.lerp(movement_velocity, delta * 10)
	applied_velocity.y = -gravity

	velocity = applied_velocity
	move_and_slide()

	# Rotation
	if Vector2(velocity.z, velocity.x).length() > 0:
		rotation_direction = Vector2(velocity.z, velocity.x).angle()

	# Spin animation rotates faster
	var rotation_speed = 20.0 if is_spinning else 10.0
	rotation.y = lerp_angle(rotation.y, rotation_direction, delta * rotation_speed)

	# Falling/respawning
	if position.y < -10:
		die()

	# Animation for scale (jumping and landing)
	model.scale = model.scale.lerp(Vector3(1, 1, 1), delta * 10)

	# Animation when landing
	if is_on_floor() and gravity > 2 and !previously_floored:
		model.scale = Vector3(1.25, 0.75, 1.25)
		Audio.play("res://sounds/land.ogg")
		animation.play("land", 0.1)

	previously_floored = is_on_floor()


# Handle spin attack
func handle_spin_attack(delta: float) -> void:
	# Update cooldown
	if spin_cooldown_timer > 0:
		spin_cooldown_timer -= delta

	# Update spin duration
	if is_spinning:
		spin_timer -= delta

		# Spin the character model
		model.rotation.y += delta * 30.0  # Fast spin

		if spin_timer <= 0:
			end_spin_attack()


# Handle animation(s)
func handle_effects(delta):
	particles_trail.emitting = false
	sound_footsteps.stream_paused = true

	# Don't play normal animations during spin
	if is_spinning:
		# Could play a spin animation here if we had one
		return

	if is_on_floor():
		var horizontal_velocity = Vector2(velocity.x, velocity.z)
		var speed_factor = horizontal_velocity.length() / movement_speed / delta

		if speed_factor > 0.05:
			# Choose walk or run based on speed
			if speed_factor > 0.5:
				# Running (fast movement)
				if animation.current_animation != "run":
					animation.play("run", 0.15)
				animation.speed_scale = speed_factor * 0.8
			else:
				# Walking (slow movement)
				if animation.current_animation != "walk":
					animation.play("walk", 0.15)
				animation.speed_scale = speed_factor * 1.2

			# Sound effects based on speed
			if speed_factor > 0.3:
				sound_footsteps.stream_paused = false
				sound_footsteps.pitch_scale = clamp(speed_factor, 0.8, 1.5)

			# Particle trail for fast movement
			if speed_factor > 0.75:
				particles_trail.emitting = true

		else:
			# Standing still - idle animation
			if animation.current_animation != "idle":
				animation.play("idle", 0.2)
			animation.speed_scale = 1.0

	else:
		# In the air
		if velocity.y > 0:
			# Rising (jumping up)
			if animation.current_animation != "jump":
				animation.play("jump", 0.1)
		else:
			# Falling down
			if animation.current_animation != "fall":
				animation.play("fall", 0.1)

		animation.speed_scale = 1.0


# Handle movement input
func handle_controls(delta):
	# Movement (can move during spin but reduced speed)
	var input := Vector3.ZERO

	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_back")

	input = input.rotated(Vector3.UP, view.rotation.y)

	if input.length() > 1:
		input = input.normalized()

	# Reduce movement during spin
	var speed_multiplier = 0.5 if is_spinning else 1.0
	movement_velocity = input * movement_speed * delta * speed_multiplier

	# Jumping
	if Input.is_action_just_pressed("jump"):
		if jump_single or jump_double:
			jump()

	# Spin attack
	if Input.is_action_just_pressed("spin_attack"):
		if can_spin_attack():
			start_spin_attack()


# Handle gravity
func handle_gravity(delta):
	gravity += 25 * delta

	if gravity > 0 and is_on_floor():
		jump_single = true
		gravity = 0


# Jumping
func jump():
	Audio.play("res://sounds/jump.ogg")

	gravity = -jump_strength
	model.scale = Vector3(0.5, 1.5, 0.5)

	if jump_single:
		jump_single = false;
		jump_double = true;
	else:
		jump_double = false;


# Check if can perform spin attack
func can_spin_attack() -> bool:
	return !is_spinning and spin_cooldown_timer <= 0


# Start spin attack
func start_spin_attack() -> void:
	if !can_spin_attack():
		return

	print("🌀 Spin attack!")
	is_spinning = true
	spin_timer = spin_attack_duration
	spin_cooldown_timer = spin_attack_cooldown + spin_attack_duration

	# Enable collision detection
	spin_attack_area.monitoring = true

	# Play spin sound (using existing sound for now)
	# TODO: Add dedicated spin sound effect
	Audio.play("res://sounds/jump.ogg", 1.2)  # Higher pitch

	# Visual feedback - scale character
	model.scale = Vector3(1.3, 0.7, 1.3)


# End spin attack
func end_spin_attack() -> void:
	is_spinning = false
	spin_timer = 0.0

	# Disable collision detection
	spin_attack_area.monitoring = false

	# Reset model rotation
	model.rotation.y = 0.0


# Called when spin attack hits a body
func _on_spin_attack_hit(body: Node3D) -> void:
	if !is_spinning:
		return

	# Check if it's an enemy
	if body.has_method("take_damage"):
		print("💥 Hit enemy!")
		body.take_damage(1)
		enemy_hit.emit()

		# Add score for enemy hit
		PlayerStats.add_score(PlayerStats.ENEMY_POINTS)

	# Check if it's a crate
	elif body.has_method("break_crate"):
		print("📦 Broke crate!")
		body.break_crate()
		crate_broken.emit()


# Called when spin attack hits an area
func _on_spin_attack_hit_area(area: Area3D) -> void:
	if !is_spinning:
		return

	# Check if parent is a crate or enemy
	var parent = area.get_parent()
	if parent and parent.has_method("break_crate"):
		print("📦 Broke crate (area)!")
		parent.break_crate()
		crate_broken.emit()


# Collecting coins (legacy - now uses fruits)
func collect_coin():
	collect_fruit(1)
	coin_collected.emit(PlayerStats.get_fruits())


# Collecting fruits (new system)
func collect_fruit(value: int = 1) -> void:
	PlayerStats.collect_fruit(value)
	fruit_collected.emit(value)
	print("🍎 Collected fruit! Total: ", PlayerStats.get_fruits())


# Player dies
func die() -> void:
	print("💀 Player died!")

	# Disable player control during death
	set_physics_process(false)

	PlayerStats.lose_life()

	# Check if game over or respawn
	if PlayerStats.get_lives() > 0:
		# Respawn after delay
		print("⏳ Respawning in 1 second...")
		await get_tree().create_timer(1.0).timeout

		# Use call_deferred to safely reload scene
		get_tree().call_deferred("reload_current_scene")
	else:
		# Game over handled by PlayerStats -> GameManager
		print("❌ Game Over - no lives remaining")
		GameManager.trigger_game_over()


# Get player stats (for UI)
func get_stats() -> Dictionary:
	return PlayerStats.get_stats()
