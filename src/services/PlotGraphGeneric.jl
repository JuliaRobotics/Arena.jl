


function plotGraph3d(
  dfg::AbstractDFG;
  tag = :POSE,
  labels::AbstractVector{Symbol} = sortDFG(ls(dfg; tags=[tag;])), # FIXME, better support for multiple trajectories via tags
  solveKey = :default,
  title::AbstractString = string(
    getSessionLabel(dfg), 
    ",  solveKey: ", solveKey,
    ",  (", length(labels), ")",
    "\n", getTimestamp(dfg[labels[1]]),
    " --> ", getTimestamp(dfg[labels[end]]),
  ),
  drawTrajectory::Bool=true,
  drawTrajectoryMarkers::Bool = drawTrajectory,
  fig = Figure(),
)
  #

  _getppepos(_v::DFGVariable{<:Position{2}}, solvK) = [getPPESuggested(_v, solvK)[1:2]; 0.0]
  _getppepos(_v::DFGVariable{<:Pose2}, solvK) = [getPPESuggested(_v, solvK)[1:2]; 0.0]
  _getppepos(_v::DFGVariable{<:Position{3}}, solvK) = getPPESuggested(_v, solvK)[1:3]
  _getppepos(_v::DFGVariable{<:Pose3}, solvK) = getPPESuggested(_v, solvK)[1:3]
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

  fig
end