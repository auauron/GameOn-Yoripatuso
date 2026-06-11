class_name WorldExit
extends Interactable

signal exit_requested

func _ready() -> void:
	interaction_prompt = "Press E to return outside."

func interact(_player: Node2D) -> void:
	exit_requested.emit()
