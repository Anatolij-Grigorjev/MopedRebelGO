extends Node2D
class_name PackagesBundle
"""
Controller for a bundle of packages
Keep track of current packages count, fires off a package 
every time the moped hits an obstacle

When the last package has been thrown off and and the moped hit an obstacle
this bundle signals that all bundles are gone
"""
var Logger : Resource = preload("res://utils/logger.gd")
var DeliveryPackage: Resource = preload("res://rebel/delivery_package.tscn")


signal delivery_package_thrown(remaining_packages)


onready var LOG: Logger = Logger.new(self)
onready var F : Helpers = get_node("/root/F")
onready var remaining_packages : int = get_child_count()


var _topmost_package: DeliveryPackage


func _ready() -> void:
	if (remaining_packages):
		_topmost_package = get_child(0)
	

func throw_top_package() -> void:
	if (remaining_packages and _topmost_package):
		remaining_packages = max(0, remaining_packages - 1)
		LOG.debug("Throwing package {}, left: {}", [_topmost_package, remaining_packages])
		var fly_package : DeliveryPackage = DeliveryPackage.instance()
		fly_package.global_position = _topmost_package.global_position
		fly_package.global_scale = _topmost_package.global_scale
		get_tree().root.add_child(fly_package)
		remove_child(_topmost_package)
		#node configuration happens between frames, lets wait
		yield(get_tree(), "idle_frame")
		fly_package.do_flyoff()
		if (remaining_packages):
			_topmost_package = get_child(0)
	emit_signal("delivery_package_thrown", remaining_packages)
