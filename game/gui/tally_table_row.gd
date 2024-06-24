extends HBoxContainer
class_name TallyTableRow
"""
Individual row controller that sets row label and value
"""


@onready var row_label: Label = $Content/Labels/Label
@onready var row_value: Label = $Content/Labels/Value


func _ready():
	pass # Replace with function body.

func set_row_data(label: String, value: String) -> void:
	row_label.text = label
	row_value.text = value
	

func set_row_label(label: String) -> void:
	row_label.text = label
	

func set_row_value(value: String) -> void:
	row_value.text = value