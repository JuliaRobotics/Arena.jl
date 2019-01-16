# general utilities




# find and set initial transform to project model in the world frame to the
# desired stating point and orientation
function findinitaffinemap!(as::ArcPointsRangeSolve; initrot::Rotation=Rotations.Quaternion(1.0,0,0,0))
  # how to go from origin to center to x1 of arc
  cent = Translation(as.center)
  rho = Translation(as.r, 0,0)
  return
end



function gettopoint(drawtype::Symbol=:max)
  topoint = +
  if drawtype == :max
    topoint = getKDEMax
  elseif drawtype == :mean
    topoint = getKDEMean
  elseif drawtype == :fit
    topoint = (x) -> getKDEfit(x).μ
  else
    error("Unknown draw type")
  end
  return topoint
end

function getdotwothree(sym::Symbol, X::Array{Float64,2})
  dims = size(X,1)
  dotwo = dims == 2 || (dims == 3 && string(sym)[1] == 'x')
  dothree = dims == 6 || (string(sym)[1] == 'l' && dims != 2)
  (dotwo && dothree) || (!dotwo && !dothree) ? error("Unknown dimension for drawing points in viewer, $((dotwo, dothree))") : nothing
  return dotwo, dothree
end
