extends Node
class_name InputProcessor
"""
Controller for collecting player input during main processing loop.
Internally manages cooldown state for action presses
"""
var Logger : Resource = preload("res://utils/logger.gd")


onready var LOG: Logger = Logger.new(self)
var max_diss_colldown : float = 0.5


var _say_diss_cooldown : float = 0


func _ready() -> void:
	pass # Replace with function body.
	
	
func _process(delta: float) -> void:
	if (_say_diss_cooldown):
		_say_diss_cooldown = max(0.0, _say_diss_cooldown - delta)


"""
Return desire to swerve (change tracks), 0 meaning no relevant input
"""
func process_swerve_input() -> int:
	return _process_axis_inputs("swerve_down", "swerve_up")
	

"""
Return desire to change diss target, 0 if no input
"""
func process_change_diss_target() -> int:
	return _process_axis_inputs("diss_target_above", "diss_target_below")

"""
Return desire to say diss, false meaning no desire
"""
func process_say_diss() -> bool:
	if (_process_press_action_cooldown("say_diss", _say_diss_cooldown)):
		_say_diss_cooldown = max_diss_colldown
		return true
	return false
	

"""
Process axis-style input, 
return -1/+1 for respective action presses or 0 if neither is pressed
"""
func _process_axis_inputs(axis_plus_action: String, axis_minus_action: String) -> int:
	var result_input : int = 0
	if Input.is_action_just_pressed(axis_plus_action):
		result_input += 1
	if Input.is_action_just_pressed(axis_minus_action):
		result_input -= 1
	
	return result_input
	

"""
Process button-style input with cooldown,
return true if button pressed post cooldown, 
false if no input or cooldown still in effect
"""	
func _process_press_action_cooldown(action_name: String, current_cooldown: float) -> bool:
	if (current_cooldown > 0):
		return false
	return Input.is_action_pressed(action_name)