class_name GameRoot
extends Node2D

@export var player_id := "Player_001"
@export var modern_world_scene: PackedScene
@export var ancient_world_scene: PackedScene

@onready var world_container: Node2D = $WorldContainer
@onready var player: PlayerController = $Player
@onready var artifact: ArtifactCollectible = $Artifact
@onready var echo_controller: EchoController = $EchoController
@onready var portal_gateway: PortalGateway = $PortalGateway
@onready var hud: PrototypeHUD = $HUD

var state := GameState.new()
var current_content: Node2D
var current_world: ExplorationWorld
var current_outdoor_scene: PackedScene
var outdoor_return_position := Vector2.ZERO
var selected_spawn_point: ArtifactSpawnPoint
var selected_location_name := ""
var selected_spawn_names := {}
var game_started := false
var navigation_bounds := Rect2(0, 0, 6400, 4200)
var navigation_era_id := GameState.Era.MODERN
var navigation_era_name := "OTON, 2026"
var input_enabled_before_map := false

func _ready() -> void:
	player.input_enabled = false
	player.interaction_prompt_changed.connect(hud.show_interaction_prompt)
	hud.begin_requested.connect(start_game)
	hud.restart_requested.connect(restart_game)
	artifact.collected.connect(_on_artifact_collected)
	portal_gateway.portal_result_received.connect(_on_portal_result_received)
	load_outdoor_world(modern_world_scene, Vector2.INF)
	hud.show_intro()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("era_transition"):
		request_era_transition()
	elif event.is_action_pressed("toggle_map") and game_started:
		toggle_full_map()
	elif event.is_action_pressed("toggle_fullscreen"):
		toggle_fullscreen()

func _process(_delta: float) -> void:
	var indoors := current_world == null
	var navigation_position := outdoor_return_position if indoors else player.global_position
	hud.update_navigation(navigation_bounds, navigation_position, navigation_era_id, navigation_era_name, indoors)

func start_game() -> void:
	game_started = true
	hud.hide_intro()
	hud.hide_portal_result()
	player.input_enabled = true
	configure_current_artifact()

func restart_game() -> void:
	state = GameState.new()
	selected_spawn_names.clear()
	load_outdoor_world(modern_world_scene, Vector2.INF)
	start_game()

func load_outdoor_world(scene: PackedScene, desired_position: Vector2) -> bool:
	if scene == null:
		push_error("Cannot load an empty outdoor world scene.")
		return false

	_clear_current_content()
	current_content = scene.instantiate() as Node2D
	world_container.add_child(current_content)
	current_world = current_content as ExplorationWorld
	if current_world == null:
		push_error("Outdoor scene must use ExplorationWorld.")
		return false
	_attach_persistent_actors(current_world.get_actor_layer())

	current_outdoor_scene = scene
	navigation_bounds = current_world.world_bounds
	navigation_era_id = current_world.era_id
	navigation_era_name = current_world.era_display_name
	var spawn_position := current_world.get_player_spawn()
	if desired_position.is_finite():
		spawn_position = current_world.clamp_to_world(desired_position)
	player.reset_to(spawn_position)
	player.set_camera_bounds(current_world.world_bounds)
	hud.set_era(current_world.era_display_name)
	connect_world_interactions()
	if game_started:
		configure_current_artifact()
	return true

func configure_current_artifact() -> void:
	if current_world == null:
		return
	if state.current_era == GameState.Era.MODERN and state.eye_piece_collected:
		artifact.visible = false
		artifact.interaction_enabled = false
		selected_spawn_point = null
		echo_controller.stop()
		hud.set_objective("The Eye Piece reveals Katagman's past from this same place.")
		hud.show_transition_hint("Press F to witness the past.")
		hud.show_context_message("")
		return
	if state.current_era == GameState.Era.ANCIENT and state.nose_piece_collected:
		artifact.visible = false
		artifact.interaction_enabled = false
		selected_spawn_point = null
		echo_controller.stop()
		return

	var component_name := "Eye Piece"
	var prompt := "Press E to recover the Eye Piece."
	var artifact_color := Color(0.35, 0.85, 1.0)
	var objective := "Follow the echoes and recover the Eye Piece hidden in modern Oton."
	if state.current_era == GameState.Era.ANCIENT:
		component_name = "Nose Piece"
		prompt = "Press E to recover the Nose Piece."
		artifact_color = Color(1.0, 0.78, 0.16)
		objective = "Follow the ancestral echoes and recover the Nose Piece in Katagman."

	selected_spawn_point = _choose_spawn_point()
	if selected_spawn_point == null:
		player.input_enabled = false
		return

	selected_location_name = selected_spawn_point.location_name
	artifact.configure_component(component_name, prompt, artifact_color)
	artifact.prepare_for_round(selected_spawn_point)
	echo_controller.begin(player, selected_spawn_point)
	hud.set_objective(objective)
	hud.show_transition_hint("")
	hud.show_context_message("")

