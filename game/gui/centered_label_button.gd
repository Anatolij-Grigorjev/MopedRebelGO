@tool
extends CenterContainer
class_name CenteredLabelButton
"""
Controller for flashing label-based button control
"""

signal button_pressed

@export var button_label: String = "Press 'DISS' button...": get = get_button_text, set = set_button_text
@export var press_action: String = "say_diss"


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
