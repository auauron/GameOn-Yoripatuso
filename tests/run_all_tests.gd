extends SceneTree

func _init() -> void:
	var suites := [
		preload("res://tests/test_game_state.gd").new(),
		preload("res://tests/test_echo_math.gd").new(),
		preload("res://tests/test_discovery_payload.gd").new(),
		preload("res://tests/test_spawn_selector.gd").new(),
		preload("res://tests/test_maritime_trade_puzzle.gd").new(),
		preload("res://tests/test_maritime_trade_puzzle_ui.gd").new(),
		preload("res://tests/test_dual_world_contract.gd").new(),
		preload("res://tests/test_interior_flow.gd").new(),
		preload("res://tests/test_navigation_map.gd").new(),
		preload("res://tests/test_diorama_world_contract.gd").new(),
	]
	for suite in suites:
		if not suite.run():
			quit(1)
			return

	var camera_suite := preload("res://tests/test_camera_profiles.gd").new()
	if not await camera_suite.run(self):
		quit(1)
		return

	var scene_suite := preload("res://tests/test_scene_contract.gd").new()
	if not await scene_suite.run(self):
		quit(1)
		return
	var game_root_suite := preload("res://tests/test_game_root_flow.gd").new()
	if not await game_root_suite.run(self):
		quit(1)
		return
	print("All Hutik sa Katagman logic tests passed.")
	quit(0)
