class_name DepthSortedProp
extends Node2D

@export var prop_size := Vector2(120, 150)
@export var body_color := Color("#7b5835")
@export var accent_color := Color("#b88b4b")

func _ready() -> void:
	set_meta("ground_contact_origin", Vector2.ZERO)
	queue_redraw()

func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.35))
	draw_circle(Vector2.ZERO, prop_size.x * 0.36, Color(0.08, 0.1, 0.07, 0.42))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var rect := Rect2(Vector2(-prop_size.x * 0.5, -prop_size.y), prop_size)
	draw_rect(rect, body_color)
	draw_line(rect.position, rect.end, accent_color, 5.0, true)
