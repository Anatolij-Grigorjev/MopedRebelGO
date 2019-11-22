extends Control
class_name HUDController
"""
Orchestration of various HUD elements and making sure data/signals intended
for them reach them from this single point of entry
"""
var Logger : Resource = preload("res://utils/logger.gd")
var WarningObstacle : Resource = preload("res://gui/WarningIconObstacle.tscn")
var LevelUpText : Resource = preload("res://gui/level_up_text.tscn")
var EarnedPoints : Resource = preload("res://gui/earned_points.tscn")


"""
Range in which moped should see warning icons about upcoming obstacles
"""
const MIN_WARNING_ICON_DISTANCE = 1000.0
const MAX_WARNING_ICON_DISTANCE = 4500.0


signal earned_points_merged


#imports
onready var State : GameState = get_node("/root/G")


#components
onready var LOG : Logger = Logger.new(self)
onready var sc_progress : StreetCredProgressBar = $StreetCredProgressBar
onready var current_sc_label : PointsLabel = $CurrentSCLabel/CurrentSCLabel
onready var additive_sc_label : PointsLabel = $AdditiveSCLabel/AdditiveSCLabel
onready var additive_sc_multiplier : PointsLabel = $AdditiveSCMultiplier/CurrentSCLabel
onready var transfer_sc_label: PointsLabel = $TransferSCLabel/AdditiveSCLabel
onready var dark_overlay : TextureRect = $DarkOverlay
onready var transfer_points_debounce : Timer = $TransferPointsDebounce
onready var transfer_sc_tween: Tween = $TransferSCTween


var _current_points_change_base_accum: float = 0.0


#TODO: separate actual accum score from multiplier

func _ready():
	transfer_points_debounce.connect("timeout", self, "_transfer_points_debounce_timeout")
	dark_overlay.visible = false
	_update_sc_label()
	_update_accum_sc_label()
	update_sc_mult_label()
	pass
	
	
func _update_sc_label() -> void:
	current_sc_label.update_current_points(State.current_street_scred)
	

func _update_accum_sc_label() -> void:
	additive_sc_label.update_current_points(_current_points_change_base_accum)
	
	
func update_sc_mult_label() -> void:
	additive_sc_multiplier.update_current_points(State.sc_multiplier)
		
		
func queue_change_points(base_amount: float) -> void:
	#reset timer if no points or its running
	if (_current_points_change_base_accum == 0.0
	or not transfer_points_debounce.is_stopped()):
		transfer_points_debounce.start()
	_current_points_change_base_accum += base_amount
	_update_accum_sc_label()


func _add_sc_points(amount: int) -> void:
	if (State.current_street_scred == C.MR_MAX_SC):
		return
		
	var new_total := State.current_street_scred + amount
	var next_sc_level_info : Dictionary = C.MR_STREET_CRED_LEVELS[State.next_street_cred_level_idx]
	#skip leves if required by total
	while(
		next_sc_level_info.has('level_sc') 
		and next_sc_level_info.level_sc < new_total
	):
		State.next_street_cred_level_idx += 1 
		next_sc_level_info = C.MR_STREET_CRED_LEVELS[State.next_street_cred_level_idx]
	
	if (next_sc_level_info.req_sc < new_total):
		#level up!
		State.next_street_cred_level_idx += 1
		_add_level_up_label(next_sc_level_info.name)
		if (next_sc_level_info.has("level_sc")):
			sc_progress.grow_progress_next_level(
				new_total,
				next_sc_level_info.req_sc,
				next_sc_level_info.level_sc
			)
		else:
			new_total = C.MR_MAX_SC
			#final level reached
			sc_progress.grow_progress_next_level(
				C.MR_MAX_SC,
				0,
				C.MR_MAX_SC
			)
	else:
		sc_progress.grow_progress_local(new_total)
	State.current_street_scred = new_total
	_update_sc_label()
	emit_signal("earned_points_merged")
	
	
func _add_level_up_label(level_up_text : String) -> void:
	#wait until levelup condition submitted
	yield(sc_progress, "progress_bar_filled")
	dark_overlay.visible = true
	#create a happy label thing
	var level_up_node : Control = LevelUpText.instance()
	var level_up_node_label_node : Label = level_up_node.get_node("LevelText")
	level_up_node_label_node.text = level_up_text
	level_up_node.rect_rotation = 0
	level_up_node.rect_scale = Vector2(2.0, 2.0)
	level_up_node.rect_position = get_viewport_rect().size / 2 - level_up_node.rect_size / 2
	add_child(level_up_node)
	
	Engine.time_scale = 0.5
	yield(level_up_node, "tree_exiting")
	dark_overlay.visible = false
	Engine.time_scale = 1.0
	

"""
Create earned points marker at base of rebel wheels and send that marker 
to main current points label on HUD
"""
func _add_earned_points_at_origin_label(from_position: Vector2, earned_points: float) -> void:
	var earned_node : EarnedPoints = EarnedPoints.instance()
	add_child(earned_node)
	earned_node.set_num_points(earned_points)
	earned_node.rect_position = from_position
	earned_node.start_reduce_to_point(additive_sc_label.merge_points_position)
	yield(earned_node.tween, 'tween_all_completed')
	earned_node.queue_free()
	
	
func add_earned_points_score_and_label(from_canvas_position: Vector2, points: float) -> void:
	yield(_add_earned_points_at_origin_label(from_canvas_position, points), "completed")
	queue_change_points(points)
	
	
func _transfer_points_debounce_timeout() -> void:
	if (_current_points_change_base_accum == 0.0):
		return
	var base_transfer := _current_points_change_base_accum
	var points_to_transfer := base_transfer * State.sc_multiplier
	#wait for previous transfer to finish
	if (transfer_sc_tween.is_active()):
		yield(transfer_sc_tween, "tween_all_completed")
	
	transfer_sc_label.update_current_points(points_to_transfer)
	$TransferSCLabel.visible = true
	$TransferSCLabel.rect_position = $AdditiveSCLabel.rect_position
	transfer_sc_tween.interpolate_property($TransferSCLabel, 'rect_position',
		null, $CurrentSCLabel.rect_position, 1.0, 
		Tween.TRANS_LINEAR, Tween.EASE_OUT_IN
	)
	transfer_sc_tween.start()
	_current_points_change_base_accum -= base_transfer
	_update_accum_sc_label()
	#wait for tween to finish
	yield(transfer_sc_tween, "tween_all_completed")
	#flush the update
	_add_sc_points(points_to_transfer)
	$TransferSCLabel.visible = false
	