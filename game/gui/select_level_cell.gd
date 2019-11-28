tool
extends Control
class_name SelectLevelCell
"""
Cell that means a level in a menu. Includes reference to level scene
is selectable
"""

export(PackedScene) var level_scene: PackedScene
export(Texture) var level_thumbnail: Texture setget set_level_thumb, get_level_thumb
export(String) var level_name: String = "test" setget set_level_name, get_level_name
export(bool) var selected: bool = false setget set_selected


func set_level_thumb(thumb: Texture) -> void:
	if ($SelectedBorder/VBoxContainer/ThumbnailMarginContainer/Thumbnail):
		$SelectedBorder/VBoxContainer/ThumbnailMarginContainer/Thumbnail.texture = thumb
		
		
func get_level_thumb() -> Texture:
	if ($SelectedBorder/VBoxContainer/ThumbnailMarginContainer/Thumbnail):
		return $SelectedBorder/VBoxContainer/ThumbnailMarginContainer/Thumbnail.texture
	else:
		return null


func get_level_name() -> String:
	var level_name_label: Label = $SelectedBorder/VBoxContainer/LabelMarginContainer/Label
	if (level_name_label):
		return level_name_label.text
	else:
		return ""
		
		
func set_level_name(name: String) -> void:
	var level_name_label: Label = $SelectedBorder/VBoxContainer/LabelMarginContainer/Label
	if (level_name_label):
		level_name_label.text = name


func set_selected(is_selected: bool) -> void:
	var level_name_label: Label = $SelectedBorder/VBoxContainer/LabelMarginContainer/Label
	var thumbnail_cover: Control = $SelectedBorder/VBoxContainer/ThumbnailMarginContainer/Cover
	var select_border: Control = $SelectedBorder
	selected = is_selected
	if (selected):
		level_name_label.modulate = Color.red
		thumbnail_cover.visible = true
		select_border.self_modulate.a = 255
	else:
		level_name_label.modulate = Color.white
		thumbnail_cover.visible = false
		select_border.self_modulate.a = 0
		
		
func pressed() -> void:
	$AnimationPlayer.play("pressed")