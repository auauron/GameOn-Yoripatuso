extends RefCounted

const GameStateScript = preload("res://scripts/gameplay/game_state.gd")

func run() -> bool:
	var state = GameStateScript.new()
	assert(state.current_era == GameStateScript.Era.MODERN)
	assert(not state.can_enter_past())
	assert(not state.enter_past())
	assert(state.current_era == GameStateScript.Era.MODERN)

	state.collect_eye_piece()
	assert(state.eye_piece_collected)
	assert(state.can_enter_past())
	assert(state.enter_past())
	assert(state.current_era == GameStateScript.Era.ANCIENT)
	assert(not state.can_enter_past())
	return true
