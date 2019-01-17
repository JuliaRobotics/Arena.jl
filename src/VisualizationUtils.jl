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
                                 cachevars::Dict{Symbol, Tuple{Symbol, Vector{Bool}, Vector{Float64}}},
                                 rose_fgl,
                                 params::Dict{String, Any}  )::Nothing
    #

    sessionId="Session"
    if isa(rose_fgl, FactorGraph) && (rose_fgl.sessionname != "" || rose_fgl.sessionname != "NA")
        sessionId = rose_fgl.sessionname
    elseif isa(rose_fgl, FactorGraph)
        sessionId = rose_fgl[2]
    end


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





struct TagkTl
	tagID::Symbol
	kTl::Vector{Float64}
end

"""
    drawTagsonPose!
Draw tags on pose.
""" #TODO: confirm xTc or cTx
function drawTagsonPose!(botvis::Arena.BotVis2,
                         tagsOnPoses::Dict{Symbol,Vector{TagkTl}};
                         sessionId::String="Session" )
    #
	lmpoint = HyperSphere(Point(0.,0,0), 0.05)
	blueMat = MeshPhongMaterial(color=RGBA(0, 0, 1, 0.5))

	for x = keys(tagsOnPoses)
	    for tag in tagsOnPoses[x]
			setobject!(botvis.vis[:poses][x][tag.tagID], lmpoint, blueMat)
			trans = Translation(tag.kTl)
			settransform!(botvis.vis[:poses][x][tag.tagID], trans)
	    end
	end
end

# tagsOnPoses = Dict{Symbol, Vector{TagkTl}}()



#
