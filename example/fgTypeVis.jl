# Visualize 2 sessions in Arena using local fgs

using UUIDs
using IncrementalInference
using RoME
using Arena

##
# create a local fg hexslam
# start with an empty factor graph object

fg1 = initfg()
v = addNode!(fg1, :x0, Pose2) # Add the first pose :x0
addFactor!(fg1, [:x0], IIF.Prior( MvNormal([0; 0; 0], Matrix(Diagonal([0.1;0.1;0.05].^2)) ))) # Add at a fixed location PriorPose2 to pin :x0 to a starting location (10,10, pi/4)
romeVis1 = Arena.BasicFactorGraphPose("DemoRobot","LocalHexVisDemo"*string(uuid4())[1:6], fg1, meanmax=:mean, poseProp = Arena.plDrawProp(0.3, 0.1, RGBA(0,1,1,0.5)))

fg2 = initfg()
addNode!(fg2, :x0, Pose2) # Add the first pose :x0
addFactor!(fg2, [:x0], IIF.Prior( MvNormal([4; 0; -pi], Matrix(Diagonal([0.1;0.1;0.05].^2)) ))) # Add at a fixed location PriorPose2 to pin :x0 to a starting location (10,10, pi/4)
romeVis2 = Arena.BasicFactorGraphPose("DemoRobot","LocalHexVisDemo"*string(uuid4())[1:6], fg2, meanmax=:mean)

# Create AbstractVarsVis container to hold different visualizers
visdatasets = Arena.AbstractAmphitheatre[romeVis1, romeVis2]

vis, vistask = Arena.visualize(visdatasets)

##
for session in visdatasets
    fg = session.fg

    # Drive around in a hexagon
    for i in 0:5
        psym = Symbol("x$i")
        nsym = Symbol("x$(i+1)")
        addNode!(fg, nsym, Pose2)
        pp = Pose2Pose2(MvNormal([1.0;0;pi/3+0.02], Matrix(Diagonal([0.01;0.01;0.1].^2))))
        addFactor!(fg, [psym;nsym], pp )
        ensureAllInitialized!(fg)
        sleep(0.5)
    end

    # Add landmarks with Bearing range measurements
    addNode!(fg, :l1, Point2, labels=["LANDMARK"])
    p2br = Pose2Point2BearingRange(Normal(0,0.01),Normal(2.0,0.1))
    addFactor!(fg, [:x6; :l1], p2br)

    # Add landmarks with Bearing range measurements
    p2br2 = Pose2Point2BearingRange(Normal(0,0.01),Normal(2.0,0.1))
    addFactor!(fg, [:x6; :l1], p2br2)
    ensureAllInitialized!(fg)
end

addFactor!(fg1, [:l1], PriorPoint2(MvNormal([2.,0], Matrix(Diagonal([0.001, 0.001].^2))) ))
addFactor!(fg2, [:l1], PriorPoint2(MvNormal([2.,0], Matrix(Diagonal([0.001, 0.001].^2))) ))

## solve
@async batchSolve!(fg1)
@async batchSolve!(fg2)

##
@info "To stop call Arena.stopAmphiVis!()"
#
Arena.stopAmphiVis!()
