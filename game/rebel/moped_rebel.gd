extends KinematicBody2D
class_name MopedRebel
"""
Main Controller class for Moped Rebel Playable Character.

* Performs constant movement
* Collects user input to:
	* Perform swerve animation and tween
	* say diss

* Receives signal callbacks to:
	* Substract lost package
	* consume citizen anger pulse
	* get non-regulation track bonus
"""
var Logger : Resource = preload("res://utils/logger.gd")
var DissWord: Resource = preload("res://rebel/diss_word.tscn")


signal swerve_direction_pressed(swerve_direction)
signal diss_said(diss_word)
signal diss_target_change_pressed(change_direction)
signal anger_pulse_consumed(sc_mult_add)


var cruise_speed : float = C.MR_CRUISE_SPEED
var cutscene_speed : float = C.MR_CUTSCENE_SPEED
export(Vector2) var velocity := Vector2(cruise_speed, 0)


onready var animator_main : AnimationPlayer = $AnimationPlayer
onready var animator_anger : AnimationPlayer = $AngerAnimationPlayer
onready var sprite : AnimatedSprite = $AnimatedSprite
onready var LOG : Logger = Logger.new(self)
onready var swerve_tween : Tween = $SwerveTween
onready var pushback_tween : Tween = $PushbackTween
onready var input : InputProcessor = $InputProcessor
onready var diss_position : Position2D = $DissPosition
onready var diss_cooldown_bar: CooldownBar = $CooldownBar
onready var nrt_travel_emitter : Particles2D = $NRTParticles


var _is_swerving: bool = false 
var _is_crashing: bool = false
var _can_control_moped: bool = true


func _ready() -> void:
	G.moped_rebel_node = self
	$ObstacleDetect.connect("hit_obstacle", self, "_on_ObstacleDetector_hit_obstacle")
	$AnimatedSprite/PackagesBundle.connect("delivery_package_thrown", self, "_on_PackagesBundle_delivery_package_thrown")
	pass


func disable_player_control(keep_speed: float = cutscene_speed) -> void:
	$Camera2D.current = false
	_can_control_moped = false
	velocity = Vector2(keep_speed, 0)
	
	
func enable_player_control() -> void:
	$Camera2D.current = true
	_can_control_moped = true
	velocity = Vector2(cruise_speed, 0)
	

func _process(delta: float) -> void:
	if (_can_control_moped):
		if (not _is_swerving
			and not _is_crashing):
			#get desired swerve direction 
			#-1 for going up +1 for going down
			var desired_swerve_direction : int = input.process_swerve_input()
			if desired_swerve_direction != 0:
				emit_signal("swerve_direction_pressed", desired_swerve_direction)
			#get desired diss selection change
			var desired_selection_change : int = input.process_change_diss_target()
			if desired_selection_change != 0:
				emit_signal("diss_target_change_pressed", desired_selection_change)
			#get desire to press diss saying
			var desire_say_diss : bool = input.process_say_diss()
			if (desire_say_diss):
				diss_cooldown_bar.start_cooldown(input.max_diss_colldown)
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
	animator_main.play(correct_anim_name)
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
	if (animator_main.is_playing()):
		animator_main.stop()
		
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
	animator_main.play("crash_obstacle")
	yield(animator_main, "animation_finished")
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
	
	
"""
Construct new diss word instance without attaching to any parent
"""
func _build_diss_word() -> Node2D:
	var new_diss_word := DissWord.instance() as Node2D
	#TODO: custom random diss phrase logic
	return new_diss_word


func _on_AngerDetector_area_entered(area: Area2D) -> void:
	if (area.is_in_group(C.GROUP_ANGER_PULSE)):
		var anger_pulse_node: AngerPulse = area.get_owner() as AngerPulse
		animator_anger.play("consume_anger")
		anger_pulse_node.queue_free()
		emit_signal("anger_pulse_consumed", anger_pulse_node.pulse_sc_mult_add)
	
