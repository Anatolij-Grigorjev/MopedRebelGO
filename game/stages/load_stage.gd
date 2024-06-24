extends CanvasLayer
"""
Used to perform loading of a scene behind a loading screen
"""

@onready var overlay: Control = $Control


func load_scene(scene_path: String, delay: float = 0.5) -> void:
	await get_tree().process_frame
	overlay.show()
	await get_tree().process_frame
	await get_tree().create_timer(delay).timeout
	assert(get_tree().change_scene_to_file(scene_path) == OK)
	overlay.hide()
