extends Node2D
class_name StageCutsceneArea
"""
Controller for in-stage cutscenes that triggers when MR enters or exits
the appointed area. 
This stops player control and lets the area camera frame the action
The area requires a specified node wit ha function to start the cutscene
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
export(NodePath) var cutscene_routine_owner 
"""
This routine gets fired for cutscenes and should support 1 argument:
	- area captive position (entry or exit)
"""
export(String) var cutscene_routine_name






func _ready():
	pass


func _on_Area2D_area_entered(area: Area2D) -> void:
	_process_cutscene_for_trigger(area, CutsceneTrigger.ENTRY)


func _on_Area2D_area_exited(area: Area2D) -> void:
	_process_cutscene_for_trigger(area, CutsceneTrigger.EXIT)
	
	
func _process_cutscene_for_trigger(area: Area2D, trigger: int) -> void:
	if (not _can_use_trigger(trigger)):
		return
	if (_cutscene_provider_missing()):
		return
	if (not area.is_in_group(C.GROUP_MR)):
		return
		
	var moped_rebel := area.owner as MopedRebel
	moped_rebel.disable_player_control()
	$Camera2D.current = true
	yield(
		cutscene_routine_owner.call(cutscene_routine_name, trigger),
		"completed"
	)
	$Camera2D.current = false
	moped_rebel.enable_player_control()


"""
actual param type should be CutsceneTrigger
"""
func _can_use_trigger(current_phase:int) -> bool:
	return (start_cutscene_on == CutsceneTrigger.BOTH 
			or current_phase == start_cutscene_on)
			
			
func _cutscene_provider_missing() -> bool:
	return (not is_instance_valid(cutscene_routine_owner)
			or Helpers.is_blank(cutscene_routine_name))
