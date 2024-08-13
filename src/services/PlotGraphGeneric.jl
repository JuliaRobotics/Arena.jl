


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
  linewidth = 0.05,
  lengthscale=0.15f0,
  arrowsize = Vec3f(0.05, 0.05, 0.1),
  aspect = :data,
)
  #

  _getppepos(_v::DFGVariable{<:Position{2}}, solvK) = [getPPESuggested(_v, solvK)[1:2]; 0.0]
  _getppepos(_v::DFGVariable{<:Pose2}, solvK) = [getPPESuggested(_v, solvK)[1:2]; 0.0]
  _getppepos(_v::DFGVariable{<:Position{3}}, solvK) = getPPESuggested(_v, solvK)[1:3]
  _getppepos(_v::DFGVariable{<:Pose3}, solvK) = getPPESuggested(_v, solvK)[1:3]
  _getppepos(_v::DFGVariable{<:RoME.VelPos3}, solvK) = getPPESuggested(_v, solvK)[4:6]
  _getppepos(_v::DFGVariable{<:RoME.RotVelPos}, solvK) = getPPESuggested(_v, solvK)[7:9]

  ax1 = Axis3(fig[1, 1]; title, aspect)
  
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

  _getPos(::RotVelPos, p::ArrayPartition) = p.x[3]
  _getPos(::Pose2, p::ArrayPartition) = [p.x[1]...; 0.0]
  _getPos(::Pose3, p::ArrayPartition) = p.x[1]
  _getPos(::Position{1}, p::AbstractVector) = [p[1]; 0; 0.0]
  _getPos(::Position{2}, p::AbstractVector) = [p[1]; p[2]; 0.0]
  _getPos(::Position{N} where N, p::AbstractVector) = p[1:3]
  
  _getRot(::RotVelPos, p::ArrayPartition) = p.x[1]
  _getRot(::Pose3, p::ArrayPartition) = p.x[2]
  _getRot(::Pose2, p::ArrayPartition) = [p.x[2][1,1] p.x[2][1,2] 0; p.x[2][2,1] p.x[2][2,2] 0; 0 0 1.0] 
  _getRot(::Position{N} where N, p::ArrayPartition) = diagm(ones(3))
  
  pos = []
  nxs = []
  nys = []
  nzs = []
  if drawTriads
    # NOTE using val (not PPE), this will help show when PPEs are out of step with val
    for var in getVariable.(dfg, labels)
      ps = calcMean(getBelief(var, solveKey))
      push!(pos, Point3f(_getPos(getVariableType(var), ps)))
      rot = _getRot(getVariableType(var),ps)
      push!(nxs, Point3f(rot[:,1]...))
      push!(nys, Point3f(rot[:,2]...))
      push!(nzs, Point3f(rot[:,3]...))
      Makie.arrows!(ax1, pos, nxs; color=:red, linewidth, lengthscale, arrowsize)
      Makie.arrows!(ax1, pos, nys; color=:green, linewidth, lengthscale, arrowsize)
      Makie.arrows!(ax1, pos, nzs; color=:blue , linewidth, lengthscale, arrowsize)
    end
  end

  fig
end
