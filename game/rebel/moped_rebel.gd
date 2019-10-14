extends KinematicBody2D
class_name MopedRebel
"""
Main Controller class for Moped Rebel Playable Character.

* Performs constant movement
* Collects user input to:
	* Perform swerve animation and tween
"""
var Logger : Resource = preload("res://utils/logger.gd")
var DissWord: Resource = preload("res://rebel/diss_word.tscn")


signal swerve_direction_pressed(swerve_direction)
signal diss_said(diss_word)


var cruise_speed : float = C.MR_CRUISE_SPEED
export(Vector2) var velocity := Vector2(cruise_speed, 0)


onready var animator := $AnimationPlayer
onready var sprite := $AnimatedSprite
onready var LOG : Logger = Logger.new(self)
onready var swerve_tween := $SwerveTween
onready var pushback_tween := $PushbackTween
onready var input := $InputProcessor


var _is_swerving: bool = false 
var _is_crashing: bool = false


func _ready() -> void:
	$ObstacleDetect.connect("hit_obstacle", self, "_on_ObstacleDetector_hit_obstacle")
	$AnimatedSprite/PackagesBundle.connect("delivery_package_thrown", self, "_on_PackagesBundle_delivery_package_thrown")
	pass


func _process(delta: float) -> void:
	if (not _is_swerving
		and not _is_crashing):
		#get desired swerve direction 
		#-1 for going up +1 for going down
		var desired_swerve_direction : int = input.process_swerve_input()
		if desired_swerve_direction != 0:
			emit_signal("swerve_direction_pressed", desired_swerve_direction)
		var desire_say_diss : bool = input.process_say_diss()
		if (desire_say_diss):
			var new_diss := _build_diss_word()
			emit_signal("diss_said", new_diss)
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
		_reset_sprite_transform()
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
Reset the rotation and scale of the rebel sprite to its original values
(after animations for example)
"""
func _reset_sprite_transform() -> void:
	#stop animations, if playing
	if (animator.is_playing()):
		animator.stop()
		
	LOG.debug("Got sprite rot/scale: {}/{}, reseting...", 
		[sprite.rotation_degrees, sprite.scale]
	)
	#reset sprite
	sprite.rotation_degrees = 0
	sprite.scale = Vector2.ONE


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
	_reset_sprite_transform()
	

"""
Get signal about having lost a package after crashing into an obstacle
param is number of packages still left on the moped
"""
func _on_PackagesBundle_delivery_package_thrown(remaining_packages: int) -> void:
	LOG.info("packages left on moped: {}", [remaining_packages])
	if (not remaining_packages):
		LOG.error("!!!GAME OVER!!!")
	pass
	
	
func _build_diss_word() -> Node2D:
	return null