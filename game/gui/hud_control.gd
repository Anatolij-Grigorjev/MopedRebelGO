extends Control
class_name HUDController
"""
Orchestration of various HUD elements and making sure data/signals intended
for them reach them from this single point of entry
"""
var EarnedPoints : Resource = preload("res://gui/earned_points.tscn")


signal earned_points_merged


#imports
onready var State : GameState = get_node("/root/G")


#components
onready var sc_progress : StreetCredProgressBar = $MarginContainer/VBoxContainer/HBoxContainer/StreetCredProgressBar
onready var current_sc_label : PointsLabel = $MarginContainer/VBoxContainer/Labels/HBoxContainer/CurrentSCLabel
onready var additive_sc_label : PointsLabel = $MarginContainer/VBoxContainer/Labels/HBoxContainer/AdditiveSCLabel
onready var additive_sc_multiplier : PointsLabel = $MarginContainer/VBoxContainer/Labels/HBoxContainer/AdditiveSCMultiplier
onready var transfer_sc_label: PointsLabel = $MarginContainer/VBoxContainer/Labels/HBoxContainer/TransferSCLabel
onready var dark_overlay : TextureRect = $DarkOverlay
onready var transfer_points_debounce : Timer = $TransferPointsDebounce
onready var transfer_sc_tween: Tween = $TransferSCTween


var _current_points_change_base_accum: float = 0.0


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug2"):
		queue_change_points(78 * randf())


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
	

"""
Create earned points marker at base of rebel wheels and send that marker 
to main current points label on HUD
"""
func _add_earned_points_at_origin_label(from_position: Vector2, earned_points: float) -> EarnedPoints:
	var earned_node : EarnedPoints = EarnedPoints.instance()
	earned_node.num_points = earned_points
	earned_node.rect_position = from_position
	earned_node.end_point = Vector2.ZERO
	add_child(earned_node)
	
	return earned_node
	
	
func add_earned_points_score_and_label(from_canvas_position: Vector2, points: float) -> void:
	yield(_add_earned_points_at_origin_label(from_canvas_position, points), "tree_exiting")
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
	_reset_sc_multiplier()
	
	transfer_sc_label.modulate.a = 1.0
	transfer_sc_label.rect_position = additive_sc_label.rect_position
	transfer_sc_tween.interpolate_property(transfer_sc_label, 'rect_position',
		null, current_sc_label.rect_position, 1.0, 
		Tween.TRANS_LINEAR, Tween.EASE_OUT_IN
	)
	transfer_sc_tween.start()
	_current_points_change_base_accum -= base_transfer
	_update_accum_sc_label()
	#wait for tween to finish
	yield(transfer_sc_tween, "tween_all_completed")
	#flush the update
	_add_sc_points(points_to_transfer)
	transfer_sc_label.modulate.a = 0
	
	
func _reset_sc_multiplier() -> void:
	State.sc_multiplier = 1.0
	update_sc_mult_label()