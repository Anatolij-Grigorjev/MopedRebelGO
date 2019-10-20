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


func _ready() -> void:
	pass


func set_num_points(earned_points: float) -> void:
	points_text.text = "+%02.2f" % earned_points


func start_reduce_to_point(end_point: Vector2) -> void:
	tween.interpolate_property(
		self, 'rect_position', 
		null, end_point, 
		REDUCE_TIME, 
		Tween.TRANS_LINEAR, Tween.EASE_OUT_IN
	)
	
	#only start reducing size in last 40% of thing
	var time_portion_wait_reduce : float = REDUCE_TIME * 0.6
	tween.interpolate_property(
		self, 'points_text:rect_scale',
		null, Vector2(0.1, 0.1),
		REDUCE_TIME - time_portion_wait_reduce,
		Tween.TRANS_LINEAR, Tween.EASE_OUT_IN,
		time_portion_wait_reduce
	)
	tween.start()