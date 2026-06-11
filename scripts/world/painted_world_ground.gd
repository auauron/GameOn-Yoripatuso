class_name PaintedWorldGround
extends Node2D

@export var modern := true
@export var world_size := Vector2(6400, 4200)

const MAIN_ROUTE := [
	Vector2(350, 2150), Vector2(1100, 2050), Vector2(1800, 2250),
	Vector2(2550, 2010), Vector2(3300, 2170), Vector2(4050, 1980),
	Vector2(4850, 2180), Vector2(5580, 1960),
]

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	var grass := Color("#6f895d") if modern else Color("#587448")
	var path := Color("#918b7d") if modern else Color("#b59a61")
	var water := Color("#377d91") if modern else Color("#316d79")
	var clearing := Color("#809768") if modern else Color("#6f8656")
	draw_rect(Rect2(Vector2.ZERO, world_size), grass)

	draw_colored_polygon(PackedVector2Array([
		Vector2(5650, 0), Vector2(6400, 0), Vector2(6400, 4200), Vector2(5750, 4200),
		Vector2(5680, 3650), Vector2(5820, 3200), Vector2(5700, 2700), Vector2(5850, 2200),
		Vector2(5690, 1650), Vector2(5810, 1100),
	]), water)

	for center in [Vector2(1300, 1050), Vector2(3050, 820), Vector2(3450, 2180), Vector2(4650, 3300), Vector2(5400, 2050)]:
		var points := PackedVector2Array()
		for index in range(12):
			var angle := TAU * float(index) / 12.0
			var radius := 330.0 + float((index * 47) % 90)
			points.append(center + Vector2(cos(angle), sin(angle)) * radius)
		draw_colored_polygon(points, clearing)

	var route := PackedVector2Array(MAIN_ROUTE)
	draw_polyline(route, path, 170.0, true)
	draw_line(Vector2(3200, 300), Vector2(3200, 3850), path, 130.0, true)
	draw_line(Vector2(950, 650), Vector2(1550, 3320), path, 96.0, true)
	draw_line(Vector2(4550, 620), Vector2(5000, 3520), path, 96.0, true)

	var detail_color := Color("#536f48") if modern else Color("#3f633f")
	for x in range(140, 5580, 230):
		var y := 180 + ((x * 37) % 3650)
		draw_circle(Vector2(x, y), 10.0 + float(x % 13), detail_color)
		draw_line(Vector2(x - 12, y + 9), Vector2(x + 14, y - 7), Color(detail_color, 0.75), 4.0, true)
