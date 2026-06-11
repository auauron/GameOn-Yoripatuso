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

	var prop_scene := load("res://scenes/environment/shared/depth_sorted_prop.tscn") as PackedScene
	assert(prop_scene != null)
	var prop := prop_scene.instantiate()
	assert(prop.has_meta("ground_contact_origin"))
	assert(prop.get_node_or_null("ContactShadow") != null)
	assert(prop.get_node_or_null("Visual") != null)
	assert(prop.get_node_or_null("CollisionBody/CollisionShape2D") != null)
	prop.free()

	var foreground_scene := load("res://scenes/environment/shared/foreground_cluster.tscn") as PackedScene
	assert(foreground_scene != null)
	var foreground := foreground_scene.instantiate()
	assert(foreground.find_child("CollisionShape2D", true, false) == null)
	foreground.free()
	return true
