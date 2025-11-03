@tool
extends EditorScript

## AUTOMATIC CHARACTER ANIMATION SETUP
## This script will automatically add AnimationPlayer to your character
## and configure all 6 core animations from the FBX files
##
## HOW TO USE:
## 1. Open this script in Godot Script Editor
## 2. File > Run (or Ctrl+Shift+X)
## 3. Check Output panel for results

# Helper function to find AnimationPlayer in node tree
func find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var result = find_animation_player(child)
		if result:
			return result
	return null

func _run():
	print("\n" + "="*60)
	print("🎬 AUTOMATIC ANIMATION SETUP STARTING...")
	print("="*60 + "\n")

	# Load the player scene
	var player_scene_path = "res://objects/player_new.tscn"

	if not ResourceLoader.exists(player_scene_path):
		print("❌ ERROR: player_new.tscn not found!")
		print("   Make sure the scene exists at: ", player_scene_path)
		return

	var packed_scene = load(player_scene_path) as PackedScene
	if not packed_scene:
		print("❌ ERROR: Could not load player_new.tscn")
		return

	# Instantiate the scene
	var player = packed_scene.instantiate()
	print("✅ Loaded player scene")

	# Find the Character node
	var character = player.get_node_or_null("Character")
	if not character:
		print("❌ ERROR: Character node not found in player scene!")
		player.queue_free()
		return

	print("✅ Found Character node")

	# Check if AnimationPlayer already exists
	var anim_player = character.get_node_or_null("AnimationPlayer")
	if anim_player:
		print("⚠️  AnimationPlayer already exists - removing old one")
		character.remove_child(anim_player)
		anim_player.queue_free()

	# Create new AnimationPlayer
	anim_player = AnimationPlayer.new()
	anim_player.name = "AnimationPlayer"
	character.add_child(anim_player)
	anim_player.owner = player  # Important for saving
	print("✅ Created AnimationPlayer node")

	# Animation configurations
	var animations = {
		"idle": {
			"file": "res://models/player/idle.fbx",
			"loop": true
		},
		"walk": {
			"file": "res://models/player/walking.fbx",
			"loop": true
		},
		"run": {
			"file": "res://models/player/running.fbx",
			"loop": true
		},
		"jump": {
			"file": "res://models/player/jumping up.fbx",
			"loop": false
		},
		"fall": {
			"file": "res://models/player/falling idle.fbx",
			"loop": true
		},
		"land": {
			"file": "res://models/player/hard landing.fbx",
			"loop": false
		}
	}

	# Create Animation Library
	var library = AnimationLibrary.new()
	var created_count = 0

	for anim_name in animations:
		var config = animations[anim_name]
		var anim_file = config["file"]

		# Check if FBX file exists
		if not ResourceLoader.exists(anim_file):
			print("⚠️  ", anim_name, ": File not found - ", anim_file)
			continue

		# Load the FBX file as a scene
		var fbx_scene = load(anim_file) as PackedScene
		if not fbx_scene:
			print("⚠️  ", anim_name, ": Could not load FBX as scene")
			continue

		# Instantiate to access animation data
		var fbx_root = fbx_scene.instantiate()

		# Find AnimationPlayer in the FBX scene
		var fbx_anim_player = null
		for child in fbx_root.get_children():
			if child is AnimationPlayer:
				fbx_anim_player = child
				break

		if not fbx_anim_player:
			# Try to find it deeper in the tree
			fbx_anim_player = find_animation_player(fbx_root)

		if fbx_anim_player:
			# Get the animation from the FBX
			var anim_list = fbx_anim_player.get_animation_list()
			if anim_list.size() > 0:
				# Get first animation from FBX
				var source_anim_name = anim_list[0]
				var source_lib = fbx_anim_player.get_animation_library("")
				if source_lib:
					var animation = source_lib.get_animation(source_anim_name)
					if animation:
						# Duplicate and configure
						var new_anim = animation.duplicate()
						new_anim.loop_mode = Animation.LOOP_LINEAR if config["loop"] else Animation.LOOP_NONE

						library.add_animation(anim_name, new_anim)
						created_count += 1
						print("✅ Imported animation: ", anim_name, " (", animation.length, "s, loop: ", config["loop"], ")")
					else:
						print("⚠️  ", anim_name, ": Could not get animation from library")
				else:
					print("⚠️  ", anim_name, ": No animation library in FBX")
			else:
				print("⚠️  ", anim_name, ": No animations in FBX AnimationPlayer")
		else:
			print("⚠️  ", anim_name, ": No AnimationPlayer found in FBX")

		# Cleanup
		fbx_root.queue_free()

	# Add library to AnimationPlayer
	anim_player.add_animation_library("", library)

	# Set autoplay to idle
	anim_player.autoplay = "idle"
	anim_player.playback_default_blend_time = 0.2

	print("\n✅ Animation library added with ", created_count, " animations")
	print("✅ Autoplay set to 'idle'")
	print("✅ Blend time set to 0.2 seconds")

	# Save the modified scene
	var new_packed = PackedScene.new()
	var result = new_packed.pack(player)

	if result == OK:
		var save_result = ResourceSaver.save(new_packed, player_scene_path)
		if save_result == OK:
			print("\n🎉 SUCCESS! Scene saved to: ", player_scene_path)
			print("\n📋 NEXT STEPS:")
			print("1. Close and reopen Godot (to reload scripts)")
			print("2. Open objects/player_new.tscn")
			print("3. Replace player.tscn with player_new.tscn")
			print("4. Run game (F5) and test!")
		else:
			print("\n❌ ERROR: Could not save scene (error code: ", save_result, ")")
	else:
		print("\n❌ ERROR: Could not pack scene (error code: ", result, ")")

	# Cleanup
	player.queue_free()

	print("\n" + "="*60)
	print("🎬 ANIMATION SETUP COMPLETE!")
	print("="*60 + "\n")
