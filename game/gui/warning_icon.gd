extends Control
class_name WarningIcon
"""
Controller script for setting distance to obstacle inside 
this non-interactive warning
"""


@onready var distance_text: Label = $DistanceText


func _ready():
	pass # Replace with function body.


func set_distance(new_distance: float) -> void:
	distance_text.text = String(new_distance)
