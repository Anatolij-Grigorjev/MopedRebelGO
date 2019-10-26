extends Node2D
class_name DissAim
"""
Visual indicator for aiming at a specific civilian. Texture is custom drawn,
runs along the ground from civilian to moped
"""

export(Color) var channel_modulate: Color = Color.white
export(float) var channel_width: float = 100


var _channel_body: Texture = preload("res://stages/tile_light_texture.png")
var _channel_start_position: Vector2
var _channel_end_position: Vector2
var _channel_present: bool = false


func _ready() -> void:
	_channel_present = true
	_channel_start_position = Vector2(100, 600)
	_channel_end_position = Vector2(500, 450)
	pass # Replace with function body.
	
	
func _process(delta: float) -> void:
	if (Input.is_action_just_released("debug1")):
		_channel_end_position.x -= 25
	if (Input.is_action_just_released("debug2")):
		_channel_end_position.x += 25
	if (Input.is_action_just_released("swerve_up")):
		_channel_end_position.y -= 25
	if (Input.is_action_just_released("swerve_down")):
		_channel_end_position.y += 25
	update()
	
	
func _draw() -> void:
	if (not _channel_present):
		return
	
	var start := _channel_start_position
	var end := _channel_end_position
	
	var end_distance: float = end.x - start.x
	if (end_distance <= 0):
		return
	
	#find channel angle
	var angle_vector := Vector2(end_distance, abs(end.y - start.y))
	var channel_angle_radians : float = angle_vector.angle()
	var angle_sin := sin(channel_angle_radians)
	var angle_cos := cos(channel_angle_radians)
	
	#create channel points
	var extents := channel_width / 2
	var channel_top_left := Vector2(start.x * angle_cos, (start.y - extents) * angle_sin)
	var channel_top_right := Vector2(end.x * angle_cos, (end.y - extents) * angle_sin)
	var channel_bottom_right := Vector2(end.x * angle_cos, (end.y + extents) * angle_sin)
	var channel_bottom_left := Vector2(start.x * angle_cos, (start.y + extents) * angle_sin)
	
	#draw poly
	var points_array : PoolVector2Array = [
		channel_top_left, channel_top_right,
		channel_bottom_right, channel_bottom_left
	]
#	draw_polyline(points_array, channel_modulate, channel_width)
	draw_colored_polygon(points_array, channel_modulate, [], _channel_body)
