# file for all point cloud drawing related functions

function reconstruct(dc::DepthCamera, depth::Array{Float64})
  s = dc.skip
  depth_sampled = depth[1:s:end,1:s:end]
  # assert(depth_sampled.shape == self.xs.shape)
  r,c = size(dc.xs)

  ret = Array{Float64,3}(r,c,3)
  ret[:,:,1] = dc.xs .* depth_sampled
  ret[:,:,2] = dc.ys .* depth_sampled
  ret[:,:,3] = depth_sampled
  return ret
end


function prepcolordepthcloud!( cvid::Int,
      X::Array;
      rgb::Array=Array{<:Colorant,2}(),
      skip::Int=4,
      maxrange::Float64=4.5 )
  #
  pointcloud = nothing
  pccols = nothing
  havecolor = size(rgb,1) > 0
  if typeof(X) == Array{Float64,3}
    r,c,h = size(X)
    Xd = X[1:skip:r,1:skip:c,:]
    rd,cd,hd = size(Xd)
    mask = Xd[:,:,:] .> maxrange
    Xd[mask] = Inf

    rgbss = havecolor ? rgb[1:skip:r,1:skip:c] : nothing
    # rgbss = rgb[1:4:r,1:4:c,:]./255.0
    pts = Vector{Vector{Float64}}()
    pccols = Vector()
    for i in 1:rd, j in 1:cd
      if !isnan(Xd[i,j,1]) && Xd[i,j,3] != Inf
        push!(pts, vec(Xd[i,j,:]) )
        havecolor ? push!(pccols, rgbss[i,j] ) : nothing
        # push!(pccols, RGB(rgbss[i,j,3], rgbss[i,j,2], rgbss[i,j,1]) )
      end
    end
    pointcloud = PointCloud(pts)
  elseif typeof(X) == Array{Array{Float64,1},1}
    pointcloud = PointCloud(X)
    pccols = rgb # TODO: refactor
  elseif size(X,1)==0
    return nothing
  else
    error("dont know how to deal with data type=$(typeof(X)),size=$(size(X))")
  end
  if havecolor
    pointcloud.channels[:rgb] = pccols
  else
    #submap colors
    smc = submapcolor(cvid, length(X))
    pointcloud.channels[:rgb] = smc
  end
  return pointcloud
end



function drawpointcloud!(vis, # ::DrakeVisualizer.Visualizer
                         poseswithdepth::Dict,
                         vsym::Symbol,
                         pointcloud,
                         va,
                         param::Dict,
                         sesssym::Symbol;
                         # imshape=(480,640),
                         wTb::CoordinateTransformations.AbstractAffineMap=
                               Translation(0,0,0.0) ∘ LinearMap(
                               CoordinateTransformations.Quat(1.0, 0, 0, 0))   )
                         # bTc::CoordinateTransformations.AbstractAffineMap=
                         #       Translation(0,0,0.6) ∘ LinearMap(
                         #       CoordinateTransformations.Quat(0.5, -0.5, 0.5, -0.5))  )
  #

  pcsym = Symbol(string("pc_", va != "none" ? va : "ID"))
  setgeometry!(vis[sesssym][pcsym][vsym][:pose], Triad())
  settransform!(vis[sesssym][pcsym][vsym][:pose], wTb) # also updated as parallel track
  setgeometry!(vis[sesssym][pcsym][vsym][:pose][:cam], Triad())
  settransform!(vis[sesssym][pcsym][vsym][:pose][:cam], param["bTc"] )
  setgeometry!(vis[sesssym][pcsym][vsym][:pose][:cam][:pc], pointcloud )

  # these poses need to be update if the point cloud is to be moved
  if !haskey(poseswithdepth,vsym)
    thetype = typeof(vis[sesssym][pcsym][vsym][:pose])
    poseswithdepth[vsym] = Vector{ thetype }()
  end
  push!(poseswithdepth[vsym], vis[sesssym][pcsym][vsym][:pose])

  nothing
end



