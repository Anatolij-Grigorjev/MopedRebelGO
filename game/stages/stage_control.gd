class_name StageControl
extends Node2D
"""
A general script for controlling stage aspects like 
- moving moped across tracks
"""
var Logger : Resource = preload("res://utils/logger.gd")
var DissAim: Resource = preload("res://rebel/diss_aim.tscn")
var SummaryScene: Resource = preload("res://gui/tally_screen.tscn")


onready var moped_rebel: MopedRebel = $MopedRebel
onready var LOG: Logger = Logger.new(self)
onready var HUD: HUDController = $CanvasLayer/HUD
onready var start_position: Position2D = $StartPosition


export(String) var stage_name := "test"


onready var _tile_size: Vector2 = $Road.get_cell_size()
onready var _tile_height: int = _tile_size.y

onready var _tracks_bounds := Helpers.get_tilemap_global_bounds($Road)
onready var _track0_position := _tracks_bounds.position.y

var _current_diss_aim: DissAim


func _ready() -> void:
	G.reset_current_stage_stats()
	#adjust track bounds due to specific tile shape
	_tracks_bounds.position.y += _tile_height / 2
	#setup moped position
	moped_rebel.connect('swerve_direction_pressed', self, '_on_MopedRebel_swerve_direction_pressed')
	moped_rebel.connect('diss_target_change_pressed', self, '_on_MopedRebel_diss_target_change_pressed')
	moped_rebel.connect('diss_said', self, '_on_MopedRebel_diss_said')
	moped_rebel.connect("anger_pulse_consumed", HUD, '_on_MopedRebel_anger_pulse_consumed')
	
	#setup track size for progress
	HUD.stage_progress.stage_bounds = Vector2(
		($StartStageCutsceneArea.global_position + $StartStageCutsceneArea.area_extents).x,
		($EndStageCutsceneArea2.global_position - $EndStageCutsceneArea2.area_extents).x
	)
	
	G.current_stage_citizens = get_tree().get_nodes_in_group(C.GROUP_DISSABLES).size()
	#setup citizen signals for stage
	_ready_citizens_for_stage()
	
	#setup NRT signals and total stage NRT length
	_ready_NRT_for_moped()

	#logging
	LOG.info("Tilemap bounds: {}", [_tracks_bounds])
	LOG.info("Moped tracks position: {}", [moped_rebel.global_position])
	if (get_node("/root/LoadingOverlay")):
		get_node("/root/LoadingOverlay").hide()


func _ready_NRT_for_moped() -> void:
	#connect signals and accum NRT distance
	for nrt_segment_node in get_tree().get_nodes_in_group(C.GROUP_NRT):
		var nrt_segment = nrt_segment_node as NonRegulationTrack
		nrt_segment.connect("moped_traveled_nrt", self, "_on_NRT_moped_traveled")
		G.current_stage_NRT_length += nrt_segment.lights_nodes.size()
	G.current_stage_NRT_length *= (_tile_size.x * 1.5)


func _ready_citizens_for_stage() -> void:
	for citizen in get_tree().get_nodes_in_group(C.GROUP_DISSABLES):
		var white_worker := citizen as CitizenRoadBlock
		white_worker.connect("got_dissed", self, "_on_CitizenRoadBlock_got_dissed")


func _process(delta: float) -> void:
	_process_diss_aim()
	
	
func _process_diss_aim() -> void:
	#check if reticule citizen is passed moped rebel to free it
	if (
			is_instance_valid(_current_diss_aim) 
			and _current_diss_aim.has_method('get_target_citizen')
	):
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
	

func _stop_aim_citizen(citizen: CitizenRoadBlock) -> void:
	if (not is_instance_valid(citizen) or not is_instance_valid(_current_diss_aim)):
		return
	if (_current_diss_aim.get_target_citizen() != citizen):
		return
	_current_diss_aim.queue_free()
	_current_diss_aim = null
	
	
func _on_MopedRebel_swerve_direction_pressed(intended_direction: int) -> void:
	var moped_on_tile_idx : Vector2 = $Road.world_to_map(moped_rebel.global_position)
	var moped_next_tile_idx := moped_on_tile_idx + Vector2(0, intended_direction)
	var moped_next_tile_type : int = $Road.get_cellv(moped_next_tile_idx)
	
	#specified direction is an invalid move
	if (moped_next_tile_type == TileMap.INVALID_CELL):
		return
	
	moped_rebel.perform_swerve(intended_direction, _tile_height)
	LOG.debug("Swerved moped {} track to track {}!", [intended_direction, moped_next_tile_idx.y])
	
	
func _on_MopedRebel_diss_target_change_pressed(change_direction: int) -> void:
	var available_citizens := _get_onscreen_dissable_citizens()
	if (not available_citizens):
		return

	#sort citizens desc
	available_citizens.sort_custom(Helpers, "sort_nodes_global_y")
	if (not is_instance_valid(_current_diss_aim)):
		_start_aim_citizen(available_citizens[0])
	else:
		#if citizen not found just aim at first one
		var target_citizen := _current_diss_aim.get_target_citizen()
		var idx := available_citizens.find(target_citizen)
		if (idx < 0):
			_start_aim_citizen(available_citizens[0])
		else:
			_stop_aim_citizen(available_citizens[idx])
			var new_citizen_idx := wrapi(
				idx + change_direction, 
				0, 
				available_citizens.size()
			)
			_start_aim_citizen(available_citizens[new_citizen_idx])
	
	
