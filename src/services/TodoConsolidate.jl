

#TODO sort out and move to Arena.jl
function plotPose2Point2Bearing(fg, 
  factor_labels=lsfTypesDict(fg)[:Pose2Point2Bearing];
  len = 3,
  kwargs...
)
  vals = map(factor_labels) do factor_label
      Z = getFactorFunction(fg, factor_label).Z
      fr = getVariableOrder(fg, factor_label)[1]
      pose = getVariableSolverData(fg, fr, :parametric).val[1]
      M = SpecialOrthogonal(2)
      α = log(M, getPointIdentity(M), pose.x[2])[2]
      θ = Z.μ + α
      pnt = Point2f(cos(θ), sin(θ)) * len
      (Point2f(pose[1:2]), pnt)
  end
  
  return Makie.arrows!(first.(vals), last.(vals); kwargs...)
end


function plotPose2Point2BearingRev(fg, 
  factor_labels=lsfTypesDict(fg)[:Pose2Point2Bearing];
  len = 3,
  kwargs...
)
  vals = map(factor_labels) do factor_label
      Z = getFactorFunction(fg, factor_label).Z
      fr,to = getVariableOrder(fg, factor_label)
      pose = getVariableSolverData(fg, fr, :parametric).val[1]
      point = getVariableSolverData(fg, to, :parametric).val[1]
      @show to
      M = SpecialOrthogonal(2)
      α = log(M, getPointIdentity(M), pose.x[2])[2]
      θ = Z.μ + α
      pnt_dir = Point2f(cos(θ), sin(θ)) * len
      # point from and point direction
      # not reverse direction!
      (Point2f(point[1:2]), -pnt_dir)
  end
  
  return Makie.arrows!(first.(vals), last.(vals); kwargs...)
end


function plotPose3Pose3UnitTransDirection(fg, 
  factor_labels=lsfTypesDict(fg)[:Pose3Pose3UnitTrans];
  len = 3,
  rev=true,
  kwargs...
)
  M = SpecialEuclidean(3)
  ϵ = getPointIdentity(M)
  vals = map(factor_labels) do factor_label
      Z = getFactorFunction(fg, factor_label).Z
      fr,to = getVariableOrder(fg, factor_label)
      if !rev
          fr_pose = getVariableSolverData(fg, fr, :parametric).val[1]
          dir = fr_pose.x[2] * Point3f(Z.μ[1:3])
          (Point3f(fr_pose[1:3]), dir*len)
      else
          to_pose = getVariableSolverData(fg, to, :parametric).val[1]
          dir = to_pose.x[2] * Point3f(Z.μ[1:3])
          (Point3f(to_pose[1:3]), -dir*len)
      end
  end
  
  return Makie.arrows!(first.(vals), last.(vals); kwargs...)
end



function plot2dPose3Pose3UnitTransDirection(fg, 
  factor_labels=lsfTypesDict(fg)[:Pose3Pose3UnitTrans];
  len = 3,
  rev=true,
  kwargs...
)
  vals = map(factor_labels) do factor_label
      Z = getFactorFunction(fg, factor_label).Z
      fr,to = getVariableOrder(fg, factor_label)
      if !rev
          fr_pose = getVariableSolverData(fg, fr, :parametric).val[1]
          dir = fr_pose.x[2] * Point3f(Z.μ[1:3])
          (Point2f(fr_pose[1:2]), Point2f(dir[1:2]*len))
      else
          #TODO is this correct
          fr_pose = getVariableSolverData(fg, fr, :parametric).val[1]
          to_pose = getVariableSolverData(fg, to, :parametric).val[1]
          dir = fr_pose.x[2] * Point3f(Z.μ[1:3])
          (Point2f(to_pose[1:3]), -Point2f(dir[1:2])*len)
      end
  end
  
  return Makie.arrows!(first.(vals), last.(vals); kwargs...)
end

function plotPose2Pose2(fg, 
  factor_labels=lsfTypesDict(fg)[:Pose2Pose2];
  len = 3,
  kwargs...
)
  vals = map(factor_labels) do factor_label
      M = SpecialEuclidean(2)
      ϵ = getPointIdentity(M)
      
      fr = getVariableOrder(fg, factor_label)[1]
      p = getVariableSolverData(fg, fr, :parametric).val[1]
      
      fct = getFactor(fg, factor_label)
      X, iΣ = IIF.getFactorMeasurementParametric(fct)
      
      # pθ = log(M, ϵ, p.x[2])[2]

      ϵX = exp(M, ϵ, X)
      q = Manifolds.compose(M, p, ϵX)    
      # qθ

      (Point2f(p[1:2]), Point2f(q[1:2]))
  end
  
  return Makie.linesegments!(vals; kwargs...)
end

