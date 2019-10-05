extends ProgressBar
class_name StreetCredProgressBar
"""
This script controls the progress bar for street cred - 
responds to signals of making it grow, loops over it if the growing reached 
a new level, add completion chyme in that case.
Street bar growth happens alongside SC label slide upwards. SC label should always 
remain just inside prgress bar progress section, (unless at bar bottom)
"""
var Logger : Resource = preload("res://utils/logger.gd")
var LevelUpText : Resource = preload("res://gui/level_up_text.tscn")


const PROGRESS_ALTER_VELOCITY_SEC = 0.5


onready var State : GameState = get_node("/root/G")
onready var LOG: Logger = Logger.new(self)
onready var sc_label : Label = $SCLabel
onready var tween : Tween = $BarGrower 
onready var animator : AnimationPlayer = $AnimationPlayer


var _progress_value_nodepath : NodePath = NodePath(":value")
onready var _bar_custom_fg_handle : StyleBoxFlat = get("custom_styles/fg")
onready var _bar_custom_bg_handle : StyleBoxFlat = get("custom_styles/bg")
onready var _initial_bar_color: Color = _bar_custom_fg_handle.bg_color
onready var _initial_bar_bg_border_color : Color = _bar_custom_bg_handle.border_color
onready var _label_size : Vector2 = sc_label.rect_size


func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("debug1")):
		var new_value : float = min_value + randf() * (max_value - min_value)
		LOG.debug("set new bar value {}", [new_value])
		grow_progress_local(new_value)
	if (Input.is_action_just_pressed("debug2")):
		var new_text : String = C.MR_STREET_CRED_LEVELS[randi() % 6].name
		var new_value : int = max_value + randf() * max_value
		LOG.debug("set new bar value {}", [new_value])
		grow_progress_next_level(new_value, max_value, max_value * 2, new_text)


func _ready():
	if (State):
		var prev_sc_level : Dictionary = C.MR_STREET_CRED_LEVELS[State.next_street_cred_level_idx - 1]
		var next_sc_level : Dictionary = C.MR_STREET_CRED_LEVELS[State.next_street_cred_level_idx]
		_set_current_progress_ranges(
			State.current_street_scred,
			prev_sc_level.req_sc,
			next_sc_level.req_sc
		)
		
	sc_label.rect_position = _get_label_position_current_progress()
	tween.connect("tween_step", self, "_on_tween_step")
	
	
func _set_current_progress_ranges(curr_value: int, min_value: int, max_value: int) -> void:
	self.min_value = min_value
	self.max_value = max_value
	self.value = curr_value
	LOG.debug("Set bar [{};{}] with value {}/{}", [min_value, max_value, value, max_value])


func _on_tween_step(source: Object, prop_path: NodePath, elapsed: float, value: Object) -> void:
	#this is a tween about changing progress bar value, adjust label
	if (source == self and prop_path == _progress_value_nodepath):
		var new_rect_pos := _get_label_position_current_progress()
		sc_label.rect_position = new_rect_pos


"""
Get the correct placement position for the SC label rect in terms of
progress bar height
"""
func _get_label_position_current_progress() -> Vector2:
	var fullness_coef : float = (value - min_value) / (max_value - min_value)
	var bar_top_pos : float = rect_size.x * fullness_coef
	var new_label_height :float = bar_top_pos - _label_size.x
	LOG.debug("value: {}/{}, fullness: {}, bar top: {}, label_pos: {}", [
			value, 
			max_value, 
			fullness_coef, 
			bar_top_pos, 
			new_label_height
	])
	if (new_label_height <= 0):
		return Vector2.ZERO
	else:
		return Vector2(new_label_height, 0)
	
	
"""
Perform change in amount of progress in progress bar, local to the 
current progress ranges min-max
If an out of range change in progress is attempted, an out of bounds
error is thrown
Performs required bar animations during value change
"""	
func grow_progress_local(new_progress: int) -> void:
	if (new_progress > max_value):
		LOG.error("Want to grow progress {} above current max {}, use 'grow_progress_next_level'!", 
			[new_progress, max_value]
		)
	#cant go below allowed in current level
	if (new_progress < min_value):
		new_progress = min_value
	
	var old_value := value
	_prepare_and_start_tween(new_progress)
	if (old_value > new_progress):
		animator.play("bar_reduce_flicker")
	else:
		animator.play("bar_rise_flicker")
	yield(tween, "tween_all_completed")
	animator.stop(true)
	_bar_custom_fg_handle.bg_color = _initial_bar_color
	_bar_custom_bg_handle.border_color = _initial_bar_bg_border_color

"""
Perform progress bar growth across bar threshold. This involves looping
the bar around and using new ranges to change it. 
Performs required animations for value changes and 
generates text based on levelup
"""
func grow_progress_next_level(new_progress: int, 
								new_min: int, 
								new_max: int, 
								level_up_text: String
) -> void:
	var prev_progress_max := max_value
	#grow current progress to end
	yield(grow_progress_local(prev_progress_max), "completed")
	#create a happy label thing
	var level_up_node : Control = LevelUpText.instance()
	var level_up_node_label_node : Label = level_up_node.get_node("LevelText")
	level_up_node_label_node.text = level_up_text
	level_up_node.rect_rotation = 90
	level_up_node.rect_position = rect_size
	add_child(level_up_node)
	#change current bar
	_set_current_progress_ranges(prev_progress_max, new_min, new_max)
	#do rest of growth
	grow_progress_local(new_progress)


func _prepare_and_start_tween(new_progress: int) -> void:
	tween.remove_all()
	var progress_alter_distance = abs(value - new_progress)
	var progress_alter_relative = progress_alter_distance / max_value
	var alter_time_secs = progress_alter_relative / PROGRESS_ALTER_VELOCITY_SEC
	LOG.debug("altering {} to {}, which is {}({}), in {} seconds", [
		value, new_progress, 
		progress_alter_distance, progress_alter_relative, 
		alter_time_secs
	])
	tween.interpolate_property(
		self, "value", 
		value, new_progress, 
		alter_time_secs, Tween.TRANS_LINEAR, Tween.EASE_OUT
	)
	tween.start()