# Tutorial on conventional 2D SLAM example
# This tutorial shows how to use some of the commonly used factor types
# This tutorial follows from the ContinuousScalar example from IncrementalInference
using GraffSDK
using GraffSDK.DataHelpers
using ProgressMeter
using UUIDs
using IncrementalInference
using RoME
using Arena

##

# 1a. Create a Configuration
config = loadGraffConfig();
#Create a hexagonal sessions
config.sessionId = "HexVisDemo"*string(uuid4())[1:6]

@info "Session backlog (queue length) = $(getSessionBacklog())"

# 2. Confirm that the robot already exists, create if it doesn't.
println(" - Creating or retrieving robot '$(config.robotId)'...")
robot = nothing
if isRobotExisting()
    println(" -- Robot '$(config.robotId)' already exists, retrieving it...")
    robot = getRobot();
else
    # Create a new one programatically - can also do this via the UI.
    println(" -- Robot '$(config.robotId)' doesn't exist, creating it...")
    newRobot = RobotRequest(config.robotId, "My New Bot", "Description of my neat robot", "Active");
    robot = addRobot(newRobot);
end
println(robot)

# 3. Create or retrieve the session.
# Get sessions, if it already exists, add to it.
println(" - Creating or retrieving data session '$(config.sessionId)' for robot...")
session = nothing
if isSessionExisting()
    println(" -- Session '$(config.sessionId)' already exists for robot '$(config.robotId)', retrieving it...")
    session = getSession()
else
    # Create a new one
    println(" -- Session '$(config.sessionId)' doesn't exist for robot '$(config.robotId)', creating it...")
    newSessionRequest = SessionDetailsRequest(config.sessionId, "A test dataset demonstrating data ingestion for a wheeled vehicle driving in a hexagon.", "Pose2")
    session = addSession(newSessionRequest)
end
println(session)

# 4. Drive around in a hexagon
println(" - Adding hexagonal driving pattern to session...")
@showprogress for i in 1:6
    deltaMeasurement = [1.0;0;pi/3]
    pOdo = Float64[0.1 0 0; 0 0.1 0; 0 0 0.1]
    println(" - Measurement $i: Adding new odometry measurement '$deltaMeasurement'...")
    @time addOdometryMeasurement(deltaMeasurement, pOdo)
end

# 5. Now lets add a couple landmarks
# Ref: https://github.com/dehann/RoME.jl/blob/master/examples/Slam2dExample.jl#L35
response = addVariable("l1", "Point2", ["LANDMARK"])
newBearingRangeFactor = BearingRangeRequest("x0", "l1",
                          DistributionRequest("Normal", Float64[0; 0.1]),
                          DistributionRequest("Normal", Float64[2.0; 0.2]))
addBearingRangeFactor(newBearingRangeFactor)
newBearingRangeFactor2 = BearingRangeRequest("x6", "l1",
                           DistributionRequest("Normal", Float64[0; 0.1]),
                           DistributionRequest("Normal", Float64[2.0; 0.2]))
addBearingRangeFactor(newBearingRangeFactor2)
# Landmarks generally require more work once they're created, e.g. creating factors,
# so they are not set to ready by default. Once you've completed all the factor links and want to solve,
# call putReady to tell the solver it can use the new nodes. This is added to the end of the processing queue.
putReady(true)

# 5. Create AbstractVarsVis container to hold different visualizers
visdatasets = Arena.AbstractVarsVis[]
graffVis = Arena.BasicGraffPose(config)
push!(visdatasets, graffVis)

vistask = @async Arena.visualize(visdatasets)


# 6. now create a local fg hexslam
# start with an empty factor graph object
fg = initfg()

# Add the first pose :x0
addNode!(fg, :x0, Pose2)

# Add at a fixed location PriorPose2 to pin :x0 to a starting location (10,10, pi/4)
addFactor!(fg, [:x0], IIF.Prior( MvNormal([4; 0; -pi], Matrix(Diagonal([0.1;0.1;0.05].^2)) )))


#
romeVis = Arena.BasicFactorGraphPose("DemoRobot","LocalHexVisDemo"*string(uuid4())[1:6], fg)
push!(visdatasets, romeVis)



# Drive around in a hexagon
for i in 0:5
  psym = Symbol("x$i")
  nsym = Symbol("x$(i+1)")
  addNode!(fg, nsym, Pose2)
  pp = Pose2Pose2(MvNormal([1.0;0;pi/3], Matrix(Diagonal([0.1;0.1;0.1].^2))))
  addFactor!(fg, [psym;nsym], pp )
end


# Add landmarks with Bearing range measurements
addNode!(fg, :l1, Point2, labels=["LANDMARK"])
    p2br = Pose2Point2BearingRange(Normal(0,0.1),Normal(2.0,0.2))
    addFactor!(fg, [:x0; :l1], p2br)


# Add landmarks with Bearing range measurements
p2br2 = Pose2Point2BearingRange(Normal(0,0.1),Normal(2.0,0.2))
    addFactor!(fg, [:x6; :l1], p2br2)

# solve
batchsolve = @async batchSolve!(fg)


##
@info "To stop call stopVis!()"
# stopVis!()
