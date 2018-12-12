# high level user API

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

  vis = Visualizer()

  show ? open(vis) : nothing

  xx, ll = ls(fgl)

  cacheposes = Dict{Symbol, Vector{Float64}}()

  for i in 1:1000
    for x in xx
      X = getKDE(fgl, x)
      xmx = meanmax == :max ? getKDEMax(X) : getKDEMean(X)
      if !haskey(cacheposes, x)
        triad = Triad(1.0)
        setobject!(vis[:poses][x], triad)
      end
      trans = Translation(xmx[1:2]..., 0.0) ∘ LinearMap(RotZ(xmx[3]))
      settransform!(vis[:poses][x], trans)
    end
  sleep(1)
  end

  @warn "visualize!(fg::FactorGraph, ...) not fully implemented yet"
end
