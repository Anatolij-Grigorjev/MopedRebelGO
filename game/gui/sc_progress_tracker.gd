extends VBoxContainer
class_name SCProgressTracker
"""
Tracker control for current player SC points and a progress bar to advance
that progress and cause levelups
"""
var Logger : Resource = preload("res://utils/logger.gd")
var LevelUpText : Resource = preload("res://gui/level_up_text.tscn")


signal levelup_ready(levelup_node)


#debug1 and debug2 are used to assign random points of this or next level
export(bool) var debug_enabled: bool = false


onready var LOG: Logger = Logger.new(self)
onready var sc_progress_bar: TextureProgress = $StreetCredProgressBar
onready var sc_points_label: NumericLabel = $CurrentSCLabel


func _ready():
	if (get_node("/root/G")):
		set_sc_points(G.current_street_scred)
	
	
func _process(delta: float) -> void:
	if (debug_enabled):
		if (Input.is_action_just_pressed("debug1")):
			var new_value : float = sc_progress_bar.min_value + randf() * (sc_progress_bar.max_value - sc_progress_bar.min_value)
			LOG.debug("set new bar value {}", [new_value])
			set_sc_points(new_value)
		if (Input.is_action_just_pressed("debug2")):
			var new_value : int = sc_progress_bar.max_value + randf() * sc_progress_bar.max_value
			LOG.debug("set new bar value {}", [new_value])
			set_sc_points(new_value)


func set_sc_points(amount: float) -> void:
	if (G.current_street_scred == C.MR_MAX_SC):
		sc_points_label.animator.play("points_changed")
		return
		
	var new_total := amount
	var next_sc_level_info : Dictionary = C.MR_STREET_CRED_LEVELS[G.next_street_cred_level_idx]
	#skip leves if required by total
	while(
		next_sc_level_info.has('level_sc') 
		and next_sc_level_info.level_sc < new_total
	):
		G.next_street_cred_level_idx += 1 
		next_sc_level_info = C.MR_STREET_CRED_LEVELS[G.next_street_cred_level_idx]
	
	if (next_sc_level_info.req_sc < new_total):
		#level up!
		G.next_street_cred_level_idx += 1
		_do_levelup_popup(next_sc_level_info.name)
		if (next_sc_level_info.has("level_sc")):
			sc_progress_bar.grow_progress_next_level(
				new_total,
				next_sc_level_info.req_sc,
				next_sc_level_info.level_sc
			)
		else:
			new_total = C.MR_MAX_SC
			#final level reached
			sc_progress_bar.grow_progress_next_level(
				C.MR_MAX_SC,
				0,
				C.MR_MAX_SC
			)
	else:
		#same level growth
		sc_progress_bar.grow_progress_next_level(new_total)
	G.current_street_scred = new_total
	sc_points_label.raw_value = G.current_street_scred
	
	
func _do_levelup_popup(level_up_text : String) -> void:
	#wait until levelup condition submitted
	yield(sc_progress_bar, "progress_bar_filled")
	#create a happy label thing
	var level_up_node : Control = LevelUpText.instance()
	var level_up_node_label_node : Label = level_up_node.get_node("LevelText")
	level_up_node_label_node.text = level_up_text
	level_up_node.rect_rotation = 0
	level_up_node.rect_scale = Vector2(2.0, 2.0)
	level_up_node.rect_position = get_viewport_rect().size / 2
	emit_signal("levelup_ready", level_up_node)
	
	Engine.time_scale = 0.5
	yield(level_up_node, "tree_exiting")
	Engine.time_scale = 1.0
