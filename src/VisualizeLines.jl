# visualize various lines


function drawLine!(vispath, from::Vector{Float64}, to::Vector{Float64}; scale=0.01,color=RGBA(0,1.0,0,0.5))
  vector = to-from
  len = norm(vector)
  buildline = Float64[len, 0, 0]

  v = norm(buildline-vector) > 1e-10 ? Base.cross(buildline, vector)  : [0,0,1.0]
  axis = v/norm(v)
  angle = acos(dot(vector, buildline)/(len^2) )
  rot = LinearMap( CoordinateTransformations.AngleAxis(angle, axis...) )

  mol = HyperRectangle(Vec(0.0,-scale,-scale), Vec(len,scale,scale))
  molbox = GeometryData(mol, color)

  setgeometry!(vispath, molbox)
  settransform!(vispath, Translation(from...) ∘ rot )
  nothing
end
