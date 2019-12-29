tool
extends CenterContainer
class_name CenteredLabelButton
"""
Controller for flashing label-based button control
"""

signal button_pressed

export(String) var button_label = "Press 'DISS' button..." setget set_button_text, get_button_text
export(String) var press_action = "say_diss"


func _process(delta: float) -> void: 
	if (Input.is_action_just_pressed(press_action)):
		emit_signal("button_pressed")
		set_button_text("PRESSED!")
		$AnimationPlayer.stop()


func set_button_text(text: String) -> void:
	if ($PressButtonLabel):
		$PressButtonLabel.text = text
		
		
func get_button_text() -> String:
	if ($PressButtonLabel):
		return $PressButtonLabel.text
	else:
		return button_label