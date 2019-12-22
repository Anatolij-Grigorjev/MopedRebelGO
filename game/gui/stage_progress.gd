extends TextureProgress
class_name StageProgressBar
"""
Progress bar that shows current progress of node in stage.
Node to track is assigned via path, stage bounds interval as well
"""


export(Vector2) var stage_bounds setget _set_bounds


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass
	

func _set_bounds(bounds: Vector2) -> void:
	stage_bounds = bounds
	min_value = bounds.x
	max_value = bounds.y 