"""
    $(SIGNATURES)
Draw point cloud on pose.
xTc -> pose to camera transform
""" #TODO: confirm xTc or cTx
function visPointCloudOnPose!(vis::Visualizer, x::Symbol, pointcloud::PointCloud, sessionId, xTc::SE3 = SE3([0,0,0],I))::Nothing
	# TODO: Cleanup and make parameter.
	material = PointsMaterial(size=0.02) # Used to set size of particles
	setobject!(vis[Symbol(sessionId)][:poses][x][:pc], pointcloud, material)
	trans = Translation(xTc.t[1], xTc.t[2], xTc.t[3])∘LinearMap(Quat(xTc.R.R))
	settransform!(vis[Symbol(sessionId)][:poses][x][:pc], trans)
	return nothing
end
function visPointCloudOnPose!(botvis::BotVis2, x::Symbol, pointcloud::PointCloud, sessionId, xTc::SE3 = SE3([0,0,0],I))::Nothing
   visPointCloudOnPose!(botvis.vis, x, pointcloud, sessionId, xTc)
end

function drawPointCloudonPose!(botvis::BotVis2, x::Symbol, pointcloud::PointCloud, xTc::SE3 = SE3([0,0,0],I))::Nothing
    @warn "drawPointCloudonPose! decprecated, use visPointCloudOnPose! instead."
    visPointCloudOnPose!(botvis, x, pointcloud, xTc)
end




"""
    $(SIGNATURES)

Main plugin callback function
"""
function pointCloudPlugins(vis::MeshCat.Visualizer,
                               params::Dict{Symbol, Any},
                               rose_fgl)
    # Assume static list for now...
	if !haskey(params, :dataEntries)
		@info "Getting data entries to cache..."
		entries = getDataEntriesForSession()
		params[:dataEntries] = entries
	end
	if !haskey(params, :depthsDrawn)
		params[:depthsDrawn] = Dict{String, Any}()
	end
	if !haskey(params, :robotConfig)
		params[:robotConfig] = getRobotConfig()
	end

	@show allVarLabels = collect(keys(params[:cachevars]))

	for varLabel in string.(allVarLabels)
		@info "Rendering potential data from $varLabel..."
		if haskey(params[:dataEntries], varLabel)
			dataSet = params[:dataEntries][varLabel]
			dataKeys = Dict(map(i -> i.id, dataSet) .=> dataSet)
			if haskey(dataKeys, "Depth") && haskey(dataKeys, "Sensor") #kQi
				# TODO: Check formats and dimensions and everything that is going to blow up here...
				# literally... everything.
				depthElem = getRawData(getNode(varLabel), dataKeys["Depth"])
				depth = collect(reinterpret(UInt16, base64decode(depthElem)))
				depth = reshape(depth, (640, 480))

				sensorElem = getRawData(getNode(varLabel), dataKeys["Sensor"])
				sensorElem = JSON.parse(sensorElem)
				kQi = map(a -> Float64(a), sensorElem["kQi"]) #Vector{Float64}
				kTc = (SE3([0,0,0], Quaternion(kQi)))
				trans = Translation([0,0,0])∘LinearMap(Quat(kTc.R.R))

				dcam = Arena.CameraModel(640, 480, 387.205, [322.042, 238.544])
                pointcloud = cloudFromDepthImageClampZ(depth, dcam, trans, maxrange=3f0, clampz = [-1f0,1f0]) # , colmap=repeatedColorMap
                Arena.visPointCloudOnPose!(vis, Symbol(varLabel), pointcloud, params[:sessionId])
			else
				@info " --- Skipping because: Depth exists? $(haskey(dataKeys, "Depth") ? "TRUE" : "FALSE"); Sensor exists? $(haskey(dataKeys, "Sensor") ? "TRUE" : "FALSE")"
			end
		else
			@info " --- No data entries for this label..."
		end
	end

	# ID of depth data ~ Depth
	# Format of depth data - hopefully UInt16
	# Dimensions - width x height
	# Camera transform - intrinsic = camModel
	# Camera transform - extrinsic = kQi
    return nothing
end
