extends Node2D
class_name StageControl
"""
A general script for controlling stage aspects like 

- moving moped across tracks
"""
var Logger : Resource = preload("res://utils/logger.gd")


onready var moped_rebel: MopedRebel = $MopedRebel
onready var LOG: Logger = Logger.new(self)


func _ready():
	moped_rebel.connect('swerve_direction_pressed', self, '_on_MopedRebel_swerve_direction_pressed')
	pass


func _process(delta):
	pass
	
	
func _on_MopedRebel_swerve_direction_pressed(intended_direction: int) -> void:
	
	pass
