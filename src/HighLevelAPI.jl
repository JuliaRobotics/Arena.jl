# high level user API

# two major visualization functions are used, namely:
# - Memory direction with visualize(::FactorGraph, ...)
# - Cloud access with visualize(robot::String, session::String, ...)


"""
    $(SIGNATURES)

Set the global transform for modifying the final draw step, for example Z up or Z down convention.

Example:
```julia
using Arena
# default is Z up

# make Z down
setGlobalDrawTransform!(quat=Quat(0.0,1.0,0.0,0.0))
```
"""
function setGlobalDrawTransform!(;trans=Translation(0.0,0.0,0.0), quat::Rotations.Quat=Quat(1.0,0.0,0.0,0.0))
  global drawtransform = trans ∘ LinearMap(quat)
end

"""
    $(SIGNATURES)

Toggle global boolean flag to terminate the visualization loop.
"""
function stopVis!()
  global loopvis
  loopvis = false
  nothing
end


function extractRobotSession!(rose_fgl::Union{FactorGraph, Tuple{<:AbstractString, <:AbstractString}},
                              params::Dict{Symbol, Any}  )

    config = nothing

    # robot and session defaults
    params[:robotId] = :Bot
    params[:sessionId] = :Session
    if isa(rose_fgl, FactorGraph)
        if rose_fgl.robotname != "" && rose_fgl.robotname != "NA"
            params[:robotId] = Symbol(rose_fgl.robotname)
        end
        if rose_fgl.sessionname != "" && rose_fgl.sessionname != "NA"
            params[:sessionId] = Symbol(rose_fgl.sessionname)
        end
    else
        # setup Graff config (iff a Graff visualization)
        getGraffConfig() == nothing && error("GraffSDK is not configured, please call loadGraffConfig() to set up Graff.")
        config = getGraffConfig()
        params[:robotId] = Symbol(rose_fgl[1])
        params[:sessionId] = Symbol(rose_fgl[2])
        config.robotId = string(params[:robotId])
        config.sessionId = string(params[:sessionId])
    end
    return config
end

"""
    $(SIGNATURES)

High level interface to launch webserver process that draws the factor graph contents using Three.js and MeshCat.jl.

Examples:
---------

```julia
# start webserver visible anywhere on the network on port 8000.
using GraffSDK, Arena
@async visualize( (robot, session), meanmax=:max )
```

Or view local memory `FactorGraph` version:
```julia
# also open a browser to connect to the three.js webserver
using Arena
@async visualize(fg, show=true, plugins=[myplugin1;])
```

See src/plugins/Template.jl for defining your own plugin to be rendered in the visualization loop.
```julia
function pluginCallback(vis::MeshCat.Visualizer, params::Dict{String, Any}, rose_fgl) ... end
```

**Note** plugins do not have to be defined in Arena, Main context or users repo is sufficient.
"""
function visualize(rose_fgl::Union{FactorGraph, Tuple{<:AbstractString, <:AbstractString}};
                   show::Bool=true,
                   meanmax=:max,
                   plugins::Vector=Function[]  )::Nothing
    #
    global loopvis
    global drawtransform

    loopvis = true

    # standard parameters dictionary
    params = Dict{Symbol, Any}()

    # set up basics in params and load Graff config if available
    extractRobotSession!(rose_fgl, params)

    # the visualizer object itself
    vis = startDefaultVisualization(show=show)

    # default variable caching format:  (softtype, already-drawn, mapEst)
    params[:cachevars] = Dict{Symbol, Tuple{Symbol, Vector{Bool}, Vector{Float64}}}()

    # Prepend default plugins to be executed
    plugins = union([cacheVariablePointEst!; visualizeVariableCache!], plugins)

    # run the visualization loop
    while loopvis
        # iterate through all listed plugin callbacks, such sa pointclouds / images / reprojections / etc.
        for callback in plugins
            try
                callback(vis, params, rose_fgl)
            catch ex
                io = IOBuffer()
                showerror(io, ex, catch_backtrace())
                err = String(take!(io))
                @error "Visualization plugin failure -- callback=$(string(callback)) errored: $ex"
                @error "Error! $err"
            end
        end

        # take a break and repeat
        sleep(1)
    end

    @info "visualize is finalizing."
    nothing
end


### Some old code -- will be deleted soon enough

# xx, ll = ls(fgl)
# for x in xx
#   X = getKDE(fgl, x)
#   xmx = meanmax == :max ? getKDEMax(X) : getKDEMean(X)
#
#   if !haskey(cachevars, x)
#     triad = Triad(1.0)
#     cachevars[x] = deepcopy(xmx)
#   end
#
#     setobject!(vis[:poses][x], triad)
#
#   cachevars[x][:] .= xmx
#   trans = Translation(xmx[1:2]..., 0.0) ∘ LinearMap(RotZ(xmx[3]))
#   settransform!(vis[:poses][x], drawtransform ∘ trans)
# end
