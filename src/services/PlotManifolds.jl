


function plotPoints(
  ::typeof(SpecialOrthogonal(3)),
  Rs::AbstractVector{<:AbstractMatrix{<:Real}};
  color::C = :red,
  scene = Scene(),
  wf_color = :gray,
) where C
  cam3d!(scene)
  wireframe!(scene, Makie.Sphere( Point3f(0), 1.0), color=wf_color)
  Makie.scale!(scene, 1.0, 1.0, 1.0)
  Makie.rotate!(scene, Vec3f(1, 0, 0), 0.5) # 0.5 rad around the y axis
  
  for (i,R) in enumerate(Rs)
    v = SA[1;0;0.0]
    vX = R*v
    c = C <: AbstractVector ? color[i] : color
    scatter!( scene, Point3f(vX...); color=c )
  end


  scene
end



function plotPoints(
  ::typeof(TranslationGroup(3)),
  Vs::AbstractVector{<:AbstractVector{<:Real}};
  color::C = :red,
  scene = Scene(),
  normalize::Bool = false,
  dropSmall::Real = 0,
  wf_color = :gray,
) where C
  cam3d!(scene)
  wireframe!(scene, Makie.Sphere( Point3f(0), 1.0), color=wf_color)
  Makie.scale!(scene, 1.0, 1.0, 1.0)
  # Makie.rotate!(scene, Vec3f(1, 0, 0), 0.5) # 0.5 rad around the y axis
  
  # scene not directly accepting RGB?
  # colormap = if C <: AbstractVector 
  #   mc,xc = minimum(color), maximum(color)
  #   ((color .- mc)./(xc-mc) .* 256) .|> s->Makie.ColorSchemes.amp[s]
  # end

  for (i,v) in enumerate(Vs)
    nv = norm(v)
    nv < dropSmall ? continue : nothing
    vX = normalize ? v./nv : v
    c = C <: AbstractVector ? color[i] : color
    scatter!( scene, Point3f(vX...); color=c )
  end

  # plot simple axes
  if normalize
    _lw = 0.025
    _ls=0.9f0
    mesh!(scene, Rect3f(Vec3f(0, -_lw, -_lw), Vec3f(_ls, _lw, _lw)); color=:red)
    mesh!(scene, Rect3f(Vec3f(-_lw, 0, -_lw), Vec3f(_lw, _ls, _lw)); color=:green)
    mesh!(scene, Rect3f(Vec3f(-_lw, -_lw, 0), Vec3f(_lw, _lw, _ls)); color=:blue)
  end

  scene
end