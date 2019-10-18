extends Control
class_name EarnedPoints
"""
This controller instantiates a label of number formatted as points
Then that label floats to a predefined position via tween,
reducing in scale dimensions as it goes along
"""
var Logger : Resource = preload("res://utils/logger.gd")


const REDUCE_TIME : float = 1.0


onready var LOG: Logger = Logger.new(self)
onready var points_text: Label = $PointsText
onready var tween : Tween = $MoveToPoints


func set_num_points(earned_points: float) -> void:
	points_text.text = "%02.2f" % earned_points
	
	
func start_reduce_to_point(end_point: Vector2) -> void:
	tween.interpolate_property(
		self, 'rect_position', 
		rect_position, end_point, 
		REDUCE_TIME, 
		Tween.TRANS_LINEAR, Tween.EASE_OUT
	)
	tween.interpolate_property(
		self, 'points_text:rect_scale',
		points_text.rect_scale, Vector2.ZERO,
		REDUCE_TIME,
		Tween.TRANS_EXPO,
		Tween.EASE_OUT
	)
	tween.start()