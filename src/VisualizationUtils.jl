# General visualization utils


# create a new Visualizer window with home axis
function startDefaultVisualization(;show::Bool=true,
                                    draworigin::Bool=true,
                                    originscale::Float64=1.0  )
    #
    global drawtransform

    viz = MeshCat.Visualizer()
    if draworigin
      setobject!( viz[:origin], Triad(originscale) )
      settransform!( viz[:origin], drawtransform ∘ (Translation(0.0, 0.0, 0.0) ∘ LinearMap(CTs.Quat(1.0,0,0,0))))
    end

    # open a new browser tab if required
    show && open(viz)

    return viz
end

"""
    $(SIGNATURES)
Initialize empty visualizer.
"""
function initVisualizer(;show::Bool=true)
    @warn "initVisualizer is deprecated, use startDefaultVisualization(..) instead"
    startDefaultVisualization(show=show)
end



function visualizeVariableCache!(vis::Visualizer,
                                 cachevars::Dict{Symbol, Tuple{Symbol, Vector{Bool}, Vector{Float64}}};
                                 sessionId::String="Session"  )::Nothing
    #

    @info "going for visualization loop"

    # draw all that the cache requires
    for (vsym, valpair) in cachevars
        @show vsym
        # TODO -- consider upgrading to MultipleDispatch with actual softtypes
        if valpair[1] == :Point2
            visPoint2!(vis, sessionId, vsym, valpair[3],  updateonly=valpair[2][1])
        elseif valpair[1] == :Pose2
            visPose2!(vis, sessionId, vsym, valpair[3],  updateonly=valpair[2][1])
        elseif valpair[1] == :Point3
            visPoint3!(vis, sessionId, vsym, valpair[3],  updateonly=valpair[2][1])
        elseif valpair[1] == :Pose3
            visPose3!(vis, sessionId, vsym, valpair[3],  updateonly=valpair[2][1])
        else
            error("Unknown softtype symbol to visualize from cache.")
        end
        valpair[2][1] = true
    end

    return nothing
end





#
