extends Sprite2D
class_name DissAim
"""
Visual indicator for aiming at a specific civilian.
"""
var Logger : Resource = preload("res://utils/logger.gd")


@onready var LOG: Logger = Logger.new(self)


var _target_citizen: CitizenRoadBlock


func _ready() -> void:
	_target_citizen = get_parent()
	var visibility = _target_citizen.visibility_controller  as VisibleOnScreenNotifier2D
	visibility.connect("screen_exited", Callable(self, "_on_Citizen_screen_exited"))
	

func get_target_citizen() -> CitizenRoadBlock:
	return _target_citizen
	
	
func _on_Citizen_screen_exited() -> void:
	queue_free()