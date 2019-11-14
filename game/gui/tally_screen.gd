extends Control
"""
Controller for screen with summary after stage.
Controls advance to next screen and shows data
"""

signal tally_forward_pressed


onready var animator: AnimationPlayer = $AnimationPlayer
onready var total_earned_position : Vector2 = $TallyScreen/ScreenBlocks/Sections/TallyArea/TallyRow/Content/Labels/Value.rect_global_position


var total_earned_points: float = 0.0


var _forward_pressed: bool = false


func _ready() -> void:
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
	var citizens_row := $TallyScreen/ScreenBlocks/Sections/TallyTable/TallyRowCitizens
	citizens_row.get_node("Content/Labels/Value").text = citizents_value
	var nrt_row := $TallyScreen/ScreenBlocks/Sections/TallyTable/TallyRowNRTs
	nrt_row.get_node("Content/Labels/Value").text = nrt_value
	var overall_rebel_row := $TallyScreen/ScreenBlocks/Sections/TallyTable/TallyRowOverallRebel
	overall_rebel_row.get_node("Content/Labels/Value").text = overall_rebeliousness_value
	var tally_row := $TallyScreen/ScreenBlocks/Sections/TallyArea/TallyRow
	tally_row.get_node("Content/Labels/Value").text = overall_points_value
	total_earned_points = (overall_rebeliousness_calc + 1.0) * stage_complete_bonus