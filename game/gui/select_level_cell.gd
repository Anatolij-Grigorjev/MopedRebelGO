@tool
extends Control
class_name SelectLevelCell
"""
Cell that means a level in a menu. Includes reference to level scene
is selectable
"""

@export var level_scene_path: String
@export var level_thumbnail: Texture2D: get = get_level_thumb, set = set_level_thumb
@export var level_name: String = "test": get = get_level_name, set = set_level_name
@export var selected: bool = false: set = set_selected


func set_level_thumb(thumb: Texture2D) -> void:
	if ($SelectedBorder/VBoxContainer/ThumbnailMarginContainer/Thumbnail):
		$SelectedBorder/VBoxContainer/ThumbnailMarginContainer/Thumbnail.texture = thumb
		
		
func get_level_thumb() -> Texture2D:
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
		level_name_label.modulate = Color.RED
		thumbnail_cover.visible = true
		select_border.self_modulate.a = 255
	else:
		level_name_label.modulate = Color.WHITE
		thumbnail_cover.visible = false
		select_border.self_modulate.a = 0
		
		
func pressed() -> void:
	$AnimationPlayer.play("pressed")