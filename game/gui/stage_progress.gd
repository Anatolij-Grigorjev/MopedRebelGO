extends ProgressBar
class_name StageProgressBar
"""
Progress bar that shows current progress of node in stage.
Node to track is assigned via path, stage bounds interval as well
"""


export(NodePath) var track_node_path setget set_track_path
export(Vector2) var stage_bounds setget set_bounds


onready var track_node: Node2D = get_node(track_node_path)


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if (is_instance_valid(track_node)):
		self.value = track_node.global_position.x
	

func set_bounds(bounds: Vector2) -> void:
	stage_bounds = bounds
	self.min_value = bounds.x
	self.max_value = bounds.y 
	
	
func set_track_path(path: NodePath) -> void:
	track_node_path = path
	track_node = get_node(path)
