extends RoadBlock
class_name CitizenRoadBlock
"""
Controller for road blocking citizen. Stops moped rebel just like roadblocks but also
gets knocked over and responds to disses beng thrown around
"""
export(float) var sc_multiplier : float = 1.4
export(int) var disses_required: int = 2


onready var animator: AnimationPlayer = $AnimationPlayer


var _disses_heard : int = 0


func _on_area_entered(area: Area2D):
	._on_area_entered(area)
	LOG.debug("citizen caught area {}", [area])
	if (area.is_in_group(C.GROUP_MR)):
		animator.play("hit_by_moped")


