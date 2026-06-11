class_name WorldEntrance
extends Interactable

signal entrance_requested(entrance: WorldEntrance)

@export var entrance_id := ""
@export var interior_scene: PackedScene
@export var interior_spawn_id := "PlayerSpawn"

func _ready() -> void:
	interaction_prompt = "Press E to enter."

func interact(_player: Node2D) -> void:
	if interior_scene:
		entrance_requested.emit(self)
