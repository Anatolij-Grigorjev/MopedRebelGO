extends Node2D
class_name DissWord
"""
Controller for diss word to approach inteded target if set
"""
var Logger : Resource = preload("res://utils/logger.gd")

const DISS_SPEED = 500


onready var LOG: Logger = Logger.new(self)
onready var tween: Tween = $Tween


var _target_reticule: Node2D


func _ready() -> void:
	pass # Replace with function body.


func set_target(target_reticule: Node2D) -> void:
	_target_reticule = target_reticule
	

"""
Make diss move towards target
"""
func send_diss() -> void:
	var target_position := _target_reticule.global_position
	var distance := global_position.distance_to(target_position)
	var time_to_reach := distance / DISS_SPEED
	
	tween.interpolate_property(
		self, 'global_position', 
		null, target_position, 
		time_to_reach, 
		Tween.TRANS_LINEAR, Tween.EASE_OUT_IN
	)
	tween.start()
	
	yield(tween, "tween_all_completed")