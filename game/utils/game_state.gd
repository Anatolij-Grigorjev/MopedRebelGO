extends Node
class_name GameState


var current_street_scred : int = 150
var next_street_cred_level_idx : int = 1
var sc_multiplier : float = 1.0


var current_stage_citizens := 0
var current_stage_citizens_dissed := 0
var current_stage_NRT_length := 0.0
var current_stage_NRT_traveled := 0.0


#cached root for access
onready var ROOT: Node = get_tree().get_root()
var moped_rebel_node: MopedRebel = null

func _ready() -> void:
	pass
	
	
func reset_current_stage_stats() -> void:
	current_stage_citizens = 0
	current_stage_citizens_dissed = 0
	current_stage_NRT_length = 0.0
	current_stage_NRT_traveled = 0.0
	sc_multiplier = 1.0