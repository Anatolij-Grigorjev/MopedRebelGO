tool
extends VBoxContainer

export(String) var section_name: String = "section" setget set_section_name, get_section_name


func set_section_name(name: String) -> void:
	if ($TitleBox/Label):
		$TitleBox/Label.text = name


func get_section_name() -> String:
	if ($TitleBox/Label):
		return $TitleBox/Label.text
	else:
		return section_name
