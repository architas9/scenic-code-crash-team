# MAP AND MODEL
param map = localPath('../assets/maps/CARLA/Town05.xodr')
param carla_map = 'Town05'
model scenic.simulators.carla.model

# CONSTANTS
EGO_SPEED = 10
OTHER_CAR_SPEED = 10

# BEHAVIORS

behavior EgoBehavior():
    do FollowLaneBehavior(target_speed=EGO_SPEED)

behavior OtherCarBehavior():
    do FollowLaneBehavior(target_speed=OTHER_CAR_SPEED)

# LANE SELECTION

# Choose a lane section with at least two lanes (right and left)
laneSecsWithMultipleLanes = []
for lane in network.lanes:
    for laneSec in lane.sections:
        if laneSec._laneToLeft is not None:
            laneSecsWithMultipleLanes.append(laneSec)

assert len(laneSecsWithMultipleLanes) > 0, 'No suitable lane sections with adjacent lanes found.'

# Select a random lane section
selectedLaneSec = Uniform(*laneSecsWithMultipleLanes)

# Define the right and left lanes
rightLaneSec = selectedLaneSec
leftLaneSec = selectedLaneSec._laneToLeft

# SPAWN POINTS

egoSpawn = new OrientedPoint on rightLaneSec.centerline
otherCarSpawn = new OrientedPoint on leftLaneSec.centerline

# VEHICLES

ego = new Car at egoSpawn,
    with behavior EgoBehavior()

otherCar = new Car left of ego by 3,
    with behavior OtherCarBehavior()

# REQUIREMENTS

require (distance from ego to intersection) > 50
require (distance from otherCar to intersection) > 50

terminate when (distance from ego to egoSpawn) > 150
