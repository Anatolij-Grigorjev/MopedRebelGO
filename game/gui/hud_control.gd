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

const MAX_SC_POINTS = 9999

signal earned_points_merged


#imports
onready var State : GameState = get_node("/root/G")


#components
onready var LOG : Logger = Logger.new(self)
onready var sc_progress : StreetCredProgressBar = $StreetCredProgressBar
onready var stage_progress : ProgressBar = $StageProgress
onready var current_sc_label : PointsLabel = $CurrentSCLabel/CurrentSCLabel
onready var additive_sc_label : PointsLabel = $AdditiveSCLabel/AdditiveSCLabel
onready var transfer_sc_label: PointsLabel = $TransferSCLabel/AdditiveSCLabel
onready var dark_overlay : TextureRect = $DarkOverlay
onready var transfer_points_debounce : Timer = $TransferPointsDebounce
onready var transfer_sc_tween: Tween = $TransferSCTween


"""
cache of currently flashing warning icons by track
"""
var _current_track_warnings := []
"""
internal list of HUD-relative positions for tracks to put warnings on them
"""
var _track_idx_icon_positions := []

var _current_points_change_accum: float = 0.0

func _ready():
	transfer_points_debounce.connect("timeout", self, "_transfer_points_debounce_timeout")
	dark_overlay.visible = false
	_update_sc_label()
	_update_accum_sc_label()
	pass
	

func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("debug1")):
		queue_change_points(randi() % 100 - 50)
	
	
func _update_sc_label() -> void:
	current_sc_label.update_current_points(State.current_street_scred)
	

func _update_accum_sc_label() -> void:
	additive_sc_label.update_current_points(_current_points_change_accum)

	
func set_stage_metadata(stage_length: float, current_pos: float, track_positions: Array) -> void:
	stage_progress.min_value = 0
	stage_progress.max_value = stage_length
	stage_progress.value = current_pos
	_track_idx_icon_positions = Array(track_positions)
	for idx in range(_track_idx_icon_positions.size()):
		_current_track_warnings.append(null)
		
		
func queue_change_points(amount: int) -> void:
	#reset timer if no points or its running
	if (_current_points_change_accum == 0.0
	or not transfer_points_debounce.is_stopped()):
		transfer_points_debounce.start()
	_current_points_change_accum += amount
	_update_accum_sc_label()


func _add_sc_points(amount: int) -> void:
	if (State.current_street_scred == MAX_SC_POINTS):
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
			new_total = MAX_SC_POINTS
			#final level reached
			sc_progress.grow_progress_next_level(
				MAX_SC_POINTS,
				0,
				MAX_SC_POINTS
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
		var warning_exists_at_track : bool = _current_track_warnings[typed_pos.track_idx] != null
		if (warning_exists_at_track and not _moped_in_warning_icon_range(typed_pos.moped_distance)):
			_remove_current_icon(typed_pos)
		elif (not warning_exists_at_track and _moped_in_warning_icon_range(typed_pos.moped_distance)):
			_add_new_icon(typed_pos)
			_update_warning_distance_on_track(typed_pos.track_idx, typed_pos.moped_distance)
		elif (warning_exists_at_track and _moped_in_warning_icon_range(typed_pos.moped_distance)):
			_update_warning_distance_on_track(typed_pos.track_idx, typed_pos.moped_distance)


func _remove_current_icon(typed_pos: Dictionary) -> void:
	var icon: Control = _current_track_warnings[typed_pos.track_idx]
	icon.queue_free()
	_current_track_warnings[typed_pos.track_idx] = null


func _add_new_icon(typed_pos: Dictionary) -> void:
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
		add_child(warning_icon)
		var icon_position_x : float = C.GAME_RESOLUTION.x - warning_icon.rect_size.x
		#hardocing stage offset into warnings for now
		#permanent solution would either communicate positions from stage or resolve
		#smartly via canvas laye matrix transform
		var icon_position_y : float = _track_idx_icon_positions[typed_pos.track_idx] + C.GAME_RESOLUTION.y / 2 + 250
		warning_icon.rect_position = Vector2(icon_position_x, icon_position_y)
		_current_track_warnings[typed_pos.track_idx] = warning_icon


func _update_warning_distance_on_track(track_idx: int, new_distance: float) -> void:
	if (not _current_track_warnings[track_idx]):
		return
		
	var icon : WarningIcon = _current_track_warnings[track_idx]
	icon.set_distance(new_distance)


func _moped_in_warning_icon_range(distance_to_obstacle: float) -> bool:
	return MIN_WARNING_ICON_DISTANCE <= distance_to_obstacle and distance_to_obstacle <= MAX_WARNING_ICON_DISTANCE


"""
Create earned points marker at base of rebel wheels and send that marker 
to main current points label on HUD
"""
func add_earned_nrt_points_label(moped_canvas_position: Vector2, earned_points: float) -> void:
	var earned_node : EarnedPoints = EarnedPoints.instance()
	add_child(earned_node)
	earned_node.set_num_points(earned_points)
	earned_node.rect_position = moped_canvas_position
	earned_node.start_reduce_to_point(current_sc_label.merge_points_position)
	yield(earned_node.tween, 'tween_all_completed')
	earned_node.queue_free()
	
	
func _transfer_points_debounce_timeout() -> void:
	if (_current_points_change_accum == 0.0):
		return
	var points_to_transfer := _current_points_change_accum
	#wait for previous transfer to finish
	if (transfer_sc_tween.is_active()):
		yield(transfer_sc_tween, "tween_all_completed")
	
	transfer_sc_label.update_current_points(points_to_transfer)
	$TransferSCLabel.visible = true
	$TransferSCLabel.rect_position = $AdditiveSCLabel.rect_position
	transfer_sc_tween.interpolate_property($TransferSCLabel, 'rect_position',
		null, $CurrentSCLabel.rect_position, 0.5, 
		Tween.TRANS_LINEAR, Tween.EASE_OUT_IN
	)
	transfer_sc_tween.start()
	_current_points_change_accum -= points_to_transfer
	_update_accum_sc_label()
	#wait for tween to finish
	yield(transfer_sc_tween, "tween_all_completed")
	#flush the update
	_add_sc_points(points_to_transfer)
	$TransferSCLabel.visible = false
	