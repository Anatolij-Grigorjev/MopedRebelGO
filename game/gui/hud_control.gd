extends Control
class_name HUDController
"""
Orchestration of various HUD elements and making sure data/signals intended
for them reach them from this single point of entry
"""
var EarnedPoints : Resource = preload("res://gui/earned_points.tscn")


export(bool) var debug_enabled := false


#components
onready var sc_progress: SCProgressTracker = $MarginContainer/HBox/SCProgressTracker
onready var timed_bonus: TimedBonus = $MarginContainer/HBox/VBoxContainer/TimedBonus
onready var stage_progress: StageProgressBar = $MarginContainer/HBox/ReferenceRect/StageProgress


func _ready():
	pass
	

func _process(delta: float) -> void:
	if (debug_enabled):
		if (Input.is_action_just_pressed("debug1")):
			var add_points := 200
			var rand_position = Vector2(
				rand_range(100, C.GAME_RESOLUTION.x - 100),
				rand_range(50, C.GAME_RESOLUTION.y - 50)
			)
			print("earned points pos: %s" % rand_position)
			add_earned_points(rand_position, add_points)
			
		if (Input.is_action_just_pressed("debug2")):
			var add_mult := randf()
			add_multiplier(add_mult)
	pass
		
		
func add_raw_points(base_amount: float) -> void:
	var actual_points := _get_actual_points(base_amount)
	sc_progress.set_sc_points(G.current_street_scred + actual_points)
	
	
func add_multiplier(additive: float) -> void:
	if (additive != 0.0):
		var current_mult = timed_bonus.current_value
		timed_bonus.set_value(current_mult + additive)
	
	
func _get_actual_points(base_amount: float) -> float:
	return base_amount * timed_bonus.current_value


"""
Create earned points marker at base of rebel wheels and send that marker 
to main current points label on HUD
"""
func _add_earned_points_at_origin_label(from_position: Vector2, earned_points: float) -> EarnedPoints:
	var earned_node : EarnedPoints = EarnedPoints.instance()
	earned_node.end_point = sc_progress.sc_points_label.rect_position
	earned_node.multiplier = timed_bonus.current_value
	earned_node.num_points = earned_points
	earned_node.rect_position = from_position
	
	add_child(earned_node)
	
	return earned_node
	
	
func add_earned_points(from_canvas_position: Vector2, points: float) -> void:
	yield(_add_earned_points_at_origin_label(from_canvas_position, points), "tree_exiting")
	add_raw_points(points)