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


signal swerve_direction_pressed(swerve_direction)


export(Vector2) var velocity := Vector2(CRUISE_SPEED, 0)


onready var animator := $AnimationPlayer
onready var LOG : Logger = Logger.new(self)


var is_swerving: bool = false 

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	_process_swerve_input()
	move_and_slide(velocity)
	pass
	
	
func _process_swerve_input() -> void:
	if (is_swerving):
		return
	
	var desired_swerve_direction := 0
	if Input.is_action_pressed("swerve_up"):
		desired_swerve_direction -= 1
	if Input.is_action_pressed("swerve_down"):
		desired_swerve_direction += 1
	
	if desired_swerve_direction != 0:
		#present stage with desired swerve direction
		# -1 for going up
		# +1 for going down
		emit_signal("swerve_direction_pressed", desired_swerve_direction)
		pass


func begin_swerve(swerve_direction: int) -> void:
	is_swerving = true
	match(swerve_direction):
		-1:
			animator.play("swerve_up")
		1:
			animator.play("swerve_down")
		_:
			LOG.error("Cant parse swerve direction from {}!", [swerve_direction])	

