extends ColorRect
class_name DissAim
"""
Visual indicator for aiming at a specific civilian.
"""
var Logger : Resource = preload("res://utils/logger.gd")


export(float) var channel_width: float = 40


onready var LOG: Logger = Logger.new(self)


var _channel_start_node: Node2D
var _channel_end_node: Node2D
var _channel_present: bool = false


func _ready() -> void:
	
	pass # Replace with function body.
	
	
func _process(delta: float) -> void:
	if (_channel_present):
		#guard agains freed instances
		if (not (is_instance_valid(_channel_end_node))):
			return
		
		var start := Vector2.ZERO
		var global_pos := _channel_start_node.get_global_transform_with_canvas().get_origin()
		var end := _channel_end_node.get_global_transform_with_canvas().get_origin()
		
		var end_distance: float = end.x - global_pos.x
		if (end_distance <= channel_width):
			stop_channel()
			return
		
		rect_position = start
		rect_size = Vector2(end.x - start.x, channel_width)
		rect_rotation = rad2deg(end.angle_to(global_pos))
		pass


func stop_channel() -> void:
	LOG.info("stop channel to {}!", [_channel_end_node.global_position])
	_channel_present = false
	_channel_start_node = null
	_channel_end_node = null
	rect_size = Vector2.ZERO
	
	
"""
Set start and end nodes to track for channel
This initialized channel with current positions of the nodes and a desire 
to draw itself. Once the positions converge and the channel can no longer be drawn 
it will disable itself
"""
func start_channel_to(start: Node2D, end: Node2D) -> void:
	_channel_start_node = start
	_channel_end_node = end
	_channel_present = true
	
	
func is_channel_active() -> bool:
	return _channel_present
	
	
func channel_origin() -> Node2D:
	return _channel_start_node
	
	
func channel_target() -> Node2D:
	return _channel_end_node