extends Node
class_name InputProcessor


func _ready() -> void:
	pass # Replace with function body.


"""
Collect current input about player desire to swerve (change tracks)
"""
func process_swerve_input() -> int:
	return _process_axis_inputs("swerve_down", "swerve_up")
	

func _process_axis_inputs(axis_plus_action: String, axis_minus_action: String) -> int:
	var result_input : int = 0
	if Input.is_action_just_pressed(axis_plus_action):
		result_input += 1
	if Input.is_action_pressed(axis_minus_action):
		result_input -= 1
	
	return result_input
