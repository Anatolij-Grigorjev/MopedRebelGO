tool
extends MarginContainer
class_name UniformMarginContainer

enum Type {
	ALL = 0, SIDES = 1
}

export(Type) var uniform_type := Type.ALL setget _set_uniformity_type, _get_uniformity_type
export(float) var uniform_all_margin := 0.0 setget _set_all_margin, _get_all_margin
export(Vector2) var uniform_sides_margins := Vector2.ZERO setget _set_sides_margins, _get_sides_margins


func _get_uniformity_type() -> int:
	return uniform_type


func _set_uniformity_type(type: int) -> void:
	uniform_type = type
	match(type):
		Type.ALL:
			_set_all_margin(uniform_all_margin)
			break
		Type.SIDES:
			_set_sides_margins(uniform_sides_margins)
		_:
			pass
			

func _get_all_margin() -> float:
	return uniform_all_margin


func _set_all_margin(margin: float) -> void:
	self.custom_constants.margin_right = margin
	self.custom_constants.margin_left = margin
	self.custom_constants.margin_top = margin
	self.custom_constants.margin_bottom = margin
	uniform_all_margin = margin
	
	
func _get_sides_margins() -> Vector2:
	return uniform_sides_margins
	
	
func _set_sides_margins(sides: Vector2) -> void:
	self.custom_constants.margin_right = sides.x
	self.custom_constants.margin_left = sides.x
	self.custom_constants.margin_top = sides.y
	self.custom_constants.margin_bottom = sides.y
	uniform_sides_margins = sides