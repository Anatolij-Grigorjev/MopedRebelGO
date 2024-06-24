extends Control
"""
Controller for screen with summary after stage.
Controls advance to next screen and shows data
"""
var Logger : Resource = preload("res://utils/logger.gd")


signal tally_forward_pressed


onready var LOG: Logger = Logger.new(self)
onready var animator: AnimationPlayer = $AnimationPlayer
onready var total_earned_position : Vector2 = $TallyScreen/ScreenBlocks/Sections/TallyArea/TallyRow/Content/Labels/Value.rect_global_position
onready var row_citizens: TallyTableRow = $TallyScreen/ScreenBlocks/Sections/TallyTable/TallyRowCitizens
onready var row_nrts: TallyTableRow = $TallyScreen/ScreenBlocks/Sections/TallyTable/TallyRowNRTs
onready var row_overall_rebel: TallyTableRow = $TallyScreen/ScreenBlocks/Sections/TallyTable/TallyRowOverallRebel
onready var centered_button: CenteredLabelButton = $TallyScreen/ScreenBlocks/ButtonContainer


var total_earned_points: float = 0.0


var _forward_pressed: bool = false
var _stats_data: Dictionary = {}
var _load_screen_animation_length: float


func _init():
	set_stats_data(4, 8, 450, 700, 450)


func _ready() -> void:
	row_citizens.set_row_label("Citizens dissed:")
	row_nrts.set_row_label("NRT traveled:")
	row_overall_rebel.set_row_label("Overall rebeliousness:")
	_apply_stored_data()
	_load_screen_animation_length = animator.get_animation("load_screen").length
	centered_button.connect("button_pressed", self, "_on_ButtonContainer_button_pressed")


func _on_ButtonContainer_button_pressed() -> void:
	if (_forward_pressed):
		return
		
	if (animator.is_playing() && animator.current_animation == "load_screen"):
		animator.seek(_load_screen_animation_length, true)
	else:
		emit_signal("tally_forward_pressed")
		_forward_pressed = true


func set_stats_data(
	citizens_dissed: float,
	citizens_total: float,
	nrt_covered: float,
	nrt_total: float,
	stage_complete_bonus: int
) -> void:
	_stats_data['citizens_dissed'] = citizens_dissed
	_stats_data['citizens_total'] = citizens_total
	_stats_data['nrt_covered'] = nrt_covered
	_stats_data['nrt_total'] = nrt_total
	_stats_data['stage_complete_bonus'] = stage_complete_bonus
	
	
func _apply_stored_data() -> void:
	var citizens_dissed: float = _stats_data.citizens_dissed
	var citizens_total: float = _stats_data.citizens_total
	var nrt_covered: float = _stats_data.nrt_covered
	var nrt_total: float = _stats_data.nrt_total
	var stage_complete_bonus: int = _stats_data.stage_complete_bonus
	
	#generate required label values
	var citizents_value := "%s/%s" % [citizens_dissed, citizens_total]
	var nrt_value := "%d/%d" % [nrt_covered, nrt_total]
	var overall_rebeliousness_calc : float = (
		0.75 * (citizens_dissed/citizens_total) 
		+ 
		0.25 * (nrt_covered / nrt_total)
	)
	LOG.info("0.75 * {} + 0.25 * {} = {}", [citizens_dissed/citizens_total, nrt_covered / nrt_total, overall_rebeliousness_calc])
	var overall_rebeliousness_value := "%04.2f%%" % (overall_rebeliousness_calc * 100.0)
	
	#set required label values
	row_citizens.set_row_value(citizents_value)
	row_nrts.set_row_value(nrt_value)
	row_overall_rebel.set_row_value(overall_rebeliousness_value)
	
	var overall_points_value := "%04.2f X %d" % [1 + overall_rebeliousness_calc, stage_complete_bonus]
	var tally_row := $TallyScreen/ScreenBlocks/Sections/TallyArea/TallyRow
	tally_row.get_node("Content/Labels/Value").text = overall_points_value
	
	total_earned_points = (overall_rebeliousness_calc + 1.0) * stage_complete_bonus
