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
"""
function visualize(rose_fgl::Union{FactorGraph, Tuple{<:AbstractString, <:AbstractString}};
                   show::Bool=true,
                   meanmax=:max,
                   plugins::Vector{Function}=Function[]  )::Nothing
    #
    global loopvis
    global drawtransform

    loopvis = true

    # setup Graff config (iff a Graff visualization)
    robotId   = "Session"
    sessionId = "Bot"
    if !isa(rose_fgl, FactorGraph)
        config = loadGraffConfig()
        if config == nothing
            error("Graff config is not set, please call setGraffConfig with a valid configuration.")
        end
        config.robotId = string(rose_fgl[1])
        config.sessionId = string(rose_fgl[2])
    end

    ## required variables
    # the visualizer object itself
    vis = startDefaultVisualization(show=show)

    # standard parameters dictionary
    params = Dict{Symbol, Any}()

    # (softtype, already-drawn, mapEst)
    params[:cachevars] = Dict{Symbol, Tuple{Symbol, Vector{Bool}, Vector{Float64}}}()

    # Prepend default plugins to be executed
    plugins = union([cacheVariablePointEst!; visualizeVariableCache!], plugins)

    # run the visualization loop
    while loopvis
        # perform special interest such as point clouds or interpose lines
        # do plugins like pointclouds / images / reprojections / etc. here
        for callback in plugins
            try
                callback(vis, params, rose_fgl)
            catch e
                @error "Visualization plugin failure -- callback=$(string(callback)) errored: $e"
                @error stacktrace()
            end
        end

        # take a break and repeat
        sleep(1)
    end

    close(vis)

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
