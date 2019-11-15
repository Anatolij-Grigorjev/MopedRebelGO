extends Label
class_name PointsLabel
"""
This controls things related to current SC amount label, 
animating it and providing points merge position
"""
var Logger : Resource = preload("res://utils/logger.gd")

signal points_changed


export(String) var label_display_format : String = "%02d"


onready var LOG: Logger = Logger.new(self)
onready var animator: AnimationPlayer = $AnimationPlayer
onready var merge_points_position : Vector2 = $MergePointsPosition.rect_global_position


func _ready():
	pass # Replace with function body.


func update_current_points(current_pts: float) -> void:
	text = label_display_format % current_pts
	if (animator.is_playing()):
		animator.stop(true)
	animator.play("points_changed")
	yield(animator, "animation_finished")
	emit_signal("points_changed")
