class_name ThreadCtx
"""
Describes a thread callsite context that is created for a 
thread with parameters being added to it
The thread should then consume these parameters in its method
via 'params' member.
Thread itself is available via 'thread'
This allows keeping thread context within the method its running,
for example to pass it to the method that needs to terminate it
"""
var thread: Thread
var call_params: Array = []


func _init(ctx: Thread):
	assert ctx != null

	thread = ctx
	call_params = []