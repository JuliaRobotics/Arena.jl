# General visualization utils


"""
    $(SIGNATURES)
Initialize empty visualizer window with home axis.  New browser window will be opened based on `show=true`.
"""
function startDefaultVisualization(;show::Bool=true,
                                    draworigin::Bool=true,
                                    originscale::Float64=1.0  )
    #
    global drawtransform

    viz = MeshCat.Visualizer()
    if draworigin
      setobject!( viz[:origin], Triad(originscale) )
      settransform!( viz[:origin], drawtransform ∘ (Translation(0.0, 0.0, 0.0) ∘ LinearMap( CTs.Quat(1.0,0,0,0))) )
    end

    # open a new browser tab if required
    show && open(viz)

    return viz
end



"""
    $(SIGNATURES)

Draw variables (triads and points) assing the `cachevars` dictionary is populated with the latest information.  Function intended for internal module use.

`cachevars` === (softtype, [inviewertree=false;], [x,y,theta])
"""
function visualizeVariableCache!(vis::Visualizer,
                                 cachevars::Dict{Symbol, Tuple{Symbol, Vector{Bool}, Vector{Float64}}};
                                 sessionId::String="Session"  )::Nothing
    #

    # draw all that the cache requires
    for (vsym, valpair) in cachevars
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
