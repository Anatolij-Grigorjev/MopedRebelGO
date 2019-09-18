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
onready var pushback_tween := $PushbackTween
onready var input := $InputProcessor
onready var _neutral_transform: Dictionary = {
	'rotation': self.rotation_degrees,
	'scale': self.scale
}


var _is_swerving: bool = false 
var _is_crashing: bool = false


func _ready() -> void:
	$ObstacleDetect.connect("hit_obstacle", self, "_on_ObstacleDetector_hit_obstacle")
	pass


func _process(delta: float) -> void:
	if (not _is_swerving
		and not _is_crashing):
		#get desired swerve direction 
		#-1 for going up +1 for going down
		var desired_swerve_direction : int = input.process_swerve_input()
		if desired_swerve_direction != 0:
			emit_signal("swerve_direction_pressed", desired_swerve_direction)
	move_and_slide(velocity)

	
	
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
	#if moped swerved into obstacle dont reset transform
	if (not _is_crashing):
		_reset_transform()
	_is_swerving = false


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
Setup and start tween required to push back rebel from current
position by force of road obstacle
"""
func _prep_start_tween_pushback() -> void:
	var final_position := global_position - Vector2(C.MR_OBSTACLE_PUSHBACK_AMOUNT, 0)
	pushback_tween.remove_all()
	pushback_tween.interpolate_property(
		self, 'global_position', 
		global_position, final_position,
		C.MR_OBSTACLE_PUSHBACK_DURATION_SEC, 
		Tween.TRANS_LINEAR, Tween.EASE_OUT
	)
	pushback_tween.start()


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
		_neutral_transform.rotation, _neutral_transform.scale]
	)
	self.rotation_degrees = _neutral_transform.rotation
	self.scale = _neutral_transform.scale


"""
Get signal about detected obstacle ahead, 
play crash animation and restore speed after crash over
"""
func _on_ObstacleDetector_hit_obstacle(obstacle: Area2D) -> void:
	_is_crashing = true
	velocity = Vector2()
	animator.play("crash_obstacle")
	yield(animator, "animation_finished")
	velocity = Vector2(C.MR_CRUISE_SPEED, 0)
	_is_crashing = false
	_reset_transform()