class_name PlayerController
extends CharacterBody2D

signal interaction_prompt_changed(prompt: String)

@export var move_speed := 180.0

const OUTDOOR_CAMERA_ZOOM := Vector2.ONE
const OUTDOOR_CAMERA_OFFSET := Vector2(0, -72)
const INTERIOR_CAMERA_ZOOM := Vector2(1.35, 1.35)
const INTERIOR_CAMERA_OFFSET := Vector2(0, -36)

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

func set_camera_bounds(bounds: Rect2) -> void:
	$Camera2D.limit_left = int(bounds.position.x)
	$Camera2D.limit_top = int(bounds.position.y)
	$Camera2D.limit_right = int(bounds.end.x)
	$Camera2D.limit_bottom = int(bounds.end.y)

func apply_outdoor_camera_profile() -> void:
	_apply_camera_profile(OUTDOOR_CAMERA_ZOOM, OUTDOOR_CAMERA_OFFSET)

func apply_interior_camera_profile() -> void:
	_apply_camera_profile(INTERIOR_CAMERA_ZOOM, INTERIOR_CAMERA_OFFSET)

func _apply_camera_profile(target_zoom: Vector2, target_offset: Vector2) -> void:
	$Camera2D.zoom = target_zoom
	$Camera2D.offset = target_offset
	$Camera2D.position_smoothing_enabled = true
	$Camera2D.position_smoothing_speed = 6.0

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
