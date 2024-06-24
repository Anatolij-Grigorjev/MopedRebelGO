extends GridContainer
"""
Grid of level cells where each one can be selected or played
"""


export(int) var selected_stage: int = 0
onready var stages: Array = get_children()



func _ready():
	_change_selected_stage(selected_stage)


func _process(delta: float) -> void:
	var direction: Vector2 = Vector2.ZERO
	if (Input.is_action_just_pressed("ui_left")):
		direction.x -= 1
	if (Input.is_action_just_pressed("ui_right")):
		direction.x += 1
	if (Input.is_action_just_pressed("ui_up")):
		direction.y -= 1
	if (Input.is_action_just_pressed("ui_down")):
		direction.y += 1
	
	var new_selected := selected_stage + (direction.x + direction.y * columns)
	if (new_selected != selected_stage):
		_change_selected_stage(new_selected)
		
		
func _change_selected_stage(new_selection: int) -> void:
	stages[selected_stage].selected = false
	selected_stage = wrapi(new_selection, 0, stages.size() - 1)
	stages[selected_stage].selected = true


func _on_ButtonContainer_button_pressed() -> void:
	var stage_node: SelectLevelCell = stages[selected_stage] as SelectLevelCell
	stage_node.pressed()
	yield(get_tree().create_timer(0.5), "timeout")
	LoadingScreen.load_scene(stage_node.level_scene_path)
