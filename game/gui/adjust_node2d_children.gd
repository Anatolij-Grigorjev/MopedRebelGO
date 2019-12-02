extends Control
"""
This scriptlet allows a Control node to adjust any Node2D children to 
reside at the right-bottom position of its rect
Used to position Node2D nodes reliably in control scenes 
based on control anchors
"""

func _ready():
	for node in get_children():
		(node as Node2D).position = OS.get_screen_size() + Vector2(margin_right, margin_bottom)
