# experiment with new point cloud slider

using GLMakie

using Manifolds
using Colors
using Caesar

##

include(joinpath(@__DIR__, "CommonUtils.jl"))

##

function alignPointCloudPairSlidersGeneric(pc_fix, pc_mov)
  vecX(pts) = (s->s.x).(pts)
  vecY(pts) = (s->s.y).(pts)
  vecZ(pts) = (s->s.z).(pts)

  M = SpecialOrthogonal(3)
  markersize=2

  fig = Figure()

  ax = Axis3(fig[1, 1]) #, viewmode=:fitzoom)

  ptf_ = (s->Point3f(s.x,s.y,s.z)).(pc_fix.points)

  sg = SliderGrid(
      fig[1, 2],
      (label = "min", range = 0:1:150, format = "{:.1f}m", startvalue = 1.0),
      (label = "max", range = 0:1:150, format = "{:.1f}m", startvalue = 150.0),
      (label = "p", range = -pi/4:0.01:pi/4, format = "{:.2f}rad", startvalue = 0.0),
      (label = "q", range = -pi/4:0.01:pi/4, format = "{:.2f}rad", startvalue = 0.0),
      (label = "r", range = -pi/4:0.01:pi/4, format = "{:.2f}rad", startvalue = 0.0),
      width = 350,
      tellheight = false)

  sliderobservables = [s.value for s in sg.sliders[1:end]]
  ptm = lift(sliderobservables...) do slvalues...
    pPq = ArrayPartition(zeros(3), exp(M, Identity(M), hat(M, Identity(M), [slvalues[3:5]...])))
    pcm = Caesar._PCL.apply(getManifold(Pose3), pPq, pc_mov)
    ptm_ = (s->Point3f(s.x,s.y,s.z)).(pcm.points)
    Caesar._PCL._filterMinRange(ptm_, slvalues[1], slvalues[2])
  end

  rangeobservables = [s.value for s in sg.sliders[1:2]]
  ptf = lift(rangeobservables...) do rnvalues...
    Caesar._PCL._filterMinRange(ptf_, rnvalues[1], rnvalues[2])
  end

  scatter!(ptf; color=:blue, markersize)
  scatter!(ptm; color=:red, markersize)

  fig
end

##

alignPointCloudPairSliders(pcA, pcB)

##
