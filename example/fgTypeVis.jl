# Tutorial on conventional 2D SLAM example
# This tutorial shows how to use some of the commonly used factor types
# This tutorial follows from the ContinuousScalar example from IncrementalInference

using UUIDs
using IncrementalInference
using RoME
using Arena

# 6. now create a local fg hexslam
# start with an empty factor graph object
fg = initfg()

# Add the first pose :x0
addNode!(fg, :x0, Pose2)

# Add at a fixed location PriorPose2 to pin :x0 to a starting location (10,10, pi/4)
addFactor!(fg, [:x0], IIF.Prior( MvNormal([4; 0; -pi], Matrix(Diagonal([0.1;0.1;0.05].^2)) )))


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


# Create AbstractVarsVis container to hold different visualizers
visdatasets = Arena.AbstractVarsVis[]

romeVis = Arena.BasicFactorGraphPose("DemoRobot","LocalHexVisDemo"*string(uuid4())[1:6], fg)
push!(visdatasets, romeVis)

vistask = @async Arena.visualize(visdatasets)


## solve
batchSolve!(fg)


##
@info "To stop call stopVis!()"
#
stopVis!()
