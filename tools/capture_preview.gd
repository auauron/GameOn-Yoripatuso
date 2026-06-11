extends SceneTree

func _init() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var scene := load("res://scenes/gameplay/game_root.tscn") as PackedScene
	var game = scene.instantiate()
	root.add_child(game)
	await process_frame
	game.start_game()
	game.player.global_position = Vector2(1300, 1050)
	await _settle_camera()
	if not _save_frame("res://docs/modern-world-preview.png"):
		return

	game.state.collect_eye_piece()
	game.request_era_transition()
	await _settle_camera()
	if not _save_frame("res://docs/ancient-world-preview.png"):
		return

	print("Saved modern and ancient world previews in res://docs/.")
	quit(0)

func _settle_camera() -> void:
	for _frame in range(12):
		await process_frame

func _save_frame(path: String) -> bool:
	var image := root.get_texture().get_image()
	var error := image.save_png(path)
	if error != OK:
		push_error("Could not save preview: %s" % error_string(error))
		quit(1)
		return false
	return true
