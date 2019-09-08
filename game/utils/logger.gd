class_name Logger
"""
General purpouse logger to be used for pretty-printing messages with
meaning in a given script.

Requires a descriptor string for initialization, but can also be 
an 'Object' reference, in which case the object class name is used for
the descriptor

Usage: 

var LOG: Logger = Logger.new(<some string>)
OR
var LOG := Logger.new(self)

LOG.info(\"hello!\") 
^^^^ prints hello preceded by log entry date/descriptor info etc, produces:
	
[2019.08.09 15:45:20] <descriptor>: hello!

class can also invoke breakfpoints when the #error log method is called
to better handle error situations
"""


func _ready():
	pass # Replace with function body.
