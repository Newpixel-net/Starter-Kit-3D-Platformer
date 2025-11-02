extends Node
## PlayerStats - Singleton for tracking player statistics
##
## Manages:
## - Lives (start with 3, lose on death, gain at 100 fruits)
## - Fruits collected (Wumpa fruit equivalent)
## - Score
## - Deaths
## - Time played
## - Checkpoints

# Signals
signal lives_changed(new_lives: int)
signal fruits_changed(new_count: int)
signal fruit_milestone_reached(count: int)  # Every 100 fruits
signal score_changed(new_score: int)
signal player_died
signal extra_life_gained
signal checkpoint_reached(checkpoint_id: String)

# Starting values
const STARTING_LIVES = 3
const FRUITS_PER_LIFE = 100
const MAX_LIVES = 99

# Current stats
var lives: int = STARTING_LIVES
var fruits: int = 0
var fruits_this_life_cycle: int = 0  # Track fruits toward next life
var score: int = 0
var deaths: int = 0
var level_time: float = 0.0
var last_checkpoint: String = ""

# Scoring constants
const FRUIT_POINTS = 10
const ENEMY_POINTS = 50
const CRATE_POINTS = 25
const CHECKPOINT_POINTS = 100
const NO_DEATH_BONUS = 1000
const TIME_BONUS_MULTIPLIER = 10

# Timer for level time
var is_timing: bool = false


func _ready() -> void:
	print("PlayerStats initialized")
	reset_stats()


func _process(delta: float) -> void:
	if is_timing:
		level_time += delta


## Reset all stats to starting values
func reset_stats() -> void:
	lives = STARTING_LIVES
	fruits = 0
	fruits_this_life_cycle = 0
	score = 0
	deaths = 0
	level_time = 0.0
	last_checkpoint = ""
	is_timing = false

	print("Stats reset - Lives: ", lives, " | Fruits: ", fruits, " | Score: ", score)

	# Emit signals
	lives_changed.emit(lives)
	fruits_changed.emit(fruits)
	score_changed.emit(score)


## Reset level-specific stats (keep lives and total fruits)
func reset_level_stats() -> void:
	score = 0
	deaths = 0
	level_time = 0.0
	last_checkpoint = ""
	is_timing = false

	print("Level stats reset")


## Start level timer
func start_timer() -> void:
	level_time = 0.0
	is_timing = true
	print("Timer started")


## Stop level timer
func stop_timer() -> void:
	is_timing = false
	print("Timer stopped at: ", format_time(level_time))


## Collect a fruit
func collect_fruit(value: int = 1) -> void:
	fruits += value
	fruits_this_life_cycle += value

	var points = value * FRUIT_POINTS
	add_score(points)

	fruits_changed.emit(fruits)

	# Check for extra life
	if fruits_this_life_cycle >= FRUITS_PER_LIFE:
		fruits_this_life_cycle -= FRUITS_PER_LIFE
		gain_extra_life()
		fruit_milestone_reached.emit(fruits)


## Gain an extra life
func gain_extra_life() -> void:
	if lives < MAX_LIVES:
		lives += 1
		lives_changed.emit(lives)
		extra_life_gained.emit()
		print("🎉 Extra life! Lives: ", lives)

		# Play celebration sound
		Audio.play("res://sounds/level/life_gain.ogg")


## Lose a life (player dies)
func lose_life() -> void:
	lives -= 1
	deaths += 1
	lives_changed.emit(lives)
	player_died.emit()

	print("💀 Lost a life! Lives remaining: ", lives)

	# Check for game over
	if lives <= 0:
		print("❌ Game Over!")
		GameManager.trigger_game_over()
	else:
		# Respawn at checkpoint
		print("Respawning at checkpoint: ", last_checkpoint)


## Add score
func add_score(points: int) -> void:
	score += points
	score_changed.emit(score)


## Set checkpoint
func set_checkpoint(checkpoint_id: String) -> void:
	if last_checkpoint != checkpoint_id:
		last_checkpoint = checkpoint_id
		add_score(CHECKPOINT_POINTS)
		checkpoint_reached.emit(checkpoint_id)
		print("🚩 Checkpoint reached: ", checkpoint_id)


## Get current stats as dictionary
func get_stats() -> Dictionary:
	return {
		"lives": lives,
		"fruits": fruits,
		"fruits_this_life_cycle": fruits_this_life_cycle,
		"score": score,
		"deaths": deaths,
		"time": level_time,
		"checkpoint": last_checkpoint
	}


## Calculate final score (with bonuses)
func calculate_final_score() -> int:
	var final_score = score

	# Time bonus: (180 seconds - time) * 10
	if level_time < 180.0:
		var time_bonus = int((180.0 - level_time) * TIME_BONUS_MULTIPLIER)
		final_score += time_bonus
		print("Time bonus: +", time_bonus)

	# No death bonus
	if deaths == 0:
		final_score += NO_DEATH_BONUS
		print("No death bonus: +", NO_DEATH_BONUS)

	# Perfect fruit collection bonus
	if fruits >= 100:
		final_score += 500
		print("Perfect fruit bonus: +500")

	return final_score


## Format time as MM:SS
func format_time(time_seconds: float) -> String:
	var minutes = int(time_seconds) / 60
	var seconds = int(time_seconds) % 60
	return "%02d:%02d" % [minutes, seconds]


## Get lives remaining
func get_lives() -> int:
	return lives


## Get fruits collected
func get_fruits() -> int:
	return fruits


## Get fruits toward next life
func get_fruits_to_next_life() -> int:
	return FRUITS_PER_LIFE - fruits_this_life_cycle


## Get current score
func get_score() -> int:
	return score


## Get level time formatted
func get_time_formatted() -> String:
	return format_time(level_time)


## Get deaths count
func get_deaths() -> int:
	return deaths
