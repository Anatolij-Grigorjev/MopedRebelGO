extends Node2D
class_name AngerPulse
"""
Controller describes basic automatic anger pulse behavior - use tween
to travel exponentially, dissolve via transpearancy and dissapear
"""

@export var pulse_travel_distance: float = 400.0
@export var pulse_ttl: float = 1.5
@export var pulse_sc_mult_add: float = 0.05: set = set_sc_mult_add


@onready var tween: Tween = get_tree().create_tween()
@onready var sprite: Sprite2D = $Sprite2D
@onready var collider : CollisionShape2D = $Sprite2D/Area2D/CollisionShape2D
@onready var intensity_light: PointLight2D = $Sprite2D/PointLight2D


var _dissapear_time : float = 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	#energy level at 0.25 for increment of 0.05
	intensity_light.energy = pulse_sc_mult_add * 5
	#carry pulse forward
	tween.interpolate_property(
		self, 'position',
		null, position + Vector2(pulse_travel_distance * scale.x, 0),
		pulse_ttl,
		Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	tween.start()
	#with 70% left start dissapearing
	await get_tree().create_timer(pulse_ttl * 0.7).timeout
	collider.disabled = true
	tween.interpolate_property(
		sprite, 'modulate:a',
		null, 0.0,
		_dissapear_time,
		Tween.TRANS_LINEAR, Tween.EASE_IN
	)
	tween.start()
	await tween.tween_all_completed
	queue_free()


func set_sc_mult_add(multiplier_add: float) -> void:
	pulse_sc_mult_add = multiplier_add
	
