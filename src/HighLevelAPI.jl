# high level user API

global loopvis = true
global drawtransform = Translation(0.0,0.0,0.0) ∘ LinearMap(Quat(1.0,0.0,0.0,0.0))

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
function visualize(fgl::FactorGraph; show::Bool=false, meanmax=:max)
  global loopvis
  global drawtransform

  loopvis = true

  vis = Visualizer()
  show ? open(vis) : nothing

  xx, ll = ls(fgl)
  cacheposes = Dict{Symbol, Vector{Float64}}()

  while loopvis
    for x in xx
      X = getKDE(fgl, x)
      xmx = meanmax == :max ? getKDEMax(X) : getKDEMean(X)
      if !haskey(cacheposes, x)
        triad = Triad(1.0)
        setobject!(vis[:poses][x], triad)
        cacheposes[x] = deepcopy(xmx)
      end
      cacheposes[x][:] .= xmx
      trans = Translation(xmx[1:2]..., 0.0) ∘ LinearMap(RotZ(xmx[3]))
      settransform!(vis[:poses][x], drawtransform ∘ trans)
    end
  sleep(1)
  end

  close(vis)
  @info "visualize!(fg::FactorGraph, show=true) is finalizing."
end


function stopVis!()
  global loopvis
  loopvis = false
  nothing
end

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
