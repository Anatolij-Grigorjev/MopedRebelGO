extends KinematicBody2D
class_name MopedRebel
"""
Main Controller class for Moped Rebel Playable Character.

* Performs constant movement
* Collects user input to:
	* Perform swerve animation and tween
"""
var Logger : Resource = preload("res://utils/logger.gd")


const CRUISE_SPEED = C.MR_CRUISE_SPEED


signal swerve_direction_pressed(swerve_direction)


export(Vector2) var velocity := Vector2(CRUISE_SPEED, 0)


onready var animator := $AnimationPlayer
onready var LOG : Logger = Logger.new(self)
onready var swerve_tween := $SwerveTween
onready var _netural_transform: Dictionary = {
	'rotation': self.rotation_degrees,
	'scale': self.scale
}


var _is_swerving: bool = false 

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	#get desired swerve direction 
	#-1 for going up +1 for going down
	var desired_swerve_direction := _process_swerve_input()
	if desired_swerve_direction != 0:
		emit_signal("swerve_direction_pressed", desired_swerve_direction)
	
	move_and_slide(velocity)
	pass
	
	
"""
Perform moped swerve operations, including animation, position tween
and swerve state reset. 
Does not validate arguments, these should come from stage.
"""
func perform_swerve(swerve_direction: int, swerve_amount: int) -> void:
	_is_swerving = true
	var correct_anim_name : String
	match(swerve_direction):
		-1:
			correct_anim_name = "swerve_up"
		1:
			correct_anim_name = "swerve_down"
		_:
			LOG.error("Cant parse swerve direction from {}!", [swerve_direction])	
	animator.play(correct_anim_name)
	_prep_tween_swerve(swerve_direction, swerve_amount)
	swerve_tween.start()
	yield(swerve_tween, 'tween_all_completed')
	_reset_transform()
	_is_swerving = false
	
	
func _process_swerve_input() -> int:
	if (_is_swerving):
		return 0
	
	var desired_swerve_direction := 0
	if Input.is_action_pressed("swerve_up"):
		desired_swerve_direction -= 1
	if Input.is_action_pressed("swerve_down"):
		desired_swerve_direction += 1
	
	return desired_swerve_direction


"""
Setup the tween required to perform swerve based on what direction
the swerve needs to be made in
"""
func _prep_tween_swerve(direction: int, offset_amount: int) -> void:
	var actual_offset := direction * offset_amount
	swerve_tween.remove_all()
	swerve_tween.interpolate_property(
		self, 'global_position:y', 
		global_position.y, global_position.y + actual_offset,
		C.MR_SWERVE_DURATION_SEC, 
		Tween.TRANS_LINEAR, Tween.EASE_OUT
	)
	

"""
Reset the rotation and scale of the rebel to its original values
(after animations for example)
"""
func _reset_transform() -> void:
	#stop animations, if playing
	if (animator.is_playing()):
		animator.stop()
		
	LOG.debug("Got rot/scale: {}/{}, change to {}/{}", 
		[self.rotation_degrees, self.scale,
		_netural_transform.rotation, _netural_transform.scale]
	)
	self.rotation_degrees = _netural_transform.rotation
	self.scale = _netural_transform.scale