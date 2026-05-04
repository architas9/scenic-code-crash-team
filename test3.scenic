# MAP AND MODEL
param map = localPath('../assets/maps/CARLA/Town05.xodr')
param carla_map = 'Town05'
model scenic.simulators.carla.model

# CONSTANTS
EGO_SPEED = 8          # speed of the ego car while turning
DIST_TO_INTERSECTION = Uniform(15, 25) * -1  # distance from the intersection for the ego car

# BEHAVIORS
behavior TurnLeftBehavior():
    # Follow the left turn trajectory at the intersection
    do FollowTrajectoryBehavior(trajectory = ego_trajectory, target_speed = EGO_SPEED)
    terminate

# GEOMETRY / INTERSECTION SELECTION
# Choose a signalized intersection with a left turn maneuver available
signalized_intersections = filter(lambda i: i.isSignalized, network.intersections)
intersection = Uniform(*signalized_intersections)

# Select a left turn maneuver for the ego car
left_turn_maneuvers = filter(lambda m: m.type == ManeuverType.LEFT_TURN, intersection.maneuvers)
require len(left_turn_maneuvers) > 0

ego_maneuver = Uniform(*left_turn_maneuvers)
ego_trajectory = [ego_maneuver.startLane, ego_maneuver.connectingLane, ego_maneuver.endLane]

# SPAWN POINT
# Spawn the ego car upstream of the intersection along the left turn lane
spawn_point = new OrientedPoint on ego_maneuver.startLane.centerline
ego = new Car at spawn_point,
    with behavior TurnLeftBehavior()

# REQUIREMENTS
# Ensure the ego car is far enough from the intersection
require (distance from ego to intersection) > 10
