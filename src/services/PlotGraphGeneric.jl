


function plot3d!(
  dfg::AbstractDFG;
  tag = :POSE,
  labels::AbstractVector{Symbol} = sortDFG(ls(dfg; tags=[tag;])), # FIXME, better support for multiple trajectories via tags
  solveKey = :default,
  fig = Figure(),
  title::AbstractString = string(
    getSessionLabel(dfg), 
    ",  solveKey: ", solveKey,
    ",  (", length(labels), ")",
    "\n", getTimestamp(dfg[labels[1]]),
    " --> ", getTimestamp(dfg[labels[end]]),
  ),
  drawTrajectory::Bool=true,
  drawTrajectoryMarkers::Bool = drawTrajectory,
  drawTriads::Bool = false,
  linewidth = 0.025,
  lengthscale=0.15f0,
  arrowsize = Vec3f(0.05, 0.05, 0.1),
)
  #

  _getppepos(_v::DFGVariable{<:Position{2}}, solvK) = [getPPESuggested(_v, solvK)[1:2]; 0.0]
  _getppepos(_v::DFGVariable{<:Pose2}, solvK) = [getPPESuggested(_v, solvK)[1:2]; 0.0]
  _getppepos(_v::DFGVariable{<:Position{3}}, solvK) = getPPESuggested(_v, solvK)[1:3]
  _getppepos(_v::DFGVariable{<:Pose3}, solvK) = getPPESuggested(_v, solvK)[1:3]
  _getppepos(_v::DFGVariable{<:RoME.VelPos3}, solvK) = getPPESuggested(_v, solvK)[4:6]
  _getppepos(_v::DFGVariable{<:RoME.RotVelPos}, solvK) = getPPESuggested(_v, solvK)[7:9]

  ax1 = Axis3(fig[1, 1]; title)
  # Axis(f[2, 1], title = L"\sum_i{x_i \times y_i}")
  # Axis(f[3, 1], title = rich(
  #     "Rich text title",
  #     subscript(" with subscript", color = :slategray)
  # ))
  
  _ppes = _getppepos.(getVariable.(dfg, labels), solveKey) # getPPESuggested.(dfg, labels, solveKey)

  @cast ppes[i,d] := _ppes[i][d]

  scatter!(ax1, ppes[:,1],ppes[:,2],ppes[:,3],)
  if drawTrajectory
    lines!(ax1, ppes[:,1],ppes[:,2],ppes[:,3],)
  end

  if drawTrajectoryMarkers
    scatter!(ax1, Point3f(ppes[1,1:3]...), markersize = 20, markerspace = :pixel, marker = '✪', label = "traj start")
    scatter!(ax1, Point3f(ppes[end,1:3]...), markersize = 20, markerspace = :pixel, marker = '⊙', label = "traj end")
    axislegend(ax1)
  end

  _nxs(rot::AbstractMatrix{<:Real}) = rot[:,1]
  _nys(rot::AbstractMatrix{<:Real}) = rot[:,2]
  _nzs(rot::AbstractMatrix{<:Real}) = rot[:,3]
  if drawTriads
    # NOTE using val (not PPE), this will help show when PPEs are out of step with val
    for var in getVariable.(dfg, labels)
      if RotVelPos() == getVariableType(var)
        ps = calcMean(getBelief(var, solveKey))
        Makie.arrows!(ax1, ps, _nxs(ps.x[1]); color=:red, linewidth, lengthscale, arrowsize)
        Makie.arrows!(ax1, ps, _nys(ps.x[2]); color=:green, linewidth, lengthscale, arrowsize)
        Makie.arrows!(ax1, ps, _nzs(ps.x[3]); color=:blue , linewidth, lengthscale, arrowsize)
      end
    end
  end

  fig
end
