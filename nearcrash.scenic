"""SCENARIO DESCRIPTION:
recreation of NearCrash.mp4 where a ego vehicle is driving straight in the night and almost collides with a crossing truck.
"""

# SET MAP AND MODEL 
param map = localPath('../../tests/formats/opendrive/maps/CARLA/Town05.xodr')
param carla_map = 'Town05'
model scenic.simulators.carla.model

# CONSTANTS
EGO_SPEED = 5
TRUCK_SPEED = 6
DIST_THRESHOLD = 5

# BEHAVIOR
behavior EgoBehavior(speed=5):
        try:
                do FollowLaneBehavior(target_speed=EGO_SPEED)
        interrupt when self.distanceToClosest(Car) < DIST_THRESHOLD:
                terminate

behavior TruckBehavior(speed = 5):
         do FollowLaneBehavior(target_speed=TRUCK_SPEED)

# PLACEMENT
fourwayintersec = filter(lambda i: i.is4Way, network.intersections)
intersec = Uniform(*fourwayintersec)
straight_maneuvers = filter(lambda m: m.type == ManeuverType.STRAIGHT, intersec.maneuvers)
ego_maneuver = Uniform(*straight_maneuvers)
egolane = Uniform(*intersec.incomingLanes)
egospot = OrientedPoint on egolane.centerline
conflicting_straights = filter(lambda m: m.type == ManeuverType.STRAIGHT, ego_maneuver.conflictingManeuvers)
truck_maneuver = Uniform(*conflicting_straights)
t_start = truck_maneuver.startLane
t_connecting = truck_maneuver.connectingLane
t_end = truck_maneuver.endLane
truckspot = OrientedPoint on t_start.centerline

ego = Car at egospot,
        with behavior EgoBehavior(EGO_SPEED)

truck = Truck at truckspot,
        with behavior TruckBehavior(speed = TRUCK_SPEED)


require (distance to intersection) < 25
terminate when (distance to egospot) > 75
require always ego can see truck
