class_name MaritimeTradeCrateDropZone
extends PanelContainer

var crate_id := 0
var crate_name := ""
var puzzle_ui: MaritimeTradePuzzleUI
var _title_label: Label
var _items_label: Label


func configure(new_crate_id: int, new_crate_name: String, new_puzzle_ui: MaritimeTradePuzzleUI) -> void:
	crate_id = new_crate_id
	crate_name = new_crate_name
	puzzle_ui = new_puzzle_ui
	custom_minimum_size = Vector2(130, 240)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_content()
	_refresh_empty_state()


func set_placed_items(item_names: Array[String]) -> void:
	if _items_label == null:
		return

	if item_names.is_empty():
		_items_label.text = "No goods yet."
	else:
		_items_label.text = "Placed goods:\n- %s" % _join_item_names(item_names)


func set_highlighted(active: bool) -> void:
	modulate = Color(1, 1, 1, 1) if active else Color(0.9, 0.9, 0.9, 1)


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.has("item_id") and puzzle_ui != null


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if puzzle_ui == null:
		return
	puzzle_ui.handle_item_dropped(str(data["item_id"]), crate_id)


func _build_content() -> void:
	if get_child_count() > 0:
		return

	var content := VBoxContainer.new()
	content.name = "Content"
	content.add_theme_constant_override("separation", 10)
	add_child(content)

	_title_label = Label.new()
	_title_label.name = "Title"
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 22)
	content.add_child(_title_label)

	var subtitle := Label.new()
	subtitle.name = "Subtitle"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.text = "Drag the right goods here."
	content.add_child(subtitle)

	_items_label = Label.new()
	_items_label.name = "Items"
	_items_label.custom_minimum_size = Vector2(210, 130)
	_items_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(_items_label)


func _refresh_empty_state() -> void:
	if _title_label != null:
		_title_label.text = crate_name
	if _items_label != null:
		_items_label.text = "No goods yet."


func _join_item_names(item_names: Array[String]) -> String:
	var combined := ""
	for index in range(item_names.size()):
		if index > 0:
			combined += "\n- "
		combined += item_names[index]
	return combined
