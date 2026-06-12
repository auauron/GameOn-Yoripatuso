class_name MaritimeTradePuzzleUI
extends Control

signal closed
signal completed
signal failed

enum PuzzleState { READY, ACTIVE, SUCCESS, FAILURE }

const MaritimeTradePuzzleScript = preload("res://scripts/puzzles/maritime_trade_puzzle.gd")
const MaritimeTradeItemCardScript = preload("res://scripts/puzzles/maritime_trade_item_card.gd")
const MaritimeTradeCrateDropZoneScript = preload("res://scripts/puzzles/maritime_trade_crate_drop_zone.gd")

var puzzle := MaritimeTradePuzzleScript.new()
var selected_item_id := ""
var puzzle_state := PuzzleState.READY
var _initialized := false
var _item_cards: Dictionary = {}
var _crate_views: Dictionary = {}
var _crate_items: Dictionary = {}


func _ready() -> void:
	initialize_ui()
	hide()


func initialize_ui() -> void:
	if _initialized:
		_reset_puzzle_state()
		return

	_initialized = true
	_connect_buttons()
	_connect_outcome_button()
	_build_cards()
	_build_crates()
	_reset_puzzle_state()


func open_puzzle() -> void:
	initialize_ui()
	puzzle_state = PuzzleState.ACTIVE
	show()
	mouse_filter = Control.MOUSE_FILTER_STOP
	_reset_puzzle_state()
	_set_status_text("Sort the trade goods by origin.")


func close_puzzle() -> void:
	var was_visible := visible
	_hide_outcome()
	hide()
	if was_visible:
		closed.emit()


func reset_puzzle() -> void:
	puzzle = MaritimeTradePuzzleScript.new()
	selected_item_id = ""
	puzzle_state = PuzzleState.ACTIVE
	_hide_outcome()
	_set_text("SelectedTitle", "Select a trade good")
	_set_text("SelectedClue", "Drag a good into the crate that matches its clue.")
	_set_text("SelectedFact", "The clues come from glaze, form, and material.")
	_set_text("StatusLabel", "Sort the trade goods by origin.")
	_set_text("TradeLog", "Trade Reconstruction Log\nNo goods sorted yet.")
	_set_text("InstabilityLabel", "Interpretation Instability: 0")
	_set_text("CompletionLabel", "")
	_set_visible("CompletionLabel", false)
	_set_visible("ContinueButton", false)
	_refresh_cards()
	_refresh_crates()


func select_item(item_id: String) -> void:
	var item := puzzle.get_item_by_id(item_id)
	if item == null:
		return

	selected_item_id = item_id
	_set_text("SelectedTitle", item.display_name)
	_set_text("SelectedClue", "Clue: %s" % item.clue)
	_set_text("SelectedFact", "History note: %s" % item.educational_fact)


func handle_item_dropped(item_id: String, crate_id: int) -> bool:
	if puzzle_state != PuzzleState.ACTIVE:
		return false
	select_item(item_id)
	var result := puzzle.place_item(item_id, crate_id)
	_refresh_cards()
	_refresh_crates()

	if result.correct:
		_set_status_text("good: %s" % result.message)
	else:
		_set_status_text("wrong: %s" % result.message)

	if puzzle.is_complete():
		_show_success_screen()
	elif puzzle.is_failed():
		_show_failure_screen()

	return result.correct


func get_item_card_count() -> int:
	return _items_grid().get_child_count()


func get_crate_count() -> int:
	return _crates_row().get_child_count()


func get_selected_item_id() -> String:
	return selected_item_id


func get_selected_fact_text() -> String:
	return _text("SelectedFact")


func get_status_text() -> String:
	return _text("StatusLabel")


func get_log_text() -> String:
	return _text("TradeLog")


func get_instability_value() -> int:
	return puzzle.instability_meter


func get_crate_id_by_name(crate_name: String) -> int:
	for crate_id in _crate_views.keys():
		var crate_view: MaritimeTradeCrateDropZone = _crate_views[crate_id]
		if crate_view != null and crate_view.crate_name == crate_name:
			return crate_id
	return -1


