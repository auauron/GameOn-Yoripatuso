extends RefCounted

const MaritimeTradePuzzleScript = preload("res://scripts/puzzles/maritime_trade_puzzle.gd")

func run() -> bool:
	var puzzle = MaritimeTradePuzzleScript.new()

	assert(puzzle.get_item_count() == 7)
	assert(puzzle.get_item_ids().size() == 7)
	assert("celadon_shard" in puzzle.get_item_ids())
	assert(puzzle.get_item_by_id("celadon_shard").origin_crate == puzzle.Crate.CHINESE)
	assert(puzzle.get_item_by_id("sukhothai_jar").origin_crate == puzzle.Crate.THAI)
	assert(puzzle.get_item_by_id("local_storage_pot").origin_crate == puzzle.Crate.LOCAL)

	var wrong_result := puzzle.place_item("celadon_shard", puzzle.Crate.LOCAL)
	assert(not wrong_result.correct)
	assert(puzzle.incorrect_placements == 1)
	assert(puzzle.instability_meter == 1)

	var right_result := puzzle.place_item("celadon_shard", puzzle.Crate.CHINESE)
	assert(right_result.correct)
	assert(puzzle.get_reconstruction_log().has("celadon_shard"))

	assert(not puzzle.is_complete())
	puzzle.place_item("blue_and_white_bowl", puzzle.Crate.CHINESE)
	puzzle.place_item("qingbai_shard", puzzle.Crate.CHINESE)
	puzzle.place_item("sukhothai_jar", puzzle.Crate.THAI)
	puzzle.place_item("thai_green_glazed_fragment", puzzle.Crate.THAI)
	puzzle.place_item("local_storage_pot", puzzle.Crate.LOCAL)
	puzzle.place_item("shell_bead", puzzle.Crate.LOCAL)
	assert(puzzle.is_complete())
	assert(puzzle.get_trade_network_map()["Chinese"] == 3)
	assert(puzzle.get_trade_network_map()["Thai"] == 2)
	assert(puzzle.get_trade_network_map()["Local Visayan"] == 2)
	assert(puzzle.get_completion_fact().find("Oton") != -1)
	return true
