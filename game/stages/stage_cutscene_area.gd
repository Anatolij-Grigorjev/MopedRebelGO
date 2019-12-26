extends Node2D
class_name StageCutsceneArea
"""
Controller for in-stage cutscenes that triggers when MR enters or exits
the appointed area. 
This stops player control and lets the area camera frame the action
The area requires a specified node with a function to start the cutscene
it will wait until this completes before returning control to player
"""
var Logger : Resource = preload("res://utils/logger.gd")

enum CutsceneTrigger {
	ENTRY = 0,
	EXIT = 1,
	BOTH = 2
}

onready var LOG: Logger = Logger.new(self)


export(CutsceneTrigger) var start_cutscene_on := CutsceneTrigger.ENTRY
export(NodePath) var cutscene_routine_owner_path 
"""
This routine gets fired for cutscenes and should support 1 argument:
	- area captive position (entry or exit)
"""
export(String) var cutscene_routine_name
export(bool) var return_control_after = true


onready var area_extents: Vector2 = $Area2D/CollisionShape2D.shape.extents



func _ready():
	pass


func _on_Area2D_area_entered(area: Area2D) -> void:
	LOG.info("Got area {} to enter cutscene area {}", [area.name, name])
	_process_cutscene_for_trigger(area, CutsceneTrigger.ENTRY)


func _on_Area2D_area_exited(area: Area2D) -> void:
	_process_cutscene_for_trigger(area, CutsceneTrigger.EXIT)
	
	
func _process_cutscene_for_trigger(area: Area2D, trigger: int) -> void:
	if (not _can_use_trigger(trigger)):
		LOG.info("cutscene {} skipped because trigger {} not set!", [name, trigger])
		return
	if (_cutscene_provider_missing()):
		LOG.info("cutscene {} skipped because cutscene method and node not set!", [name])
		return
	if (not area.is_in_group(C.GROUP_MR)):
		LOG.info("cutscene {} skipped since area {} is not part of moped rebel!", [name, area.name])
		return
	LOG.info("trigger cutscene on {} for area {}", [trigger, area])
	var moped_rebel := area.owner as MopedRebel
	moped_rebel.disable_player_control()
	$Camera2D.current = true
	var cutscene_routine_owner : Node = get_node(cutscene_routine_owner_path)
	yield(
		cutscene_routine_owner.call(cutscene_routine_name, trigger),
		"completed"
	)
	if (return_control_after):
		$Camera2D.current = false
		moped_rebel.enable_player_control()


"""
actual param type should be CutsceneTrigger
"""
func _can_use_trigger(current_phase:int) -> bool:
	return (start_cutscene_on == CutsceneTrigger.BOTH 
			or current_phase == start_cutscene_on)
			
			
func _cutscene_provider_missing() -> bool:
	return (not is_instance_valid(get_node(cutscene_routine_owner_path))
			or Helpers.is_blank(cutscene_routine_name))
