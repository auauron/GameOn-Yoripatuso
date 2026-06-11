extends RefCounted

func run(tree: SceneTree) -> bool:
	var scene := load("res://scenes/gameplay/game_root.tscn") as PackedScene
	if scene == null:
		push_error("GameRoot scene is missing or invalid.")
		return false

	var game := scene.instantiate()
	tree.root.add_child(game)
	await tree.process_frame

	var required_paths := [
		"WorldContainer",
		"Player",
		"Artifact",
		"EchoController",
		"PortalGateway",
		"HUD",
	]
	for path in required_paths:
		if game.get_node_or_null(path) == null:
			push_error("Missing required persistent scene node: %s" % path)
			game.queue_free()
			return false

	if game.current_world == null or game.current_world.era_id != GameState.Era.MODERN:
		push_error("GameRoot must initially load Modern Oton.")
		game.queue_free()
		return false

	if game.current_world.get_artifact_spawn_points().size() < 6:
		push_error("Each outdoor world needs at least six artifact locations.")
		game.queue_free()
		return false

	game.queue_free()
	await tree.process_frame
	return true
