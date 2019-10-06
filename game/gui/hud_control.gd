extends Control
class_name HUDController
"""
Orchestration of various HUD elements and making sure data/signals intended
for them reach them from this single point of entry
"""
var Logger : Resource = preload("res://utils/logger.gd")
var WarningObstacle : Resource = preload("res://gui/WarningIconObstacle.tscn")

"""
Range in which moped should see warning icons about upcoming obstacles
"""
const MIN_WARNING_ICON_DISTANCE = 1000.0
const MAX_WARNING_ICON_DISTANCE = 3000.0


#imports
onready var State : GameState = get_node("/root/G")


#components
onready var LOG : Logger = Logger.new(self)
onready var sc_progress : StreetCredProgressBar = $StreetCredProgressBar
onready var stage_progress : ProgressBar = $StageProgress
onready var current_sc_label : Label = $CurrentSCLabel


"""
cache of currently flashing warning icons by track
"""
var _current_track_warnings := []
"""
internal list of HUD-relative positions for tracks to put warnings on them
"""
var _track_idx_icon_positions := []


func _ready():
	_update_sc_label()
	pass
	
	
func _update_sc_label() -> void:
	current_sc_label.text = str(State.current_street_scred)
	
	
func set_stage_metadata(stage_length: float, current_pos: float, track_positions: Array) -> void:
	stage_progress.min_value = 0
	stage_progress.max_value = stage_length
	stage_progress.value = current_pos
	_track_idx_icon_positions = Array(track_positions)


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
	

"""
Manage current state of warning icons abut upcoming track obstacles
Expects a list of maps where each element has a 
	* track_idx - int key that indicated which track the element is about
	* moped_distance - how far is the moped currently (in pixels) from the obstacle
	* obstacle_type - type of the obstacle to warn about (of enum C.ObstacleTypes)
	
If moped is too far or too close to obstacle (according to this script) then exisitng
warnings are cleared on the track.
If the moped is within warning range but no warnings have been created, this method
creates those and adds them to scene
"""
func update_next_obstacle_warning_icons(next_obstacles_typed_pos: Array) -> void:
	for elem in next_obstacles_typed_pos:
		var typed_pos : Dictionary = elem as Dictionary
		if (
			_current_track_warnings[typed_pos.track_idx]
			and not _moped_in_warning_icon_range(typed_pos.moped_distance)
		):
			var icon: Control = _current_track_warnings[typed_pos.track_idx]
			icon.queue_free()
			_current_track_warnings[typed_pos.track_idx] = null
		elif (not _current_track_warnings[typed_pos.track_idx]
			and _moped_in_warning_icon_range(typed_pos.moped_distance)
		):
			var warning_icon : Control
			match typed_pos.obstacle_type:
				C.ObstacleTypes.ROADBLOCK:
					warning_icon = WarningObstacle.instance()
				C.ObstacleTypes.CITIZEN:
					pass
				_:
					#log problem but dont break here
					LOG.error("Cant make warning icon for unrecognized obstacle type {}!", [typed_pos.obstacle_type], false)
			if (warning_icon):
				warning_icon.rect_position = _track_idx_icon_positions[typed_pos.track_idx]
				add_child(warning_icon)
				_current_track_warnings[typed_pos.track_idx] = warning_icon
	

func _moped_in_warning_icon_range(distance_to_obstacle: float) -> bool:
	return not (distance_to_obstacle < MIN_WARNING_ICON_DISTANCE or distance_to_obstacle > MAX_WARNING_ICON_DISTANCE)
