"""
    $(SIGNATURES)
Initialize empty visualizer
"""
function initVis(;showLocal::Bool = true)
    vis = Visualizer()
    showLocal && open(vis)
    return vis
end



"""
    $(SIGNATURES)
Initialize empty visualizer
"""
function initBotVis2(;showLocal::Bool = true)::BotVis2
    vis = Visualizer()
    showLocal && open(vis)
    return BotVis2(vis,
                   # Dict{Symbol, NTuple{3,Float64}}(),
                   # Dict{Symbol, NTuple{3,Float64}}(),
                   Dict{Symbol, Tuple{Symbol, Vector{Bool}, Vector{Float64}}}() )
end


"""
    $(SIGNATURES)
Draw all poses in an 2d factor graph, use meanmax = :max or :mean for distribution max or mean, respectively.
"""
function drawPoses2!(botvis::BotVis2,
                     fgl::FactorGraph;
                     meanmax::Symbol=:max,
                     triadLength=0.25,
                     sessionId::String="Session" )::Nothing
    #
    xx, ll = Caesar.ls(fgl)

    for x in xx
        X = getKDE(fgl, x)
        xmx = meanmax == :max ? getKDEMax(X) : getKDEMean(X)
        trans = Translation(xmx[1:2]..., 0.0) ∘ LinearMap(RotZ(xmx[3]))
        if !haskey(botvis.cachevars, x)
            triad = Triad(triadLength)
            setobject!(botvis.vis[Symbol(sessionId)][:poses][x], triad)
            botvis.cachevars[x] = (:Pose2, [true;], xmx)
        else
            botvis.cachevars[x][3][:] = xmx
        end
        settransform!(botvis.vis[Symbol(sessionId)][:poses][x], trans)
    end
	return nothing
end

"""
    $(SIGNATURES)
Draw all landmarks in an 2d factor graph, use meanmax = :max or :mean for distribution max or mean, respectively.
"""
function drawLandmarks2!(botvis::BotVis2,
                         fgl::FactorGraph;
                         meanmax::Symbol=:max,
                         sessionId::String="Session"  )::Nothing
    #
    xx, ll = Caesar.ls(fgl)

    for x in ll
        X = getKDE(fgl, x)
        xmx = meanmax == :max ? getKDEMax(X) : getKDEMean(X)
        trans = Translation(xmx[1:2]..., 0.0)
        if !haskey(botvis.cachevars, x)
            setobject!(botvis.vis[Symbol(sessionId)][:landmarks][x], lmpoint, greenMat)
            botvis.cachevars[x] = (:Point2, [true;], [xmx[1]; xmx[2]; 0.0 ] )
        else
            botvis.cachevars[x][3][1:2] = xmx[1:2]
        end
        settransform!(botvis.vis[Symbol(sessionId)][:landmarks][x], trans)
    end
	return nothing
end





#
