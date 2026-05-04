# MAP AND MODEL
param map = localPath('../assets/maps/CARLA/Town05.xodr')
param carla_map = 'Town05'
model scenic.simulators.carla.model

# CONSTANTS
EGO_SPEED = 6

# BEHAVIORS

behavior EgoRightTurnBehavior(trajectory):
    do FollowTrajectoryBehavior(trajectory=trajectory, target_speed=EGO_SPEED)

# INTERSECTION SELECTION

# Choose a signalized intersection
signalizedIntersections = filter(lambda i: i.isSignalized, network.intersections)
intersection = Uniform(*signalizedIntersections)

# Ego: choose an incoming lane with a right-turn maneuver
egoIncomingLane = Uniform(*intersection.incomingLanes)
rightTurnManeuvers = filter(lambda m: m.type == ManeuverType.RIGHT_TURN, egoIncomingLane.maneuvers)
require len(rightTurnManeuvers) > 0
rightTurnManeuver = Uniform(*rightTurnManeuvers)
egoTrajectory = [rightTurnManeuver.startLane, rightTurnManeuver.connectingLane, rightTurnManeuver.endLane]

# SPAWN POINT

egoSpawn = new OrientedPoint on rightTurnManeuver.startLane.centerline

# EGO VEHICLE
ego = new Car at egoSpawn,
    with behavior EgoRightTurnBehavior(egoTrajectory)

# REQUIREMENTS

require (distance from ego to intersection) > 10

terminate when (distance from ego to intersection) > 40
