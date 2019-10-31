extends Sprite
class_name DissAim
"""
Visual indicator for aiming at a specific civilian.
"""
var Logger : Resource = preload("res://utils/logger.gd")


onready var LOG: Logger = Logger.new(self)


func _ready() -> void:
	
	pass # Replace with function body.
	
	
func _process(delta: float) -> void:
	pass