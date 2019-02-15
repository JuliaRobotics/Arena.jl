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


push!(visdatasets, BasicGraffPose(config,
                                    meanmax=:max,
                                    poseProp = plDrawProp(0.15, 0.05, RGBA(1,1,0,0.5)),
                                    landmarkProp = plDrawProp(0.2, 0.1, RGBA(0,1,0,0.5))))


push!(visdatasets, GraffTagOnPose(config) )


vis, vistask = visualize(visdatasets, quat=Amphitheatre.Quat(0.0,1.0,0.0,0.0))
vistask



##
stopAmphiVis!()
