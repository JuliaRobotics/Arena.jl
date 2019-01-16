# high level user API

# two major visualization functions are used, namely:
# - Memory direction with visualize(::FactorGraph, ...)
# - Cloud access with visualize(robot::String, session::String, ...)

global loopvis = true
global drawtransform = Translation(0.0,0.0,0.0) ∘ LinearMap(Quat(1.0,0.0,0.0,0.0))

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


function stopVis!()
  global loopvis
  loopvis = false
  nothing
end




"""
    $(SIGNATURES)

High level interface to launch webserver process that draws the factor graph contents using Three.js and MeshCat.jl.

Example:
```julia
# start webserver visible anywhere on the network on port 8000.
@async visualize(fg)

# also open a browser to connect to the three.js webserver
@async visualize(fg, show=true)
```
"""
function visualize(fgl::FactorGraph; show::Bool=true, meanmax=:max)
  global loopvis
  global drawtransform

  loopvis = true

  vis = initVisualizer(show=show)
  cachevars = Dict{Symbol, Vector{Float64}}()

  while loopvis

    # rapid fetch of all point-value variable estimates (poses/landmarks/etc.)
    cacheVariablePointEst!( fgl, cachevars )

    # vis or update all variable estimates
    visualizeVariableCache!( vis, cachevars )

    # perform special interest such as point clouds or interpose lines

    # take a break and repeat
    sleep(1)

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
  sleep(1)
  end

  close(vis)
  @info "visualize is finalizing."
end


"""
    $(SIGNATURES)

High level interface to launch webserver process that draws the factor graph contents using Three.js and MeshCat.jl.

Example:
```julia
# start webserver visible anywhere on the network on port 8000.
@async visualize( (robot, session), meanmax=:max )
```
"""
function visualize(robosess::Tuple{<:AbstractString, <:AbstractString};
                   show::Bool=true,
                   meanmax=:max  )
    #
    global loopvis
    global drawtransform

    robotId   = string(robosess[1])
    sessionId = string(robosess[2])

    config = getGraffConfig()
    if config == nothing
        error("Graff config is not set, please call setGraffConfig with a valid configuration.")
    end

    loopvis = true

    vis = initVisualizer(show=show)
    cachevars = Dict{Symbol, Vector{Float64}}()

    while loopvis

        # rapid fetch of all point-value variable estimates (poses/landmarks/etc.)
        cacheVariablePointEst!( robosess, cachevars )

        # vis or update all variable estimates
        visualizeVariableCache!( vis, cachevars )

        # perform special interest such as point clouds or interpose lines

        # take a break and repeat
        sleep(1)
    end

    @info "visualize is finalizing."
    nothing
end
