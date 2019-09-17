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
Group name denoting anything in-game that acts as an obstacle on the road
An obstacle makes moped rebel crash and lose package
"""
const GROUP_OBSTACLES : String = "obstacle"
"""
Group for moped rebel himself
"""
const GROUP_MR : String = "moped_rebel"

"""
*****************************
*		MOPED REBEL			*
*****************************
"""
const MR_CRUISE_SPEED: float = 334.56
const MR_SWERVE_DURATION_SEC: float = 0.2
const MR_OBSTACLE_PUSHBACK_DURATION_SEC: float = 0.3
const MR_OBSTACLE_PUSHBACK_AMOUNT: float = 700.7