class_name MaritimeTradeItemCard
extends Button

var item_id := ""
var display_name := ""
var clue_text := ""
var educational_fact := ""
var puzzle_ui: MaritimeTradePuzzleUI


func configure(new_item_id: String, new_display_name: String, new_clue_text: String, new_educational_fact: String, new_puzzle_ui: MaritimeTradePuzzleUI) -> void:
	item_id = new_item_id
	display_name = new_display_name
	clue_text = new_clue_text
	educational_fact = new_educational_fact
	puzzle_ui = new_puzzle_ui
	text = "%s\n%s" % [display_name, clue_text]
	tooltip_text = educational_fact
	custom_minimum_size = Vector2(220, 72)
	focus_mode = Control.FOCUS_NONE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func refresh_state(correctly_sorted: bool) -> void:
	disabled = correctly_sorted
	modulate = Color(1, 1, 1, 0.35) if correctly_sorted else Color(1, 1, 1, 1)


func _get_drag_data(_at_position: Vector2) -> Variant:
	if disabled:
		return null

	var preview := PanelContainer.new()
	var preview_label := Label.new()
	preview_label.text = display_name
	preview_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	preview.add_child(preview_label)
	preview.custom_minimum_size = Vector2(180, 54)
	set_drag_preview(preview)
	return {"item_id": item_id}
