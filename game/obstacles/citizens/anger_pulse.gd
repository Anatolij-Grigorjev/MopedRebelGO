extends Node2D
class_name AngerPulse
"""
Controller describes basic automatic anger pulse behavior - use tween
to travel exponentially, dissolve via transpearancy and dissapear
"""

export(float) var pulse_travel_distance : float = 400.0
export(float) var pulse_ttl : float = 1.5


onready var tween: Tween = $Tween
onready var sprite: Sprite = $Sprite
onready var collider : CollisionShape2D = $Area2D/CollisionShape2D


var _dissapear_time : float = 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	#carry pulse forward
	tween.interpolate_property(
		self, 'position',
		null, position + Vector2(pulse_travel_distance, 0),
		pulse_ttl,
		Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	tween.start()
	#with 70% left start dissapearing
	yield(get_tree().create_timer(pulse_ttl * 0.7), "timeout")
	collider.disabled = true
	tween.interpolate_property(
		sprite, 'modulate:a',
		null, 0.0,
		_dissapear_time,
		Tween.TRANS_LINEAR, Tween.EASE_IN
	)
	tween.start()
	yield(tween, "tween_all_completed")
	queue_free()
