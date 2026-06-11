extends RefCounted

func run() -> bool:
	assert(InputMap.has_action("toggle_map"))
	assert(InputMap.has_action("toggle_fullscreen"))
	assert(InputMap.action_get_events("toggle_map")[0].physical_keycode == KEY_M)
	assert(InputMap.action_get_events("toggle_fullscreen")[0].physical_keycode == KEY_F11)
	var bounds := Rect2(0, 0, 6400, 4200)
	var map_size := Vector2(320, 210)
	assert(NavigationMap.world_to_map(Vector2.ZERO, bounds, map_size) == Vector2.ZERO)
	assert(NavigationMap.world_to_map(bounds.get_center(), bounds, map_size) == map_size * 0.5)
	assert(NavigationMap.world_to_map(bounds.end, bounds, map_size) == map_size)
	assert(NavigationMap.world_to_map(Vector2(-500, 5000), bounds, map_size) == Vector2(0, 210))
	return true
