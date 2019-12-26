extends TextureProgress
class_name TimedBonus
"""
Gui element that has a default value which resets after a timeout. 
Time to reset indicated by diminishing progress bar
"""

const MAX_RESET_TIME = 2.0
const MIN_RESET_TIME = 1.0

export(float) var default_value := 1.0 setget _set_default_value, _get_default_value
export(bool) var debug_enabled := false


onready var timer: Timer = $ValueReset
onready var value_lbl: NumericLabel = $HBoxContainer/CurrentSCLabel


var current_value: float setget ,_get_current_value


func _ready() -> void:
	timer.wait_time = MAX_RESET_TIME
	min_value = 0.0
	max_value = timer.wait_time
	value_lbl.raw_value = default_value

	
func _process(delta: float) -> void:
	if (debug_enabled):
		if (Input.is_action_just_pressed("debug1")):
			var new_bonus = randf() + 1.0
			set_value(new_bonus)
	
	if (not timer.is_stopped()):
		value = timer.time_left
	
	
func set_value(new_value: float) -> void:
	if (new_value == default_value or new_value < 1.0):
		return
	value_lbl.raw_value = new_value
	
	if (not timer.is_stopped()):
		timer.stop()
	var reset_time = MAX_RESET_TIME / new_value
	reset_time = clamp(reset_time, MIN_RESET_TIME, MAX_RESET_TIME)
	_set_reset_time(reset_time)
	timer.start()
	
	
func _set_default_value(new_default_value: float) -> void:
	default_value = new_default_value
	if ($HBoxContainer/CurrentSCLabel):
		var value_lbl: NumericLabel = $HBoxContainer/CurrentSCLabel
		value_lbl.raw_value = new_default_value 
	
	
func _set_reset_time(time: float) -> void:
	var timer: Timer = $ValueReset
	timer.stop()
	timer.wait_time = time
	max_value = timer.wait_time


func _get_default_value() -> float:
	if ($HBoxContainer/CurrentSCLabel):
		return $HBoxContainer/CurrentSCLabel.raw_value
	else:
		return 1.0


func _on_ValueReset_timeout():
	if (value_lbl.raw_value != default_value):
		value_lbl.raw_value = default_value
		value = 0.0
		
		
func _get_current_value() -> float:
	if ($HBoxContainer/CurrentSCLabel):
		return $HBoxContainer/CurrentSCLabel.raw_value
	else:
		return default_value
