extends RefCounted

func run() -> bool:
	for world_path in [
		"res://scenes/worlds/modern_oton_world.tscn",
		"res://scenes/worlds/ancient_katagman_world.tscn",
	]:
		var world_scene := load(world_path) as PackedScene
		var world = world_scene.instantiate()
		var entrances := world.get_node("Entrances").get_children()
		assert(entrances.size() >= 1)
		for entrance in entrances:
			assert(entrance.interior_scene != null)
			var interior = entrance.interior_scene.instantiate()
			assert(interior.get_node_or_null("PlayerSpawn") != null)
			assert(interior.get_node_or_null("WorldExit") != null)
			interior.free()
		world.free()
	return true
