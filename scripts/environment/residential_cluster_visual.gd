class_name ResidentialClusterVisual
extends Node2D

@export var modern := true
@export var draw_roof := false
@export var building_size := Vector2(250, 180)

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	if draw_roof:
		_draw_roof()
	else:
		_draw_base()

func _draw_base() -> void:
	var wall := Color("#c3b299") if modern else Color("#815b35")
	var outline := Color("#554638") if modern else Color("#49301d")
	var rect := Rect2(Vector2(-building_size.x * 0.5, -building_size.y), building_size)
	draw_rect(rect, wall)
	var border := PackedVector2Array([
		rect.position,
		Vector2(rect.end.x, rect.position.y),
		rect.end,
		Vector2(rect.position.x, rect.end.y),
		rect.position,
	])
	draw_polyline(border, outline, 6.0, true)
	draw_rect(Rect2(Vector2(-30, -82), Vector2(60, 82)), Color("#38291f"))
	if modern:
		draw_rect(Rect2(Vector2(-98, -112), Vector2(45, 44)), Color("#79a8b3"))
		draw_rect(Rect2(Vector2(53, -112), Vector2(45, 44)), Color("#79a8b3"))
	else:
		for y in range(-145, -24, 22):
			draw_line(Vector2(-building_size.x * 0.46, y), Vector2(building_size.x * 0.46, y), Color("#aa7e48"), 3.0, true)
		draw_line(Vector2(-90, 0), Vector2(-90, 48), outline, 10.0, true)
		draw_line(Vector2(90, 0), Vector2(90, 48), outline, 10.0, true)

func _draw_roof() -> void:
	var roof := Color("#8c5848") if modern else Color("#b28a4b")
	var outline := Color("#55352c") if modern else Color("#5b421f")
	var points := PackedVector2Array([
		Vector2(-building_size.x * 0.62, -building_size.y),
		Vector2(0, -building_size.y * 1.45),
		Vector2(building_size.x * 0.62, -building_size.y),
	])
	draw_colored_polygon(points, roof)
	draw_polyline(PackedVector2Array([points[0], points[1], points[2], points[0]]), outline, 7.0, true)
	if not modern:
		for x in range(-110, 111, 22):
			draw_line(Vector2(x, -building_size.y - 4), Vector2(x * 0.25, -building_size.y * 1.39), Color("#d1aa63"), 3.0, true)
