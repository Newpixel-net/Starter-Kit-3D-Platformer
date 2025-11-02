extends Node
## GameManager - Singleton for managing game state, scenes, and progression
##
## This autoload script handles:
## - Scene transitions (menu, levels, game over)
## - Game state management (playing, paused, game over)
## - Level progression
## - Save/load functionality (future)

# Signals
signal game_started
signal game_paused
signal game_resumed
signal game_over
signal level_completed(level_name: String, score: int, stars: int)
signal scene_changed(scene_path: String)

# Game states
enum GameState {
	MENU,
	PLAYING,
	PAUSED,
	LEVEL_COMPLETE,
	GAME_OVER
}

# Scene paths
const MAIN_MENU_SCENE = "res://scenes/ui/main_menu.tscn"
const PAUSE_MENU_SCENE = "res://scenes/ui/pause_menu.tscn"
const LEVEL_COMPLETE_SCENE = "res://scenes/ui/level_complete.tscn"
const GAME_OVER_SCENE = "res://scenes/ui/game_over.tscn"
const LEVEL_1_SCENE = "res://scenes/levels/level_01_jungle.tscn"
const DEMO_SCENE = "res://scenes/main.tscn"  # Fallback demo scene

# Current state
var current_state: GameState = GameState.MENU
var current_level: String = ""
var is_transitioning: bool = false

# Level completion data
var level_completion_data = {
	"time": 0.0,
	"fruits_collected": 0,
	"total_fruits": 100,
	"score": 0,
	"deaths": 0,
	"stars": 0
}


func _ready() -> void:
	print("GameManager initialized")
	process_mode = Node.PROCESS_MODE_ALWAYS  # Always process, even when paused


func _input(event: InputEvent) -> void:
	# Handle pause input (ESC or Start button)
	if event.is_action_pressed("ui_cancel"):
		if current_state == GameState.PLAYING:
			pause_game()
		elif current_state == GameState.PAUSED:
			resume_game()


## Start a new game from Level 1
func start_new_game() -> void:
	print("Starting new game...")
	PlayerStats.reset_stats()
	load_level(LEVEL_1_SCENE)
	game_started.emit()


## Load a specific level
func load_level(level_path: String) -> void:
	if is_transitioning:
		return

	is_transitioning = true
	current_level = level_path
	current_state = GameState.PLAYING

	# Reset level completion data
	level_completion_data = {
		"time": 0.0,
		"fruits_collected": 0,
		"total_fruits": 100,
		"score": 0,
		"deaths": 0,
		"stars": 0
	}

	print("Loading level: ", level_path)
	var result = get_tree().change_scene_to_file(level_path)

	if result == OK:
		scene_changed.emit(level_path)
		is_transitioning = false
	else:
		push_error("Failed to load level: " + level_path)
		is_transitioning = false


## Restart current level
func restart_level() -> void:
	if current_level.is_empty():
		print("No level to restart")
		return

	print("Restarting level: ", current_level)
	PlayerStats.reset_level_stats()
	load_level(current_level)


## Pause the game
func pause_game() -> void:
	if current_state != GameState.PLAYING:
		return

	print("Game paused")
	current_state = GameState.PAUSED
	get_tree().paused = true
	game_paused.emit()

	# TODO: Show pause menu overlay


## Resume the game
func resume_game() -> void:
	if current_state != GameState.PAUSED:
		return

	print("Game resumed")
	current_state = GameState.PLAYING
	get_tree().paused = false
	game_resumed.emit()


## Complete current level
func complete_level(time: float, fruits: int, score: int, deaths: int) -> void:
	print("Level completed!")
	current_state = GameState.LEVEL_COMPLETE

	# Calculate stars (3-star system)
	var stars = calculate_stars(time, fruits, deaths)

	level_completion_data = {
		"time": time,
		"fruits_collected": fruits,
		"total_fruits": 100,
		"score": score,
		"deaths": deaths,
		"stars": stars
	}

	level_completed.emit(current_level, score, stars)

	# TODO: Show level complete screen
	print("Stars: ", stars, " | Time: ", time, " | Fruits: ", fruits, "/100")


## Calculate star rating (3-star system)
func calculate_stars(time: float, fruits: int, deaths: int) -> int:
	var stars = 1  # Complete = 1 star

	# 2 stars: Collect 70+ fruits
	if fruits >= 70:
		stars = 2

	# 3 stars: Collect 100 fruits + under 3 minutes + no deaths
	if fruits >= 100 and time < 180.0 and deaths == 0:
		stars = 3

	return stars


## Trigger game over
func trigger_game_over() -> void:
	print("Game Over!")
	current_state = GameState.GAME_OVER
	get_tree().paused = true
	game_over.emit()

	# TODO: Show game over screen


## Return to main menu
func return_to_menu() -> void:
	print("Returning to main menu...")
	current_state = GameState.MENU
	get_tree().paused = false

	# Reset player stats
	PlayerStats.reset_stats()

	# Load main menu (for now, restart current level as placeholder)
	if FileAccess.file_exists(MAIN_MENU_SCENE):
		get_tree().change_scene_to_file(MAIN_MENU_SCENE)
	else:
		print("Main menu scene not found yet, staying in current scene")


## Quit game
func quit_game() -> void:
	print("Quitting game...")
	get_tree().quit()


## Get current game state
func get_state() -> GameState:
	return current_state


## Check if game is paused
func is_paused() -> bool:
	return current_state == GameState.PAUSED
