extends SceneTree

func _init() -> void:
	var suites := [
		preload("res://tests/test_echo_math.gd").new(),
		preload("res://tests/test_discovery_payload.gd").new(),
		preload("res://tests/test_spawn_selector.gd").new(),
	]
	for suite in suites:
		if not suite.run():
			quit(1)
			return

	var scene_suite := preload("res://tests/test_scene_contract.gd").new()
	if not await scene_suite.run(self):
		quit(1)
		return
	print("All Hutik sa Katagman logic tests passed.")
	quit(0)
