class_name ForegroundClusterVisual
extends Node2D

@export var cluster_size := Vector2(520, 260)
@export var foliage_color := Color("#14261a")

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	var offsets := [
		Vector2(0, 80),
		Vector2(110, 15),
		Vector2(230, 70),
		Vector2(350, 5),
		Vector2(460, 75),
	]
	for offset in offsets:
		draw_circle(offset, 105.0, foliage_color)
