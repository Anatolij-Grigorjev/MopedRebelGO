extends Control
"""
This scriptlet allows a Control node to adjust any Node2D children to 
reside at the right-bottom position of its rect
Used to position Node2D nodes reliably in control scenes 
based on control anchors
"""

func _ready():
	for node in get_children():
		#node is actually a node2d (transalte is method for 2d transform)
		if (node.has_method("translate")):
			print(size)
			(node as Node2D).position = DisplayServer.screen_get_size() + Vector2(offset_right, offset_bottom)
