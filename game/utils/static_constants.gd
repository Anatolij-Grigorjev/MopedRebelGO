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
const GAME_LOGGING_LEVEL : int = 1
"""
Screen resolution of game
"""
const GAME_RESOLUTION: Vector2 = Vector2(1280, 720)
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
Group for diss words thrown by moped rebel
"""
const GROUP_DISS_WORK : String = "diss_words"
"""
Types of obstacles present on the road 
(the kinds HUD makes warnings about)
"""
enum ObstacleTypes {
	ROADBLOCK,
	CITIZEN
}

"""
*****************************
*		MOPED REBEL			*
*****************************
"""
const MR_CRUISE_SPEED : float = 334.56
const MR_SWERVE_DURATION_SEC : float = 0.2
const MR_OBSTACLE_PUSHBACK_DURATION_SEC : float = 0.3
const MR_OBSTACLE_PUSHBACK_AMOUNT : float = 700.7
const MR_SC_PER_TRACK_UNIT : float = 0.75
const MR_STREET_CRED_LEVELS : Array = [
	{
		"req_sc": 0,
		"level_sc": 1000,
		"name": "Moped Nobody"
	},
	{
		"req_sc": 1000,
		"level_sc": 2000,
		"name": "Moped Kid"
	},
	{
		"req_sc": 2000,
		"level_sc": 3000,
		"name": "Moped Punk" 
	},
	{
		"req_sc": 3000,
		"level_sc": 4000,
		"name": "Moped Bro"
	},
	{
		"req_sc": 4000,
		"level_sc": 5000,
		"name": "Moped Dude"
	},
	{
		"req_sc": 5000,
		"name": "Moped Rebel"
	}
]