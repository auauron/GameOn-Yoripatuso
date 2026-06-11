class_name ArtifactCollectible
extends Interactable

signal collected(artifact: ArtifactCollectible)

@export var artifact_name := "Oton Gold Death Mask"
@export var component_name := "Nose Piece"
@export var discovery_sound: AudioStream

var is_collected := false

func configure_component(new_component_name: String, prompt: String, color: Color) -> void:
	component_name = new_component_name
	interaction_prompt = prompt
	if has_node("PlaceholderVisual"):
		$PlaceholderVisual.color = color
	if has_node("Glow"):
		$Glow.color = Color(color, 0.25)

func prepare_for_round(spawn_point: ArtifactSpawnPoint) -> void:
	global_position = spawn_point.global_position
	is_collected = false
	interaction_enabled = false
	visible = false
	if spawn_point.get_searchable_prop() == null:
		reveal_at(spawn_point.global_position)

func reveal_at(reveal_position: Vector2) -> void:
	if is_collected:
		return
	global_position = reveal_position
	visible = true
	interaction_enabled = true

func interact(_player: Node2D) -> void:
	if is_collected or not interaction_enabled:
		return
	is_collected = true
	interaction_enabled = false
	visible = false
	if discovery_sound:
		$DiscoverySound.stream = discovery_sound
		$DiscoverySound.play()
	collected.emit(self)
