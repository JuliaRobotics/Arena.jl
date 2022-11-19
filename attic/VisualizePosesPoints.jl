# code to help visualize poses and points

## functions to visualize a point

function visPoint2!(vis::Visualizer,
                    sessionId::Union{String, Symbol},
                    vsym::Union{String, Symbol},
                    tfarr::Vector{Float64};
                    scale::Float64=0.1,
                    updateonly::Bool=false,
                    color=RGBA(0., 1, 0, 0.5),
                    zoffset::Float64=0.0  )::Nothing
    #
    global drawtransform
    if !updateonly
        sphere = HyperSphere(Point(0., 0, 0), scale)
        matcolor = MeshPhongMaterial(color=color)
        setobject!(vis[sessionId][:landmarks][vsym], sphere, matcolor)
    end
    tf = Translation(tfarr[1:2]..., zoffset )
    settransform!(vis[sessionId][:landmarks][vsym], drawtransform ∘ tf)
    nothing
end


function visPoint3!(vis::Visualizer,
                    sessionId::Union{String, Symbol},
                    vsym::Union{String, Symbol},
                    tfarr::Vector{Float64};
                    scale::Float64=0.1,
                    updateonly::Bool=false,
                    color=RGBA(0., 1, 0, 0.5)  )::Nothing
    #
    global drawtransform
    if !updateonly
        sphere = HyperSphere(Point(0., 0, 0), scale)
        matcolor = MeshPhongMaterial(color=color)
        setobject!(vis[sessionId][:landmarks][vsym], sphere, matcolor)
    end
    tf = Translation(tfarr[1:3]...)
    settransform!(vis[sessionId][:landmarks][vsym], drawtransform ∘ tf)
    nothing
end


## Functions to visualize a pose

function visPose2!(vis::Visualizer,
                   sessionId::Union{String, Symbol},
                   vsym::Union{String, Symbol},
                   tfarr::Vector{Float64};
                   scale::Float64=0.3,
                   updateonly::Bool=false,
                   zoffset::Float64=0.0  )::Nothing
    #
    global drawtransform
    if !updateonly
        setobject!(vis[sessionId][:poses][vsym], Triad(scale))
    end
    tf = Translation(tfarr[1:2]..., zoffset) ∘ LinearMap(CTs.RotZ(tfarr[3]))
    settransform!(vis[sessionId][:poses][vsym], drawtransform ∘ tf)
    nothing
end


function visPose3!(vis::Visualizer,
                   sessionId::Union{String, Symbol},
                   vsym::Union{String, Symbol},
                   tfarr::Vector{Float64};
                   scale::Float64=0.3,
                   updateonly::Bool=false  )::Nothing
    #
    global drawtransform
    if !updateonly
        setobject!(vis[sessionId][:poses][vsym], Triad(scale))
    end
    tf = Translation(tfarr[1:3]...) ∘ LinearMap(CTs.RotXYZ(tfarr[4:6]...))
    settransform!(vis[sessionId][:poses][vsym], drawtransform ∘ tf)
    nothing
end
