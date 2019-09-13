extends Node
class_name Helpers
"""
Library of static helper functions for system-wide calculations and logic
that doesnt belong in dedicated scene controllers.
"""


"""
Calculate the global bounding rectangle for the given tilemap.
If supplied null/empty map returns empty Rect
"""
func get_tilemap_global_bounds(tilemap: TileMap) -> Rect2:
	if (not tilemap):
		return Rect2()
	
	var tilemap_cells := tilemap.get_used_cells()
	if (not tilemap_cells):
		return Rect2()
		
	var first_cell : Vector2 = tilemap_cells[0]
	var low_x := first_cell.x
	var low_y := first_cell.y
	var high_x := low_x
	var high_y := low_y
	
	for cell_idx in range(1, tilemap_cells.size()):
		var a_cell_pos : Vector2 = tilemap_cells[cell_idx]
		
		#check X
		if (a_cell_pos.x < low_x):
			low_x = a_cell_pos.x
		elif (a_cell_pos.x > high_x):
			high_x = a_cell_pos.x
			
		#check Y
		if (a_cell_pos.y < low_y):
			low_y = a_cell_pos.y
		elif (a_cell_pos.y > high_y):
			high_y = a_cell_pos.y
	
	var cell_extents : Vector2 = tilemap.get_cell_size() / 2
	
	var upper_left_corner_pos := tilemap.map_to_world(Vector2(low_x, low_y)) - cell_extents
	var lower_right_corner_pos := tilemap.map_to_world(Vector2(high_x, high_y)) + cell_extents
	
	return Rect2(
		#x/y vector
		upper_left_corner_pos,
		#w/h vector
		(lower_right_corner_pos - upper_left_corner_pos)
	)