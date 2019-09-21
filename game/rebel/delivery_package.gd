extends Node2D
class_name DeliveryPackage
"""
Controller class for individual static delivery package
"""
var Logger : Resource = preload("res://utils/logger.gd")


onready var LOG: Logger = Logger.new(self)
onready var animator: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	pass # Replace with function body.


func do_flyoff() -> void:
	animator.play("fly_off")
	yield(animator, "animation_finished")
	queue_free()
