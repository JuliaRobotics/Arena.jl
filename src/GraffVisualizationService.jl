using GraffSDK
using MeshCat
using CoordinateTransformations
import GeometryTypes: HyperRectangle, Vec, Point, HomogenousMesh, SignedDistanceField, Point3f0
import ColorTypes: RGBA, RGB

# Internal transform functions
function projectPose2(renderObject, node::NodeDetailsResponse)::Nothing
    mapEst = node.properties["MAP_est"]
    trans = Translation(mapEst[1],mapEst[2],0) ∘ LinearMap(RotZ(mapEst[3]))
    settransform!(renderObject, trans)
    return nothing
end

function projectPose3(renderObject, node::NodeDetailsResponse)::Nothing
    mapEst = node.properties["MAP_est"]
     # one day when this changes to quaternions -- for now though Pose3 is using Euler angles during infinite product approximations (but convolutions are generally done on a proper rotation manifold)
     # yaw = convert(q).theta3
    trans = Translation(mapEst[1],mapEst[2],mapEst[3])
    settransform!(renderObject, LinearMap(RotZ(mapEst[6])) ∘ trans)
    return nothing
end

# Callbacks for pose transforms
poseTransforms = Dict{String, Function}(
    "Pose2" => projectPose2,
    "Pose3" => projectPose3
)

"""
$(SIGNATURES)
Visualize a session using MeshCat.
Return: Nothing.
"""
function visualizeSession(robotId::String, sessionId::String, bigDataImageKey::String = "", pointCloudKey::String = "")::Nothing
    config = getGraffConfig()
    if config == nothing
        error("Graff config is not set, please call setGraffConfig with a valid configuration.")
    end

    # Create a new visualizer instance
    vis = Visualizer()
    open(vis)

    # Get the session info
    println("Get the session info for session '$sessionId'...")
    sessionInfo = getSession(robotId, sessionId)
    println("Looking if we have a pose transform for '$(sessionInfo.initialPoseType)'...")
    if isempty(sessionInfo.initialPoseType)
        error("The session doesn't have a specified pose type - please provide a pose type when creating the session with the parameter 'initialPoseType'")
    end
    if !haskey(poseTransforms, sessionInfo.initialPoseType)
        error("Need an explicit transform for '$(sessionInfo.initialPoseType)' to visualize it. Please edit VisualizationService.jl and add a new PoseTransform.")
    end
    println("Good stuff, using it!")
    pose2TransFunc = poseTransforms[sessionInfo.initialPoseType]

    # Retrieve all variables and render them.
    println("Retrieving all variables and rendering them...")
    nodesResponse = getNodes(robotId, sessionId)
    println(" -- Rendering $(length(nodesResponse.nodes)) nodes for session $sessionId for robot $robotId...")
    @showprogress for nSummary in nodesResponse.nodes
        node = getNode(robotId, sessionId, nSummary.id)
        label = node.label

        println(" - Rendering $(label)...")
        if haskey(node.properties, "MAP_est")
            mapEst = node.properties["MAP_est"]

            # Parent triad
            triad = Triad(1.0)
            setobject!(vis[label], triad)
            pose2TransFunc(vis[label], node)
        else
            warn("  - Node hasn't been solved, can't really render this one...")
        end
    end
    # Rendering the point clouds and images
    @showprogress for nSummary in nodesResponse.nodes
        node = getNode(robotId, sessionId, nSummary.id)
        label = node.label

        println(" - Rendering $(label)...")
        if haskey(node.properties, "MAP_est")
            mapEst = node.properties["MAP_est"]

            # # Stochastic point clouds
            # if haskey(node.packed, "val")
            #     println(" - Rendering stochastic measurements")
            #     # TODO: Make a lookup as well.
            #     points = map(p -> Point3f0(p[1], p[2], 0), node.packed["val"])
            #     # Make more fancy in future.
            #     # cols = reinterpret(RGB{Float32}, points); # use the xyz value as rgb color
            #     cols = map(p -> RGB{Float32}(1.0, 1.0, 1.0), points)
            #     # pointsMaterial = PointsMaterial(RGB(1., 1., 1.), 0.001, 2)
            #     pointCloud = PointCloud(points, cols)
            #     setobject!(vis[label]["statsPointCloud"], pointCloud)
            # end

            if pointCloudKey != "" # Get and render point clouds
                println(" - Rendering point cloud data for keys that have id = $bigDataImageKey...")
                bigEntries = getDataEntries(robotId, sessionId, nSummary.id)
                for bigEntry in bigEntries
                    if bigEntry.id == pointCloudKey
                        dataFrame = getDataElement(robotId, sessionId, nSummary.id, bigEntry.id)

                        # Form the data.
                        pointData = eval(parse(dataFrame.data))
                        points = Vector{Point3f0}(length(pointData[1]))
                        for i in 1:length(pointData[1])
                            points[i] = Point3f0(pointData[1][i], pointData[2][i], pointData[3][i])
                        end

                        # Make more fancy in future.
                        # cols = reinterpret(RGB{Float32}, points); # use the xyz value as rgb color
                        cols = map(p -> RGB{Float32}(1.0, 1.0, 1.0), points)
                        # pointsMaterial = PointsMaterial(RGB(1., 1., 1.), 0.001, 2)
                        pointCloud = PointCloud(points, cols)
                        setobject!(vis[label][pointCloudKey], pointCloud)
                    end
                end
            end

            # Camera imagery
            if bigDataImageKey != "" # Get and render big data images and pointclouds
                println(" - Rendering image data for keys that have id = $bigDataImageKey...")
                bigEntries = getDataEntries(robotId, sessionId, nSummary.id)
                for bigEntry in bigEntries
                    if bigEntry.id == bigDataImageKey
                        # HyperRectangle until we have sprites
                        box = HyperRectangle(Vec(0,0,0), Vec(0.01, 9.0/16.0/2.0, 16.0/9.0/2.0))
                        dataFrame = getDataElement(robotId, sessionId, nSummary.id, bigEntry.id)
                        image = PngImage(base64decode(dataFrame.data))

                        # Make an image and put it in the right place.
                        texture = Texture(image=image)
                        material = MeshBasicMaterial(map=texture)
                        trans = Translation(1.0,16.0/9.0/4.0,0) ∘ LinearMap(RotX(pi/2.0))
                        setobject!(vis[label]["camImage"], box, material)
                        settransform!(vis[label]["camImage"], trans)
                    end
                end
            end
        else
            warn("  - Node hasn't been solved, can't really render this one...")
        end
    end
end

"""
$(SIGNATURES)
Visualize a session using MeshCat.
Return: Nothing.
"""
function visualizeSession(bigDataImageKey::String = "", pointCloudKey::String = "")::Nothing
    config = getGraffConfig()
    if config == nothing
        error("Graff config is not set, please call setGraffConfig with a valid configuration.")
    end

    if config.robotId == "" || config.sessionId == ""
        error("Your config doesn't have a robot or a session specified, please attach your config to a valid robot or session by setting the robotId and sessionId fields. Robot = $(config.robotId), Session = $(config.sessionId)")
    end

    visualizeSession(config.robotId, config.sessionId, bigDataImageKey, pointCloudKey)
end
