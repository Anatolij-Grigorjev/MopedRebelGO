class_name Logger
"""
General purpouse logger to be used for pretty-printing messages with
meaning in a given script.

Requires a descriptor for initialization, whcih can be any 
'Object' reference, though if said object is not a string itself, its
classname is used.
Logger is preconfigured with pattern 
<date time> <LOG LEVEL> <descriptor>#<method>:<line number> - <msg>

Usage: 

func test() -> void:
	var LOG: Logger = Logger.new(<any object>)
	LOG.info('hello!') 
^^^^ assuming thread idx 0, 
invocation time and doing in script of node named 'Node' 
and same line numbers:
2019.09.08 14:34:20 INFO Node#test:16 - hello!


class can also invoke breakpoints when the #error log method is called
to fail-fast handle error situations
"""

const DATETIME_FORMAT := "%04d.%02d.%02d %02d:%02d:%02d"
const LOG_LEVEL_NAMES : Array = [ "DEBUG", "INFO", "WARN", "ERROR" ]

enum LogLevel {
	DEBUG = 0,
	INFO = 1, 
	WARN = 2,
	ERROR = 3
}

var _logger_name: String

"""
Create a bound logger instance with the given descriptor
"""
func _init(descriptor: Object):
	if (typeof(descriptor) == TYPE_STRING):
		_logger_name = str(descriptor)
	if (typeof(descriptor) == TYPE_OBJECT):
		_logger_name = str(descriptor.get('name'))
		

"""
Log message at DEBUG level. Should be used for auxillary corrective info
and mostly left turned off
"""
func debug(message: String, params: Array = []) -> void:
	_log_at_level(LogLevel.DEBUG, message, params)


"""

"""
func info(message: String, params: Array = []) -> void:
	_log_at_level(LogLevel.INFO, message, params)
	
	
func warn(message: String, params: Array = []) -> void:
	_log_at_level(LogLevel.WARN, message, params)
	
	
func error(message: String, params: Array = [], break_here: bool = true) -> void:
	_log_at_level(LogLevel.ERROR, message, params)
	if (break_here):
		breakpoint


func _log_at_level(level: int, message: String, params: Array) -> void:
	#true means date time in UTC timezone
	var current_datetime := OS.get_datetime(true)
	var log_level_name : String = LOG_LEVEL_NAMES[level]
	var current_stack_frame : Dictionary = get_stack()[0]
	var resolved_message: String = _resolve_message_params(message, params)
	
	var full_message : String = ("%s %s %s#%s:%s - %s"
	% [
		_format_datetime_dict(current_datetime), 
		log_level_name, 
		descriptor, 
		current_stack_frame.function,
		current_stack_frame.line,
		resolved_message
	])

	print(full_message)
	
	
func _format_datetime_dict(datetime_dict: Dictionary) -> String:
	return DATETIME_FORMAT % [
		datetime_dict.year,
		datetime_dict.month,
		datetime_dict.day,
		datetime_dict.hour,
		datetime_dict.minute,
		datetime_dict.second
	]	

func _resolve_message_params(message: String, params: Array) -> String:
	return ""

