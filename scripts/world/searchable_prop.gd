class_name SearchableProp
extends Interactable

signal searched(prop: SearchableProp)

@export var prop_name := "container"
@export var search_sound: AudioStream

var is_open := false

func _ready() -> void:
	reset_prop()

func interact(_player: Node2D) -> void:
	if is_open:
		return
	is_open = true
	interaction_enabled = false
	$ClosedVisual.visible = false
	$OpenVisual.visible = true
	if search_sound:
		$SearchSound.stream = search_sound
		$SearchSound.play()
	searched.emit(self)

func reset_prop() -> void:
	is_open = false
	interaction_enabled = true
	interaction_prompt = "Press E to search the %s." % prop_name
	$ClosedVisual.visible = true
	$OpenVisual.visible = false

func get_reveal_position() -> Vector2:
	return $RevealPoint.global_position
