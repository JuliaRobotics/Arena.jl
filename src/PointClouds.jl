# file for all point cloud drawing related functions



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




function cloudFromDepthImageClampZ(depths::Array{UInt16,2},
                                   cm::Arena.CameraModel,
                                   trans::AffineMap;    #=colmap::Vector{RGB{N0f8}} = repeatedColorMap=#
                                   depthscale = 0.001f0,
                                   skip::Int = 2,
                                   maxrange::Float32=5f0,
                                   clampz = [0f0,1f0],
                                   colmap::Vector{T} = [0f0]  ) where T

	cx = Float32(cm.cc[1])
	cy = Float32(cm.cc[2])
	fx = Float32(cm.fc[1])
	fy = Float32(cm.fc[2])
    (row,col) = size(depths)
    cloud = Point3f0[]
    cloudCol = RGB{Float32}[]

    for u = 1:skip:row, v = 1:skip:col
        z = depths[u,v]*depthscale
        if  0 < z < maxrange
            x = (v-cx)/fx * z
            y = (u-cy)/fy * z
            p = trans(Point3f0(z,x,y))
			if clampz[1] <= p[3] <= clampz[2]
            	push!(cloud, p) #NOTE rotated to Forward Starboard Down, TODO: maybe leave in camera frame?
				if length(colmap) == 2560
					push!(cloudCol, colmap[round(Int,((p[3]-clampz[1])/(clampz[2]-clampz[1]))*2559f0/4f0)+1])
				else
            		push!(cloudCol, RGB{Float32}(0.,1.,0.))#colmap[round(Int,(z/maxrange)*2559f0)+1]
				end
			end
        end
    end
    pointcloud = PointCloud(cloud, cloudCol)

    return pointcloud
end



#TODO its a start, still need transform etc.
"""
    $(SIGNATURES)
Create a {Float32} point cloud from a depth image. Note: rotated to Forward Starboard Down
""" #TODO fix color map
function cloudFromDepthImage(depths::Array{UInt16,2}, cm::CameraModel;
							 depthscale = 0.001f0, skip::Int = 2, maxrange::Float32 = 5f0, trans::AffineMap=Translation(0,0,0))::PointCloud

	cx = Float32(cm.cc[1])
	cy = Float32(cm.cc[2])
	fx = Float32(cm.fc[1])
	fy = Float32(cm.fc[2])
    (row,col) = size(depths)
    cloud = Point3f0[]
    cloudCol = RGB{Float32}[]

    for u = 1:skip:row, v = 1:skip:col
        z = depths[u,v]*depthscale
        if  0 < z < maxrange
            x = (v-cx)/fx * z
			y = (u-cy)/fy * z
			p = trans(Point3f0(z,x,y))
            push!(cloud, p) #NOTE rotated to Forward Starboard Down, TODO: maybe leave in camera frame?
            push!(cloudCol, RGB{Float32}(0.,1.,0.))#colmap[round(Int,(z/maxrange)*2559f0)+1]
        end
    end
    pointcloud = PointCloud(cloud, cloudCol)

    return pointcloud
end



"""
    $(SIGNATURES)
Draw point cloud on pose.
xTc -> pose to camera transform
""" #TODO: confirm xTc or cTx
function drawPointCloudonPose!(botvis::BotVis2, x::Symbol, pointcloud::PointCloud, xTc::SE3 = SE3([0,0,0],I))::Nothing
    setobject!(botvis.vis[:poses][x][:pc], pointcloud)
	trans = Translation(xTc.t[1], xTc.t[2], xTc.t[3])∘LinearMap(Quat(xTc.R.R))
	settransform!(botvis.vis[:poses][x][:pc], trans)
	return nothing
end
