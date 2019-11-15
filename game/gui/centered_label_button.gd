extends CenterContainer
class_name CenteredLabelButton
"""
Controller for flashing label-based button control
"""

signal button_pressed

export(String) var button_label = "Press 'DISS' button..."
export(String) var press_action = "say_diss"


func _ready():
	pass # Replace with function body.

func _process(delta: float) -> void: 
	if (Input.is_action_just_pressed(press_action)):
		emit_signal("button_pressed")
