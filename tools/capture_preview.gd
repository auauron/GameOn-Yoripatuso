extends SceneTree

func _init() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var scene := load("res://scenes/gameplay/main_game.tscn") as PackedScene
	var game := scene.instantiate()
	root.add_child(game)
	await process_frame
	game.hud.get_node("IntroBackdrop").visible = false
	game.hud.get_node("IntroPanel").visible = false
	game.start_round()
	await process_frame
	await process_frame
	var image := root.get_texture().get_image()
	var error := image.save_png("res://docs/prototype-preview.png")
	if error != OK:
		push_error("Could not save prototype preview: %s" % error_string(error))
		quit(1)
		return
	print("Saved prototype preview to res://docs/prototype-preview.png")
	quit(0)