func _build_cards() -> void:
	_clear_children(_items_grid())
	_item_cards.clear()

	for item_id in puzzle.get_item_ids():
		var item := puzzle.get_item_by_id(item_id)
		if item == null:
			continue
		var card := MaritimeTradeItemCardScript.new()
		card.configure(item.id, item.display_name, item.clue, item.educational_fact, self)
		var card_item_id := item.id
		card.pressed.connect(func() -> void:
			_on_card_pressed(card_item_id)
		)
		_items_grid().add_child(card)
		_item_cards[item.id] = card


func _build_crates() -> void:
	_clear_children(_crates_row())
	_crate_views.clear()
	_crate_items = {
		puzzle.Crate.CHINESE: [],
		puzzle.Crate.THAI: [],
		puzzle.Crate.LOCAL: [],
	}

	for crate_id in [puzzle.Crate.CHINESE, puzzle.Crate.THAI, puzzle.Crate.LOCAL]:
		var crate_view := MaritimeTradeCrateDropZoneScript.new()
		crate_view.configure(crate_id, _crate_name(crate_id), self)
		_crates_row().add_child(crate_view)
		_crate_views[crate_id] = crate_view


func _on_card_pressed(item_id: String) -> void:
	select_item(item_id)


func _reset_puzzle_state() -> void:
	reset_puzzle()


func _refresh_cards() -> void:
	for item_id in _item_cards.keys():
		var card: MaritimeTradeItemCard = _item_cards[item_id]
		if card == null:
			continue
		card.refresh_state(puzzle.is_item_correct(item_id))
		card.visible = not puzzle.is_item_correct(item_id)

	_set_text("InstabilityLabel", "Interpretation Instability: %d" % puzzle.instability_meter)


func _refresh_crates() -> void:
	_crate_items = {
		puzzle.Crate.CHINESE: [],
		puzzle.Crate.THAI: [],
		puzzle.Crate.LOCAL: [],
	}

	for item_id in puzzle.get_item_ids():
		if not puzzle.is_item_correct(item_id):
			continue
		var item := puzzle.get_item_by_id(item_id)
		if item == null:
			continue
		_crate_items[item.origin_crate].append(item.display_name)

	for crate_id in _crate_views.keys():
		var crate_view: MaritimeTradeCrateDropZone = _crate_views[crate_id]
		if crate_view == null:
			continue
		crate_view.set_placed_items(_string_array_from_variant(_crate_items.get(crate_id, [])))

	var log_lines: Array[String] = ["Trade Reconstruction Log"]
	for crate_id in [puzzle.Crate.CHINESE, puzzle.Crate.THAI, puzzle.Crate.LOCAL]:
		var items: Array[String] = _string_array_from_variant(_crate_items.get(crate_id, []))
		if items.is_empty():
			continue
		log_lines.append("%s: %s" % [_crate_name(crate_id), _join_item_names(items)])
	_set_text("TradeLog", _join_lines(log_lines))


func _connect_buttons() -> void:
	_button("CloseButton").pressed.connect(close_puzzle)
	_button("ResetButton").pressed.connect(_reset_puzzle_state)


func _connect_outcome_button() -> void:
	var outcome_button := get_node_or_null("OutcomeOverlay/OutcomePanel/OutcomeContent/OutcomeButton") as Button
	if outcome_button and not outcome_button.pressed.is_connected(_on_outcome_button_pressed):
		outcome_button.pressed.connect(_on_outcome_button_pressed)


func _items_grid() -> GridContainer:
	return get_node("MainPanel/RootVBox/ContentRow/ItemColumn/ItemScroll/ItemsGrid") as GridContainer


func _crates_row() -> HBoxContainer:
	return get_node("MainPanel/RootVBox/ContentRow/CrateColumn/CratesRow") as HBoxContainer


func _button(node_name: String) -> Button:
	return get_node_or_null("MainPanel/RootVBox/TopBar/%s" % node_name) as Button


func _text(node_name: String) -> String:
	var label := get_node_or_null("MainPanel/RootVBox/ContentRow/NotesColumn/%s" % node_name) as Label
	return label.text if label else ""


func _set_text(node_name: String, value: String) -> void:
	var label := get_node_or_null("MainPanel/RootVBox/ContentRow/NotesColumn/%s" % node_name) as Label
	if label:
		label.text = value


func _set_status_text(value: String) -> void:
	_set_text("StatusLabel", value)
	_set_text("InstabilityLabel", "Interpretation Instability: %d" % puzzle.instability_meter)


