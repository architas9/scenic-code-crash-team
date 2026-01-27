""" 
Scenario Description:
Recreation of Hazard_Car8.mp4 — the ego car is following a truck in the leftmost lane, 
and another car merges into the left lane without checking its blindspot.
"""

# MAP AND MODEL
param map = localPath('../assets/CARLA/Town05.xodr')
param carla_map = 'Town05'
model scenic.simulators.carla.model

# CONSTANTS

EGO_MODEL = "vehicle.tesla.model3"
MERGE_MODEL = "vehicle.ford.mustang"
EGO_SPEED = 4
MERGE_SPEED =5
DIST_THRESHOLD = 3.5

# BEHAVIORS

# EGO drives in left lane and stops if a car gets too close
behavior EgoBehavior(speed=EGO_SPEED):
    try:
        do FollowLaneBehavior(target_speed=speed)
    interrupt when ((distance to merge) < DIST_THRESHOLD):
        terminate

# MERGE car drives in middle lane, then merges left into ego's lane
behavior MergeBehavior(speed=MERGE_SPEED):
    do FollowLaneBehavior(target_speed=speed) for 10 seconds
    leftLaneSec = self.laneSection.fasterLane
    require leftLaneSec is not None
    do LaneChangeBehavior(laneSectionToSwitch=leftLaneSec, target_speed=speed - 1)
    do FollowLaneBehavior(target_speed=speed, laneToFollow=leftLaneSec.lane)

# LANE AND POSITION SETUP
lane = Uniform(*network.lanes)
egoSpot = new OrientedPoint on lane.centerline

ego = new Car at egoSpot,
    with blueprint EGO_MODEL,
    with behavior EgoBehavior(EGO_SPEED)

merge = new Car right of ego by 4.2,
    with blueprint MERGE_MODEL,
    with behavior MergeBehavior(MERGE_SPEED)

extra = new Car ahead of ego by (0, 15),
    with blueprint EGO_MODEL,
    with behavior EgoBehavior(EGO_SPEED)

require (ego.laneSection._fasterLane is None)        # ego is already in leftmost lane
require (ego.laneSection._slowerLane is not None)    # has a middle lane next to it
terminate when (distance to egoSpot) > 150
