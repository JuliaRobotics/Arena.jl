# Reproject Bearing Range factors to see what is happening.



struct TagkTl
	tagID::Symbol
	kTl::Vector{Float64}
end


"""
    $(SIGNATURES)

Draw tags on pose.
""" #TODO: confirm xTc or cTx
function visTagsOnPose!(vis::Visualizer,
                        tagsOnPoses::Dict{Symbol,Vector{TagkTl}},
                        sessionId::Symbol )
    #
	lmpoint = HyperSphere(Point(0.,0,0), 0.05)
	blueMat = MeshPhongMaterial(color=RGBA(0, 0, 1, 0.5))

	for x = keys(tagsOnPoses)
	    for tag in tagsOnPoses[x]
			setobject!(botvis.vis[sessionId][:poses][x][tag.tagID], lmpoint, blueMat)
			trans = CTs.Translation(tag.kTl)
			settransform!(botvis.vis[sessionId][:poses][x][tag.tagID], trans)
	    end
	end
end



"""
    $(SIGNATURES)

Main plugin callback function
"""
function reprojectBearingRange(vis::MeshCat.Visualizer,
                               params::Dict{Symbol, Any},
                               rose_fgl)
    #

    # create the necessary cache Dict
    tagsOnPoses = Dict{Symbol,Vector{TagkTl}}()
    if !haskey(params, :tagsOnPoses)
        # point to the required memory
        params[:tagsOnPoses] = tagsOnPoses
    else
        # convenience variable avoiding Dict look-up in later loops
        tagsOnPoses = params[:tagsOnPoses]
    end

    # populate / update the tag cache
    for (xx, val) in params[:cachevars]
        # add projections only once and ensure pose is already drawn in viewer
        if string(xx)[1] == 'x' && val[2][1] && !haskey(tagsOnPose, xx)
            # @show xx, val[1] == :Pose2  # assume this is a pose

            # get tags and measurements
            poseTags = getBearingRangesOnPose(rose_fgl, xx)

            # cache the tags to be projected from this pose
            # if haskey(tagsOnPoses, xx)
            #     push!(tagsOnPoses[xx], TagkTl(???) )
            # else
            #     tagsOnPoses[xx] = TagkTl[TagkTl(???);]
            #     @info "reprojectBearingRange plugin needs to update an already existing tagOnPose ???"
            # end
        end
    end

    # visualize the contents of the cache
    visTagsOnPose!(vis, params[:tagsOnPoses], params[:sessionId])

    nothing
end
