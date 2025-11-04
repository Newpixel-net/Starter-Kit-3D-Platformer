extends CharacterBody3D

## Enemy AI Script
## Handles patrol, chase, attack, health, and death behavior

# ===== CONFIGURATION =====
@export_group("Stats")
@export var max_health: int = 3
@export var damage_to_player: int = 1

@export_group("Movement")
@export var patrol_speed: float = 2.0
@export var chase_speed: float = 4.0
@export var gravity: float = 20.0

@export_group("AI Behavior")
@export var detection_range: float = 5.0
@export var attack_range: float = 1.5
@export var patrol_wait_time: float = 2.0
@export var attack_cooldown: float = 1.5

@export_group("Patrol Points")
@export var patrol_distance: float = 3.0  # Distance to patrol left/right

# ===== STATE MACHINE =====
enum State {
	IDLE,
	PATROL,
	CHASE,
	ATTACK,
	HIT,
	DEATH
}

# ===== VARIABLES =====
var current_state: State = State.IDLE
var current_health: int
var player: CharacterBody3D = null
var animation: AnimationPlayer

# Patrol variables
var patrol_origin: Vector3
var patrol_target: Vector3
var patrol_direction: int = 1  # 1 = right, -1 = left

# Timers
var attack_timer: float = 0.0
var hit_stun_timer: float = 0.0

# Detection
var detection_area: Area3D
var attack_area: Area3D
var patrol_timer: Timer

# ===== INITIALIZATION =====
func _ready() -> void:
	current_health = max_health
	patrol_origin = global_position
	patrol_target = patrol_origin + Vector3(patrol_distance, 0, 0)

	# Get child nodes
	animation = $Character/AnimationPlayer
	detection_area = $DetectionArea
	attack_area = $AttackArea
	patrol_timer = $PatrolTimer

	# Configure detection areas
	detection_area.get_child(0).shape.radius = detection_range
	attack_area.get_child(0).shape.radius = attack_range

	# Connect signals
	detection_area.body_entered.connect(_on_player_detected)
	detection_area.body_exited.connect(_on_player_lost)
	attack_area.body_entered.connect(_on_attack_range_entered)
	patrol_timer.timeout.connect(_on_patrol_timer_timeout)

	# Set collision layers (layer 3 = enemies)
	collision_layer = 4
	collision_mask = 1

	# Start in idle state
	change_state(State.IDLE)

	print("🤖 Enemy spawned at ", global_position)

# ===== MAIN LOOP =====
func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Update timers
	if attack_timer > 0:
		attack_timer -= delta
	if hit_stun_timer > 0:
		hit_stun_timer -= delta
		return  # Skip AI while stunned

	# State machine
	match current_state:
		State.IDLE:
			process_idle(delta)
		State.PATROL:
			process_patrol(delta)
		State.CHASE:
			process_chase(delta)
		State.ATTACK:
			process_attack(delta)
		State.HIT:
			process_hit(delta)
		State.DEATH:
			process_death(delta)

	# Apply movement
	move_and_slide()

# ===== STATE FUNCTIONS =====
func process_idle(delta: float) -> void:
	velocity.x = 0
	velocity.z = 0

	# Check for player
	if player:
		change_state(State.CHASE)

func process_patrol(delta: float) -> void:
	# Move towards patrol target
	var direction = (patrol_target - global_position).normalized()
	direction.y = 0  # Keep on ground

	velocity.x = direction.x * patrol_speed
	velocity.z = direction.z * patrol_speed

	# Face movement direction
	if direction.length() > 0.1:
		look_at(global_position + direction, Vector3.UP)

	# Check if reached patrol target
	var distance_to_target = global_position.distance_to(patrol_target)
	if distance_to_target < 0.5:
		# Reached patrol point, wait then switch direction
		change_state(State.IDLE)
		patrol_timer.start(patrol_wait_time)

	# Check for player
	if player:
		change_state(State.CHASE)

func process_chase(delta: float) -> void:
	if not player:
		change_state(State.PATROL)
		return

	# Move towards player
	var direction = (player.global_position - global_position).normalized()
	direction.y = 0  # Keep on ground

	velocity.x = direction.x * chase_speed
	velocity.z = direction.z * chase_speed

	# Face player
	if direction.length() > 0.1:
		look_at(global_position + direction, Vector3.UP)

	# Check if in attack range
	var distance_to_player = global_position.distance_to(player.global_position)
	if distance_to_player <= attack_range:
		change_state(State.ATTACK)
	elif distance_to_player > detection_range:
		player = null
		change_state(State.PATROL)

