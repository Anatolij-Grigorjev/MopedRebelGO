extends Node2D
class_name DissAim
"""
Visual indicator for aiming at a specific civilian. Texture is custom drawn,
runs along the ground from civilian to moped
"""

export(Color) var channel_modulate: Color = Color(0.5, 0.5, 0.5, 1.0)
export(float) var channel_width: float = 100


var _channel_body: Texture = preload("res://stages/tile_light_texture.png")
var _channel_start_node: Node2D
var _channel_end_node: Node2D
var _channel_present: bool = false


func _ready() -> void:

	pass # Replace with function body.
	
	
func _process(delta: float) -> void:
	if (_channel_present):
		update()
		
	
func _draw() -> void:
	if (not _channel_present):
		return
	#guard agains freed instances
	if (not (
		is_instance_valid(_channel_start_node) 
		and is_instance_valid(_channel_end_node)
	)):
		return
	
	var start := _channel_start_node.global_position
	var end := _channel_end_node.global_position
	
	var end_distance: float = end.x - start.x
	if (end_distance <= channel_width):
		stop_channel()
		return
	
	#create channel points
	var extents := channel_width / 2
	var channel_top_left := Vector2(start.x, start.y - extents)
	var channel_top_right := Vector2(end.x, end.y - extents)
	var channel_bottom_right := Vector2(end.x, end.y + extents)
	var channel_bottom_left := Vector2(start.x, start.y + extents)
	
	#draw poly
	var points_array : PoolVector2Array = [
		channel_top_left, channel_top_right,
		channel_bottom_right, channel_bottom_left
	]
#	draw_polyline(points_array, channel_modulate, channel_width)
	draw_colored_polygon(points_array, channel_modulate, [], _channel_body)


func stop_channel() -> void:
	_channel_present = false
	_channel_start_node = null
	_channel_end_node = null
	#perform last redraw to clear screen
	update()
	
	
"""
Set start and end nodes to track for channel
This initialized channel with current positions of the nodes and a desire 
to draw itself. Once the positions converge and the channel can no longer be drawn 
it will disable itself
"""
func start_channel_between(start: Node2D, end: Node2D) -> void:
	_channel_start_node = start
	_channel_end_node = end
	_channel_present = true
	
	
func is_channel_active() -> bool:
	return _channel_present
	
	
func channel_origin() -> Node2D:
	return _channel_start_node
	
	
func channel_target() -> Node2D:
	return _channel_end_node