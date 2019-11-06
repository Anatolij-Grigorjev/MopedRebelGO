extends PointsLabel
class_name AdditivePointsLabel

func update_current_points(current_pts: float) -> void:
	if (current_pts != 0.0):
		_set_points_color(current_pts)
		_adjust_display_format(current_pts)
		.update_current_points(current_pts)
	self.visible = current_pts != 0.0
	

func _set_points_color(for_points: float) -> void:
	if (for_points > 0):
		self.set("custom_colors/font_color", Color.yellow)
	else:
		self.set("custom_colors/font_color", Color.red)
		
		
func _adjust_display_format(for_points: float) -> void:
	if (for_points > 0 and not label_display_format.begins_with("+")):
		label_display_format = "+" + label_display_format
	if (for_points < 0 and label_display_format.begins_with("+")):
		label_display_format = label_display_format.substr(1, label_display_format.length())
