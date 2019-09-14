class_name C
"""
Holder class for static game constants that can be references by other 
script files in 'const' fields

The idea here is to separete gameplay constants that will not be configured
via ingame files for easy in-place editing later
"""


"""
*****************************
*		GAME				*
*****************************
"""
"""
Leves range from 0 to 3 for DEBUG, INFO, WARN, ERROR respectively
"""
const GAME_LOGGING_LEVEL: int = 0


"""
*****************************
*		MOPED REBEL			*
*****************************
"""
const MR_CRUISE_SPEED: float = 234.56
const MR_SWERVE_DURATION_SEC: float = 0.2