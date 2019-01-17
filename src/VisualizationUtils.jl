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
