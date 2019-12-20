tool
extends Control
class_name EarnedPoints
"""
This controller instantiates a label of number formatted as points
Then that label floats to a predefined position via tween,
reducing in scale dimensions as it goes along
"""
const REDUCE_TIME : float = 1.0


export(Vector2) var end_point: Vector2 = Vector2.ZERO
export(float) var num_points = 0.0 setget _set_num_points, _get_num_points
export(float) var multiplier = 1.0 setget _set_multiplier, _get_multiplier


onready var points_text: Label = $HBoxContainer/PointsText
onready var mult_text: Label = $HBoxContainer/MultiplierText
onready var tween : Tween = $MoveToPoints


func _ready() -> void:
	_start_reduce_to_point()
	if (multiplier != 1.0):
		$AnimationPlayer.play("bonus_flicker")
	yield(tween, "tween_all_completed")
	queue_free()


func _set_num_points(earned_points: float) -> void:
	
	num_points = earned_points
	if ($HBoxContainer/PointsText):
		var label = $HBoxContainer/PointsText
		if (earned_points > 0):
			label.text = "+%02.2f" % earned_points
			label.set("custom_colors/font_color", Color.yellow)
		else:
			label.text = "%02.2f" % earned_points
			label.set("custom_colors/font_color", Color.red)
		
		
func _get_num_points() -> float:
	return num_points
	
	
func _get_multiplier() -> float:
	return multiplier
	
	
func _set_multiplier(new_mult: float) -> void:
	multiplier = new_mult
	if ($HBoxContainer/MultiplierText):
		var mult_text := $HBoxContainer/MultiplierText
		mult_text.text = "X %01.1f" % new_mult
		mult_text.visible = multiplier != 1.0


func _start_reduce_to_point() -> void:
	
	tween.interpolate_property(
		self, 'rect_position', 
		null, end_point, 
		REDUCE_TIME, 
		Tween.TRANS_LINEAR, Tween.EASE_OUT_IN
	)
	
	#only start reducing size in last 40% of thing
	var time_portion_wait_reduce : float = REDUCE_TIME * 0.6
	#wait an extra second with bigger bonus
	if (multiplier > 1.0):
		time_portion_wait_reduce += 1.0
	tween.interpolate_property(
		self, 'rect_scale',
		null, Vector2(0.1, 0.1),
		REDUCE_TIME - time_portion_wait_reduce,
		Tween.TRANS_LINEAR, Tween.EASE_OUT_IN,
		time_portion_wait_reduce
	)
	tween.start()