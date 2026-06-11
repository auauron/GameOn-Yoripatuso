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
	var loaded_worlds: Array[ExplorationWorld] = []
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
		var residential := world.get_node_or_null("DepthSortedWorld/ResidentialShowcase")
		assert(residential != null)
		assert(residential.get_child_count() >= 5)
		assert(world.get_node("NearForeground").get_child_count() >= 2)
		loaded_worlds.append(world)
	assert(loaded_worlds[0].get_node("DepthSortedWorld/ResidentialShowcase").position == loaded_worlds[1].get_node("DepthSortedWorld/ResidentialShowcase").position)
	for world in loaded_worlds:
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

	for path in [
		"res://scenes/environment/modern/modern_house_exterior.tscn",
		"res://scenes/environment/ancient/kubo_exterior.tscn",
	]:
		var building_scene := load(path) as PackedScene
		assert(building_scene != null)
		var building := building_scene.instantiate()
		assert(building.has_meta("ground_contact_origin"))
		assert(building.get_node_or_null("BaseVisual") != null)
		assert(building.get_node_or_null("RoofVisual") != null)
		assert(building.get_node_or_null("CollisionBody/CollisionShape2D") != null)
		building.free()
	return true
