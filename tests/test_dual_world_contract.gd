extends RefCounted

const EXPECTED_BOUNDS := Rect2(0, 0, 6400, 4200)

func run() -> bool:
	var modern_scene := load("res://scenes/worlds/modern_oton_world.tscn") as PackedScene
	var ancient_scene := load("res://scenes/worlds/ancient_katagman_world.tscn") as PackedScene
	assert(modern_scene != null)
	assert(ancient_scene != null)

	var modern = modern_scene.instantiate()
	var ancient = ancient_scene.instantiate()
	assert(modern.world_bounds == EXPECTED_BOUNDS)
	assert(ancient.world_bounds == EXPECTED_BOUNDS)
	assert(modern.artifact_group_name == "eye_piece_spawn_points")
	assert(ancient.artifact_group_name == "nose_piece_spawn_points")
	assert(modern.get_artifact_spawn_points().size() >= 6)
	assert(ancient.get_artifact_spawn_points().size() >= 6)
	assert(modern.get_node("SharedAnchors/RiverLanding").position == ancient.get_node("SharedAnchors/RiverLanding").position)
	assert(modern.get_node("SharedAnchors/ResidentialDistrict").position == ancient.get_node("SharedAnchors/ResidentialDistrict").position)
	assert(modern.get_node("SharedAnchors/CraftDistrict").position == ancient.get_node("SharedAnchors/CraftDistrict").position)
	modern.free()
	ancient.free()
	return true
