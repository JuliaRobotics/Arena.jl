# tools used to animate objects in the visualized scene



function (as::ArcPointsRangeSolve)(res::Vector{Float64}, x::Vector{Float64})
  res[1] = norm(x-as.x1)^2 - as.r^2
  res[2] = norm(x-as.x2)^2 - as.r^2
  if length(res) == 3
    res[3] = norm(x-as.x3)^2 - as.r^2
  end
  nothing
end

function animatearc(vc,
                    drmodel::DrawObject,
                    as::ArcPointsRangeSolve;
                    N::Int=100,
                    delaytime::Float64=0.05,
                    initrot::Rotation=Rotations.Quat(1.0,0,0,0),
                    from::Number=0,
                    to::Number=1  )
  #
  for t in linspace(from,to,N)
    am = parameterizeArcAffineMap(t, as, initrot=initrot )
    drmodel(vc, am )
    sleep(delaytime)
  end
  nothing
end


function findaxiscenter!(as::ArcPointsRangeSolve)
  d = length(as.center)
  x0 = 0.5*(as.x1+as.x2)
  r = nlsolve(as, x0)
  as.center = r.zero
  vA, vB, vC = as.x1-as.center, as.x2-as.center, as.x3-as.center
  l1, l2 = norm(as.x1-as.x2), norm(as.x2-as.x3)
  halfl0 = 0.5*norm(as.x1-as.x3)
  axt = l1 < l2 ? LinearAlgebra.cross(vA,vB) : LinearAlgebra.cross(vB,vC)
  as.axis[1:3] = axt / norm(axt)
  ta = LinearAlgebra.cross(vA,vC)
  ta ./= norm(ta)
  alph = acos(halfl0/as.r)
  if norm(ta-as.axis) < 1e-4
    #accute
    as.angle = pi - 2*alph
  else
    # oblique
    as.angle = pi + 2*alph
  end
  r.f_converged
end
