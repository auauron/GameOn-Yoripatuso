extends RefCounted

func run(tree: SceneTree) -> bool:
	var player_scene := load("res://scenes/player/player.tscn") as PackedScene
	var player := player_scene.instantiate() as PlayerController
	tree.root.add_child(player)
	await tree.process_frame

	assert(player.get_node_or_null("ContactShadow") != null)
	assert(player.get_node_or_null("PaintedVisual") != null)
	assert(player.get_node("PaintedVisual").position.y < 0.0)
	assert(player.get_node("CollisionShape2D").position.y <= -10.0)

	player.apply_outdoor_camera_profile()
	assert(player.get_node("Camera2D").zoom == Vector2.ONE)
	assert(player.get_node("Camera2D").offset == Vector2(0, -72))
	assert(player.get_node("Camera2D").position_smoothing_speed == 6.0)

	player.apply_interior_camera_profile()
	assert(player.get_node("Camera2D").zoom == Vector2(1.35, 1.35))
	assert(player.get_node("Camera2D").offset == Vector2(0, -36))

	player.queue_free()
	await tree.process_frame
	return true
