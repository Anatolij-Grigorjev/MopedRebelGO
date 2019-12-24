extends TextureProgress
class_name StageProgressBar
"""
Progress bar that shows current progress of node in stage.
Node to track is assigned via path, stage bounds interval as well
"""


export(Vector2) var stage_bounds setget _set_bounds


var _moped_rebel: MopedRebel = null
onready var figure_tex: TextureRect = $TextureRect


func _ready() -> void:
	#wait to initialize rebel
	yield(get_tree(), "idle_frame")
	if (get_node("/root/G")):
		_moped_rebel = G.moped_rebel_node
	set_process(is_instance_valid(_moped_rebel))


func _process(delta: float) -> void:
	#if this is running means we have a valid MR instance
	value = _moped_rebel.global_position.x
	figure_tex.rect_position.x = Helpers.mapval(
		value, 
		min_value, max_value, 
		0.0, rect_size.x - figure_tex.rect_size.x)
	

func _set_bounds(global_bounds: Vector2) -> void:
	stage_bounds = global_bounds
	min_value = stage_bounds.x
	max_value = stage_bounds.y 
