#all types shoud inheret from AbstractAmphitheatre and provide a visualize! function
abstract type AbstractAmphitheatre end

#pose landmark draw property #TODO Move to core?
mutable struct plDrawProp
	scale::Float64
	sphereScale::Float64
	color::RGBA
end

plDrawProp() = plDrawProp(0.3, 0.1, RGBA())

# ============================================================
# --------------------BasicFactorGraphPose--------------------
# ============================================================

struct BasicFactorGraphPose <: AbstractAmphitheatre
	robotId::String
	sessionId::String
	fg::FactorGraph

	nodes::Dict{Symbol, AbstractPointPose} #poseId, Softtype
	meanmax::Symbol
	zoffset::Float64
	drawPath::Bool
	#pose drawing propeties
	poseProp::plDrawProp
	#landmark drawing propeties
	landmarkProp::plDrawProp
end


"""
    $(SIGNATURES)
Basic visualizer object to draw poses and landmarks.
"""
function BasicFactorGraphPose(robotId::String, sessionId::String, fg::FactorGraph;
							  meanmax::Symbol=:max,
						      zoffset::Float64=0.0,
							  drawPath::Bool=true,
							  poseProp::plDrawProp = plDrawProp(0.3, 0.1, RGBA(1,1,0,0.5)),
							  landmarkProp::plDrawProp = plDrawProp(0.3, 0.2, RGBA(0,1,0,0.5)))

    return BasicFactorGraphPose(robotId, sessionId, fg, Dict{Symbol,AbstractPointPose}(),
							    meanmax,
							    zoffset,
							    drawPath,
							    poseProp,
							    landmarkProp)
end

"""
    $(SIGNATURES)
Basic visualizer object visualize! function.
"""
function visualize!(vis::Visualizer, basicfg::BasicFactorGraphPose)::Nothing
	#TODO maybe improve this function to lower memmory allocations

	fg = basicfg.fg

	robotId = basicfg.robotId
	sessionId = basicfg.sessionId


	# get all variables
    xx, ll = IIF.ls(fg)
    vars = union(xx, ll)

	basicfg.drawPath && (trackPoints = Point3f0[])
    # update the variable point-estimate cache
    for vsym in vars

        # get vertex and estimate from the factor graph object
        vert = getVert(fg, vsym)
        X = getKDE(vert)

        xmx = basicfg.meanmax == :max ? getKDEMax(X) : getKDEMean(X)

        # get the variable type
        typestr = Caesar.getData(vert).softtype |> typeof
		typesym = Symbol("Arena$typestr")

		nodef = getfield(Arena, typesym)

		#NOTE make sure storage order and softtypes are always the same
		nodestruct = nodef(xmx...)

		nodelabels = Caesar.getData(vert).softtype.labels
		if in("POSE", nodelabels)
			groupsym = :poses
			drawProp = basicfg.poseProp
		elseif in("LANDMARK", nodelabels)
			groupsym = :landmarks
			drawProp = basicfg.landmarkProp

		# for savety fall back to symbol names
		elseif string(vsym)[1] == 'l'
			groupsym = :landmarks
			drawProp = basicfg.landmarkProp
		elseif string(vsym)[1] == 'x'
			groupsym = :poses
			drawProp = basicfg.poseProp
		else
			@warn "Unknown symbol encountered $vsym"
			groupsym = :unknown
		end


		isnewnode = !haskey(basicfg.nodes, vsym)
		if isnewnode
			push!(basicfg.nodes, vsym=>nodestruct)
		else
			basicfg.nodes[vsym] = nodestruct
		end

		visNode!(vis[robotId][sessionId][groupsym][vsym], nodestruct, isnewnode,
				 zoffset = basicfg.zoffset,
				 scale = drawProp.scale,
				 sphereScale = drawProp.sphereScale,
				 color = drawProp.color)

		#FIXME this is bad, but just testing feature TODO figure out how to do it properly
		basicfg.drawPath && groupsym == :poses && push!(trackPoints, Point3f0(xmx[1],xmx[2],0.0))

    end

	basicfg.drawPath && setobject!(vis[robotId][sessionId][:track], Object(PointCloud(trackPoints), LineBasicMaterial(), "Line"))

    return nothing
