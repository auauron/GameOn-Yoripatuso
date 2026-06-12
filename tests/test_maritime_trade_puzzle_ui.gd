extends RefCounted

const PuzzleScene = preload("res://scenes/puzzles/maritime_trade_puzzle.tscn")

func run() -> bool:
	var puzzle_ui = PuzzleScene.instantiate()
	puzzle_ui.initialize_ui()

	assert(not puzzle_ui.visible)
	assert(puzzle_ui.get_item_card_count() == 7)
	assert(puzzle_ui.get_crate_count() == 3)

	puzzle_ui.open_puzzle()
	assert(puzzle_ui.visible)
	assert(puzzle_ui.get_selected_item_id() == "")
	assert(puzzle_ui.get_status_text().find("Sort") != -1)

	puzzle_ui.select_item("celadon_shard")
	assert(puzzle_ui.get_selected_item_id() == "celadon_shard")
	assert(puzzle_ui.get_selected_fact_text().find("Chinese") != -1)

	puzzle_ui.handle_item_dropped("celadon_shard", puzzle_ui.get_crate_id_by_name("Chinese"))
	assert(puzzle_ui.get_log_text().find("Celadon Shard") != -1)
	assert(puzzle_ui.get_instability_value() == 0)

	puzzle_ui.handle_item_dropped("celadon_shard", puzzle_ui.get_crate_id_by_name("Local Visayan"))
	assert(puzzle_ui.get_instability_value() == 1)
	assert(puzzle_ui.get_status_text().find("wrong") != -1)

	puzzle_ui.reset_puzzle()
	for index in range(5):
		puzzle_ui.handle_item_dropped("celadon_shard", puzzle_ui.get_crate_id_by_name("Local Visayan"))

	assert(puzzle_ui.is_failure_screen_visible())
	assert(puzzle_ui.get_outcome_title_text().find("Failed") != -1)
	assert(puzzle_ui.get_outcome_body_text().find("instability") != -1)

	puzzle_ui.reset_puzzle()
	puzzle_ui.handle_item_dropped("celadon_shard", puzzle_ui.get_crate_id_by_name("Chinese"))
	puzzle_ui.handle_item_dropped("blue_and_white_bowl", puzzle_ui.get_crate_id_by_name("Chinese"))
	puzzle_ui.handle_item_dropped("qingbai_shard", puzzle_ui.get_crate_id_by_name("Chinese"))
	puzzle_ui.handle_item_dropped("sukhothai_jar", puzzle_ui.get_crate_id_by_name("Thai"))
	puzzle_ui.handle_item_dropped("thai_green_glazed_fragment", puzzle_ui.get_crate_id_by_name("Thai"))
	puzzle_ui.handle_item_dropped("local_storage_pot", puzzle_ui.get_crate_id_by_name("Local Visayan"))
	puzzle_ui.handle_item_dropped("shell_bead", puzzle_ui.get_crate_id_by_name("Local Visayan"))

	assert(puzzle_ui.is_success_screen_visible())
	assert(puzzle_ui.get_outcome_title_text().find("Good") != -1)
	assert(puzzle_ui.get_outcome_body_text().find("Oton") != -1)
	puzzle_ui.close_outcome_and_puzzle()
	assert(not puzzle_ui.visible)

	puzzle_ui.close_puzzle()
	assert(not puzzle_ui.visible)
	return true
