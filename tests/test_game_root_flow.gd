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
	assert(game.player.get_parent() == game.current_world.get_actor_layer())
	assert(game.artifact.get_parent() == game.current_world.get_actor_layer())
	assert(game.hud.get_node("MiniMapFrame").visible)
	assert(not game.hud.is_full_map_visible())
	game.toggle_full_map()
	assert(game.hud.is_full_map_visible())
	assert(not game.player.input_enabled)
	game.toggle_full_map()
	assert(not game.hud.is_full_map_visible())
	assert(game.player.input_enabled)

	var modern_position := Vector2(3100, 2050)
	game.player.global_position = modern_position
	var modern_prop = game.selected_spawn_point.get_searchable_prop()
	if modern_prop:
		modern_prop.interact(game.player)
		await tree.process_frame
	game.artifact.interact(game.player)
	await tree.process_frame
	assert(game.state.eye_piece_collected)
	var modern_entrance_container = game.current_world.find_child("Entrances", true, false)
	var modern_entrance = modern_entrance_container.get_child(0)
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
	assert(game.hud.get_node("MiniMapFrame/NavigationMap").era_id == GameState.Era.ANCIENT)

	var entrance_container = game.current_world.find_child("Entrances", true, false)
	var entrance = entrance_container.get_child(0)
	game.enter_interior(entrance)
	await tree.process_frame
	assert(game.current_world == null)
	assert(game.current_content.find_child("WorldExit", true, false) != null)
	assert(game.player.get_parent() == game.current_content.get_node("DepthSortedWorld"))
	assert(game.artifact.get_parent() == game.current_content.get_node("DepthSortedWorld"))
	assert(game.hud.get_node("MiniMapFrame/NavigationMap").indoors)
	assert(game.hud.get_node("MiniMapFrame/NavigationMap").tracked_position == game.outdoor_return_position)
	game.return_to_outdoor()
	await tree.process_frame
	assert(game.current_world != null)
	assert(game.state.current_era == GameState.Era.ANCIENT)
	assert(game.player.get_parent() == game.current_world.get_actor_layer())

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
