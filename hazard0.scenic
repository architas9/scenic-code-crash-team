""" Scenario Description
Recreation of hazard0.mp4 where the ego car and other car are both in the center lane, 
the ego car merges and then the other car merges into the right lane as well without checking its blindspot
"""

# SET MAP AND MODEL 
param map = localPath('../../tests/formats/opendrive/maps/CARLA/Town05.xodr')  
param carla_map = 'Town05'
model scenic.simulators.carla.model

# CONSTANTS
EGO_MODEL = "vehicle.tesla.model3"
EGO_SPEED = 5
MERGE_SPEED = 5
MERGE_MODEL = "vehicle.ford.mustang"
DIST_THRESHOLD = 7

# EGO BEHAVIOR
behavior EgoBehavior(speed=5):
        # follow in center lane for a bit
        do FollowLaneBehavior(target_speed=EGO_SPEED) for 8 seconds
        if self.distanceToClosest(Car) < DIST_THRESHOLD:
                terminate
        # switch into right/slower lane
        rightLaneSec = self.laneSection.slowerLane
        do LaneChangeBehavior(laneSectionToSwitch=rightLaneSec, target_speed=EGO_SPEED)

        # stabilize by explicitly following the new lane
        try:
                do FollowLaneBehavior(target_speed=8, laneToFollow=rightLaneSec.lane)
        # brake if too close to any object ahead
        interrupt when self.distanceToClosest(Car) < DIST_THRESHOLD:
                #do FollowLaneBehavior(target_speed=0, laneToFollow=rightLaneSec.lane) for 2 seconds
                terminate


# MERGE BEHAVIOR
behavior MergeBehavior(speed = 10):
            # merge car also follows lane for a while
        do FollowLaneBehavior(target_speed=MERGE_SPEED) for 20 seconds

    # then it too merges right
        rightLaneSec = self.laneSection.slowerLane    
        if self.distanceToClosest(Car) == 2:
                do LaneChangeBehavior(laneSectionToSwitch=rightLaneSec, target_speed=MERGE_SPEED)
        do FollowLaneBehavior(target_speed=MERGE_SPEED, laneToFollow=rightLaneSec.lane)  
 
## DEFINING SPATIAL RELATIONS
fourWayIntersection = filter(lambda i: i.isSignalized, network.intersections)
intersec = Uniform(*fourWayIntersection)
lane = Uniform(*intersec.incomingLanes)
spot = OrientedPoint on lane.centerline

ego = Car at spot,
    with blueprint EGO_MODEL,
    with behavior EgoBehavior(EGO_SPEED)

merge = Car ahead of ego by (0, 15),
    with blueprint MERGE_MODEL,
    with behavior MergeBehavior(MERGE_SPEED)

rightLane = ego.laneSection._slowerLane

require 75 < (distance to intersection) < 100
require (ego.laneSection._slowerLane is not None)
require (ego.laneSection._fasterLane is not None)
terminate when (distance to spot) > 150
