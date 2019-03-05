# Tutorial on conventional 2D SLAM example
# This tutorial shows how to use some of the commonly used factor types
# This tutorial follows from the ContinuousScalar example from IncrementalInference
using GraffSDK
using GraffSDK.DataHelpers
using ProgressMeter
using UUIDs
using IncrementalInference
using RoME
using Arena.Amphitheatre
using Colors
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
addVariable(:x0, Pose2, ["POSE"])
# Add at a fixed location PriorPose2 to pin :x0 to a starting location (10,10, pi/4)
addFactor([:x0], IIF.Prior( MvNormal([0.0; 0.0; 0.0], Matrix(Diagonal([0.1;0.1;0.05].^2)) )))


println(" - Adding hexagonal driving pattern to session...")
@showprogress for i in 0:5
    psym = Symbol("x$i")
    nsym = Symbol("x$(i+1)")
    println(" - Pose $nsym: Adding new odometry measurement...")
    addVariable(nsym, Pose2, ["POSE"])

    pp = Pose2Pose2(MvNormal([1.0;0;pi/3], Matrix(Diagonal([0.1;0.1;0.1].^2))))
    addFactor([psym;nsym], pp)
end

# 5. Now lets add a couple landmarks
# Ref: https://github.com/dehann/RoME.jl/blob/master/examples/Slam2dExample.jl#L35
addVariable(:l1, Point2, ["LANDMARK"])
p2br2 = Pose2Point2BearingRange(Normal(0,0.1),Normal(2.0,0.2))
addFactor([:x0; :l1], p2br2)
addFactor([:x6; :l1], p2br2)

# Landmarks generally require more work once they're created, e.g. creating factors,
# so they are not set to ready by default. Once you've completed all the factor links and want to solve,
# call putReady to tell the solver it can use the new nodes. This is added to the end of the processing queue.
putReady(true)

# 5. Create AbstractAmphitheatre container to hold different visualizers
visdatasets = AbstractAmphitheatre[]
graffVis = BasicGraffPose(config)

push!(visdatasets, graffVis)

vis, vistask = visualize(visdatasets)


# 6. now create a local fg hexslam
# start with an empty factor graph object
fg = initfg()

# Add the first pose :x0
addVariable!(fg, :x0, Pose2, labels=["POSE"])

# Add at a fixed location PriorPose2 to pin :x0 to a starting location (10,10, pi/4)
addFactor!(fg, [:x0], IIF.Prior( MvNormal([4; 0; -pi], Matrix(Diagonal([0.1;0.1;0.05].^2)) )))

#
romeVis = BasicFactorGraphPose("DemoRobot","LocalHexVisDemo"*string(uuid4())[1:6], fg, meanmax=:mean, poseProp = plDrawProp(0.3, 0.1, RGBA(0,1,1,0.5)))

push!(visdatasets, romeVis)


# Drive around in a hexagon
for i in 0:5
  psym = Symbol("x$i")
  nsym = Symbol("x$(i+1)")
  addVariable!(fg, nsym, Pose2, labels=["POSE"])
  pp = Pose2Pose2(MvNormal([1.0;0;pi/3], Matrix(Diagonal([0.1;0.1;0.1].^2))))
  addFactor!(fg, [psym;nsym], pp )
end


# Add landmarks with Bearing range measurements
addVariable!(fg, :l1, Point2, labels=["LANDMARK"])
    p2br = Pose2Point2BearingRange(Normal(0,0.1),Normal(2.0,0.2))
    addFactor!(fg, [:x0; :l1], p2br)


# Add landmarks with Bearing range measurements
p2br2 = Pose2Point2BearingRange(Normal(0,0.1),Normal(2.0,0.2))
    addFactor!(fg, [:x6; :l1], p2br2)

# solve
batchsolve = @async batchSolve!(fg)


##
@info "To stop call stopAmphiVis!()"
stopAmphiVis!()
