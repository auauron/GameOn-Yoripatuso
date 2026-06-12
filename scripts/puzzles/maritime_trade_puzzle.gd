extends RefCounted


class TradeItemDefinition:
	extends RefCounted

	var id: String = ""
	var display_name: String = ""
	var origin_crate: int = 0
	var clue: String = ""
	var educational_fact: String = ""

	func _init(new_id: String, new_display_name: String, new_origin_crate: int, new_clue: String, new_educational_fact: String) -> void:
		id = new_id
		display_name = new_display_name
		origin_crate = new_origin_crate
		clue = new_clue
		educational_fact = new_educational_fact


class TradePlacementResult:
	extends RefCounted

	var item_id: String = ""
	var correct: bool = false
	var placed_crate: int = 0
	var instability_after: int = 0
	var message: String = ""


enum Crate { CHINESE, THAI, LOCAL }

const MAX_INSTABILITY := 5

const CrateLabel := {
	Crate.CHINESE: "Chinese",
	Crate.THAI: "Thai",
	Crate.LOCAL: "Local Visayan",
}

var incorrect_placements := 0
var instability_meter := 0

var _items_by_id: Dictionary = {}
var _placements: Dictionary = {}
var _correct_item_ids: Dictionary = {}
var _reconstruction_log: Array[String] = []


func _init() -> void:
	_register_default_items()


func get_item_count() -> int:
	return _items_by_id.size()


func get_item_ids() -> Array[String]:
	var item_ids: Array[String] = []
	for item_id in _items_by_id.keys():
		item_ids.append(str(item_id))
	return item_ids


func get_item_by_id(item_id: String) -> TradeItemDefinition:
	return _items_by_id.get(item_id)


func get_reconstruction_log() -> Array[String]:
	var reconstruction_log: Array[String] = []
	for item_id in _reconstruction_log:
		reconstruction_log.append(item_id)
	return reconstruction_log


func place_item(item_id: String, crate: int) -> TradePlacementResult:
	var result := TradePlacementResult.new()
	result.item_id = item_id
	result.placed_crate = crate

	var item: TradeItemDefinition = get_item_by_id(item_id)
	if item == null:
		result.message = "Unknown trade good."
		return result

	_placements[item_id] = crate
	var was_correct := _correct_item_ids.has(item_id)
	var is_correct := crate == item.origin_crate

	if is_correct:
		_correct_item_ids[item_id] = true
		if not was_correct:
			_rebuild_log()
		result.correct = true
		result.message = "%s fits the %s crate." % [item.display_name, CrateLabel.get(crate, "Unknown")]
	else:
		incorrect_placements += 1
		instability_meter = incorrect_placements
		if was_correct:
			_correct_item_ids.erase(item_id)
			_rebuild_log()
		result.correct = false
		result.message = "%s does not belong here." % item.display_name

	result.instability_after = instability_meter
	return result


func is_complete() -> bool:
	return _correct_item_ids.size() == _items_by_id.size()


func is_item_correct(item_id: String) -> bool:
	return _correct_item_ids.has(item_id)


func is_failed() -> bool:
	return instability_meter >= MAX_INSTABILITY and not is_complete()


func get_trade_network_map() -> Dictionary:
	var network_map := {
		CrateLabel[Crate.CHINESE]: 0,
		CrateLabel[Crate.THAI]: 0,
		CrateLabel[Crate.LOCAL]: 0,
	}

	for item_id in _correct_item_ids.keys():
		var item: TradeItemDefinition = _items_by_id[item_id]
		if item != null:
			network_map[CrateLabel.get(item.origin_crate, "Unknown")] += 1

	return network_map


func get_completion_fact() -> String:
	if not is_complete():
		return "Keep sorting. The trade routes are still broken."

	return "Oton sat in a busy sea network. Chinese ceramics, Thai jars, and local Visayan goods all helped prove that Katagman lived inside 14th-15th century maritime exchange."


func get_item_clue(item_id: String) -> String:
	var item: TradeItemDefinition = get_item_by_id(item_id)
	if item == null:
		return ""
	return item.clue


func get_item_fact(item_id: String) -> String:
	var item: TradeItemDefinition = get_item_by_id(item_id)
	if item == null:
		return ""
	return item.educational_fact


func _register_default_items() -> void:
	_add_item(
		"celadon_shard",
		"Celadon Shard",
		Crate.CHINESE,
		"Pale green glaze and a thin, smooth body.",
		"Celadon ceramics are strongly associated with Chinese maritime trade and often traveled far from their workshops."
	)
	_add_item(
		"blue_and_white_bowl",
		"Blue and White Bowl",
		Crate.CHINESE,
		"White clay with painted blue lines under a clear glaze.",
		"Blue-and-white ware shows Chinese kiln technology and long-distance exchange across the sea lanes."
	)
	_add_item(
		"qingbai_shard",
		"Qingbai Shard",
		Crate.CHINESE,
		"Light glaze, soft blue tint, and a fine broken edge.",
		"Qingbai ceramics are another clue that imported Chinese goods reached communities like Oton."
	)
	_add_item(
		"sukhothai_jar",
		"Sukhothai Jar",
		Crate.THAI,
		"Thicker body, dark glaze, and a shape made for storage.",
		"Sukhothai and related Thai ceramics help show that Katagman joined a wider Southeast Asian trade world."
	)
	_add_item(
		"thai_green_glazed_fragment",
		"Thai Green Glazed Fragment",
		Crate.THAI,
		"Green glaze pooling in a carved groove near the rim.",
		"Thai ceramics often carried distinct glaze and rim forms that archaeologists can use to trace movement by sea."
	)
	_add_item(
		"local_storage_pot",
		"Local Storage Pot",
		Crate.LOCAL,
		"Coarse clay, smoke marks, and a sturdy hand-built body.",
		"Local Visayan pottery shows daily life and local craft, not just imported prestige goods."
	)
	_add_item(
		"shell_bead",
		"Shell Bead",
		Crate.LOCAL,
		"Small, rounded, and cut from a local natural material.",
		"Shell beads and similar ornaments remind us that trade was not only about jars; it also moved everyday and personal goods."
	)


func _add_item(item_id: String, display_name: String, origin_crate: int, clue: String, educational_fact: String) -> void:
	_items_by_id[item_id] = TradeItemDefinition.new(item_id, display_name, origin_crate, clue, educational_fact)


func _rebuild_log() -> void:
	_reconstruction_log.clear()
	for item_id in _items_by_id.keys():
		if _correct_item_ids.has(item_id):
			_reconstruction_log.append(item_id)
