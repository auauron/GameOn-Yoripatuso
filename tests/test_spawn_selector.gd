extends RefCounted

const SpawnSelectorScript = preload("res://scripts/gameplay/spawn_selector.gd")

func run() -> bool:
	var points: Array[String] = ["worktable", "mat", "chest"]
	for seed_value in range(20):
		var selected: String = SpawnSelectorScript.choose(points, "mat", seed_value)
		assert(selected in points)
		assert(selected != "mat")

	assert(SpawnSelectorScript.choose(["only"], "only", 1) == "only")
	assert(SpawnSelectorScript.choose([], "", 1) == "")
	return true
