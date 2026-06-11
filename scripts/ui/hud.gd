class_name PrototypeHUD
extends CanvasLayer

signal begin_requested
signal restart_requested

func _ready() -> void:
	$IntroPanel/Content/BeginButton.pressed.connect(_on_begin_pressed)
	$PortalPanel/Content/RestartButton.pressed.connect(_on_restart_pressed)
	show_interaction_prompt("")
	hide_portal_result()
	show_transition_hint("")
	show_context_message("")
	set_transition_active(false)

func _on_begin_pressed() -> void:
	$IntroBackdrop.visible = false
	$IntroPanel.visible = false
	begin_requested.emit()

func _on_restart_pressed() -> void:
	restart_requested.emit()

func show_intro() -> void:
	$IntroBackdrop.visible = true
	$IntroPanel.visible = true

func hide_intro() -> void:
	$IntroBackdrop.visible = false
	$IntroPanel.visible = false

func show_interaction_prompt(prompt: String) -> void:
	$InteractionPrompt.text = prompt
	$InteractionPrompt.visible = not prompt.is_empty()

func show_portal_result(message: String, payload: Dictionary) -> void:
	$PortalPanel/Content/PortalMessage.text = "%s\n\nFound Location: %s\nStatus: Ready to send to organizer portal." % [
		message,
		payload.get("discovered_location", "Unknown"),
	]
	$PortalPanel.visible = true

func hide_portal_result() -> void:
	$PortalPanel.visible = false

func set_round_status(round_number: int) -> void:
	$RoundStatus.text = "RECONSTRUCTION ROUND %02d" % round_number

func set_era(era_name: String) -> void:
	$EraLabel.text = era_name

func set_objective(objective: String) -> void:
	$ObjectiveStatus.text = objective

func show_transition_hint(message: String) -> void:
	$TransitionHint.text = message
	$TransitionHint.visible = not message.is_empty()

func show_context_message(message: String) -> void:
	$ContextMessage.text = message
	$ContextMessage.visible = not message.is_empty()

func set_transition_active(active: bool) -> void:
	$TransitionOverlay.visible = active

func update_navigation(bounds: Rect2, world_position: Vector2, era_id: int, era_name: String, indoors: bool) -> void:
	$MiniMapFrame/NavigationMap.set_navigation_context(bounds, world_position, era_id, indoors)
	$FullMapOverlay/MapPanel/Content/NavigationMap.set_navigation_context(bounds, world_position, era_id, indoors)
	$FullMapOverlay/MapPanel/Content/MapTitle.text = "%s - EXPLORATION MAP" % era_name
	var location_kind := "OUTDOOR RETURN LOCATION" if indoors else "CURRENT LOCATION"
	$FullMapOverlay/MapPanel/Content/LocationStatus.text = "%s  X: %d  Y: %d" % [
		location_kind,
		int(world_position.x),
		int(world_position.y),
	]

func toggle_full_map() -> bool:
	set_full_map_visible(not is_full_map_visible())
	return is_full_map_visible()

func set_full_map_visible(visible: bool) -> void:
	$FullMapOverlay.visible = visible

func is_full_map_visible() -> bool:
	return $FullMapOverlay.visible
