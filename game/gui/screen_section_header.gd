@tool
extends VBoxContainer

@export var section_name: String = "section": get = get_section_name, set = set_section_name


func set_section_name(name: String) -> void:
	if ($TitleBox/Label):
		$TitleBox/Label.text = name


func get_section_name() -> String:
	if ($TitleBox/Label):
		return $TitleBox/Label.text
	else:
		return section_name
