


# something like this later for botvis 3
# poses3::Dict{Symbol,Tuple{Point{3,Float32},Quat{Float64}}}



"""
    $(SIGNATURES)
Initialize empty visualizer
"""
function initBotVis2(;showLocal::Bool = true)::BotVis2
    vis = Visualizer()
    showLocal && open(vis)
    return BotVis2(vis, Dict{Symbol, NTuple{3,Float64}}(), Dict{Symbol, NTuple{3,Float64}}())
end

"""
    $(SIGNATURES)
Draw all poses in an 2d factor graph, use meanmax = :max or :mean for distribution max or mean, respectively.
"""
function drawPoses2!(botvis::BotVis2, fgl::FactorGraph; meanmax::Symbol=:max, triadLength=0.25)::Nothing

    xx, ll = ls(fgl)

    for x in xx
        X = getKDE(fgl, x)
        xmx = meanmax == :max ? getKDEMax(X) : getKDEMean(X)
        if !haskey(botvis.poses, x)
            triad = Triad(triadLength)
            setobject!(botvis.vis[:poses][x], triad)
            push!(botvis.poses, x => (xmx[1],xmx[2],xmx[3]))
            trans = Translation(xmx[1:2]..., 0.0) ∘ LinearMap(RotZ(xmx[3]))
            settransform!(botvis.vis[:poses][x], trans)
        else
            botvis.poses[x] => (xmx[1],xmx[2],xmx[3])
            trans = Translation(xmx[1:2]..., 0.0) ∘ LinearMap(RotZ(xmx[3]))
            settransform!(botvis.vis[:poses][x], trans)
        end
    end
	return nothing
end

"""
    $(SIGNATURES)
Draw all landmarks in an 2d factor graph, use meanmax = :max or :mean for distribution max or mean, respectively.
"""
function drawLandmarks2!(botvis::BotVis2, fgl::FactorGraph; meanmax::Symbol=:max)::Nothing

    xx, ll = ls(fgl)

    for x in ll
        X = getKDE(fgl, x)
        xmx = meanmax == :max ? getKDEMax(X) : getKDEMean(X)
        if !haskey(botvis.landmarks, x)
            setobject!(botvis.vis[:landmarks][x], lmpoint,  greenMat)
            push!(botvis.landmarks, x => (xmx[1],xmx[2],0.))
            trans = Translation(xmx[1:2]..., 0.0)
            settransform!(botvis.vis[:landmarks][x], trans)
        else
            botvis.landmarks[x] => (xmx[1],xmx[2],0.0)
            trans = Translation(xmx[1:2]..., 0.0)
            settransform!(botvis.vis[:landmarks][x], trans)
        end
    end
	return nothing
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
