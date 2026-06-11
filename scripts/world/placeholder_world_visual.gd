class_name PlaceholderWorldVisual
extends Node2D

@export var modern := true
@export var world_size := Vector2(6400, 4200)

const SHARED_BUILDING_POSITIONS := [
	Vector2(820, 720), Vector2(1120, 930), Vector2(1450, 620), Vector2(1720, 1050),
	Vector2(2380, 650), Vector2(2740, 900), Vector2(3180, 610), Vector2(3560, 970),
	Vector2(4320, 720), Vector2(4660, 1050), Vector2(5200, 760), Vector2(5520, 1120),
	Vector2(980, 2650), Vector2(1420, 2980), Vector2(2070, 2500), Vector2(2620, 3080),
	Vector2(3380, 2690), Vector2(3940, 3050), Vector2(4700, 2580), Vector2(5300, 3000),
]

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	var ground := Color("#667d58") if modern else Color("#415c39")
	var road := Color("#77736a") if modern else Color("#9a8254")
	var water := Color("#28718a") if modern else Color("#2a6172")
	var structure := Color("#b7a58c") if modern else Color("#75512e")
	var roof := Color("#7c5142") if modern else Color("#b08a4b")
	var foliage := Color("#294d32") if modern else Color("#183d27")

	draw_rect(Rect2(Vector2.ZERO, world_size), ground)
	draw_colored_polygon(PackedVector2Array([
		Vector2(5650, 0), Vector2(6400, 0), Vector2(6400, 4200), Vector2(5750, 4200),
		Vector2(5680, 3650), Vector2(5820, 3200), Vector2(5700, 2700), Vector2(5850, 2200),
		Vector2(5690, 1650), Vector2(5810, 1100),
	]), water)

	var main_route := PackedVector2Array([
		Vector2(350, 2150), Vector2(1100, 2050), Vector2(1800, 2250), Vector2(2550, 2010),
		Vector2(3300, 2170), Vector2(4050, 1980), Vector2(4850, 2180), Vector2(5580, 1960),
	])
	draw_polyline(main_route, road, 150.0, true)
	draw_line(Vector2(3200, 300), Vector2(3200, 3850), road, 120.0, true)
	draw_line(Vector2(950, 650), Vector2(1550, 3320), road, 90.0, true)
	draw_line(Vector2(4550, 620), Vector2(5000, 3520), road, 90.0, true)

	for position in SHARED_BUILDING_POSITIONS:
		_draw_building(position, structure, roof)

	for x in range(180, 5550, 360):
		draw_circle(Vector2(x, 260 + (int(x / 120) % 3) * 90), 85.0, foliage)
		draw_circle(Vector2(x + 130, 3860 - (int(x / 120) % 4) * 70), 95.0, foliage)

	for position in [Vector2(700, 1700), Vector2(2100, 1500), Vector2(3900, 1450), Vector2(5200, 1570), Vector2(1800, 3500), Vector2(4100, 3550)]:
		draw_circle(position, 180.0, Color(foliage, 0.9))

	var landing_color := Color("#b9b6ad") if modern else Color("#76502d")
	draw_rect(Rect2(Vector2(5380, 1880), Vector2(360, 280)), landing_color)

func _draw_building(position: Vector2, structure: Color, roof: Color) -> void:
	var size := Vector2(230, 160) if modern else Vector2(190, 145)
	draw_rect(Rect2(position - size * 0.5, size), structure)
	var roof_points := PackedVector2Array([
		position + Vector2(-size.x * 0.62, -size.y * 0.5),
		position + Vector2(0, -size.y * 0.82),
		position + Vector2(size.x * 0.62, -size.y * 0.5),
	])
	draw_colored_polygon(roof_points, roof)
	if modern:
		draw_rect(Rect2(position + Vector2(-52, -5), Vector2(40, 42)), Color("#75a6b8"))
		draw_rect(Rect2(position + Vector2(18, -5), Vector2(40, 42)), Color("#75a6b8"))
	else:
		draw_line(position + Vector2(-70, 70), position + Vector2(-70, 105), Color("#392817"), 8.0)
		draw_line(position + Vector2(70, 70), position + Vector2(70, 105), Color("#392817"), 8.0)
