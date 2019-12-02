extends CanvasLayer
"""
Used to perform loading of a scene behind a loading screen
"""

onready var overlay: Control = $Control


func load_scene(scene_path: String, delay: float = 0.5) -> void:
	yield(get_tree(), "idle_frame")
	overlay.show()
	yield(get_tree(), "idle_frame")
	yield(get_tree().create_timer(delay), "timeout")
	assert(get_tree().change_scene(scene_path) == OK)
	overlay.hide()
