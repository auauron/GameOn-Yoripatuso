extends RefCounted

const EchoControllerScript = preload("res://scripts/audio/echo_controller.gd")

func run() -> bool:
	assert(is_equal_approx(EchoControllerScript.proximity_from_distance(900.0, 90.0, 900.0), 0.0))
	assert(is_equal_approx(EchoControllerScript.proximity_from_distance(90.0, 90.0, 900.0), 1.0))
	assert(is_equal_approx(EchoControllerScript.proximity_from_distance(495.0, 90.0, 900.0), 0.5))
	assert(is_equal_approx(EchoControllerScript.proximity_from_distance(20.0, 90.0, 900.0), 1.0))
	assert(is_equal_approx(EchoControllerScript.proximity_from_distance(1200.0, 90.0, 900.0), 0.0))
	return true
