class_name PaintedPlayerVisual
extends Node2D

var facing := Vector2.DOWN
var movement_strength := 0.0
var walk_time := 0.0

func set_motion(direction: Vector2, moving: bool, delta: float) -> void:
	if direction.length_squared() > 0.01:
		facing = direction.normalized()
	movement_strength = 1.0 if moving else 0.0
	if moving:
		walk_time += delta * 9.0
	queue_redraw()

func _draw() -> void:
	var bob := sin(walk_time) * 1.5 * movement_strength
	var stride := sin(walk_time) * 3.0 * movement_strength
	var looking_side := signf(facing.x)

	draw_line(Vector2(-6, -14 + bob), Vector2(-7 - stride, -1), Color("#3d3028"), 6.0, true)
	draw_line(Vector2(6, -14 + bob), Vector2(7 + stride, -1), Color("#3d3028"), 6.0, true)
	draw_line(Vector2(-10 - stride, 0), Vector2(-4 - stride, 0), Color("#201b18"), 4.0, true)
	draw_line(Vector2(4 + stride, 0), Vector2(10 + stride, 0), Color("#201b18"), 4.0, true)

	var coat := PackedVector2Array([
		Vector2(-15, -42 + bob),
		Vector2(15, -42 + bob),
		Vector2(18, -13 + bob),
		Vector2(-18, -13 + bob),
	])
	draw_colored_polygon(coat, Color("#c56f45"))
	draw_polyline(PackedVector2Array([coat[0], coat[1], coat[2], coat[3], coat[0]]), Color("#50352d"), 3.0, true)
	draw_line(Vector2(0, -40 + bob), Vector2(0, -16 + bob), Color("#e0ad6a"), 2.0, true)

	var bag_x := -18.0 if looking_side >= 0.0 else 10.0
	draw_line(Vector2(-8, -42 + bob), Vector2(bag_x + 7, -21 + bob), Color("#5a3b29"), 3.0, true)
	draw_rect(Rect2(Vector2(bag_x, -27 + bob), Vector2(14, 12)), Color("#8f633c"))
	draw_rect(Rect2(Vector2(bag_x, -27 + bob), Vector2(14, 12)), Color("#4b3326"), false, 2.0)

	var head_center := Vector2(looking_side * 2.0, -51 + bob)
	draw_circle(head_center, 11.0, Color("#c99069"))
	draw_arc(head_center, 11.0, 0.0, TAU, 20, Color("#4b332c"), 2.5, true)
	draw_arc(head_center + Vector2(0, -3), 10.0, PI, TAU, 12, Color("#302721"), 6.0, true)
	draw_line(Vector2(-13, -57 + bob), Vector2(14, -57 + bob), Color("#d7b15d"), 4.0, true)
	if absf(facing.x) > 0.2:
		draw_circle(head_center + Vector2(looking_side * 6.0, 0), 1.6, Color("#27201c"))
	else:
		draw_circle(head_center + Vector2(-4, 0), 1.5, Color("#27201c"))
		draw_circle(head_center + Vector2(4, 0), 1.5, Color("#27201c"))
