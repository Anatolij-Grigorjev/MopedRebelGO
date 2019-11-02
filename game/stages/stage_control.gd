class_name StageControl
extends Node2D
"""
A general script for controlling stage aspects like 

- moving moped across tracks
"""
var Logger : Resource = preload("res://utils/logger.gd")
var DissAim: Resource = preload("res://rebel/diss_aim.tscn")


onready var moped_rebel: MopedRebel = $MopedRebel
onready var LOG: Logger = Logger.new(self)
onready var State : GameState = get_node("/root/G")
onready var HUD: HUDController = $CanvasLayer/HUD


export(int) var num_stage_tracks := 5
export(int) var current_moped_track := 3


var _sorted_obstacle_positions_by_track := []
onready var _tile_size: Vector2 = $Road.get_cell_size()
onready var _tile_height: int = _tile_size.y

onready var _tracks_bounds := Helpers.get_tilemap_global_bounds($Road)
onready var _track0_position := _tracks_bounds.position.y

var _current_diss_aim: DissAim


func _ready() -> void:
	#adjust track bounds due to specific tile shape
	_tracks_bounds.position.y += _tile_height / 2
	#setup moped position
	moped_rebel.connect('swerve_direction_pressed', self, '_on_MopedRebel_swerve_direction_pressed')
	moped_rebel.connect('diss_said', self, '_on_MopedRebel_diss_said')
	var moped_tracks_offset : int = _tile_height * current_moped_track
	moped_rebel.global_position.y = _track0_position + moped_tracks_offset
	
	#setup track positions for HUD warnings
	_ready_bounds_indices_for_HUD()
	
	#setup NRT signals
	_ready_NRT_for_moped()
	
	#setup obstacle positions lines
	_ready_sorted_obstacle_positions()
	
	_put_all_nodes_under_ysort()

	#logging
	LOG.info("Tilemap bounds: {}", [_tracks_bounds])
	LOG.info("Moped tracks position: {}", [moped_rebel.global_position])
	for idx in range(_sorted_obstacle_positions_by_track.size()):
		LOG.info("For track {} got {} obstacles!", [idx, _sorted_obstacle_positions_by_track[idx].size()])
		

"""
Inserts all relevant ontrack nodes under the YSort node on the stage
All relevant nodes are:
* Obstacles children
* Citizens children
* Moped Rebel
"""
func _put_all_nodes_under_ysort() -> void:
	var parent := $YSort
	#reparent rebel node itself
	Helpers.reparent_node(moped_rebel, parent)
	
	#reparent all static obstacles
	for obstacle in $Obstacles.get_children():
		Helpers.reparent_node(obstacle, parent)
		
	#reparent all citizens
	for citizen in $Citizens.get_children():
		Helpers.reparent_node(citizen, parent)


func _ready_bounds_indices_for_HUD() -> void:
	var track_positions : Array = []
	for track_idx in range(num_stage_tracks):
		track_positions.append(_track0_position + track_idx * _tile_height)
	HUD.set_stage_metadata(_tracks_bounds.size.x, moped_rebel.global_position.x, track_positions)


func _ready_NRT_for_moped() -> void:
	for nrt_segment in $NRT.get_children():
		nrt_segment.connect("moped_traveled_nrt", self, "_on_NRT_moped_traveled")


func _ready_sorted_obstacle_positions() -> void:
	for idx in range(num_stage_tracks):
		_sorted_obstacle_positions_by_track.append([])
		
	for elem in $Obstacles.get_children():
		var obstacle_track_idx : int = floor((elem.global_position.y - _track0_position) / _tile_height) - 1
		LOG.info("obstacle {} -> idx {}", [elem.global_position.y, obstacle_track_idx])
		_sorted_obstacle_positions_by_track[obstacle_track_idx].append(elem.global_position)
		
	for idx in range(_sorted_obstacle_positions_by_track.size()):
		var positions_list : Array = _sorted_obstacle_positions_by_track[idx]
		positions_list.sort_custom(Helpers, "sort_positions_x")


func _process(delta: float) -> void:
	HUD.set_stage_progress(moped_rebel.global_position.x)
	var nearest_tracks_obstacles := _build_nearest_track_obstacles_list()
	if (nearest_tracks_obstacles):
		HUD.update_next_obstacle_warning_icons(nearest_tracks_obstacles)
	_process_diss_aim()
	
	
