extends RefCounted

const REQUIRED_LAYERS := [
	"FarBackground",
	"Ground",
	"GroundDetail",
	"DepthSortedWorld",
	"RoofAndCanopyOverlays",
	"NearForeground",
	"EraAtmosphere",
]

func run() -> bool:
	for path in [
		"res://scenes/worlds/modern_oton_world.tscn",
		"res://scenes/worlds/ancient_katagman_world.tscn",
	]:
		var scene := load(path) as PackedScene
		assert(scene != null)
		var world := scene.instantiate() as ExplorationWorld
		for layer_name in REQUIRED_LAYERS:
			assert(world.get_node_or_null(layer_name) != null)
		assert(world.get_actor_layer() == world.get_node("DepthSortedWorld"))
		assert(world.get_actor_layer().y_sort_enabled)
		assert(world.get_node("FarBackground").z_index < world.get_actor_layer().z_index)
		assert(world.get_node("NearForeground").z_index > world.get_actor_layer().z_index)
		world.free()
	return true
