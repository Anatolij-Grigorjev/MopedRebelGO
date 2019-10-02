extends Control
class_name HUDController
"""
Orchestration of various HUD elements and making sure data/signals intended
for them reach them from this single point of entry
"""
var Logger : Resource = preload("res://utils/logger.gd")

#imports
onready var State : GameState = get_node("/root/G")
onready var Utils : Helpers = get_node("/root/F") 

#components
onready var LOG : Logger = Logger.new(self)
onready var sc_progress : StreetCredProgressBar = $StreetCredProgressBar
onready var stage_progress : ProgressBar = $StageProgress
onready var current_sc_label : Label = $CurrentSCLabel


func _ready():
	_update_sc_label()
	pass # Replace with function body.
	
	
func _update_sc_label() -> void:
	current_sc_label.text = str(State.current_street_scred)
	
	
func set_stage_size(stage_length: float, current_pos: float) -> void:
	stage_progress.min_value = 0
	stage_progress.max_value = stage_length
	stage_progress.value = current_pos


func add_sc_points(amount: int) -> void:
	var new_total := State.current_street_scred + amount
	var next_sc_level_info : Dictionary = C.MR_STREET_CRED_LEVELS[State.next_street_cred_level_idx]
	if (next_sc_level_info.req_sc < new_total):
		#level up!
		State.next_street_cred_level_idx += 1
		if (next_sc_level_info.has("level_sc")):
			sc_progress.grow_progress_next_level(
				new_total,
				next_sc_level_info.req_sc,
				next_sc_level_info.level_sc,
				next_sc_level_info.name
			)
		else:
			#final level reached
			sc_progress.grow_progress_next_level(
				9999,
				0,
				9999,
				next_sc_level_info.name
			)
	else:
		sc_progress.grow_progress_local(new_total)
	State.current_street_scred = new_total
	_update_sc_label()

func set_stage_progress(distance_covered: float) -> void:
	stage_progress.value = distance_covered
