class_name ExplorationWorld
extends Node2D

@export var era_id := 0
@export var era_display_name := "OTON, 2026"
@export var artifact_group_name := "eye_piece_spawn_points"
@export var world_bounds := Rect2(0, 0, 6400, 4200)
@export var player_spawn_path := NodePath("PlayerSpawn")
@export var safe_transition_spawn_path := NodePath("SafeTransitionSpawn")
@export var actor_layer_path := NodePath("DepthSortedWorld")

func _ready() -> void:
	if get_actor_layer() == null:
		push_error("%s requires a DepthSortedWorld actor layer." % name)
	for point in get_artifact_spawn_points():
		point.add_to_group(artifact_group_name)
	_build_boundary_collisions()

func get_player_spawn() -> Vector2:
	var marker := get_node_or_null(player_spawn_path) as Marker2D
	return marker.global_position if marker else world_bounds.get_center()

func get_safe_transition_position() -> Vector2:
	var marker := get_node_or_null(safe_transition_spawn_path) as Marker2D
	return marker.global_position if marker else world_bounds.get_center()

func get_actor_layer() -> Node2D:
	return get_node_or_null(actor_layer_path) as Node2D

func get_artifact_spawn_points() -> Array[ArtifactSpawnPoint]:
	var points: Array[ArtifactSpawnPoint] = []
	var container := get_node_or_null("ArtifactSpawnPoints")
	if container:
		for child in container.get_children():
			if child is ArtifactSpawnPoint:
				points.append(child)
	return points

func clamp_to_world(target_position: Vector2, margin := 48.0) -> Vector2:
	return Vector2(
		clamp(target_position.x, world_bounds.position.x + margin, world_bounds.end.x - margin),
		clamp(target_position.y, world_bounds.position.y + margin, world_bounds.end.y - margin)
	)

func _build_boundary_collisions() -> void:
	var boundaries := get_node_or_null("GeneratedBoundaries")
	if boundaries == null:
		boundaries = Node2D.new()
		boundaries.name = "GeneratedBoundaries"
		add_child(boundaries)
	if boundaries.get_child_count() > 0:
		return

	var thickness := 48.0
	_add_boundary(boundaries, "NorthBoundary", Vector2(world_bounds.size.x, thickness), Vector2(world_bounds.get_center().x, world_bounds.position.y))
	_add_boundary(boundaries, "SouthBoundary", Vector2(world_bounds.size.x, thickness), Vector2(world_bounds.get_center().x, world_bounds.end.y))
	_add_boundary(boundaries, "WestBoundary", Vector2(thickness, world_bounds.size.y), Vector2(world_bounds.position.x, world_bounds.get_center().y))
	_add_boundary(boundaries, "EastBoundary", Vector2(thickness, world_bounds.size.y), Vector2(world_bounds.end.x, world_bounds.get_center().y))

func _add_boundary(parent: Node, node_name: String, size: Vector2, center: Vector2) -> void:
	var body := StaticBody2D.new()
	body.name = node_name
	body.position = center
	body.collision_layer = 1
	body.collision_mask = 1
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	parent.add_child(body)
