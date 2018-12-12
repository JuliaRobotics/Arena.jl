
const lmpoint = HyperSphere(Point(0.,0,0), 0.05)
const greenMat = MeshPhongMaterial(color=RGBA(0, 1, 0, 0.5))
const redMat = MeshPhongMaterial(color=RGBA(0, 1, 0, 0.5))

"""
Type for 2d visualization
"""
struct BotVis2
    vis::Visualizer
    poses::Dict{Symbol, NTuple{3,Float64}}
    landmarks::Dict{Symbol, NTuple{3,Float64}}
end


# something like this later for botvis 3
# poses3::Dict{Symbol,Tuple{Point{3,Float32},Quat{Float64}}}



"""
    $(SIGNATURES)
Initialize empty visualizer
"""
function initBotVis2(;showLocal::Bool = true)

    vis = Visualizer()
    showLocal && open(vis)
    return BotVis2(vis, Dict{Symbol, NTuple{3,Float64}}(), Dict{Symbol, NTuple{3,Float64}}())

end

"""
    $(SIGNATURES)
Draw all poses in an 2d factor graph, use meanmax = :max or :mean for distribution max or mean, respectively.
"""
function drawPoses2!(botvis::BotVis2, fgl::FactorGraph; meanmax::Symbol=:max, triadLength=1.0)

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
end

"""
    $(SIGNATURES)
Draw all landmarks in an 2d factor graph, use meanmax = :max or :mean for distribution max or mean, respectively.
"""
function drawLandmarks2!(botvis::BotVis2, fgl::FactorGraph; meanmax::Symbol=:max)

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
end

#TODO its a start, still need transform etc.
"""
    $(SIGNATURES)
Create a point cloud from a depth image.
""" #TODO fix color map
function cloudFromDepthImage(depths::Array{UInt16,2}, #=colmap::Vector{RGB{N0f8}} = repeatedColorMap=#; d::Int = 2,
                            cu::Float32 = 322.042f0, cv::Float32 = 238.544f0, f::Float32 = 387.205f0, maxrange::Float32 = 10f0)

    (row,col) = size(depths)
    cloud = Point3f0[]
    cloudCol = RGB{Float32}[]

    for u = 1:d:row, v = 1:d:col
        z = depths[u,v]*0.001f0
        if  0 < z < maxrange
            x = (u-cu)/f * z
            y = (v-cv)/f * z
            push!(cloud, Point3f0(z,x,y))
            push!(cloudCol, RGB{Float32}(0.,1.,0.))#colmap[round(Int,(z/maxrange)*2559f0)+1]
        end
    end
    pointcloud = PointCloud(cloud, cloudCol)

    return pointcloud
end

"""
    $(SIGNATURES)
Draw point cloud on pose.
"""
function drawPointCloudonPose!(botvis::BotVis2, x::Symbol, pointcloud::PointCloud)

    setobject!(botvis.vis[:poses][x][:pc], pointcloud)

end


##
"""
botvis = initBotVis2(showLocal=true)
drawPoses!(botvis, fg)
drawLandmarks2!(botvis, fg)
""""
