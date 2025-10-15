"""SCENARIO DESCRIPTION:
recreation of NearCrash.mp4 where a ego vehicle is driving straight in the night and almost collides with a crossing truck.
"""

# SET MAP AND MODEL 
param map = localPath('../../tests/formats/opendrive/maps/CARLA/Town05.xodr')  
param carla_map = 'Town05'
model scenic.simulators.carla.model

# CONSTANTS
EGO_SPEED = 5
TRUCK_SPEED = 2
DIST_THRESHOLD = 5

# BEHAVIOR
behavior EgoBehavior(speed=5):
        try:
                do FollowLaneBehavior(target_speed=EGO_SPEED)
        interrupt when self.distanceToClosest(Truck) < DIST_THRESHOLD:
                terminate

behavior TruckBehavior(speed = 5):
         do FollowLaneBehavior(target_speed=TRUCK_SPEED)

# PLACEMENT
fourwayintersec = filter(lambda i: i.is4Way, network.intersections)
intersec = Uniform(*fourwayintersec)
egolane = Uniform(*intersec.incomingLanes)
egospot = OrientedPoint on egolane.centerline
truckspot = OrientedPoint in intersection

ego = Car at egospot,
        with behavior EgoBehavior(EGO_SPEED)

truck = Truck at truckspot,
        apparently facing 90 deg,
        with behavior TruckBehavior(speed = TRUCK_SPEED) 

require 9 < (distance to intersection) < 10
terminate when (distance to egospot) > 75
require always ego can see truck
require always relative heading of truck is 90 deg
