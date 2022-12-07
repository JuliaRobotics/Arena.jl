

#fixed z color spread
function colorsPointCloud(
  pca::Caesar._PCL.PointCloud;
  vecZ = (s->s.z).(pca.points),
  bottom=-3.0,
  top=7.0,
)
  scl = top / maximum(vecZ)
  color = scl .* vecZ
  # everything below bottom gets the same color
  color[ color .< bottom ] .= bottom
  color
end



function plotPointCloud(
  pca::Caesar._PCL.PointCloud; 
  plotfnc=scatter, 
  col=-1,
  bottom=-3.0,
  top=7.0,
  color = colorsPointCloud(pca;bottom,top),
  colormap = ColorSchemes.gist_earth.colors,
  markersize=2,
  ax=nothing
)
  vecX(pts) = (s->s.x).(pts)
  vecY(pts) = (s->s.y).(pts)
  vecZ(pts) = (s->s.z).(pts)

  X = vecX(pca.points)
  Y = vecY(pca.points)
  Z = vecZ(pca.points)

  plotfnc(
    (isnothing(ax) ? () : (ax,))...,
    X,Y,Z; 
    color, 
    markersize,
    colormap,
  )
end

function plotPointCloudPair(pca,pcb)
  pl = plotPointCloud(pca; plotfnc=scatter, bottom=100, top=101)
  plotPointCloud(pcb; plotfnc=scatter!, bottom=-100, top=1000 )
  pl
end


function plotPointCloud2D(pc::Caesar._PCL.PointCloud)
  xy = (s->s.data[1:2]).(pc.points)

  @cast xy_[i,d] := xy[i][d]

  f = Figure()
  pos = f[1, 1]
  scatter(pos, xy_)
end



function plotGraphPointClouds(
  dfg::AbstractDFG,
  getpointcloud::Function = (v)->_PCL.getDataPointCloud(dfg, v, Regex("PCLPointCloud2"); checkhash=false);
  varList = (listVariables(dfg) |> sortDFG .|> string),
  solveKey = :default
)
  pl = nothing

  #

  pc_map = nothing
  pc_last = nothing

  # attempting to fix #107
  # f = Figure()
  # ERROR: `Makie.convert_arguments` for the plot type MakieCore.Scatter{Tuple{Makie.Axis3, Vector{Float32}, Vector{Float32}, Vector{Float32}}} and its conversion trait MakieCore.PointBased() was unsuccessful.
  # ax = Axis3(
  #   f[1, 1],
  #   title = string(solveKey)
  # )
  # ax = Axis(fig[1,1]) #Axis3(fig[1, 1], viewmode=:stretch)

  count = 0
  M = getManifold(Pose3)
  ϵ0_ = MJL.identity_element(M)
  ϵ0 = ArrayPartition(ϵ0_.parts...)
  for vl in varList
    @show vl
    count += 1
    pc_ = getpointcloud(vl)
    if pc_ isa Nothing
      @warn "Skipping variable without point cloud" vl
      continue
    end
    pc = Caesar._PCL.PointCloud(pc_)
    
    # pts_a = (s->[s.x;s.y;s.z]).(pc.points)

    # minrange = 1
    # maxrange = 50
    # pts_a = Caesar._PCL._filterMinRange(pts_a, minrange, maxrange)

    v = getVariable(dfg, Symbol(vl))
    if !(:parametric in listSolveKeys(v))
      @warn "Skipping $vl which does not have solveKey :parametric"
      continue
    end
    w_Cwp = calcPPE(v; solveKey).suggested
    wPp = MJL.exp(M,ϵ0,MJL.hat(M,ϵ0,w_Cwp))
    # wPp = getSolverData(v, solveKey).val[1]
    wPC = Caesar._PCL.apply(M, wPp, pc)

    if pl isa Nothing
      pl = plotPointCloud(wPC; plotfnc = scatter, col=-1.0, ax=nothing)
      pc_map = deepcopy(wPC)
    else
      # col = -1*(count%2)
      col = if vl == varList[end]
        pc_last = wPC
        0
      else
        pc_map = cat(pc_map, wPC; reuse=true)
        -1
      end
      plotPointCloud(wPC; plotfnc = scatter!) #, col)
    end
  end

  return pl, pc_map, pc_last
end