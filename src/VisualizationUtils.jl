# General visualization utils


"""
    $(SIGNATURES)
Initialize empty visualizer

TODO: Merge with startdefaultvisualization
"""
function initVisualizer(;show::Bool=true)
    vis = Visualizer()
    showLocal && open(vis)
    return vis
end


# create a new Visualizer window with home axis
function startdefaultvisualization(;newwindow::Bool=true,
                                    draworigin::Bool=true,
                                    vismodule=MeshCat)
  # Visualizer.any_open_windows() || Visualizer.new_window(); #Visualizer.new_window()
  viz = vismodule.Visualizer()
  if draworigin
    setgeometry!(viz[:origin], Triad())
    settransform!(viz[:origin], Translation(0.0, 0.0, 0.0) ∘ LinearMap(Rotations.Quat(1.0,0,0,0)))
  end

  # realtime, rttfs = Dict{Symbol, Any}(), Dict{Symbol, AbstractAffineMap}()
  # dc = VisualizationContainer(Dict{Symbol, Visualizer}(), triads, trposes, meshes, realtime, rttfs)
  # visualizetriads!(dc)
  return viz
end





function visualizeVariableCache!(vis::Visualizer,
                                 cachevars::Dict{Symbol, Tuple{Symbol,Vector{Float64}}};
                                 sessionId::String="Session"  )::Nothing
    #

    for (vsym, valpair) in cachevars
        # TODO -- consider upgrading to MultipleDispatch with actual softtypes
        if valpair[1] == :Point2
            visPoint2!(vis, sessionId, vsym, valpair[2])
        elseif valpair[1] == :Pose2
            visPose2!(vis, sessionId, vsym, valpair[2])
        elseif valpair[1] == :Point3
            visPoint3!(vis, sessionId, vsym, valpair[2])
        elseif valpair[1] == :Pose3
            visPose3!(vis, sessionId, vsym, valpair[2])
        else
            error("Unknown softtype symbol to visualize from cache.")
        end

    end

    return nothing
end





#
