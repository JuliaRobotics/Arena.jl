


function plotPointCloud(pca::_PCL.PointCloud; plotfnc=scatter, col=1, markersize=2)
  vecX(pts) = (s->s.x).(pts)
  vecY(pts) = (s->s.y).(pts)
  vecZ(pts) = (s->s.z).(pts)

  X = vecX(pca.points)
  Y = vecY(pca.points)
  Z = vecZ(pca.points)

  plotfnc(X,Y,Z; color=[0;col*ones(length(Z)-1)], markersize)
end

function plotPointCloudPair(pca,pcb)
  pl = plotPointCloud(pca; plotfnc=scatter, col=-0.5)
  plotPointCloud(pcb; plotfnc=scatter!, col=0.0)
  pl
end


function plotPointCloud2D(pc::_PCL.PointCloud)
  x = (s->s.data[1]).(pc.points)
  y = (s->s.data[2]).(pc.points)

  Gadfly.plot(x=x,y=y, Main.Gadfly.Geom.point)
end
