class_name EchoController
extends Node

@export var maximum_echo_distance := 900.0
@export var full_volume_distance := 90.0
@export var silent_volume_db := -36.0
@export var loud_volume_db := -2.0

@onready var nature_echo: AudioStreamPlayer = $NatureEcho
@onready var activity_echo: AudioStreamPlayer = $ActivityEcho
@onready var music_echo: AudioStreamPlayer = $MusicEcho
@onready var voice_echo: AudioStreamPlayer = $VoiceEcho

var player: Node2D
var target: Node2D
var active := false
var echo_players: Array[AudioStreamPlayer] = []

func _ready() -> void:
	echo_players = [nature_echo, activity_echo, music_echo, voice_echo]

static func proximity_from_distance(distance: float, near_distance: float, far_distance: float) -> float:
	if far_distance <= near_distance:
		return 1.0 if distance <= near_distance else 0.0
	return 1.0 - clamp(inverse_lerp(near_distance, far_distance, distance), 0.0, 1.0)

func begin(searching_player: Node2D, target_node: Node2D) -> void:
	player = searching_player
	target = target_node
	active = true
	for echo_player in echo_players:
		if echo_player.stream:
			echo_player.play()

func stop() -> void:
	active = false
	for echo_player in echo_players:
		echo_player.stop()

func _process(_delta: float) -> void:
	if not active or not is_instance_valid(player) or not is_instance_valid(target):
		return
	var distance := player.global_position.distance_to(target.global_position)
	var proximity := proximity_from_distance(distance, full_volume_distance, maximum_echo_distance)
	for echo_player in echo_players:
		echo_player.volume_db = lerp(silent_volume_db, loud_volume_db, proximity)
