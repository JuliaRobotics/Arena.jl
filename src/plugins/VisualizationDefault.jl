# Default visualization functions

function cacheVariablePointEst!(dummyvis,
                                params::Dict{Symbol, Any},
                                fgl::FactorGraph;
                                meanmax=:max  )::Nothing
    #
    cachevars = params[:cachevars]

    # get all variables
    xx, ll = IIF.ls(fgl)
    vars = union(xx, ll)

    # update the variable point-estimate cache
    for vsym in vars

        # get vertex and estimate from the factor graph object
        vert = getVert(fgl, vsym)
        X = getKDE(vert)

        # TODO should be defined through params and not a keyword
        xmx = meanmax == :max ? getKDEMax(X) : getKDEMean(X)

        # get the variable type
        typesym = getData(vert).softtype |> typeof |> Symbol

        # cache variable type and estimated value (slightly memory intensive)
        cachevars[vsym] = (typesym, [false;], xmx)
    end

    return nothing
end



"""
    $(SIGNATURES)

Draw variables (triads and points) assing the `cachevars` dictionary is populated with the latest information.  Function intended for internal module use.

`cachevars` === (softtype, [inviewertree=false;], [x,y,theta])
"""
function visualizeVariableCache!(vis::Visualizer,
                                 params::Dict{Symbol, Any},
                                 rose_fgl  )::Nothing
    #

    sessionId="Session"
    if isa(rose_fgl, FactorGraph) && (rose_fgl.sessionname != "" || rose_fgl.sessionname != "NA")
        sessionId = rose_fgl.sessionname
    elseif isa(rose_fgl, FactorGraph)
        sessionId = rose_fgl[2]
    end


    # draw all that the cache requires
    for (vsym, valpair) in params[:cachevars]
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