func _on_MopedRebel_diss_said(diss_word: DissWord) -> void:
	add_child(diss_word)
	diss_word.global_position = moped_rebel.diss_position.global_position
	
	diss_word.set_target(moped_rebel)
	#there is an actual diss receiver
	if (is_instance_valid(_current_diss_aim)):
		diss_word.set_target(_current_diss_aim)
	#start diss
	diss_word.send_diss()

	
func _on_NRT_moped_traveled(nrt_num_tiles: int, nrt_travel_points: float, travel_distance: float) -> void:
	#actual tile size is about half a tile longer than advertised
	var total_nrt_length : float = nrt_num_tiles * (_tile_size.x * 1.5)
	var raw_points : float = travel_distance/total_nrt_length * nrt_travel_points
	LOG.info("MR gets {}*{} SC points for travelling {}/{} NRT!", [HUD.current_multiplier, raw_points, travel_distance, total_nrt_length])
	G.current_stage_NRT_traveled += travel_distance
	HUD.add_earned_points(
		moped_rebel.get_global_transform_with_canvas().get_origin(), 
		raw_points
	)
	
	
func _on_CitizenRoadBlock_got_dissed(worker: CitizenRoadBlock) -> void:
	G.current_stage_citizens_dissed += 1
	var citizen_origin : Vector2 = worker.get_global_transform_with_canvas().get_origin()
	HUD.add_earned_points(
		citizen_origin, 
		C.DISS_CITIZEN_BONUS
	)
	
	
func _get_onscreen_dissable_citizens() -> Array:
	var onscreen_dissables : Array = []
	for dissable in get_tree().get_nodes_in_group(C.GROUP_DISSABLES):
		var citizen : CitizenRoadBlock = dissable as CitizenRoadBlock
		var citizen_visibility: VisibilityNotifier2D = citizen.visibility_controller
		if (citizen_visibility.is_on_screen()
			and not citizen.is_dissed()
			and citizen_visibility.global_position.x > moped_rebel.global_position.x):
			onscreen_dissables.append(citizen)
		
	return onscreen_dissables


func _toggle_ui_elements_visible(visible: bool) -> void:
	$CanvasLayer/HUD.visible = visible
	if (is_instance_valid(_current_diss_aim)):
		_current_diss_aim.visible = visible


func _start_moped_stage_intro(cutscene_trigger: int) -> void:
	_toggle_ui_elements_visible(false)
	var stage_position := start_position.global_position
	var mover_tween : Tween = $Tween
	
	mover_tween.interpolate_property(moped_rebel, 'global_position',
		null, stage_position, 2.0, 
		Tween.TRANS_LINEAR, Tween.EASE_OUT_IN
	)
	mover_tween.start()
	yield(mover_tween, "tween_all_completed")
	_toggle_ui_elements_visible(true)
	
	
func _start_moped_stage_outro(cutscene_trigger: int) -> void:
	if (StageCutsceneArea.CutsceneTrigger.ENTRY == cutscene_trigger):
		_toggle_ui_elements_visible(false)
		yield(get_tree().create_timer(10.0), "timeout")
		G.reset_current_stage_stats()

	else:
		#passed end of outro
		LOG.info("stage finished! tally up!")
		_toggle_ui_elements_visible(false)
		if (not C.STAGE_COMPLETION_BONUS.has(stage_name)):
			LOG.error("stage bonus not found for '{}'", [stage_name])
		var stage_bonus : float = C.STAGE_COMPLETION_BONUS[stage_name]
		var tally_screen = SummaryScene.instance()
		tally_screen.set_stats_data(
			G.current_stage_citizens_dissed,
			G.current_stage_citizens,
			G.current_stage_NRT_traveled,
			G.current_stage_NRT_length,
			stage_bonus
		)
		$CanvasLayer.add_child_below_node($CanvasLayer/SummaryTablePosition, tally_screen)
		yield(tally_screen, "tally_forward_pressed")
		if (tally_screen.total_earned_points > 0 and G.current_street_scred < C.MR_MAX_SC):
			var earned_points : float = tally_screen.total_earned_points
			#make only progress bar visible
			HUD.visible = true
			HUD.stage_progress.visible = false
			HUD.timed_bonus.visible = false
			
			HUD.add_earned_points(
				tally_screen.total_earned_position, 
				earned_points, 
				HUD.sc_progress.sc_points_label.rect_position - tally_screen.total_earned_position
			)
			yield(HUD, "points_update_done")
			
		#wait before transition
		tally_screen.centered_button.modulate.a = 0.0
		yield(get_tree().create_timer(1.2), "timeout")
		LoadingScreen.load_scene(C.STAGE_SELECT_SCENE_PATH)