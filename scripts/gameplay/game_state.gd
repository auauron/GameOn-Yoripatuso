class_name GameState
extends RefCounted

enum Era { MODERN, ANCIENT }

var current_era := Era.MODERN
var eye_piece_collected := false
var nose_piece_collected := false

func can_enter_past() -> bool:
	return eye_piece_collected and current_era == Era.MODERN

func collect_eye_piece() -> void:
	eye_piece_collected = true

func enter_past() -> bool:
	if not can_enter_past():
		return false
	current_era = Era.ANCIENT
	return true

func collect_nose_piece() -> void:
	nose_piece_collected = true
