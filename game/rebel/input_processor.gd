extends Node
class_name InputProcessor
"""
Controller for collecting player input during main processing loop.
Internally manages cooldown state for action presses
"""
var Logger : Resource = preload("res://utils/logger.gd")


onready var LOG: Logger = Logger.new(self)
var max_diss_colldown : float = 0.3


var _say_diss_cooldown : float = 0


func _ready() -> void:
	pass # Replace with function body.
	
	
func _process(delta: float) -> void:
	if (_say_diss_cooldown):
		_say_diss_cooldown = max(0.0, _say_diss_cooldown - delta)


"""
Collect current input about player desire to swerve (change tracks)
"""
func process_swerve_input() -> int:
	return _process_axis_inputs("swerve_down", "swerve_up")
	
	
func process_say_diss() -> bool:
	if (_process_press_action_cooldown("say_diss", _say_diss_cooldown)):
		_say_diss_cooldown = max_diss_colldown
		return true
	return false
	

func _process_axis_inputs(axis_plus_action: String, axis_minus_action: String) -> int:
	var result_input : int = 0
	if Input.is_action_just_pressed(axis_plus_action):
		result_input += 1
	if Input.is_action_pressed(axis_minus_action):
		result_input -= 1
	
	return result_input
	
	
func _process_press_action_cooldown(action_name: String, current_cooldown: float) -> bool:
	if (current_cooldown > 0):
		return false
	return Input.is_action_pressed(action_name)