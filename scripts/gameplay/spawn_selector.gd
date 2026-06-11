class_name SpawnSelector
extends RefCounted

static func choose(points: Array[String], previous: String, seed_value: int) -> String:
	if points.is_empty():
		return ""

	var candidates := points.filter(func(point: String) -> bool: return point != previous)
	if candidates.is_empty():
		candidates = points.duplicate()

	var random := RandomNumberGenerator.new()
	random.seed = seed_value
	return candidates[random.randi_range(0, candidates.size() - 1)]
