class_name ForegroundClusterVisual
extends Node2D

@export var cluster_size := Vector2(520, 260)
@export var foliage_color := Color("#14261a")

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	var radius := cluster_size.y * 0.27
	var offsets := [
		Vector2(0, cluster_size.y * 0.36),
		Vector2(cluster_size.x * 0.24, cluster_size.y * 0.12),
		Vector2(cluster_size.x * 0.49, cluster_size.y * 0.34),
		Vector2(cluster_size.x * 0.74, cluster_size.y * 0.10),
		Vector2(cluster_size.x, cluster_size.y * 0.34),
	]
	for offset in offsets:
		draw_circle(offset, radius, foliage_color)