function points2(fg, varlabels=ls(fg);  solveKey = :parametric)
  ps = map(varlabels) do v
      val = getVal(fg, v; solveKey)[1]
      # val = getPPESuggested(fg, v, :parametric)
      if getVariableType(fg, v) == RotVelPos()
          # Point2f(val.x[3][1:2])
          Point2f(val.x[3][2:3])
      else 
          Point2f(val[1:2])
      end
  end
  return ps
end

function points2(lm_r::AbstractVector)
  ps = map(eachindex(lm_r)) do i
      Point2f(lm_r[i][1:2])
  end
  return ps
end

function points3(lm_r::AbstractVector)
  ps = map(eachindex(lm_r)) do i
      Point3f(lm_r[i][1:3])
  end
  return ps
end

function points3(fg, varlabels=ls(fg))
  ps = map(varlabels) do v
      val = getVal(fg, v; solveKey = :parametric)[1]
      # val = getPPESuggested(fg, v, :parametric)
      if getVariableType(fg, v) == RotVelPos()
          Point3f(val.x[3][1:3])
      else 
          Point3f(val[1:3])
      end
  end
  return ps
end

function heading(fg, varlabels=ls(fg))
  ps = map(varlabels) do v
      val = getVal(fg, v; solveKey = :parametric)[1]
      # val = getPPESuggested(fg, v, :parametric)
      if getVariableType(fg, v) == RotVelPos()
          Euler(TU.SO3(Matrix(val.x[1]))).Y
      else 
          Euler(TU.SO3(Matrix(val.x[2]))).Y
      end
  end
  return ps
end

function headings(fg, labels=ls(fg))
  θs = map(labels) do v
      val = getVal(fg, v; solveKey = :parametric)[1]
      # atan(val.x[2][2],val.x[2][1])+pi
      atan(val.x[2][2],val.x[2][1])
  end
  return θs
end

function vels3(fg, varlabels=ls(fg, r"^x"))
  ps = map(varlabels) do v
      val = getVal(fg, v; solveKey = :parametric)[1]
      # val = getPPESuggested(fg, v, :parametric)
      if getVariableType(fg, v) == RotVelPos()
          Point3f(val.x[2][1:3])
      else 
          error("FIXME")
      end
  end
  return ps
end

function biases6(fg, varlabels=ls(fg, r"^b"))
  ps = map(varlabels) do v
      getVal(fg, v; solveKey = :parametric)[1]
  end
  return ps
end


## ALSO see ellipse utils in RoMEPlotting.jl

function _covellipse_args(
  μ::AbstractVector{<:Real},
  Σ::AbstractMatrix{<:Real};
  n_std::Real=1,
)
  size(μ) == (2,) && size(Σ) == (2, 2) ||
      error("covellipse requires mean of length 2 and covariance of size 2×2.")
  λ, U = eigen(Σ)
  μ, n_std * U * diagm(.√λ)
end

function ellipsePoints(μ, Σ; n_ellipse_vertices = 100)
  μ, S = _covellipse_args(μ,Σ)

  θ = range(0, 2π; length = n_ellipse_vertices)
  A = S * [cos.(θ)'; sin.(θ)']

  Point2f.(μ[1] .+ A[1, :], μ[2] .+ A[2, :])
  # showaxes && @series begin
  #     label := false
  #     linecolor --> "gray"
  #     ([μ[1] + S[1, 1], μ[1], μ[1] + S[1, 2]], [μ[2] + S[2, 1], μ[2], μ[2] + S[2, 2]])
  # end
end

function ellipsePoints(v::DFGVariable; n_ellipse_vertices = 100, solveKey=:parametric)
  vnd = getSolverData(v, solveKey)
  μ = vnd.val[1][1:2]
  Σ = vnd.bw[1:2,1:2]
  return ellipsePoints(μ, Σ)
end

function ellipsePoints(fg, label::Symbol; kwargs...)
  ellipsePoints(getVariable(fg, label); kwargs...)
end




function plot2d!(
  fg,
  vsyms = ls(fg, r"^x");
  # linewidth = 0.025,
  # lengthscale=0.15f0,
  # arrowsize = Vec3f(0.05, 0.05, 0.1),
  solveKey=:parametric,
)

  ps = map(enumerate(vsyms)) do (i,v)
      val = getVal(fg, v; solveKey)[1]
      Point2f(val[1:2]...)
  end

  nxs = map(vsyms) do v
      val = getVal(fg, v; solveKey)[1] 
      Point2f(val.x[2][:,1]...)
  end

  # Makie.arrows!(ps, nxs; color=:red, linewidth, lengthscale, arrowsize)
  Makie.arrows!(ps, nxs; color=:red)

  # lines!(ps)
end

##

