extends RefCounted

func run(tree: SceneTree) -> bool:
	var scene := load("res://scenes/gameplay/main_game.tscn") as PackedScene
	if scene == null:
		push_error("Main game scene is missing or invalid.")
		return false

	var game := scene.instantiate()
	tree.root.add_child(game)
	await tree.process_frame

	var required_paths := [
		"World/Player",
		"World/Artifact",
		"World/EchoController",
		"World/Props",
		"World/SpawnPoints",
		"PortalGateway",
		"HUD",
	]
	for path in required_paths:
		if game.get_node_or_null(path) == null:
			push_error("Missing required main scene node: %s" % path)
			game.queue_free()
			return false

	if tree.get_nodes_in_group("artifact_spawn_points").size() < 6:
		push_error("The prototype needs at least six artifact spawn points.")
		game.queue_free()
		return false

	if tree.get_nodes_in_group("searchable_props").size() < 3:
		push_error("The prototype needs at least three searchable props.")
		game.queue_free()
		return false

	for node in tree.get_nodes_in_group("artifact_spawn_points"):
		if node.searchable_prop_path != NodePath() and node.get_searchable_prop() == null:
			push_error("Covered spawn point has an invalid searchable prop path: %s" % node.name)
			game.queue_free()
			return false

	game.start_round()
	await tree.process_frame
	if game.selected_spawn_point == null or game.round_number != 1:
		push_error("A round did not select an artifact location.")
		game.queue_free()
		return false

	var first_spawn_id: String = game.previous_spawn_id
	var selected_prop = game.selected_spawn_point.get_searchable_prop()
	if selected_prop:
		selected_prop.interact(game.player)
		await tree.process_frame
	if not game.artifact.visible:
		push_error("The selected artifact could not be revealed.")
		game.queue_free()
		return false

	game.artifact.interact(game.player)
	await tree.process_frame
	if not game.artifact_collected or not game.hud.get_node("PortalPanel").visible:
		push_error("Artifact recovery did not complete the round or show portal feedback.")
		game.queue_free()
		return false

	game.start_round()
	await tree.process_frame
	if game.round_number != 2 or game.previous_spawn_id == first_spawn_id:
		push_error("Restart did not create a new non-repeating round.")
		game.queue_free()
		return false

	game.queue_free()
	await tree.process_frame
	return true
