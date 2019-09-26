extends Node2D
class_name NonRegulationTrack
"""
Controller for non regulation track segment. 
This records when moped enters the track, when it leaves the track and the actual 
in-track distance travelled. 
The light under this track segment changes color 
based on moped presence on that part of track
"""
var Logger : Resource = preload("res://utils/logger.gd")


signal moped_traveled(distance)

export(Color) var track_regular_shine : Color = Color.blue
export(Color) var track_moped_shine : Color = Color.green

onready var LOG: Logger = Logger.new(self)
onready var lights_nodes : Array = $Lights.get_children()
onready var area: Area2D = $Area2D


var _moped_enter_position : Vector2 = Vector2.ZERO

func _ready() -> void:
	_change_track_lights_to(track_regular_shine)
	area.connect("body_entered", self, "_on_body_entered")
	area.connect("body_exited", self, "_on_body_exited")
	
	
func _on_body_entered(body: PhysicsBody2D) -> void:
	var moped_rebel := body as MopedRebel
	if (moped_rebel):
		_moped_enter_position = moped_rebel.global_position
		_change_track_lights_to(track_moped_shine)
	pass
	

func _on_body_exited(body: PhysicsBody2D) -> void:
	var moped_rebel := body as MopedRebel
	if (moped_rebel):
		if (_moped_enter_position):
			var travel_distance : float = moped_rebel.global_position.x - _moped_enter_position.x
			emit_signal("moped_traveled", travel_distance)
			LOG.info("moped traveled {}px on this track", [travel_distance])
			_change_track_lights_to(track_regular_shine)
			_moped_enter_position = Vector2.ZERO
	pass
	
	
func _change_track_lights_to(new_lights_color: Color) -> void:
	for light in lights_nodes:
		(light as Light2D).color = new_lights_color