end


# ============================================================
# -----------------------BasicGraffPose-----------------------
# ============================================================

struct BasicGraffPose <: AbstractAmphitheatre
	robotId::String
	sessionId::String
	config::GraffConfig
	nodes::Dict{Symbol, AbstractPointPose} #poseId, AbstractPointPose

	meanmax::Symbol
	zoffset::Float64
	drawPath::Bool
	#pose drawing propeties
	poseProp::plDrawProp
	#landmark drawing propeties
	landmarkProp::plDrawProp
end

"""
   $(SIGNATURES)
Basic visualizer object to draw poses and landmarks from GraffSDK.
"""
function BasicGraffPose(config::GraffConfig;
							  meanmax::Symbol=:max,
						      zoffset::Float64=0.0,
							  drawPath::Bool=true,
							  poseProp::plDrawProp = plDrawProp(0.3, 0.1, RGBA(1,1,0,0.5)),
							  landmarkProp::plDrawProp = plDrawProp(0.3, 0.2, RGBA(0,1,0,0.5)))

   return BasicGraffPose(config.robotId, config.sessionId, config, Dict{Symbol,AbstractPointPose}(),
							    meanmax,
							    zoffset,
							    drawPath,
							    poseProp,
							    landmarkProp)
end

function visualize!(vis::Visualizer, grafffg::BasicGraffPose)::Nothing
	#TODO maybe improve this function to lower memmory allocations


	# get the Graff factor graph object
	robotId = grafffg.robotId
	sessionId = grafffg.sessionId

	nodes = GraffSDK.getNodes(robotId, sessionId).nodes

	for nod in nodes


		# TODO fix hack -- use softtype instead, see http://www.github.com/GearsAD/GraffSDK.jl#72
		if nod.mapEst == nothing
		    continue
		end
		if length(nod.mapEst) == 2
		    typesym = :ArenaPoint2
		elseif length(nod.mapEst) == 3 && nod.label[1] == 'x'
		    typesym = :ArenaPose2
		elseif length(nod.mapEst) == 3 && nod.label[1] == 'l'
		    typesym = :ArenaPoint3
		elseif length(nod.mapEst) == 6 && nod.label[1] == 'x'
		    typesym = :ArenaPose3
		else
		    typesym = :error
		    error("Unknown estimate dimension and naming")
		end

		nodef = getfield(Arena, typesym)
		#NOTE make sure storage order and softtypes are always the same
		nodestruct = nodef(nod.mapEst...)

		# TODO Can we alwyas assume labels are correct? If so, this will work nicely
		# nodelabels = Caesar.getData(vert).softtype.labels
		# if length(nodelabels) > 0
		# 	groupsym = Symbol(nodelabels[1])
		# else
		# 	groupsym = :group
		# end

		vsym = Symbol(nod.label)

		if string(vsym)[1] == 'l'
			groupsym = :landmarks
			drawProp = grafffg.landmarkProp
		elseif string(vsym)[1] == 'x'
			groupsym = :poses
			drawProp = grafffg.poseProp
		else
			@warn "Unknown symbol encountered $vsym"
			groupsym = :unknown
		end

		isnewnode = !haskey(grafffg.nodes, vsym)
		if isnewnode
			push!(grafffg.nodes, vsym=>nodestruct)
		else
			grafffg.nodes[vsym] = nodestruct
		end

		# visNode!(vis[robotId][sessionId][groupsym][vsym], nodestruct, isnewnode)
		visNode!(vis[robotId][sessionId][groupsym][vsym], nodestruct, isnewnode,
				 zoffset = grafffg.zoffset,
				 scale = drawProp.scale,
				 sphereScale = drawProp.sphereScale,
				 color = drawProp.color)
	end

	return nothing
end
