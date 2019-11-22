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
Group name for any citizen to which a diss can be directed by moped rebel
"""
const GROUP_DISSABLES: String = "dissable"
"""
Group for pieces of non-regulation tracks
"""
const GROUP_NRT = "nrt"
"""
Marker for root node of moped rebel
"""
const GROUP_MR_ROOT = "moped_rebel_root"
"""
Group for moped rebel collision components
"""
const GROUP_MR : String = "moped_rebel"
"""
Group for diss words thrown by moped rebel
"""
const GROUP_DISS_WORD : String = "diss_word"
"""
Group for anger pulse areas that are in the middle of node hierarchy
"""
const GROUP_ANGER_PULSE : String = "anger_pulse"
"""
Types of obstacles present on the road 
(the kinds HUD makes warnings about)
"""
enum ObstacleTypes {
	ROADBLOCK,
	CITIZEN
}
"""
Directions within a single X dimension
"""
enum DIRECTION {
	LEFT = -1,
	RIGHT = 1
}

"""
*****************************
*		STAGES				*
*****************************
"""
const STAGE_COMPLETION_BONUS = {
	"test": 450
}
const DISS_CITIZEN_BONUS = 120



"""
*****************************
*		MOPED REBEL			*
*****************************
"""
const MR_MAX_SC: float = 9999.0
const MR_DISS_SC_COST: float = 15.5
const MR_CRUISE_SPEED : float = 255.56
const MR_CUTSCENE_SPEED : float = 155.54
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