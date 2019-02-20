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


		nodes = getNodes(robotId, sessionId)

		for noderesp = nodes.nodes

			dataEntries = getDataEntries(robotId, sessionId, noderesp.id)
			!("TagkTl" in [de.id for de in dataEntries]) && continue

			# node = getNode(robotId, sessionId, noderesp.id)
			d = GraffSDK.getData(robotId, sessionId, noderesp.id, "TagkTl")
			jtags = JSON2.read(d.data)
			poseKey = Symbol(node.label)

			if !get(isdrawn, poseKey, false)
				haskey(isdrawn, poseKey) ? isdrawn[poseKey] = true : push!(isdrawn, poseKey=>true)

				for tag = jtags

					tform = Translation(tag.ktl.translation) ∘ LinearMap(Quat(tag.kQl))

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
