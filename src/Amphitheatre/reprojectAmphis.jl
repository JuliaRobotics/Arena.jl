"""
	$(TYPEDEF)
Struct to store tag id with translations from body to landmark
"""
struct TagkTl
	tagID::Symbol
	ktl::Translation
	kQl::Quat
end

# ============================================================
# --------------------TagOnPose--------------------
# ============================================================
# import Arena.Amphitheatre: visualize!

struct TagOnPose <: AbstractAmphitheatre
	robotId::String
	sessionId::String

	tags::Dict{Symbol,Vector{TagkTl}}

	isdrawn::Dict{Symbol, Bool}
	#tag on pose drawing propeties
	tagProp::plDrawProp
end


TagOnPose(robotId::String, sessionId::String, tagsOnPoses::Dict{Symbol,Vector{TagkTl}};
								tagProp::plDrawProp = plDrawProp(0.2, 0.1, RGBA(1,0,1,0.5))) =
			TagOnPose(robotId, sessionId, tagsOnPoses, Dict{Symbol, Bool}(), tagProp)


"""
    $(SIGNATURES)
Basic visualizer object visualize! function.
"""
function visualize!(vis::Visualizer, top::TagOnPose)::Nothing
	#TODO maybe improve this function to lower memmory allocations

	robotId = top.robotId
	sessionId = top.sessionId

	tagsOnPoses = top.tags
	isdrawn = top.isdrawn
	tagProp = top.tagProp

	for poseKey in keys(tagsOnPoses)

		if !get(isdrawn, poseKey, false)
			haskey(isdrawn, poseKey) ? isdrawn[poseKey] = true : push!(isdrawn, poseKey=>true)

			for tag = tagsOnPoses[poseKey]

				tform = tag.ktl ∘ LinearMap(tag.kQl)

				visPose!(vis[robotId][sessionId][:poses][poseKey][tag.tagID], tform,
							scale = tagProp.scale,
							sphereScale = tagProp.sphereScale,
							color = tagProp.color)
			end
		end
	end

    return nothing
end
