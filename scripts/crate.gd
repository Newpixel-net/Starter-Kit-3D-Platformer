extends StaticBody3D
## Breakable Crate - Destroyed by spin attack or jump
##
## Features:
## - Breaks when hit by spin attack
## - Explosion particle effect
## - Sound effect
## - Awards points
## - Can contain fruit inside

@export var health: int = 1
@export var contains_fruit: bool = false
@export var fruit_count: int = 3
@export var points: int = 25

var is_broken = false

@onready var mesh_instance = $MeshInstance3D
@onready var collision_shape = $CollisionShape3D


func _ready() -> void:
	# Add to spin_attack group so player can detect it
	add_to_group("breakable")


## Called by player spin attack or jump
func break_crate() -> void:
	if is_broken:
		return

	is_broken = true

	print("💥 Crate broken!")

	# Award points
	PlayerStats.add_score(points)

	# Spawn fruits if crate contains them
	if contains_fruit:
		spawn_fruits()

	# Play break sound
	Audio.play("res://sounds/break.ogg", 1.0, 0.0, true)

	# Create explosion effect
	create_explosion()

	# Hide mesh and disable collision
	if mesh_instance:
		mesh_instance.visible = false
	if collision_shape:
		collision_shape.disabled = true

	# Remove after delay
	await get_tree().create_timer(1.0).timeout
	queue_free()


## Create explosion particle effect
func create_explosion() -> void:
	# Create particles for crate pieces
	var particles = GPUParticles3D.new()
	get_parent().add_child(particles)
	particles.global_position = global_position

	# Configure particles for explosion
	particles.amount = 20
	particles.lifetime = 0.8
	particles.explosiveness = 1.0
	particles.one_shot = true
	particles.emitting = true

	# Simple upward burst
	var process_material = ParticleProcessMaterial.new()
	process_material.direction = Vector3(0, 1, 0)
	process_material.spread = 45.0
	process_material.initial_velocity_min = 3.0
	process_material.initial_velocity_max = 6.0
	process_material.gravity = Vector3(0, -9.8, 0)
	particles.process_material = process_material

	# Visual feedback - scale before breaking
	if mesh_instance:
		var tween = create_tween()
		tween.tween_property(mesh_instance, "scale", Vector3(1.2, 0.8, 1.2), 0.1)

	# Clean up particles after lifetime
	await get_tree().create_timer(1.0).timeout
	particles.queue_free()


## Spawn fruits when crate breaks
func spawn_fruits() -> void:
	# TODO: Load fruit scene and spawn multiple fruits
	# For now, just add fruits to player's count
	PlayerStats.collect_fruit(fruit_count)
	print("🍎 Crate contained ", fruit_count, " fruits!")


## Take damage (for future enemy interactions)
func take_damage(damage: int) -> void:
	health -= damage
	if health <= 0:
		break_crate()