func _set_visible(node_name: String, should_show: bool) -> void:
	var node := get_node_or_null("MainPanel/RootVBox/TopBar/%s" % node_name)
	if node == null:
		node = get_node_or_null("MainPanel/RootVBox/ContentRow/NotesColumn/%s" % node_name)
	if node:
		node.visible = should_show


func is_failure_screen_visible() -> bool:
	return _outcome_overlay_visible() and puzzle_state == PuzzleState.FAILURE


func is_success_screen_visible() -> bool:
	return _outcome_overlay_visible() and puzzle_state == PuzzleState.SUCCESS


func get_outcome_title_text() -> String:
	return _text_from_path("OutcomeOverlay/OutcomePanel/OutcomeContent/OutcomeTitle")


func get_outcome_body_text() -> String:
	return _text_from_path("OutcomeOverlay/OutcomePanel/OutcomeContent/OutcomeBody")


func close_outcome_and_puzzle() -> void:
	if puzzle_state == PuzzleState.SUCCESS:
		close_puzzle()
	elif puzzle_state == PuzzleState.FAILURE:
		reset_puzzle()


func _show_success_screen() -> void:
	puzzle_state = PuzzleState.SUCCESS
	_set_text("CompletionLabel", "Trade log stable.\nOton stays linked to China, Siam, and local Visayan makers.")
	_set_visible("CompletionLabel", true)
	_set_visible("ContinueButton", false)
	_show_outcome(
		"GOOD FIND",
		"Nice work. These ceramics and local goods show that Oton lived inside a 14th-15th century sea trade network. Archaeology reads glaze, shape, and material to trace where things came from.",
		"CONTINUE"
	)
	completed.emit()


func _show_failure_screen() -> void:
	puzzle_state = PuzzleState.FAILURE
	_set_visible("CompletionLabel", false)
	_set_visible("ContinueButton", false)
	_show_outcome(
		"FAILED",
		"Too many wrong placements. The instability meter reached 5, so the reconstruction breaks apart. Try again and use the clues in glaze, shape, and material.",
		"TRY AGAIN"
	)
	failed.emit()


func _show_outcome(title: String, body: String, button_text: String) -> void:
	var outcome_title := get_node_or_null("OutcomeOverlay/OutcomePanel/OutcomeContent/OutcomeTitle") as Label
	var outcome_body := get_node_or_null("OutcomeOverlay/OutcomePanel/OutcomeContent/OutcomeBody") as Label
	if outcome_title:
		outcome_title.text = title
	if outcome_body:
		outcome_body.text = body
	var outcome_button := get_node_or_null("OutcomeOverlay/OutcomePanel/OutcomeContent/OutcomeButton") as Button
	if outcome_button:
		outcome_button.text = button_text
	var overlay := get_node_or_null("OutcomeOverlay")
	if overlay:
		overlay.visible = true


func _hide_outcome() -> void:
	var overlay := get_node_or_null("OutcomeOverlay")
	if overlay:
		overlay.visible = false


func _outcome_overlay_visible() -> bool:
	var overlay := get_node_or_null("OutcomeOverlay")
	return overlay.visible if overlay else false


func _crate_name(crate_id: int) -> String:
	match crate_id:
		puzzle.Crate.CHINESE:
			return "Chinese"
		puzzle.Crate.THAI:
			return "Thai"
		puzzle.Crate.LOCAL:
			return "Local Visayan"
		_:
			return "Unknown"


func _clear_children(container: Node) -> void:
	for child in container.get_children():
		child.queue_free()


func _join_item_names(item_names: Array[String]) -> String:
	var combined := ""
	for index in range(item_names.size()):
		if index > 0:
			combined += ", "
		combined += item_names[index]
	return combined


func _join_lines(lines: Array[String]) -> String:
	var combined := ""
	for index in range(lines.size()):
		if index > 0:
			combined += "\n"
		combined += lines[index]
	return combined


func _string_array_from_variant(value: Variant) -> Array[String]:
	var strings: Array[String] = []
	if value is Array:
		for entry in value:
			strings.append(str(entry))
	return strings


func _text_from_path(node_path: String) -> String:
	var label := get_node_or_null(node_path) as Label
	return label.text if label else ""


func _on_outcome_button_pressed() -> void:
	close_outcome_and_puzzle()
