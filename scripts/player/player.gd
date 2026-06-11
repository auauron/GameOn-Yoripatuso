class_name PlayerController
extends CharacterBody2D

signal interaction_prompt_changed(prompt: String)

@export var move_speed := 180.0

var input_enabled := false
var nearby_interactables: Array[Interactable] = []
var current_interactable: Interactable

func _ready() -> void:
	$InteractionDetector.area_entered.connect(_on_interaction_area_entered)
	$InteractionDetector.area_exited.connect(_on_interaction_area_exited)

func _physics_process(_delta: float) -> void:
	if not input_enabled:
		velocity = Vector2.ZERO
		return

	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * move_speed
	move_and_slide()

func _process(_delta: float) -> void:
	_refresh_current_interactable()
	if input_enabled and Input.is_action_just_pressed("interact") and current_interactable:
		current_interactable.interact(self)

func reset_to(start_position: Vector2) -> void:
	global_position = start_position
	velocity = Vector2.ZERO

func _on_interaction_area_entered(area: Area2D) -> void:
	if area is Interactable and area not in nearby_interactables:
		nearby_interactables.append(area)

func _on_interaction_area_exited(area: Area2D) -> void:
	if area is Interactable:
		nearby_interactables.erase(area)

func _refresh_current_interactable() -> void:
	nearby_interactables = nearby_interactables.filter(
		func(item: Interactable) -> bool:
			return is_instance_valid(item) and item.interaction_enabled
	)
	nearby_interactables.sort_custom(
		func(a: Interactable, b: Interactable) -> bool:
			return global_position.distance_squared_to(a.global_position) < global_position.distance_squared_to(b.global_position)
	)

	var next_interactable: Interactable = null
	if not nearby_interactables.is_empty():
		next_interactable = nearby_interactables.front()
	if next_interactable == current_interactable:
		return

	current_interactable = next_interactable
	interaction_prompt_changed.emit(
		current_interactable.get_interaction_prompt() if current_interactable else ""
	)
