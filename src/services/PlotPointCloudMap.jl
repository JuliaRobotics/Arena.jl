

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
  markersize=2
)
  vecX(pts) = (s->s.x).(pts)
  vecY(pts) = (s->s.y).(pts)
  vecZ(pts) = (s->s.z).(pts)

  X = vecX(pca.points)
  Y = vecY(pca.points)
  Z = vecZ(pca.points)

  plotfnc(
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
  x = (s->s.data[1]).(pc.points)
  y = (s->s.data[2]).(pc.points)

  error("TODO, convert to Makie")
  # Gadfly.plot(x=x,y=y, Main.Gadfly.Geom.point)
end



function plotGraphPointClouds(
  dfg::AbstractDFG,
  getpointcloud::Function; #(v)->getBlobPointCloudRegex(dfg, v, Regex("PCLPointCloud2"))
  plotlist = (listVariables(dfg) |> sortDFG .|> string)
)
  pl = nothing

  #

  pc_map = nothing
  pc_last = nothing

  # fig = Figure()
  # ax = Axis(fig[1,1]) #Axis3(fig[1, 1], viewmode=:stretch)

  count = 0
  for vl in plotlist
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
    wPp = getSolverData(v, :parametric).val[1]
    wPC = Caesar._PCL.apply(getManifold(Pose3), wPp, pc)

    if pl isa Nothing
      pl = plotPointCloud(wPC; plotfnc = scatter, col=-1.0)
      pc_map = deepcopy(wPC)
    else
      # col = -1*(count%2)
      col = if vl == plotlist[end]
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