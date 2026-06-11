extends RefCounted

func run(tree: SceneTree) -> bool:
	var root_scene := load("res://scenes/gameplay/game_root.tscn") as PackedScene
	if root_scene == null:
		push_error("Persistent GameRoot scene is missing.")
		return false

	var game = root_scene.instantiate()
	tree.root.add_child(game)
	await tree.process_frame
	game.start_game()
	await tree.process_frame
	assert(game.state.current_era == GameState.Era.MODERN)
	assert(game.current_world.world_bounds == Rect2(0, 0, 6400, 4200))

	var modern_position := Vector2(3100, 2050)
	game.player.global_position = modern_position
	var modern_prop = game.selected_spawn_point.get_searchable_prop()
	if modern_prop:
		modern_prop.interact(game.player)
		await tree.process_frame
	game.artifact.interact(game.player)
	await tree.process_frame
	assert(game.state.eye_piece_collected)
	var modern_entrance = game.current_world.get_node("Entrances").get_child(0)
	game.enter_interior(modern_entrance)
	await tree.process_frame
	game.return_to_outdoor()
	await tree.process_frame
	assert(not game.echo_controller.active)
	assert(game.hud.get_node("TransitionHint").visible)
	game.player.global_position = modern_position
	assert(game.request_era_transition())
	await tree.process_frame
	assert(game.state.current_era == GameState.Era.ANCIENT)
	assert(game.player.global_position.distance_to(modern_position) < 2.0)

	var entrance = game.current_world.get_node("Entrances").get_child(0)
	game.enter_interior(entrance)
	await tree.process_frame
	assert(game.current_world == null)
	assert(game.current_content.get_node_or_null("WorldExit") != null)
	game.return_to_outdoor()
	await tree.process_frame
	assert(game.current_world != null)
	assert(game.state.current_era == GameState.Era.ANCIENT)

	var ancient_prop = game.selected_spawn_point.get_searchable_prop()
	if ancient_prop:
		ancient_prop.interact(game.player)
		await tree.process_frame
	game.artifact.interact(game.player)
	await tree.process_frame
	assert(game.state.nose_piece_collected)
	assert(game.hud.get_node("PortalPanel").visible)

	game.queue_free()
	await tree.process_frame
	return true
