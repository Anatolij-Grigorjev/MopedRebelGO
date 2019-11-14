extends RoadBlock
class_name CitizenRoadBlock
"""
Controller for road blocking citizen. Stops moped rebel just like roadblocks but also
gets knocked over and responds to disses beng thrown around
"""
var AngerPulse: Resource = preload("res://obstacles/citizens/anger_pulse.tscn")


export(int) var disses_required: int = 2
export(float) var diss_mult_add_pulse: float = 0.3


onready var animator: AnimationPlayer = $AnimationPlayer
onready var dissed_progress : ProgressBar = $ProgressBar
onready var visibility_controller: VisibilityNotifier2D = $VisibilityNotifier2D
onready var hearing_area: Area2D = $Hearing


var _disses_heard : int = 0 


func _ready() -> void:
	_update_diss_progress()
	
	
func is_dissed() -> bool:
	return disses_required <= _disses_heard
	

func _on_area_entered(area: Area2D):
	._on_area_entered(area)
	LOG.debug("citizen caught area {}", [area])
	if (area.is_in_group(C.GROUP_MR)):
		_remove_target()
		animator.play("hit_by_moped")
		
		
func _remove_target() -> void:
	if (is_instance_valid($DissAim)):
		$DissAim.visible = false
		$DissAim.queue_free()


func _on_Hearing_area_entered(area: Area2D):
	if (_disses_heard >= disses_required or 
		not area.is_in_group(C.GROUP_DISS_WORD)):
		return
		
	_disses_heard += 1
	_update_diss_progress()
	if (_disses_heard >= disses_required):
		_remove_target()
		G.current_stage_citizens_dissed += 1
		animator.play("be_dissed")
		
		
		
func _update_diss_progress() -> void:
	dissed_progress.value = _disses_heard
	dissed_progress.visible = _disses_heard > 0 and _disses_heard < disses_required
	

func _build_anger_pulse_direction(direction: int) -> void:
	var anger_pulse_node = AngerPulse.instance()
	anger_pulse_node.scale = Vector2(direction, 1)
	anger_pulse_node.set_sc_mult_add(diss_mult_add_pulse)
	add_child(anger_pulse_node)
	
	
func _build_anger_pulses() -> void:
	_build_anger_pulse_direction(C.DIRECTION.LEFT)
	_build_anger_pulse_direction(C.DIRECTION.RIGHT)
