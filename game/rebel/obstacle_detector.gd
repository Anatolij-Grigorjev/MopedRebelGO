extends Area2D
class_name ObstacleDetector
"""
Detect and send signals when rebel hits an obstacle
"""
signal hit_obstacle(obstacle)


func inform_hit_obstacle(obstacle: Area2D) -> void:
	emit_signal("hit_obstacle", obstacle)
