extends Node2D
class_name StageControl
"""
A general script for controlling stage aspects like 

- moving moped across tracks
"""
var Logger : Resource = preload("res://utils/logger.gd")


onready var moped_rebel: MopedRebel = $MopedRebel
onready var LOG: Logger = Logger.new(self)
onready var State : GameState = get_node("/root/G")
onready var HUD: HUDController = $CanvasLayer/HUD


export(int) var num_stage_tracks := 5
export(int) var current_moped_track := 3


var _sorted_obstacle_positions_by_track := []
onready var _tile_height: int = $Road.get_cell_size().y

onready var _tracks_bounds := Helpers.get_tilemap_global_bounds($Road)
onready var _track0_position := _tracks_bounds.position.y


func _ready() -> void:
	#adjust track bounds due to specific tile shape
	_tracks_bounds.position.y += _tile_height / 2
	#setup moped position
	moped_rebel.connect('swerve_direction_pressed', self, '_on_MopedRebel_swerve_direction_pressed')
	var moped_tracks_offset : int = _tile_height * current_moped_track
	moped_rebel.global_position.y = _track0_position + moped_tracks_offset
	
	#setup track positions for HUD warnings
	_ready_bounds_indices_for_HUD()
	
	#setup NRT signals
	_ready_NRT_for_moped()
	
	#setup obstacle positions lines
	_ready_sorted_obstacle_positions()

	#logging
	LOG.info("Tilemap bounds: {}", [_tracks_bounds])
	LOG.info("Moped tracks position: {}", [moped_rebel.global_position])
	for idx in range(_sorted_obstacle_positions_by_track.size()):
		LOG.info("For track {} got {} obstacles!", [idx, _sorted_obstacle_positions_by_track[idx].size()])


func _ready_bounds_indices_for_HUD() -> void:
	var track_positions : Array = []
	for track_idx in range(num_stage_tracks):
		track_positions.append(_track0_position + track_idx * _tile_height)
	HUD.set_stage_metadata(_tracks_bounds.size.x, moped_rebel.global_position.x, track_positions)


func _ready_NRT_for_moped() -> void:
	for nrt_segment in $NRT.get_children():
		nrt_segment.connect("moped_traveled", self, "_on_NRT_moped_traveled")		


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
	
	
func _on_NRT_moped_traveled(distance: float) -> void:
	var raw_points : float = distance * C.MR_SC_PER_TRACK_UNIT
	var sc_with_bonus : float = State.sc_multiplier * raw_points
	LOG.info("MR gets {} SC points for travelling {} NRT!", [sc_with_bonus, distance])
	HUD.add_sc_points(sc_with_bonus)
