extends Node2D
class_name GroupGrabYsort
"""
A kind of Node2D that puts all nodes 
from specified groups in the tree under itself at scene load
"""
var Logger : Resource = preload("res://utils/logger.gd")


@export var grab_groups: Array = [] # (Array, String)


@onready var LOG: Logger = Logger.new(self)


var _target_nodes: Array = []


func _ready() -> void:
	for group_name in grab_groups:
		var nodes_in_group := get_tree().get_nodes_in_group(group_name)
		LOG.info("Found {} nodes in group {}!", [nodes_in_group.size(), group_name])
		for node in nodes_in_group:
			#save references to all nodes for later reparent
			_target_nodes.append(node)
			
	if (_target_nodes):
		call_deferred("_do_reparent")

		
func _do_reparent() -> void:
	for node in _target_nodes:
		Helpers.reparent_node(node, self, true)
 