func request_era_transition() -> bool:
	if not state.can_enter_past():
		hud.show_context_message("The Eye Piece is needed to witness the past.")
		return false

	var matching_position := player.global_position
	if not state.enter_past():
		return false

	hud.set_transition_active(true)
	var loaded := load_outdoor_world(ancient_world_scene, matching_position)
	hud.set_transition_active(false)
	return loaded

func enter_interior(entrance: WorldEntrance) -> void:
	if entrance == null or entrance.interior_scene == null or current_world == null:
		return

	var interior_scene := entrance.interior_scene
	var interior_spawn_id := entrance.interior_spawn_id
	outdoor_return_position = entrance.global_position + Vector2(0, 120)
	echo_controller.stop()
	artifact.visible = false
	artifact.interaction_enabled = false
	_clear_current_content()
	current_content = interior_scene.instantiate() as Node2D
	world_container.add_child(current_content)
	current_world = null
	_attach_persistent_actors(current_content.get_node("DepthSortedWorld") as Node2D)

	var player_spawn := current_content.get_node_or_null(interior_spawn_id) as Marker2D
	if player_spawn:
		player.reset_to(player_spawn.global_position)
	var interior_bounds: Rect2 = current_content.get_meta("interior_bounds", Rect2(0, 0, 1280, 900))
	player.set_camera_bounds(interior_bounds)
	connect_world_interactions()
	hud.set_objective("Explore the interior, then return outside to continue the search.")
	hud.show_interaction_prompt("")

func return_to_outdoor() -> void:
	load_outdoor_world(current_outdoor_scene, outdoor_return_position)

func toggle_full_map() -> void:
	if hud.is_full_map_visible():
		hud.set_full_map_visible(false)
		player.input_enabled = input_enabled_before_map
		return
	input_enabled_before_map = player.input_enabled
	player.input_enabled = false
	hud.set_full_map_visible(true)

func toggle_fullscreen() -> void:
	var current_mode := DisplayServer.window_get_mode()
	if current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN or current_mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func connect_world_interactions() -> void:
	if current_content == null:
		return
	for node in get_tree().get_nodes_in_group("searchable_props"):
		if node is SearchableProp and current_content.is_ancestor_of(node):
			if not node.searched.is_connected(_on_prop_searched):
				node.searched.connect(_on_prop_searched)

	var entrances := current_content.find_child("Entrances", true, false)
	if entrances:
		for node in entrances.get_children():
			if node is WorldEntrance and not node.entrance_requested.is_connected(enter_interior):
				node.entrance_requested.connect(enter_interior)

	var world_exit := current_content.find_child("WorldExit", true, false) as WorldExit
	if world_exit and not world_exit.exit_requested.is_connected(return_to_outdoor):
		world_exit.exit_requested.connect(return_to_outdoor)

func _choose_spawn_point() -> ArtifactSpawnPoint:
	var points := current_world.get_artifact_spawn_points()
	if points.is_empty():
		push_error("No artifact spawn points exist in %s." % current_world.name)
		return null

	var point_names: Array[String] = []
	for point in points:
		point_names.append(point.name)
	var era_key := state.current_era
	var selected_name: String = selected_spawn_names.get(era_key, "")
	if selected_name.is_empty():
		selected_name = SpawnSelector.choose(point_names, "", Time.get_ticks_usec())
		selected_spawn_names[era_key] = selected_name
	for point in points:
		if point.name == selected_name:
			return point
	return points.front()

func _on_prop_searched(prop: SearchableProp) -> void:
	if selected_spawn_point and selected_spawn_point.get_searchable_prop() == prop:
		artifact.reveal_at(prop.get_reveal_position())

func _on_artifact_collected(collected_artifact: ArtifactCollectible) -> void:
	echo_controller.stop()
	if collected_artifact.component_name == "Eye Piece":
		state.collect_eye_piece()
		hud.set_objective("The Eye Piece reveals Katagman's past from this same place.")
		hud.show_transition_hint("Press F to witness the past.")
		return

	state.collect_nose_piece()
	player.input_enabled = false
	var payload := PortalGateway.build_discovery_payload(player_id, selected_location_name)
	portal_gateway.trigger_portal_unlock_placeholder(payload)

func _on_portal_result_received(success: bool, message: String, payload: Dictionary) -> void:
	if success:
		hud.show_portal_result(message, payload)

func _clear_current_content() -> void:
	echo_controller.stop()
	_detach_persistent_actors()
	if is_instance_valid(current_content):
		world_container.remove_child(current_content)
		current_content.free()
	current_content = null
	current_world = null

func _attach_persistent_actors(actor_layer: Node2D) -> void:
	if actor_layer == null:
		push_error("Current content has no actor layer.")
		return
	for actor: Node2D in [player, artifact]:
		var saved_transform: Transform2D = actor.global_transform
		actor.reparent(actor_layer)
		actor.global_transform = saved_transform

func _detach_persistent_actors() -> void:
	for actor: Node2D in [player, artifact]:
		if actor.get_parent() == self:
			continue
		var saved_transform: Transform2D = actor.global_transform
		actor.reparent(self)
		actor.global_transform = saved_transform
