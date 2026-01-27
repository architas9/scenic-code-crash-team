""" 
Scenario Description:
Recreation of Hazzard5.mp4 — the ego car is turning left on a yellow light while while the incoming car is trying to go straight at the intersection
"""

# MAP AND MODEL
param map = localPath('../../assets/maps/CARLA/Town05.xodr')
param carla_map = 'Town05'
model scenic.simulators.carla.model

# CONSTANTS

EGO_SPEED = 4
ADVERSARY_SPEED = 5
DIST_THRESHOLD = 4

# BEHAVIORS

behavior EgoBehavior(trajectory):
        try:
                do FollowTrajectoryBehavior(target_speed=EGO_SPEED, trajectory=trajectory)
                do FollowLaneBehavior(target_speed=EGO_SPEED)
        interrupt when withinDistanceToAnyObjs(self, DIST_THRESHOLD):
                terminate

# SPATIAL RELATIONS

intersection = Uniform(*filter(lambda i: i.is4Way, network.intersections))
egoInitLane = Uniform(*intersection.incomingLanes)
egoManeuver = Uniform(*filter(lambda m: m.type is ManeuverType.LEFT_TURN, egoInitLane.maneuvers))
egoTrajectory = [egoInitLane, egoManeuver.connectingLane, egoManeuver.endLane]
egospot = new OrientedPoint in egoInitLane.centerline

advInitLane = Uniform(*filter(lambda m: m.type is ManeuverType.STRAIGHT, Uniform(*filter(lambda m: m.type is ManeuverType.STRAIGHT, egoInitLane.maneuvers)).reverseManeuvers)).startLane
advManeuver = Uniform(*filter(lambda m: m.type is ManeuverType.STRAIGHT, advInitLane.maneuvers))
advTrajectory = [advInitLane, advManeuver.connectingLane, advManeuver.endLane]
advspot = new OrientedPoint in advInitLane.centerline

ego = new Car at egospot,
  with behavior EgoBehavior(egoTrajectory)

adversary = new Car at advspot,
  with behavior FollowTrajectoryBehavior(target_speed=ADVERSARY_SPEED, trajectory=advTrajectory)

require (distance to intersection) < 35
terminate when (distance to egospot) > 150
