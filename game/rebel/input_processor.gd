extends Node
class_name InputProcessor
"""
Controller for collecting player input during main processing loop.
Internally manages cooldown state for action presses
"""

var max_diss_colldown : float = 3.0


var _say_diss_cooldown : float = 0


func _ready() -> void:
	pass # Replace with function body.
	
	
func _process(delta: float) -> void:
	_cooldown_timeout(_say_diss_cooldown, delta)


"""
Collect current input about player desire to swerve (change tracks)
"""
func process_swerve_input() -> int:
	return _process_axis_inputs("swerve_down", "swerve_up")
	
	
func process_say_diss() -> bool:
	return _process_press_action_cooldown("say_diss", _say_diss_cooldown, max_diss_colldown)
	

func _process_axis_inputs(axis_plus_action: String, axis_minus_action: String) -> int:
	var result_input : int = 0
	if Input.is_action_just_pressed(axis_plus_action):
		result_input += 1
	if Input.is_action_pressed(axis_minus_action):
		result_input -= 1
	
	return result_input
	
	
func _process_press_action_cooldown(action_name: String, current_cooldown: float, reset_cooldown: float) -> bool:
	if (current_cooldown > 0):
		return false
	if Input.is_action_pressed(action_name):
		current_cooldown = reset_cooldown
		return true
	else:
		return false
		

func _cooldown_timeout(timeout: float, reduce_delta: float) -> void:
	if (timeout > 0):
		timeout = max(0.0, timeout - reduce_delta)