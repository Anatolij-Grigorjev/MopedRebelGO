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
signal diss_said(diss_word, diss_recipient)


var cruise_speed : float = C.MR_CRUISE_SPEED
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
onready var diss_channel: DissAim = $DissChannel
onready var nrt_travel_emitter : Particles2D = $NRTParticles


var _is_swerving: bool = false 
var _is_crashing: bool = false


func _ready() -> void:
	$ObstacleDetect.connect("hit_obstacle", self, "_on_ObstacleDetector_hit_obstacle")
	$AnimatedSprite/PackagesBundle.connect("delivery_package_thrown", self, "_on_PackagesBundle_delivery_package_thrown")
	pass

func _draw() -> void:
	#draw circle at global pos
	draw_circle(global_position, diss_channel.channel_width, Color.red)


func _process(delta: float) -> void:
	
	_process_diss_channel()
	if (not _is_swerving
		and not _is_crashing):
		#get desired swerve direction 
		#-1 for going up +1 for going down
		var desired_swerve_direction : int = input.process_swerve_input()
		if desired_swerve_direction != 0:
			emit_signal("swerve_direction_pressed", desired_swerve_direction)
		var desire_say_diss : bool = input.process_say_diss()
		if (desire_say_diss):
			diss_cooldown_bar.start_cooldown(input.max_diss_colldown)
			var new_diss := _build_diss_word()
			#if no receiver present just curse at self
			var diss_receiver := (
				diss_channel.channel_target() if diss_channel.is_channel_active() 
				else self
			)
			emit_signal("diss_said", new_diss, diss_receiver)
	move_and_slide(velocity)


func _process_diss_channel() -> void:
	var visible_dissable_citizens := []
	
	if (not diss_channel.is_channel_active()):
		visible_dissable_citizens = _get_onscreen_dissable_citizens()
		if (visible_dissable_citizens):
			diss_channel.start_channel_to(self, visible_dissable_citizens[0])
	#at this point channel is active if there were citizens
	if (diss_channel.is_channel_active()):
		var change_target := input.process_change_diss_target()
		if (change_target):
			#if channel was active up to now we need to fetch citizens
			if (not visible_dissable_citizens):
				visible_dissable_citizens = _get_onscreen_dissable_citizens()
			#skip processing change if only one dissable onscreen
			if (visible_dissable_citizens.size() > 1):
				_process_diss_channel_change_diss_target(change_target, visible_dissable_citizens)


func _process_diss_channel_change_diss_target(change: int, visible_dissable_citizens: Array) -> void:
	visible_dissable_citizens.sort_custom(Helpers, "sort_nodes_global_y")
	var current_idx := visible_dissable_citizens.find(diss_channel.channel_target())
	var changed_idx := wrapi(current_idx + change, 0, visible_dissable_citizens.size())
	diss_channel.start_channel_to(self, visible_dissable_citizens[changed_idx])		
	
	
func _get_onscreen_dissable_citizens() -> Array:
	var onscreen_dissables : Array = []
	var channel_end_x := global_position.x + diss_channel.channel_width
	for dissable in get_tree().get_nodes_in_group(C.GROUP_DISSABLES):
		var citizen : CitizenRoadBlock = dissable as CitizenRoadBlock
		if (
			#citizen not so far to be ofscreen
			citizen.visibility_controller.is_on_screen()
			#citizen still far enough away to diss
			and citizen.global_position.x > channel_end_x
		):
			onscreen_dissables.append(citizen)
		
	return onscreen_dissables
	
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
		G.sc_multiplier += anger_pulse_node.pulse_sc_mult_add
		animator_anger.play("consume_anger")
		anger_pulse_node.queue_free()
	
