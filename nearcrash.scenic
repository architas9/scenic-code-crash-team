"""SCENARIO DESCRIPTION:
recreation of NearCrash.mp4 where a ego vehicle is driving straight in the night and almost collides with a crossing truck.
"""

# SET MAP AND MODEL 
param map = localPath('../../assets/maps/CARLA/Town05.xodr')  
param carla_map = 'Town05'
model scenic.simulators.carla.model
param sun_altitude_angle = -90 

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
egospot = new OrientedPoint on egolane.centerline
truckspot = new OrientedPoint in intersection

ego = new Car at egospot,
        with behavior EgoBehavior(EGO_SPEED)

truck = new Truck right of truckspot,
        apparently facing 90 deg,
        with behavior TruckBehavior(speed = TRUCK_SPEED)


require 9 < (distance to intersection) < 10
require (distance from truck to intersection) < 8
terminate when (distance to egospot) > 75
require always ego can see truck
require always relative heading of truck is 90 deg
