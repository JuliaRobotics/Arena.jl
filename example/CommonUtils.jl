
function plotPointCloud(_pc; col=-1, plotfnc=scatter, markersize=2)
  # internal helper functions
  vecX(pc::_PCL.PointCloud) = (s->s.x).(pc.points)
  vecY(pc::_PCL.PointCloud) = (s->s.y).(pc.points)
  vecZ(pc::_PCL.PointCloud) = (s->s.z).(pc.points)

  # plot point clouds fixed and moved
  plotfnc(vecX(_pc), vecY(_pc), vecZ(_pc); color=[0.;col*ones(length(vecZ(_pc))-1)], markersize)
end

function plotPointCloudPair(pc_fixed, pc_moved; colf = 0, colm=-1)
  pl = plotPointCloud(pc_fixed; col=colf)
  plotPointCloud(pc_moved; col=colm, plotfnc=scatter!)
  pl
end