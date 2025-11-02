extends Area3D
## Fruit Collectible - Main collectible in the game (like Wumpa fruit)
##
## Features:
## - Bobs up and down
## - Rotates continuously
## - Particle effects
## - Sound on collection
## - Awards points and counts toward extra life

@export var fruit_value: int = 1
@export var bob_height: float = 0.3
@export var bob_speed: float = 3.0
@export var rotation_speed: float = 2.0
@export var points: int = 10

var grabbed = false
var start_y: float

@onready var mesh_instance = $MeshInstance3D
@onready var particles = $GPUParticles3D
@onready var collision = $CollisionShape3D

func _ready() -> void:
	start_y = position.y

	# Setup particle system
	if particles:
		particles.emitting = true


func _process(delta: float) -> void:
	if grabbed:
		return

	# Bob up and down
	position.y = start_y + sin(Time.get_ticks_msec() / 1000.0 * bob_speed) * bob_height

	# Rotate continuously
	if mesh_instance:
		mesh_instance.rotation.y += delta * rotation_speed


func _on_body_entered(body: Node3D) -> void:
	if grabbed:
		return

	if body.has_method("collect_fruit"):
		grabbed = true

		# Collect fruit
		body.collect_fruit(fruit_value)

		# Play sound
		Audio.play("res://sounds/coin.ogg", 1.1, 0.0, true)  # Slight pitch variation

		# Visual feedback - pop effect
		if mesh_instance:
			var tween = create_tween()
			tween.set_parallel(true)
			tween.tween_property(mesh_instance, "scale", Vector3(1.5, 1.5, 1.5), 0.2)
			tween.tween_property(mesh_instance, "modulate:a", 0.0, 0.2)

		# Burst particles
		if particles:
			particles.emitting = true

		# Remove after animation
		await get_tree().create_timer(0.3).timeout
		queue_free()
