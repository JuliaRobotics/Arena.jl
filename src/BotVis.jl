
const lmpoint = HyperSphere(Point(0.,0,0), 0.05)
const greenMat = MeshPhongMaterial(color=RGBA(0, 1, 0, 0.5))
const redMat = MeshPhongMaterial(color=RGBA(0, 1, 0, 0.5))


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
            println(x, " ", xmx)
        else
            botvis.landmarks[x] => (xmx[1],xmx[2],0.0)
            trans = Translation(xmx[1:2]..., 0.0)
            settransform!(botvis.vis[:landmarks][x], trans)
        end
    end
end

##
"""
botvis = initBotVis2(showLocal=true)
drawPoses!(botvis, fg)
drawLandmarks2!(botvis, fg)
""""
