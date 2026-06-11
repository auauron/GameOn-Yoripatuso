class_name GameRound
extends Node2D

@export var player_id := "Player_001"

@onready var player: PlayerController = $World/Player
@onready var player_start: Marker2D = $World/PlayerStart
@onready var artifact: ArtifactCollectible = $World/Artifact
@onready var echo_controller: EchoController = $World/EchoController
@onready var portal_gateway: PortalGateway = $PortalGateway
@onready var hud: PrototypeHUD = $HUD

var selected_spawn_point: ArtifactSpawnPoint
var previous_spawn_id := ""
var selected_location_name := ""
var artifact_collected := false
var round_number := 0

func _ready() -> void:
	player.input_enabled = false
	player.interaction_prompt_changed.connect(hud.show_interaction_prompt)
	portal_gateway.portal_result_received.connect(_on_portal_result_received)
	hud.begin_requested.connect(start_round)
	hud.restart_requested.connect(start_round)
	artifact.collected.connect(_on_artifact_collected)
	for node in get_tree().get_nodes_in_group("searchable_props"):
		if node is SearchableProp:
			node.searched.connect(_on_prop_searched)
	hud.show_intro()

func _unhandled_input(event: InputEvent) -> void:
	if artifact_collected and event.is_action_pressed("restart_round"):
		start_round()

func start_round() -> void:
	round_number += 1
	artifact_collected = false
	hud.hide_portal_result()
	hud.show_interaction_prompt("")
	hud.set_round_status(round_number)

	for node in get_tree().get_nodes_in_group("searchable_props"):
		if node is SearchableProp:
			node.reset_prop()

	selected_spawn_point = _choose_spawn_point()
	if selected_spawn_point == null:
		player.input_enabled = false
		return

	previous_spawn_id = str(selected_spawn_point.get_path())
	selected_location_name = selected_spawn_point.location_name
	artifact.prepare_for_round(selected_spawn_point)
	player.reset_to(player_start.global_position)
	player.input_enabled = true
	echo_controller.begin(player, selected_spawn_point)
	print("Round %d selected: %s" % [round_number, selected_location_name])

func _choose_spawn_point() -> ArtifactSpawnPoint:
	var points: Array[ArtifactSpawnPoint] = []
	var point_ids: Array[String] = []
	for node in get_tree().get_nodes_in_group("artifact_spawn_points"):
		if node is ArtifactSpawnPoint:
			points.append(node)
			point_ids.append(str(node.get_path()))

	if points.is_empty():
		push_error("No artifact spawn points exist in main_game.tscn.")
		return null

	var selected_id := SpawnSelector.choose(point_ids, previous_spawn_id, Time.get_ticks_usec())
	for point in points:
		if str(point.get_path()) == selected_id:
			return point
	return points.front()

func _on_prop_searched(prop: SearchableProp) -> void:
	if selected_spawn_point and selected_spawn_point.get_searchable_prop() == prop:
		artifact.reveal_at(prop.get_reveal_position())

func _on_artifact_collected(_artifact: ArtifactCollectible) -> void:
	artifact_collected = true
	player.input_enabled = false
	echo_controller.stop()
	var payload := PortalGateway.build_discovery_payload(player_id, selected_location_name)
	portal_gateway.trigger_portal_unlock_placeholder(payload)

func _on_portal_result_received(success: bool, message: String, payload: Dictionary) -> void:
	if success:
		hud.show_portal_result(message, payload)
