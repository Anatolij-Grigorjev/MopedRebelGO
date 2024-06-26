@tool
extends Control
class_name EarnedPoints
"""
This controller instantiates a label of number formatted as points
Then that label floats to a predefined position via tween,
reducing in scale dimensions as it goes along
"""
const DEFAULT_TTL:float = 1.0


@export var move_offset: Vector2 = Vector2.ZERO
@export var ttl: float = DEFAULT_TTL
@export var num_points: float = 0.0: set = _set_num_points
@export var multiplier: float = 1.0: set = _set_multiplier


@onready var points_text: Label = $HBoxContainer/PointsText
@onready var mult_text: Label = $HBoxContainer/MultiplierText
@onready var tween : Tween = get_tree().create_tween()


func _ready() -> void:
	_start_move_tween()
	if (multiplier != 1.0):
		$AnimationPlayer.play("bonus_flicker")
	await tween.tween_all_completed
	queue_free()


func _set_num_points(earned_points: float) -> void:
	
	num_points = earned_points
	if ($HBoxContainer/PointsText):
		var label = $HBoxContainer/PointsText
		if (earned_points > 0):
			label.text = "+%02.2f" % earned_points
			label.set("theme_override_colors/font_color", Color.YELLOW)
		else:
			label.text = "%02.2f" % earned_points
			label.set("theme_override_colors/font_color", Color.RED)
	
	
func _set_multiplier(new_mult: float) -> void:
	multiplier = new_mult
	ttl = DEFAULT_TTL * new_mult
	if ($HBoxContainer/MultiplierText):
		var mult_text := $HBoxContainer/MultiplierText
		mult_text.text = "X %01.1f" % new_mult
		mult_text.visible = multiplier != 1.0


func _start_move_tween() -> void:
	
	tween.interpolate_property(
		self, 'position', 
		null, position + move_offset, 
		ttl, 
		Tween.TRANS_LINEAR, Tween.EASE_OUT_IN
	)
	tween.start()
