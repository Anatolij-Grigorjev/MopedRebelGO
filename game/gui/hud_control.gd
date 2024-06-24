extends Control
class_name HUDController
"""
Orchestration of various HUD elements and making sure data/signals intended
for them reach them from this single point of entry
"""
var EarnedPoints : Resource = preload("res://gui/earned_points.tscn")


signal points_update_done


@export var debug_enabled := false


#components
@onready var sc_progress: SCProgressTracker = $MarginContainer/HBox/SCProgressTracker
@onready var timed_bonus: TimedBonus = $MarginContainer/HBox/TimedBonus
@onready var stage_progress: StageProgressBar = $MarginContainer/HBox/ReferenceRect/StageProgress


var current_multiplier: float: get = get_current_multiplier


func _ready():
	sc_progress.sc_points_label.connect("points_anim_done", Callable(self, "_on_SCPointsLabel_points_anim_done"))
	sc_progress.connect("levelup_ready", Callable(self, "_on_SCProgressTracker_levelup_ready"))
	

func _process(delta: float) -> void:
	if (debug_enabled):
		if (Input.is_action_just_pressed("debug1")):
			var add_points := 200
			var rand_position = Vector2(
				randf_range(100, C.GAME_RESOLUTION.x - 100),
				randf_range(50, C.GAME_RESOLUTION.y - 50)
			)
			print("earned points pos: %s" % rand_position)
			add_earned_points(rand_position, add_points)
			
		if (Input.is_action_just_pressed("debug2")):
			var add_mult := randf()
			_add_multiplier(add_mult)
	
	
func add_earned_points(from_canvas_position: Vector2, points: float, move_offset = Vector2(0, -50)) -> void:
	await _add_earned_points_at_origin_label(from_canvas_position, points, move_offset).tree_exiting
	add_raw_points(points)
		
		
func add_raw_points(base_amount: float) -> void:
	var actual_points := _get_actual_points(base_amount)
	sc_progress.set_sc_points(G.current_street_scred + actual_points)
		
		
func get_current_multiplier() -> float:
	return timed_bonus.current_value
	
	
func _get_actual_points(base_amount: float) -> float:
	#only apply multiplier to positive points
	if (base_amount > 0):
		return base_amount * timed_bonus.current_value
	else:
		return base_amount


func _add_multiplier(additive: float) -> void:
	if (additive != 0.0):
		var current_mult = timed_bonus.current_value
		timed_bonus.set_value(current_mult + additive)


"""
Create earned points marker at base of rebel wheels and send that marker 
to main current points label on HUD
"""
func _add_earned_points_at_origin_label(from_position: Vector2, earned_points: float, move_offset = Vector2(0, -50)) -> EarnedPoints:
	var earned_node : EarnedPoints = EarnedPoints.instantiate()
	earned_node.move_offset = move_offset
	earned_node.multiplier = timed_bonus.current_value
	earned_node.num_points = earned_points
	earned_node.position = from_position
	
	add_child(earned_node)
	
	return earned_node
	
	
func _on_MopedRebel_anger_pulse_consumed(multiplier_add: float) -> void:
	_add_multiplier(multiplier_add)
	
	
func _on_SCPointsLabel_points_anim_done() -> void:
	emit_signal("points_update_done")
	
	
func _on_SCProgressTracker_levelup_ready(levelup_node: Node) -> void:
	var parent = get_parent() if is_instance_valid(get_parent()) else self
	parent.add_child(levelup_node)
