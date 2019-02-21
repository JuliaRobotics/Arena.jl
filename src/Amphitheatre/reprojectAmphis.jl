"""
	$(TYPEDEF)
Struct to store tag id with translations from body to landmark
"""
struct TagkTl
	tagID::Symbol
	ktl::Translation
	kQl::SVector{4}#Quat #Quat does not serialize as wanted out of the box so use SVector instead
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

				tform = tag.ktl ∘ LinearMap(Quat(tag.kQl...))

				visPose!(vis[robotId][sessionId][:poses][poseKey][tag.tagID], tform,
							scale = tagProp.scale,
							sphereScale = tagProp.sphereScale,
							color = tagProp.color)
			end
		end
	end

    return nothing
end



# ============================================================
# --------------------GraffTagOnPose--------------------
# ============================================================
# import Arena.Amphitheatre: visualize!

struct GraffTagOnPose <: AbstractAmphitheatre
	robotId::String
	sessionId::String
	config::GraffConfig

	tags::Dict{Symbol,Vector{TagkTl}}

	isdrawn::Dict{Symbol, Bool}
	#tag on pose drawing propeties
	tagProp::plDrawProp
end


GraffTagOnPose(config::GraffConfig; tagProp::plDrawProp = plDrawProp(0.2, 0.1, RGBA(1,0,1,0.5))) =
			GraffTagOnPose(config.robotId, config.sessionId, config, Dict{Symbol,Vector{TagkTl}}(), Dict{Symbol, Bool}(), tagProp)


"""
    $(SIGNATURES)
Basic visualizer object visualize! function.
"""
function visualize!(vis::Visualizer, top::GraffTagOnPose)::Nothing

	# only read and update from graff once
	isdrawn = top.isdrawn

	if length(isdrawn) == 0

		robotId = top.robotId
		sessionId = top.sessionId

		tagsOnPoses = top.tags

		tagProp = top.tagProp
		config = top.config

		sessionDataEntries = getDataEntriesForSession(config)

		for nodeKey = keys(sessionDataEntries)

			dataEntries = sessionDataEntries[nodeKey]

			!("TagkTl" in [de.id for de in dataEntries]) && continue

			d = GraffSDK.getData(robotId, sessionId, dataEntries[1].nodeId, "TagkTl")
			jtags = JSON2.read(d.data)
			poseKey = Symbol(node.label)

			if !get(isdrawn, poseKey, false)
				haskey(isdrawn, poseKey) ? isdrawn[poseKey] = true : push!(isdrawn, poseKey=>true)

				for tag = jtags

					tform = Translation(tag.ktl.translation) ∘ LinearMap(Quat(tag.kQl...))

					visPose!(vis[robotId][sessionId][:poses][poseKey][Symbol(tag.tagID)], tform,
								scale = tagProp.scale,
								sphereScale = tagProp.sphereScale,
								color = tagProp.color)
				end
			end
		end
	end
    return nothing
end