function plot3d(fg;
  linewidth = 0.025,
  lengthscale=0.15f0,
  arrowsize = Vec3f(0.05, 0.05, 0.1),
  solveKey=:parametric,
  vsyms = ls(fg, r"^x"),
)

  ps = map(enumerate(vsyms)) do (i,v)
      val = getVal(fg, v; solveKey)[1]
      if getVariableType(fg, v) == RotVelPos() 
          Point3f(val.x[3][1:3])
      else
          Point3f(val[1:3])
      end
  end

  nxs = map(vsyms) do v
      val = getVal(fg, v; solveKey)[1]
      if getVariableType(fg, v) == RotVelPos() 
          Point3f(val.x[1][:,1])
      else
          Point3f(val.x[2][:,1])
      end
  end
  nys = map(vsyms) do v
      val = getVal(fg, v; solveKey)[1]
      if getVariableType(fg, v) == RotVelPos() 
          Point3f(val.x[1][:,2])
      else
          Point3f(val.x[2][:,2])
      end
  end
  nzs = map(vsyms) do v
      val = getVal(fg, v; solveKey)[1] 
      if getVariableType(fg, v) == RotVelPos() 
          Point3f(val.x[1][:,3])
      else
          Point3f(val.x[2][:,3])
      end
  end

  fig = Makie.arrows(ps, nxs; color=:red, linewidth, lengthscale, arrowsize)
  Makie.arrows!(ps, nys; color=:green, linewidth, lengthscale, arrowsize)
  Makie.arrows!(ps, nzs; color=:blue , linewidth, lengthscale, arrowsize)

  lines!(ps)
  fig
end


function plot3d_p3(poses::Vector;
  linewidth = 0.025,
  lengthscale=0.15f0,
  arrowsize = Vec3f(0.05, 0.05, 0.1),
)

  ps = map(poses) do val
      Point3f(val[1:3])
  end

  nxs = map(poses) do val
      Point3f(val.x[2][:,1])
  end
  nys = map(poses) do val
      Point3f(val.x[2][:,2])
  end
  nzs = map(poses) do val
      Point3f(val.x[2][:,3])
  end

  fig = Makie.arrows(ps, nxs; color=:red, linewidth, lengthscale, arrowsize)
  Makie.arrows!(ps, nys; color=:green, linewidth, lengthscale, arrowsize)
  Makie.arrows!(ps, nzs; color=:blue , linewidth, lengthscale, arrowsize)

  lines!(ps)
  fig
end

function plot3d!(fg;
  linewidth = 0.025,
  lengthscale=0.15f0,
  arrowsize = Vec3f(0.05, 0.05, 0.1),
  solveKey=:parametric,
  vsyms = ls(fg, r"^x"),
)


  ps = map(enumerate(vsyms)) do (i,v)
      val = getVal(fg, v; solveKey)[1]
      Point3f(val[1:3])
  end

  nxs = map(vsyms) do v
      val = getVal(fg, v; solveKey)[1] 
      Point3f(val.x[2][:,1])
  end
  nys = map(vsyms) do v
      val = getVal(fg, v; solveKey)[1] 
      Point3f(val.x[2][:,2])
  end
  nzs = map(vsyms) do v
      val = getVal(fg, v; solveKey)[1] 
      Point3f(val.x[2][:,3])
  end

  Makie.arrows!(ps, nxs; color=:red, linewidth, lengthscale, arrowsize)
  Makie.arrows!(ps, nys; color=:green, linewidth, lengthscale, arrowsize)
  Makie.arrows!(ps, nzs; color=:blue , linewidth, lengthscale, arrowsize)

  lines!(ps)
end



function plotPose2s!(fg::AbstractDFG, labels = ls(fg, r"x"); 
  solveKey=:parametric,
  markersize=10
)

  # f.axis.aspect[] = 1.0
  path_x = map(labels) do v
      val = getVal(fg, v; solveKey)[1]
      val[1]
  end
  path_y = map(labels) do v
      val = getVal(fg, v; solveKey)[1]
      val[2]
  end

  θs = map(labels) do v
      val = getVal(fg, v; solveKey)[1]
      # atan(val.x[2][2],val.x[2][1])+pi # NOTE sure it used to be offset look fixed?
      atan(val.x[2][2],val.x[2][1])
  end
  scatter!(path_x, path_y; rotations = θs, markersize, marker = '►')
  # lines!(path_x,path_y, color = range(0, 1, length=100), colormap = :darkrainbow)
end

function plotPose2s!(points; 
  solveKey=:parametric,
  markersize=10
)

  # f.axis.aspect[] = 1.0
  path_x = getindex.(points,1)
  path_y = getindex.(points,2)

  θs = map(points) do p
      # atan(p.x[2][2], p.x[2][1])+pi
      atan(p.x[2][2], p.x[2][1])
  end
  scatter!(path_x, path_y; rotations = θs, markersize, marker = '►')
  # lines!(path_x,path_y, color = range(0, 1, length=100), colormap = :darkrainbow)
end