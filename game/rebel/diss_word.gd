extends Node2D
class_name DissWord
"""
Controller for diss word to approach inteded target if set
"""
const DISS_SPEED = 300
const DISTANCE_TOLERANCE_SQR = 5.0 * 5.0


signal hit_citizen


var _target_citizen: Node2D
var _diss_arrived: bool = false


func _ready() -> void:
	pass # Replace with function body.
	
	
func _process(delta: float) -> void:
	if (_target_citizen and not _diss_arrived):
		var citizen_position := _target_citizen.global_position
		var advance := (global_position - citizen_position) * DISS_SPEED * delta
		global_position += advance
		if (global_position.distance_squared_to(citizen_position) < DISTANCE_TOLERANCE_SQR):
			_diss_arrived = true
			emit_signal("hit_citizen")
	pass


func set_target(target_citizen: Node2D) -> void:
	_target_citizen = target_citizen