func process_attack(delta: float) -> void:
	# Stop moving during attack
	velocity.x = 0
	velocity.z = 0

	if not player:
		change_state(State.PATROL)
		return

	# Face player
	var direction = (player.global_position - global_position).normalized()
	direction.y = 0
	if direction.length() > 0.1:
		look_at(global_position + direction, Vector3.UP)

	# Check if still in attack range
	var distance_to_player = global_position.distance_to(player.global_position)
	if distance_to_player > attack_range:
		change_state(State.CHASE)
		return

	# Attack if cooldown ready
	if attack_timer <= 0:
		perform_attack()
		attack_timer = attack_cooldown

func process_hit(delta: float) -> void:
	# Slow down during hit
	velocity.x *= 0.9
	velocity.z *= 0.9

	# Return to previous state after stun
	if hit_stun_timer <= 0:
		if player:
			change_state(State.CHASE)
		else:
			change_state(State.PATROL)

func process_death(delta: float) -> void:
	# Stop all movement
	velocity = Vector3.ZERO

	# Wait for death animation to finish, then queue_free
	if animation and not animation.is_playing():
		# Add small delay before disappearing
		await get_tree().create_timer(0.5).timeout
		queue_free()

# ===== STATE MANAGEMENT =====
func change_state(new_state: State) -> void:
	if current_state == State.DEATH:
		return  # Can't change from death state

	current_state = new_state

	# Play appropriate animation
	match current_state:
		State.IDLE:
			play_animation("idle")
		State.PATROL:
			play_animation("walk")
		State.CHASE:
			play_animation("walk")
		State.ATTACK:
			play_animation("attack")
		State.HIT:
			play_animation("hit")
		State.DEATH:
			play_animation("death")
			set_physics_process(false)  # Disable physics

func play_animation(anim_name: String) -> void:
	if animation and animation.has_animation(anim_name):
		if animation.current_animation != anim_name:
			animation.play(anim_name, 0.2)
	else:
		print("⚠️ Animation not found: ", anim_name)

# ===== COMBAT =====
func take_damage(amount: int, from_position: Vector3 = Vector3.ZERO) -> void:
	if current_state == State.DEATH:
		return

	current_health -= amount
	print("🤖 Enemy took ", amount, " damage! Health: ", current_health, "/", max_health)

	if current_health <= 0:
		die()
	else:
		# Apply knockback
		if from_position != Vector3.ZERO:
			var knockback_dir = (global_position - from_position).normalized()
			knockback_dir.y = 0
			velocity += knockback_dir * 5.0

		# Enter hit state
		change_state(State.HIT)
		hit_stun_timer = 0.3

func perform_attack() -> void:
	print("🤖 Enemy attacking!")

	# Check if player is still in attack area
	if player and attack_area:
		var bodies = attack_area.get_overlapping_bodies()
		if player in bodies:
			# Damage player
			if player.has_method("take_damage"):
				player.take_damage(damage_to_player)

func die() -> void:
	print("💀 Enemy died!")
	current_health = 0
	change_state(State.DEATH)

	# Disable collision
	collision_layer = 0
	collision_mask = 0

# ===== DETECTION =====
func _on_player_detected(body: Node3D) -> void:
	if body.is_in_group("player"):
		player = body
		print("👁️ Enemy detected player!")
		if current_state == State.IDLE or current_state == State.PATROL:
			change_state(State.CHASE)

func _on_player_lost(body: Node3D) -> void:
	if body == player:
		var distance = global_position.distance_to(player.global_position)
		if distance > detection_range:
			print("👁️ Enemy lost player")
			player = null
			if current_state == State.CHASE:
				change_state(State.PATROL)

func _on_attack_range_entered(body: Node3D) -> void:
	if body == player and current_state == State.CHASE:
		change_state(State.ATTACK)

# ===== PATROL TIMER =====
func _on_patrol_timer_timeout() -> void:
	# Switch patrol direction
	patrol_direction *= -1

	if patrol_direction == 1:
		patrol_target = patrol_origin + Vector3(patrol_distance, 0, 0)
	else:
		patrol_target = patrol_origin + Vector3(-patrol_distance, 0, 0)

	# Resume patrol
	if current_state == State.IDLE and not player:
		change_state(State.PATROL)

# ===== DEBUG =====
func _to_string() -> String:
	return "Enemy[HP:%d/%d State:%s]" % [current_health, max_health, State.keys()[current_state]]
