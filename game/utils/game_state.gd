extends Node
class_name GameState


var current_street_scred : int = 150
var next_street_cred_level_idx : int = 1
var sc_multiplier : float = 1.0


var current_stage_citizens := 0
var current_stage_citizens_dissed := 0
var current_stage_NRT_length := 0.0
var current_stage_NRT_traveled := 0.0


func _ready() -> void:
	pass # Replace with function body.
	
	
func reset_stage_stats() -> void:
	current_stage_citizens = 0
	current_stage_citizens_dissed = 0
	current_stage_NRT_length = 0.0
	current_stage_NRT_traveled = 0.0