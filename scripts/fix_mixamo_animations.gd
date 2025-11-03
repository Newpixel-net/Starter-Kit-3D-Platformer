@tool
extends EditorScript

## MIXAMO ANIMATION FIX AUTOMATION SCRIPT
##
## This script automatically extracts animations from Mixamo FBX files
## and adds them to the character's AnimationPlayer with proper configuration.
##
## HOW TO USE:
## 1. In Godot, go to File > Run
## 2. Select this script (scripts/fix_mixamo_animations.gd)
## 3. Click "Run"
## 4. Check the Output panel for results
##
## The script will:
## - Extract animations from each FBX file in objects/animation/
## - Add them to player.tscn's AnimationPlayer
## - Configure loop modes and blend times
## - Save the updated scene

# Configuration
const ANIMATION_SOURCE_DIR = "res://objects/animation/"
const PLAYER_SCENE_PATH = "res://objects/player.tscn"
const CHARACTER_SCENE_PATH = "res://objects/new_character.tscn"

# Animation settings
const ANIMATION_CONFIGS = {
	"Idle.fbx": {
		"name": "idle",
		"length": 3.0,
		"loop": Animation.LOOP_LINEAR,
		"source_anim": "Armature|mixamo.com|Layer0"
	},
	"walk.fbx": {
		"name": "walk",
		"length": 1.0,
		"loop": Animation.LOOP_LINEAR,
		"source_anim": "Armature|mixamo.com|Layer0"
	},
	"run.fbx": {
		"name": "run",
		"length": 0.8,
		"loop": Animation.LOOP_LINEAR,
		"source_anim": "Armature|mixamo.com|Layer0"
	},
	"jump.fbx": {
		"name": "jump",
		"length": 0.5,
		"loop": Animation.LOOP_NONE,
		"source_anim": "Armature|mixamo.com|Layer0"
	},
	"fall.fbx": {
		"name": "fall",
		"length": 1.0,
		"loop": Animation.LOOP_LINEAR,
		"source_anim": "Armature|mixamo.com|Layer0"
	},
	"land.fbx": {
		"name": "land",
		"length": 0.5,
		"loop": Animation.LOOP_NONE,
		"source_anim": "Armature|mixamo.com|Layer0"
	}
}

func _run():
	print("\n========================================")
	print("MIXAMO ANIMATION FIX - STARTING")
	print("========================================\n")

	# Process both scenes
	var scenes_to_fix = [PLAYER_SCENE_PATH, CHARACTER_SCENE_PATH]

	for scene_path in scenes_to_fix:
		print("Processing scene: ", scene_path)
		if fix_scene_animations(scene_path):
			print("✓ Successfully fixed: ", scene_path)
		else:
			print("✗ Failed to fix: ", scene_path)
		print("")

	print("========================================")
	print("MIXAMO ANIMATION FIX - COMPLETE")
	print("========================================\n")
	print("Next steps:")
	print("1. Open objects/player.tscn in the editor")
	print("2. Select Character > AnimationPlayer")
	print("3. Test each animation by clicking the play button")
	print("4. Run the game (F5) and verify animations work in-game")


func fix_scene_animations(scene_path: String) -> bool:
	# Load the scene
	var scene = load(scene_path)
	if not scene:
		print("ERROR: Could not load scene: ", scene_path)
		return false

	var scene_root = scene.instantiate()
	if not scene_root:
		print("ERROR: Could not instantiate scene")
		return false

	# Find the Character node and its AnimationPlayer
	var character_node = scene_root.find_child("Character", true, false)
	if not character_node:
		print("ERROR: Could not find Character node")
		scene_root.queue_free()
		return false

	var anim_player = character_node.find_child("AnimationPlayer", true, false)
	if not anim_player:
		print("ERROR: Could not find AnimationPlayer under Character")
		scene_root.queue_free()
		return false

	print("Found AnimationPlayer at: ", anim_player.get_path())

	# Get the skeleton for bone path validation
	var skeleton = character_node.find_child("Skeleton3D", true, false)
	if not skeleton:
		print("WARNING: Could not find Skeleton3D - animations may not work correctly")

	# Clear existing animation library (we'll rebuild it)
	var anim_library = anim_player.get_animation_library("")
	if anim_library:
		# Keep the library but clear animations
		var anim_names = anim_library.get_animation_list()
		for anim_name in anim_names:
			anim_library.remove_animation(anim_name)
	else:
		# Create new library if it doesn't exist
		anim_library = AnimationLibrary.new()
		anim_player.add_animation_library("", anim_library)

	# Process each animation
	var success_count = 0
	for fbx_file in ANIMATION_CONFIGS.keys():
		var config = ANIMATION_CONFIGS[fbx_file]
		if extract_and_add_animation(fbx_file, config, anim_library, skeleton):
			success_count += 1
			print("  ✓ Added animation: ", config["name"])
		else:
			print("  ✗ Failed to add animation: ", config["name"])

	if success_count == 0:
		print("ERROR: No animations were successfully added")
		scene_root.queue_free()
		return false

	# Configure AnimationPlayer settings
	anim_player.autoplay = "idle"
	anim_player.playback_default_blend_time = 0.2

	# Pack and save the scene
	var packed_scene = PackedScene.new()
	var result = packed_scene.pack(scene_root)
	if result != OK:
		print("ERROR: Failed to pack scene")
		scene_root.queue_free()
		return false

	var save_result = ResourceSaver.save(packed_scene, scene_path)
	if save_result != OK:
		print("ERROR: Failed to save scene")
		scene_root.queue_free()
		return false

	scene_root.queue_free()
	print("Successfully updated ", success_count, " animations")
	return true


