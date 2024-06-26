@tool
extends Label
class_name NumericLabel
"""
This controls things related to current SC amount label, 
animating it and providing points merge position
"""
var Logger : Resource = preload("res://utils/logger.gd")


signal points_changed(new_value, old_value)
signal points_anim_done


@export var number_format: String = "%02d": get = get_number_format, set = set_number_format
@export var raw_value: float = 0.0: get = get_value, set = set_value


@onready var LOG: Logger = Logger.new(self)
@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var merge_points_position : Vector2 = size / 2


func set_number_format(new_format: String) -> void:
	if (Helpers.is_blank(new_format)):
		text = str(raw_value)
	else:
		text = new_format % raw_value
	number_format = new_format
	

func get_number_format() -> String:
	return number_format
	
	
func get_value() -> float:
	return raw_value


func set_value(new_value: float) -> void:
	if (new_value != raw_value):
		text = number_format % new_value
		if ($AnimationPlayer):
			var animator = $AnimationPlayer
			if (animator.is_playing()):
				animator.stop(true)
			animator.play("points_changed")
		emit_signal("points_changed", new_value, raw_value)
		raw_value = new_value
