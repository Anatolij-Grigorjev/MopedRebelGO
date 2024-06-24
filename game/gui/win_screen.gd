extends Control

func _on_ButtonContainer_button_pressed() -> void:
	await get_tree().create_timer(1.5).timeout
	G.reset_sc()
	G.reset_current_stage_stats()
	LoadingScreen.load_scene(C.STAGE_SELECT_SCENE_PATH)
