extends Area2D
class_name RoadBlock
"""
General script to control any kind of static roadblock standing on the road.
A roadblock should be able to know when moped collided with it
and tell moped to react appropriately
"""
var Logger : Resource = preload("res://utils/logger.gd")


onready var LOG: Logger = Logger.new(self)

func _on_area_entered(area: Area2D):
	LOG.debug("obstacle caught area {}", [area])
	if (area.is_in_group(C.GROUP_MR)):
		area.inform_hit_obstacle(self)
