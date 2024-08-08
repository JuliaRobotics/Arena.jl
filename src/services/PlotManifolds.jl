


function plotPoints(
  ::typeof(SpecialOrthogonal(3)),
  ps::AbstractVector{<:AbstractMatrix{<:Real}};
  color = :red
)
  scene = Scene()
  cam3d!(scene)
  wireframe!(scene, Makie.Sphere( Point3f(0), 1.0), color=:gray)
  Makie.scale!(scene, 1.0, 1.0, 1.0)
  Makie.rotate!(scene, Vec3f(1, 0, 0), 0.5) # 0.5 rad around the y axis

  
  for R in ps
    vX = R*SA[1;0;0.0]
    scatter!( scene, Point3f(vX...); color )
  end

  scene
end