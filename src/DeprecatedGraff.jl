
# Callbacks for pose transforms
# TODO -- MAKE OBSOLETE wishlist, use MultipleDispatch instead of global
global poseTransforms = Dict{String, Function}(
    "Pose2" => projectPose2,
    "Pose3" => projectPose3
)


"""
$(SIGNATURES)
Visualize a session using MeshCat.
Return: Nothing.

OBSOLETE, WORK IN PROGRESS ON new unified visualization functions
"""
function visualizeSession(vis::Visualizer,
                          robotId::String,
                          sessionId::String,
                          bigDataImageKey::String = "",
                          pointCloudKey::String = "",
                          dCamModel::Arena.CameraModel = Arena.CameraModel(640, 480, 387.205, [322.042, 238.544])  )::Nothing
    #
    global poseTransforms
    config = getGraffConfig()
    if config == nothing
        error("Graff config is not set, please call setGraffConfig with a valid configuration.")
    end

    # Create a new visualizer instance
    # vis = Visualizer()
    # open(vis)

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
            triad = Triad(0.5)
            setobject!(vis[label], triad)
            pose2TransFunc(vis[label], node)

            # Landmark
            if "LANDMARK" in node.labels
                sphere = HyperSphere(Point(0.,0,0), 0.1)
                setobject!(vis[label]["landmark"], sphere, MeshLambertMaterial(color=colorant"blue"))
            end
        else
            @warn "  - Node hasn't been solved, can't really render this one..."
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

            bigEntries = getDataEntries(node)
            # Making a material to set the size
        	material = PointsMaterial(color=RGBA(0,1.0,1.0,0.5),size=0.02)

            if pointCloudKey != "" # Get and render point clouds
                println(" - Rendering point cloud data for keys that have id = $bigDataImageKey...")
                for bigEntry in bigEntries
                    if bigEntry.id == pointCloudKey
                        dataFrame = GraffSDK.getData(node, bigEntry.id)
                        dData = base64decode(dataFrame.data)

                        # Testing: Get the sensor pose
                        sensor = JSON.parse(getRawData(node, "Sensor"))
                        kQi = map(a -> Float64(a), sensor["kQi"]) #Vector{Float64}
                        kTc = (SE3([0,0,0], Quaternion(kQi)))
                        trans = Translation([0,0,0])∘LinearMap(Quat(kTc.R.R))

                        # Form it up.
                        c = reinterpret(UInt16, dData)
                        depths = collect(reshape(c, (640, 480)))
                        pointCloud = cloudFromDepthImage(depths, dCamModel; trans=trans)

                        setobject!(vis[label][pointCloudKey], pointCloud, material)
                    end
                end
            end

            # Camera imagery
            if bigDataImageKey != "" # Get and render big data images and pointclouds
                println(" - Rendering image data for keys that have id = $bigDataImageKey...")
                for bigEntry in bigEntries
                    if bigEntry.id == bigDataImageKey
                        # HyperRectangle until we have sprites
                        box = HyperRectangle(Vec(0,0,0), Vec(0.01, 9.0/16.0/2.0, 16.0/9.0/2.0))
                        dataFrame = GraffSDK.getData(robotId, sessionId, nSummary.id, bigEntry.id)
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
            @warn "  - Node hasn't been solved, can't really render this one..."
        end
    end
end

"""
$(SIGNATURES)
Visualize a session using MeshCat.
Return: Nothing.
"""
function visualizeSession(vis::Visualizer; dataImageKey::String = "", pointCloudKey::String = "", dCamModel::Arena.CameraModel = Arena.CameraModel(640, 480, 387.205, [322.042, 238.544]))::Nothing
    config = getGraffConfig()
    if config == nothing
        error("Graff config is not set, please call setGraffConfig with a valid configuration.")
    end

    if config.robotId == "" || config.sessionId == ""
        error("Your config doesn't have a robot or a session specified, please attach your config to a valid robot or session by setting the robotId and sessionId fields. Robot = $(config.robotId), Session = $(config.sessionId)")
    end

    visualizeSession(vis, config.robotId, config.sessionId, dataImageKey, pointCloudKey, dCamModel)
end