func extract_and_add_animation(fbx_file: String, config: Dictionary, anim_library: AnimationLibrary, skeleton: Node3D) -> bool:
	var fbx_path = ANIMATION_SOURCE_DIR + fbx_file

	# Load the FBX scene
	var fbx_scene = load(fbx_path)
	if not fbx_scene:
		print("    ERROR: Could not load FBX: ", fbx_path)
		return false

	var fbx_root = fbx_scene.instantiate()
	if not fbx_root:
		print("    ERROR: Could not instantiate FBX scene")
		return false

	# Find the AnimationPlayer in the FBX
	var source_anim_player = fbx_root.find_child("AnimationPlayer", true, false)
	if not source_anim_player:
		print("    ERROR: No AnimationPlayer found in FBX: ", fbx_file)
		fbx_root.queue_free()
		return false

	# Get the source animation
	var source_lib = source_anim_player.get_animation_library("")
	if not source_lib:
		print("    ERROR: No animation library in FBX AnimationPlayer")
		fbx_root.queue_free()
		return false

	var source_anim = source_lib.get_animation(config["source_anim"])
	if not source_anim:
		print("    ERROR: Animation '", config["source_anim"], "' not found in FBX")
		print("    Available animations: ", source_lib.get_animation_list())
		fbx_root.queue_free()
		return false

	# Duplicate the animation so we have our own copy
	var new_anim = source_anim.duplicate(true)

	# Configure the animation
	new_anim.length = config["length"]
	new_anim.loop_mode = config["loop"]

	# Retarget bone tracks (Godot 4.x may have different bone paths)
	# This ensures tracks point to the correct skeleton
	retarget_animation_tracks(new_anim, skeleton)

	# Add to the animation library
	var add_result = anim_library.add_animation(config["name"], new_anim)

	fbx_root.queue_free()

	if add_result != OK:
		print("    ERROR: Failed to add animation to library: ", config["name"])
		return false

	return true


func retarget_animation_tracks(animation: Animation, target_skeleton: Node3D):
	"""
	Ensure all bone tracks in the animation target the correct Skeleton3D path.
	This fixes issues where imported animations have different node paths.
	"""
	if not target_skeleton:
		return

	# Get track count
	var track_count = animation.get_track_count()

	for i in range(track_count):
		var track_path = animation.track_get_path(i)

		# Check if this is a bone track (contains "Skeleton3D:")
		var path_string = str(track_path)
		if "Skeleton3D:" in path_string or ":" in path_string:
			# Extract the bone name (everything after the last ":")
			var parts = path_string.split(":")
			if parts.size() >= 2:
				var bone_name = parts[-1]

				# Create new path targeting our Skeleton3D
				var new_path = NodePath("Skeleton3D:" + bone_name)
				animation.track_set_path(i, new_path)


func print_animation_info(animation: Animation, name: String):
	"""Debug helper to print animation details"""
	print("  Animation: ", name)
	print("    Length: ", animation.length)
	print("    Loop Mode: ", animation.loop_mode)
	print("    Track Count: ", animation.get_track_count())

	for i in range(min(5, animation.get_track_count())):
		print("      Track ", i, ": ", animation.track_get_path(i), " (", animation.track_get_type(i), ")")

	if animation.get_track_count() > 5:
		print("      ... and ", animation.get_track_count() - 5, " more tracks")
