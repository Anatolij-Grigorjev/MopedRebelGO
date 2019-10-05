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


var _upper_tracks_pos : Vector2


func _ready() -> void:
	moped_rebel.connect('swerve_direction_pressed', self, '_on_MopedRebel_swerve_direction_pressed')
	var tracks_bounds := Helpers.get_tilemap_global_bounds($Road)
	LOG.info("Tilemap bounds: {}", [tracks_bounds])
	var moped_tracks_offset : int = ($Road.get_cell_size().y) * current_moped_track
	moped_rebel.global_position.y = tracks_bounds.position.y + moped_tracks_offset
	LOG.info("Moped tracks position: {}", [moped_rebel.global_position])
	HUD.set_stage_size(tracks_bounds.size.x, moped_rebel.global_position.x)
	for nrt_segment in $NRT.get_children():
		nrt_segment.connect("moped_traveled", self, "_on_NRT_moped_traveled")


func _process(delta: float) -> void:
	HUD.set_stage_progress(moped_rebel.global_position.x)
	pass
	
	
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
