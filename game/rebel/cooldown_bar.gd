extends Node2D
class_name CooldownBar
"""
Controller for cooldown bar that appears duiring triggered cooldown
for a specified duration and is invisible otherwise
"""

@onready var _bar: ProgressBar = $ProgressBar


var _is_cooldown_running: bool = false
var _cooldown_time_left: float = 0.0
var _max_cooldown: float = 1.0


func _ready() -> void:
	_bar.visible = _is_cooldown_running
	_bar.max_value = _max_cooldown


func _process(delta: float) -> void:
	if (_is_cooldown_running):
		_bar.value = _bar.max_value - _cooldown_time_left
		_cooldown_time_left -= delta
		if (_bar.value == _bar.max_value):
			_is_cooldown_running = false
			_bar.visible = false


func start_cooldown(cooldown_time: float) -> void:
	if (cooldown_time):
		_bar.visible = true
		_is_cooldown_running = true
		_cooldown_time_left = cooldown_time
		_bar.max_value = cooldown_time
		_bar.value = 0.0