func _process_diss_aim() -> void:
	#check if reticule citizen is passed moped rebel to free it
	if (is_instance_valid(_current_diss_aim)):
		var target_citizen := _current_diss_aim.get_target_citizen()
		if (target_citizen.global_position.x <= moped_rebel.global_position.x):
			_current_diss_aim.queue_free() 
		else:
			#if aim is active and citizen still onscreen then all good
			return
		
	var available_citizens := _get_onscreen_dissable_citizens()
	if (available_citizens):
		#sort citizens desc
		available_citizens.sort_custom(Helpers, "sort_nodes_global_y")
		#use first from top
		_start_aim_citizen(available_citizens[0])
		
		
func _start_aim_citizen(citizen: CitizenRoadBlock) -> void:
	_current_diss_aim = DissAim.instance()
	citizen.add_child(_current_diss_aim)
	#add citizen height to target head
	_current_diss_aim.position = citizen.hearing_area.position

	
func _build_nearest_track_obstacles_list() -> Array:
	var next_obstacle_distances := []
	for track_idx in range(_sorted_obstacle_positions_by_track.size()):
		var obstacle_positions : Array = _sorted_obstacle_positions_by_track[track_idx]
		var next_position_idx := _get_first_idx_position_ahead(obstacle_positions)
		if (next_position_idx >= 0):
			var moped_distance : float = obstacle_positions[next_position_idx].x - moped_rebel.global_position.x
			next_obstacle_distances.append({
				"track_idx": track_idx,
				"obstacle_type": C.ObstacleTypes.ROADBLOCK,
				"moped_distance": moped_distance
			})
	return next_obstacle_distances
	
	
func _get_first_idx_position_ahead(positions: Array) -> int:
	var moped_position : float = moped_rebel.global_position.x
	for idx in range(positions.size()):
		if (positions[idx].x > moped_position):
			return idx
	return -1
	
	
func _on_MopedRebel_swerve_direction_pressed(intended_direction: int) -> void:
	# want to go lowed than last track
	if (intended_direction == 1 and current_moped_track == num_stage_tracks):
		return
	# want to go higher than top track
	if (intended_direction == -1 and current_moped_track == 1):
		return
	
	moped_rebel.perform_swerve(intended_direction, $Road.get_cell_size().y)	
	current_moped_track += intended_direction
	LOG.debug("Swerved moped to track {}!", [current_moped_track])
	
	
func _on_MopedRebel_diss_said(diss_word: DissWord) -> void:
	add_child(diss_word)
	diss_word.global_position = moped_rebel.diss_position.global_position
	
	diss_word.set_target(moped_rebel)
	#there is an actual diss receiver
	if (is_instance_valid(_current_diss_aim)):
		diss_word.set_target(_current_diss_aim)
	#start diss
	diss_word.send_diss()
	#substract diss cost
	HUD.add_sc_points(-C.MR_DISS_SC_COST)

	
func _on_NRT_moped_traveled(
	nrt_num_tiles: int, 
	nrt_travel_points: float, 
	travel_distance: float
) -> void:
	#actual tile size is about half a tile longer than advertised
	var total_nrt_length : float = nrt_num_tiles * (_tile_size.x * 1.5)
	var raw_points : float = travel_distance/total_nrt_length * nrt_travel_points
	var sc_with_bonus : float = State.sc_multiplier * raw_points
	LOG.info("MR gets {}*{} SC points for travelling {}/{} NRT!", [State.sc_multiplier, raw_points, travel_distance, total_nrt_length])
	yield(
		HUD.add_earned_nrt_points_label(moped_rebel.get_global_transform_with_canvas().get_origin(), sc_with_bonus), 
		'completed'
	)
	HUD.add_sc_points(sc_with_bonus)
	
	
func _get_onscreen_dissable_citizens() -> Array:
	var onscreen_dissables : Array = []
	for dissable in get_tree().get_nodes_in_group(C.GROUP_DISSABLES):
		var citizen : CitizenRoadBlock = dissable as CitizenRoadBlock
		if (citizen.visibility_controller.is_on_screen()
			and citizen.global_position.x > moped_rebel.global_position.x):
			onscreen_dissables.append(citizen)
		
	return onscreen_dissables
