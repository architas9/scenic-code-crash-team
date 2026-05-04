# MAP AND MODEL
param map = localPath('../assets/maps/CARLA/Town05.xodr')
param carla_map = 'Town05'
model scenic.simulators.carla.model

# CONSTANTS
EGO_MODEL = "vehicle.tesla.model3"
ADV_MODEL = "vehicle.audi.tt"
EGO_SPEED = 10
ADV_SPEED = 5
BRAKE_DISTANCE = 10         # distance at which adversary will brake suddenly
NUM_OTHER_CARS = 10          # number of other cars on the road

# BEHAVIORS

behavior AdversaryBehavior():
    # Adversary drives straight and then brakes suddenly
    do FollowLaneBehavior(target_speed=ADV_SPEED) for 3 seconds
    take SetBrakeAction(1.0)  # sudden brake

behavior EgoBehavior():
    # Ego follows the lane at a constant speed
    try:
        do FollowLaneBehavior(target_speed=EGO_SPEED)
    interrupt when (distance from ego to adversary) < 5:
        take SetBrakeAction(1.0)
        terminate

# LANE SELECTION

# Choose a straight lane section with multiple lanes
straightLaneSecs = []
for lane in network.lanes:
    for sec in lane.sections:
        if len(sec.adjacentLanes) > 1:  # ensure multiple lanes
            straightLaneSecs.append(sec)

assert len(straightLaneSecs) > 0, 'No suitable straight lane sections found.'

egoLaneSec = Uniform(*straightLaneSecs)

# SPAWN POINTS

# Spawn adversary vehicle in the same lane ahead of ego
advSpawnRef = new OrientedPoint on egoLaneSec.centerline
adversary = new Car at advSpawnRef,
    with behavior AdversaryBehavior()

# Spawn ego vehicle behind the adversary
ego = new Car behind adversary by 10,
    with behavior EgoBehavior()

# SPAWN OTHER CARS IN ADJACENT LANES

for _ in range(NUM_OTHER_CARS):
    otherLaneSec = Uniform(*straightLaneSecs)
    require otherLaneSec is not egoLaneSec 
    otherSpawnRef = new OrientedPoint on otherLaneSec.centerline
    new Car at otherSpawnRef,
        with blueprint ADV_MODEL,
        with behavior FollowLaneBehavior(target_speed=ADV_SPEED)

# REQUIREMENTS

# Ensure ego is not too close to an intersection
require (distance from ego to intersection) > 50
require (distance from adversary to intersection) > 50

# Termination condition: when ego collides with the adversary
terminate when (distance from ego to adversary) < 3
