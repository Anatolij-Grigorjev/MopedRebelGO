extends Control
"""
Controller for screen with summary after stage.
Controls advance to next screen and shows data
"""

signal tally_forward_pressed


onready var animator: AnimationPlayer = $AnimationPlayer
onready var total_earned_position : Vector2 = $TallyScreen/ScreenBlocks/Sections/TallyArea/TallyRow/Content/Labels/Value.rect_global_position
onready var row_citizens: TallyTableRow = $TallyScreen/ScreenBlocks/Sections/TallyTable/TallyRowCitizens
onready var row_nrts: TallyTableRow = $TallyScreen/ScreenBlocks/Sections/TallyTable/TallyRowNRTs
onready var row_overall_rebel: TallyTableRow = $TallyScreen/ScreenBlocks/Sections/TallyTable/TallyRowOverallRebel


var total_earned_points: float = 0.0


var _forward_pressed: bool = false


func _ready() -> void:
	row_citizens.set_row_label("Citizens dissed:")
	row_nrts.set_row_label("NRT traveled:")
	row_overall_rebel.set_row_label("Overall rebeliousness:")
	pass # Replace with function body.
	
	
func _process(delta: float) -> void:
	if (_forward_pressed):
		return
	
	if (Input.is_action_just_pressed("say_diss")):
		#finish animation quickly when pressed first time
		if (animator.is_playing() && animator.current_animation == "load_screen"):
			animator.seek(7.5, true)
		else:
			emit_signal("tally_forward_pressed")
			_forward_pressed = true
	pass


func set_data(
	citizens_dissed: int,
	citizens_total: int,
	nrt_covered: float,
	nrt_total: float,
	stage_complete_bonus: int
) -> void:
	#generate required label values
	var citizents_value := "%s/%s" % [citizens_dissed, citizens_total]
	var nrt_value := "%d/%d" % [nrt_covered, nrt_total]
	var overall_rebeliousness_calc : float = (
		0.5 * (
			citizens_dissed/citizens_total 
			+ nrt_covered / nrt_total
		))
	var overall_rebeliousness_value := "%04.2f%%" % (overall_rebeliousness_calc * 100.0)
	var overall_points_value := "%04.2f X %d" % [1 + overall_rebeliousness_calc, stage_complete_bonus]
	
	#set required label values
	row_citizens.set_row_value(citizents_value)
	row_nrts.set_row_value(nrt_value)
	row_overall_rebel.set_row_value(overall_rebeliousness_value)
	
	var tally_row := $TallyScreen/ScreenBlocks/Sections/TallyArea/TallyRow
	tally_row.get_node("Content/Labels/Value").text = overall_points_value
	total_earned_points = (overall_rebeliousness_calc + 1.0) * stage_complete_bonus