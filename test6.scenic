# MAP AND MODEL
param map = localPath('../../assets/maps/CARLA/Town05.xodr')
param carla_map = 'Town05'
model scenic.simulators.carla.model

# CONSTANTS
EGO_MODEL = "vehicle.tesla.model3"
EGO_SPEED = 10

# BEHAVIOR
behavior EgoBehavior():
    do FollowLaneBehavior(target_speed=EGO_SPEED)

# GEOMETRY / LANE SELECTION

# Find lane sections that are the leftmost lane (no faster lane)
leftmostLaneSecs = []
for lane in network.lanes:
    for laneSec in lane.sections:
        if laneSec._fasterLane is None and laneSec._slowerLane is not None:
            leftmostLaneSecs.append(laneSec)

assert len(leftmostLaneSecs) > 0, 'No leftmost lane sections found in network.'

# Randomly select a leftmost lane section
egoLaneSec = Uniform(*leftmostLaneSecs)

# SPAWN POINT
egoSpawn = new OrientedPoint on egoLaneSec.centerline

# EGO VEHICLE
ego = new Car at egoSpawn,
    with blueprint EGO_MODEL,
    with behavior EgoBehavior()

# REQUIREMENTS
require (distance from ego to intersection) > 50

terminate when (distance from ego to egoSpawn) > 200
