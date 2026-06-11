class_name Interactable
extends Area2D

@export var interaction_prompt := "Press E to interact."
var interaction_enabled := true

func get_interaction_prompt() -> String:
	return interaction_prompt if interaction_enabled else ""

func interact(_player: Node2D) -> void:
	pass
