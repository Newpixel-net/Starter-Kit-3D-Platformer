extends Control
## Enhanced HUD - Displays lives, fruits, timer, and score

# UI Elements - will be created programmatically or from scene
@onready var lives_container: HBoxContainer
@onready var fruits_label: Label
@onready var timer_label: Label
@onready var score_label: Label

# Icons
var icon_life: Texture2D
var icon_fruit: Texture2D

# Styles
var font: Font
var font_size: int = 32


func _ready() -> void:
	# Load icons
	icon_life = load("res://sprites/ui/icons/icon_life.png")
	icon_fruit = load("res://sprites/ui/icons/icon_fruit.png")

	# Load font (use existing font)
	font = load("res://fonts/lilita_one_regular.ttf")
	font_size = 32

	# Setup UI elements
	setup_hud()

	# Connect to PlayerStats signals
	PlayerStats.lives_changed.connect(_on_lives_changed)
	PlayerStats.fruits_changed.connect(_on_fruits_changed)
	PlayerStats.score_changed.connect(_on_score_changed)
	PlayerStats.extra_life_gained.connect(_on_extra_life_gained)

	# Initial update
	update_all()


func _process(_delta: float) -> void:
	# Update timer every frame
	if timer_label and PlayerStats.is_timing:
		timer_label.text = PlayerStats.get_time_formatted()


## Setup HUD layout
func setup_hud() -> void:
	# Clear existing children (if any from scene)
	for child in get_children():
		child.queue_free()

	# Create main container
	var main_container = VBoxContainer.new()
	main_container.name = "MainContainer"
	main_container.set_anchors_preset(Control.PRESET_TOP_WIDE)
	main_container.offset_top = 20
	main_container.offset_left = 20
	main_container.offset_right = -20
	add_child(main_container)

	# Top row (Lives, Fruits, Timer, Score)
	var top_row = HBoxContainer.new()
	top_row.name = "TopRow"
	top_row.alignment = BoxContainer.ALIGNMENT_BEGIN
	top_row.add_theme_constant_override("separation", 40)
	main_container.add_child(top_row)

	# === LIVES ===
	var lives_box = HBoxContainer.new()
	lives_box.name = "LivesBox"
	lives_box.add_theme_constant_override("separation", 10)
	top_row.add_child(lives_box)

	# Lives icon
	if icon_life:
		var life_icon = TextureRect.new()
		life_icon.texture = icon_life
		life_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		life_icon.custom_minimum_size = Vector2(32, 32)
		lives_box.add_child(life_icon)

	# Lives label
	var lives_label = Label.new()
	lives_label.name = "LivesLabel"
	lives_label.text = "x3"
	lives_label.add_theme_font_override("font", font)
	lives_label.add_theme_font_size_override("font_size", font_size)
	lives_label.add_theme_color_override("font_color", Color.WHITE)
	lives_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	lives_label.add_theme_constant_override("shadow_offset_x", 2)
	lives_label.add_theme_constant_override("shadow_offset_y", 2)
	lives_box.add_child(lives_label)

	# === FRUITS ===
	var fruits_box = HBoxContainer.new()
	fruits_box.name = "FruitsBox"
	fruits_box.add_theme_constant_override("separation", 10)
	top_row.add_child(fruits_box)

	# Fruit icon
	if icon_fruit:
		var fruit_icon = TextureRect.new()
		fruit_icon.texture = icon_fruit
		fruit_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		fruit_icon.custom_minimum_size = Vector2(32, 32)
		fruits_box.add_child(fruit_icon)

	# Fruits label
	fruits_label = Label.new()
	fruits_label.name = "FruitsLabel"
	fruits_label.text = "0/100"
	fruits_label.add_theme_font_override("font", font)
	fruits_label.add_theme_font_size_override("font_size", font_size)
	fruits_label.add_theme_color_override("font_color", Color.WHITE)
	fruits_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	fruits_label.add_theme_constant_override("shadow_offset_x", 2)
	fruits_label.add_theme_constant_override("shadow_offset_y", 2)
	fruits_box.add_child(fruits_label)

	# === TIMER ===
	var timer_box = HBoxContainer.new()
	timer_box.name = "TimerBox"
	timer_box.add_theme_constant_override("separation", 10)
	top_row.add_child(timer_box)

	# Timer icon (⏱️)
	var timer_icon_label = Label.new()
	timer_icon_label.text = "⏱️"
	timer_icon_label.add_theme_font_size_override("font_size", 28)
	timer_box.add_child(timer_icon_label)

	# Timer label
	timer_label = Label.new()
	timer_label.name = "TimerLabel"
	timer_label.text = "0:00"
	timer_label.add_theme_font_override("font", font)
	timer_label.add_theme_font_size_override("font_size", font_size)
	timer_label.add_theme_color_override("font_color", Color.WHITE)
	timer_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	timer_label.add_theme_constant_override("shadow_offset_x", 2)
	timer_label.add_theme_constant_override("shadow_offset_y", 2)
	timer_box.add_child(timer_label)

	# === SCORE ===
	var score_box = HBoxContainer.new()
	score_box.name = "ScoreBox"
	score_box.add_theme_constant_override("separation", 10)
	top_row.add_child(score_box)

	# Score icon (💎)
	var score_icon_label = Label.new()
	score_icon_label.text = "💎"
	score_icon_label.add_theme_font_size_override("font_size", 28)
	score_box.add_child(score_icon_label)

	# Score label
	score_label = Label.new()
	score_label.name = "ScoreLabel"
	score_label.text = "0"
	score_label.add_theme_font_override("font", font)
	score_label.add_theme_font_size_override("font_size", font_size)
	score_label.add_theme_color_override("font_color", Color.WHITE)
	score_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	score_label.add_theme_constant_override("shadow_offset_x", 2)
	score_label.add_theme_constant_override("shadow_offset_y", 2)
	score_box.add_child(score_label)

	print("✅ HUD setup complete")


