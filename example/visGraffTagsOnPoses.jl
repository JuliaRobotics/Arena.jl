using Arena.Amphitheatre
using RoME
using GraffSDK

#Point the giraffe in the right direction
config = loadGraffConfig()
config.userId = ""
config.robotId = ""
config.sessionId = ""

#Set up amphis
visdatasets = AbstractAmphitheatre[]

# visualize factor graph
push!(visdatasets, BasicGraffPose(config,
                                    meanmax=:max,
                                    poseProp = plDrawProp(0.15, 0.05, RGBA(1,1,0,0.5)),
                                    landmarkProp = plDrawProp(0.2, 0.1, RGBA(0,1,0,0.5))))

# visualize april tags on poses
push!(visdatasets, GraffTagOnPose(config) )

# visualize point cloud on poses
push!(visdatasets, Amphitheatre.GraffCloudOnPose(config, CameraModel(640, 480, 387.205, [322.042, 238.544])))

# run visualzer
vis, vistask = visualize(visdatasets, quat=Amphitheatre.Quat(0.0,1.0,0.0,0.0))
vistask


## stop visualizer
stopAmphiVis!()
