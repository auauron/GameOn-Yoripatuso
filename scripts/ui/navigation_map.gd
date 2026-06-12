class_name NavigationMap
extends Control

@export var compact := false

var world_bounds := Rect2(0, 0, 6400, 4200)
var tracked_position := Vector2.ZERO
var era_id: int = GameState.Era.MODERN
var indoors := false

const ROUTE_POINTS := [
	Vector2(350, 2150), Vector2(1100, 2050), Vector2(1800, 2250),
	Vector2(2550, 2010), Vector2(3300, 2170), Vector2(4050, 1980),
	Vector2(4850, 2180), Vector2(5580, 1960),
]

const DISTRICTS := {
	"RESIDENTIAL": Vector2(1300, 1050),
	"CRAFT": Vector2(3050, 820),
	"MARKET": Vector2(3450, 2180),
	"RIVER": Vector2(5500, 2020),
	"BURIAL": Vector2(4650, 3300),
}

static func world_to_map(world_position: Vector2, bounds: Rect2, map_size: Vector2) -> Vector2:
	if bounds.size.x <= 0.0 or bounds.size.y <= 0.0:
		return Vector2.ZERO
	var normalized := Vector2(
		inverse_lerp(bounds.position.x, bounds.end.x, world_position.x),
		inverse_lerp(bounds.position.y, bounds.end.y, world_position.y)
	)
	normalized = normalized.clamp(Vector2.ZERO, Vector2.ONE)
	return normalized * map_size

func set_navigation_context(bounds: Rect2, world_position: Vector2, new_era_id: int, is_indoors: bool) -> void:
	world_bounds = bounds
	tracked_position = world_position
	era_id = new_era_id
	indoors = is_indoors
	queue_redraw()

func _draw() -> void:
	var map_size := size
	if map_size.x <= 0.0 or map_size.y <= 0.0:
		return

	var modern := era_id == GameState.Era.MODERN
	var land_color := Color("#607957") if modern else Color("#365334")
	var route_color := Color("#8b8981") if modern else Color("#a78d59")
	var water_color := Color("#347b91") if modern else Color("#326c78")
	var marker_color := Color("#7ed8ea") if modern else Color("#e7bd55")
	draw_rect(Rect2(Vector2.ZERO, map_size), Color("#151b18"))
	draw_rect(Rect2(Vector2(4, 4), map_size - Vector2(8, 8)), land_color)

	var river_left := world_to_map(Vector2(5650, 0), world_bounds, map_size)
	draw_rect(Rect2(Vector2(river_left.x, 4), Vector2(map_size.x - river_left.x - 4, map_size.y - 8)), water_color)

	var route := PackedVector2Array()
	for point in ROUTE_POINTS:
		route.append(world_to_map(point, world_bounds, map_size))
	draw_polyline(route, route_color, 5.0 if compact else 9.0, true)
	draw_line(
		world_to_map(Vector2(3200, 300), world_bounds, map_size),
		world_to_map(Vector2(3200, 3850), world_bounds, map_size),
		route_color,
		4.0 if compact else 7.0,
		true
	)

	for district_name in DISTRICTS:
		var district_position: Vector2 = world_to_map(DISTRICTS[district_name], world_bounds, map_size)
		draw_circle(district_position, 3.0 if compact else 6.0, marker_color)
		if not compact:
			draw_string(get_theme_default_font(), district_position + Vector2(9, 5), district_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color.WHITE)

	var player_position := world_to_map(tracked_position, world_bounds, map_size)
	var player_color := Color("#ffcf4f") if not indoors else Color("#ffffff")
	draw_circle(player_position, 6.0 if compact else 10.0, Color(0, 0, 0, 0.7))
	draw_circle(player_position, 4.0 if compact else 7.0, player_color)
	if indoors and not compact:
		draw_arc(player_position, 14.0, 0.0, TAU, 24, player_color, 2.0)