## Update all HUD elements
func update_all() -> void:
	_on_lives_changed(PlayerStats.get_lives())
	_on_fruits_changed(PlayerStats.get_fruits())
	_on_score_changed(PlayerStats.get_score())


## Update lives display
func _on_lives_changed(new_lives: int) -> void:
	var lives_label = get_node_or_null("MainContainer/TopRow/LivesBox/LivesLabel")
	if lives_label:
		lives_label.text = "x" + str(new_lives)

		# Color change based on lives
		if new_lives <= 1:
			lives_label.add_theme_color_override("font_color", Color.RED)
		elif new_lives <= 3:
			lives_label.add_theme_color_override("font_color", Color.YELLOW)
		else:
			lives_label.add_theme_color_override("font_color", Color.WHITE)


## Update fruits display
func _on_fruits_changed(new_fruits: int) -> void:
	if fruits_label:
		var fruits_to_next_life = PlayerStats.get_fruits_to_next_life()
		var total_collected = new_fruits % 100
		if total_collected == 0 and new_fruits > 0:
			total_collected = 100

		fruits_label.text = str(total_collected) + "/100"

		# Visual feedback when close to extra life
		if fruits_to_next_life <= 10:
			fruits_label.add_theme_color_override("font_color", Color.GOLD)
		else:
			fruits_label.add_theme_color_override("font_color", Color.WHITE)


## Update score display
func _on_score_changed(new_score: int) -> void:
	if score_label:
		score_label.text = format_score(new_score)


## Extra life animation
func _on_extra_life_gained() -> void:
	print("🎉 EXTRA LIFE ANIMATION!")

	# Flash the lives display
	var lives_box = get_node_or_null("MainContainer/TopRow/LivesBox")
	if lives_box:
		# Create tween for pulsing animation
		var tween = create_tween()
		tween.set_loops(3)
		tween.tween_property(lives_box, "modulate", Color.GOLD, 0.2)
		tween.tween_property(lives_box, "modulate", Color.WHITE, 0.2)


## Format score with thousands separators
func format_score(score: int) -> String:
	var score_str = str(score)
	var formatted = ""
	var count = 0

	for i in range(score_str.length() - 1, -1, -1):
		if count == 3:
			formatted = "," + formatted
			count = 0
		formatted = score_str[i] + formatted
		count += 1

	return formatted


## Legacy coin collection handler (for compatibility)
func _on_coin_collected(coins: int) -> void:
	_on_fruits_changed(coins)


## Show/hide HUD
func set_visible_hud(visible: bool) -> void:
	visible = visible


## Get HUD size for other UI elements
func get_hud_height() -> float:
	return 80.0  # Approximate HUD height
