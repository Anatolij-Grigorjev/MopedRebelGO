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


const PROGRESS_ALTER_VELOCITY_SEC = 0.5


onready var State : GameState = get_node("/root/G")
onready var LOG: Logger = Logger.new(self)
onready var sc_label : Label = $SCLabel
onready var tween : Tween = $BarGrower 


var _progress_value_nodepath : NodePath = NodePath(":value")

func _process(delta: float) -> void:
	if (Input.is_key_pressed(KEY_SPACE)):
		var new_value : float = randf() * max_value
		grow_progress_local(new_value)


func _ready():
	if (State):
		var prev_sc_level : Dictionary = C.MR_STREET_CRED_LEVELS[State.next_street_cred_level_idx - 1]
		var next_sc_level : Dictionary = C.MR_STREET_CRED_LEVELS[State.next_street_cred_level_idx]
		self.min_value = prev_sc_level.req_sc
		self.max_value = next_sc_level.req_sc
		self.value = State.current_street_scred

	sc_label.rect_position = _get_label_position_current_progress()
	tween.connect("tween_step", self, "_on_tween_step")


func _on_tween_step(source: Object, prop_path: NodePath, elapsed: float, value: Object) -> void:
	#this is a tween about changing progress bar value, adjust label
	if (source == self and prop_path == _progress_value_nodepath):
		var new_rect_pos := _get_label_position_current_progress()
		sc_label.rect_position = new_rect_pos


func _get_label_position_current_progress() -> Vector2:
	var label_size := sc_label.rect_size
	var fullness_coef : float = value / max_value
	var bar_top_pos : float = rect_size.x * fullness_coef
	var new_label_height :float = bar_top_pos - label_size.x
	if (new_label_height <= 0):
		return Vector2.ZERO
	else:
		return Vector2(new_label_height, 0)
	
	
func grow_progress_local(new_progress: int) -> void:
	if (new_progress > max_value):
		LOG.error("Want to grow progress {} above current max {}, use 'grow_progress_next_level'!", 
			[new_progress, max_value]
		)
	_prepare_and_start_tween(new_progress)


func _prepare_and_start_tween(new_progress: int) -> void:
	tween.remove_all()
	var progress_alter_distance = abs(value - new_progress)
	var progress_alter_relative = progress_alter_distance / max_value
	var alter_time_secs = progress_alter_relative / PROGRESS_ALTER_VELOCITY_SEC
	LOG.info("altering {} to {}, which is {}({}), in {} seconds", [
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
