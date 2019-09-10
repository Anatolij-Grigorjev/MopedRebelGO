extends KinematicBody2D
class_name MopedRebel
"""
Main Controller class for Moped Rebel Playable Character.

Controls constant movement, controls invkoing of dissing and turning
Handles collisions and plays animations at required times. 
Controls delivery packages
"""
var Logger : Resource = preload("res://utils/logger.gd")

const CRUISE_SPEED = C.MR_CRUISE_SPEED

export(Vector2) var velocity := Vector2(CRUISE_SPEED, 0)

onready var animator := $AnimationPlayer
onready var LOG : Logger = Logger.new(self)


func _ready() -> void:
	pass 
