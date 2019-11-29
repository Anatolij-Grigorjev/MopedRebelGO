class_name AsyncTask
"""
A task with internally managed thread state. 
This performs a specified task (method) on a separate thread
and then returns the result to a callback function (if provided)
Task and callback parameter type validations are not performed
"""

var _worker_thread: Thread

var _task_node: Node
var _task_method_name: String
var _task_method_arguments: Array = []

var _result_node: Node
var _result_method_name: String


func _init():
	_worker_thread = Thread.new()
	

func set_task(owner: Node, name: String, params: Array) -> void:
	_task_node = owner
	_task_method_name = name
	_task_method_arguments = params
	
	
func set_callback(owner: Node, name: String) -> void:
	_result_node = owner
	_result_method_name = name
	
	
func start() -> void:
	assert _task_node != null
	assert _task_method_name != null
	
	_worker_thread.start(self, "_do_task_async")
	print("finish start")
	
func _do_task_async():
	print("start async")
	var result = _task_node.callv(_task_method_name, _task_method_arguments)
	call_deferred("_finish_task_sync")
	return result
	
	
func _finish_task_sync():
	print("get result")
	var result = _worker_thread.wait_to_finish()
	if (_result_node != null and not Helpers.is_blank(_result_method_name)):
		_result_node.call(_result_method_name, result)