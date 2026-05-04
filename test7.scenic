# MAP AND MODEL
param map = localPath('../assets/maps/CARLA/Town05.xodr')
param carla_map = 'Town05'
model scenic.simulators.carla.model

# CONSTANTS
EGO_SPEED = 6
ADV_SPEED = 8
STOP_DISTANCE = 10          # distance to stop before intersection
YIELD_DISTANCE = 5          # distance to yield to adversary

# BEHAVIORS

behavior EgoStoppedAtLightBehavior():
    # Initially stopped at the intersection
    wait for 2 seconds
    do FollowLaneBehavior(target_speed=EGO_SPEED)

behavior AdversaryApproachBehavior():
    # Adversary approaches the intersection
    try:
        do FollowLaneBehavior(target_speed=ADV_SPEED)

    # Stop on the side of the road after entering the intersection
    interrupt when (distance to ego) < YIELD_DISTANCE:
        take SetBrakeAction(1.0)  # full stop
        wait  # stay stopped

# INTERSECTION AND MANEUVERS

# Choose a signalized intersection
signalizedIntersections = filter(lambda i: i.isSignalized, network.intersections)
intersection = Uniform(*signalizedIntersections)

# Ego: choose an incoming lane that allows for a green light
egoIncomingLane = Uniform(*intersection.incomingLanes)
egoManeuvers = filter(lambda m: m.type == ManeuverType.STRAIGHT, egoIncomingLane.maneuvers)
require len(egoManeuvers) > 0
egoManeuver = Uniform(*egoManeuvers)

# Adversary: choose a lane that approaches from the left
adversaryIncomingLane = Uniform(*intersection.incomingLanes)
adversaryManeuvers = filter(lambda m: m.type == ManeuverType.STRAIGHT, egoManeuver.conflictingManeuvers)
require len(adversaryManeuvers) > 0
adversaryManeuver = Uniform(*adversaryManeuvers)

# SPAWN POINTS

# Spawn ego at the intersection, initially stopped
egoSpawn = new OrientedPoint on egoManeuver.startLane.centerline
ego = new Car at egoSpawn,
    with behavior EgoStoppedAtLightBehavior()

# Spawn adversary approaching from the left
adversarySpawn = new OrientedPoint on adversaryManeuver.startLane.centerline
adversary = new Car at adversarySpawn,
    with behavior AdversaryApproachBehavior()

# REQUIREMENTS

# Ensure both vehicles are approaching the intersection
require (distance from ego to intersection) < 40
require (distance from adversary to intersection) < 40

# Terminate when ego has passed the intersection
terminate when (distance from ego to intersection) > 40
