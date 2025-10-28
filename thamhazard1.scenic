"""Scenario Description
Ego vehicle is following the leftmost lane at a higher speed than the leading cars 
until it reaches the leading cars. In order to avoid colliding with the leading cars, 
the ego vehicle drives on the right lane. 
"""

# SET MAP AND MODEL 
param map = localPath('../../tests/formats/opendrive/maps/CARLA/Town05.xodr')  
param carla_map = 'Town05'
model scenic.simulators.carla.model
param maxIterations = 3000

# CONSTANTS
EGO_SPEED = 5
TRAFFIC_SPEED = 3
DIST_THRESHOLD = 10

# BEHAVIORS
behavior EgoBehavior(speed=5):
        try:
                do FollowLaneBehavior(target_speed=EGO_SPEED)
        interrupt when self.distanceToClosest(Car) < DIST_THRESHOLD:
                ego.steering = -0.8
                wait
        
        do FollowLaneBehavior(target_speed=EGO_SPEED - 2)

behavior TrafficBehavior(speed = 2):
        try:
                do FollowLaneBehavior(target_speed=TRAFFIC_SPEED)
        interrupt when self.distanceToClosest(Car) < 4:
                traffic1.steering = 0.6
                traffic2.steering = 0.6
                wait
        do FollowLaneBehavior(target_speed=TRAFFIC_SPEED)

# ENVIRONMENT
lane = Uniform(*network.lanes)
egospot = OrientedPoint on lane.centerline
trafficspot = OrientedPoint on lane.centerline

ego = Car at egospot,
        with behavior EgoBehavior(EGO_SPEED)

traffic1 = Car at trafficspot,
        with behavior TrafficBehavior(TRAFFIC_SPEED)

traffic2 = Car ahead of traffic1 by (0, 3),
        with behavior TrafficBehavior(TRAFFIC_SPEED)

require always ego can see traffic1
require (ego.laneSection._slowerLane is not None)
require (ego.laneSection._fasterLane is None)
require (distance from intersection) > 75
terminate when (distance to egospot) > 150
