extends RoadBlock
class_name CitizenRoadBlock
"""
Controller for road blocking citizen. Stops moped rebel just like roadblocks but also
gets knocked over and responds to disses beng thrown around
"""
export(float) var sc_multiplier : float = 1.4
export(int) var disses_required: int = 2


onready var animator: AnimationPlayer = $AnimationPlayer
onready var dissed_progress : ProgressBar = $ProgressBar


var _disses_heard : int = 0 

func _ready() -> void:
	_update_diss_progress()
	

func _on_area_entered(area: Area2D):
	._on_area_entered(area)
	LOG.debug("citizen caught area {}", [area])
	if (area.is_in_group(C.GROUP_MR)):
		animator.play("hit_by_moped")


func _on_Hearing_area_entered(area: Area2D):
	if (_disses_heard >= disses_required or 
		not area.is_in_group(C.GROUP_DISS_WORD)):
		return
		
	_disses_heard += 1
	_update_diss_progress()
	if (_disses_heard >= disses_required):
		animator.play("be_dissed")
		G.sc_multiplier *= sc_multiplier
		
		
func _update_diss_progress() -> void:
	dissed_progress.value = _disses_heard
	dissed_progress.visible = _disses_heard > 0 and _disses_heard < disses_required
