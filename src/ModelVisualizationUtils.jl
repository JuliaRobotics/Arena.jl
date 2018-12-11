
# ROV visualization

"""
    $(SIGNATURES)

Brings model data into context, but generating or loading meshes, Geometries, etc as required by requested model,
and must still be drawn with the Visualizer object using mdl(vis).
"""
function loadmodel(model::Symbol=:rov;
    color=RGBA(0., 1.0, 0.5, 0.3),
    offset = Translation(0.,0,0) ∘ LinearMap(Rotations.Quat(1.0,0,0,0))  )
  #
  if model==:rov
    @show file = joinpath(dirname(@__FILE__), ".." , "data", "models", "rov3.obj")
    rov = load(file)
    rovdata = GeometryData(rov)
    rovdata.color = color
    offset = Translation(-0.5,0,0.25) ∘ LinearMap(Rotations.Quat(0,0,0,1.0))
    return DrawROV(rovdata, 99, :rov, offset)
  elseif model == :scene01
    boxdata = GeometryData(HyperRectangle(Vec(4.0,0,0), Vec(5.0,5.0,0)), RGBA(0.5,0.1,0.0,0.5))
    # boxdata.color =
    offset = Translation(0.0,0,0) ∘ LinearMap(CoordinateTransformations.AngleAxis(0.0,0,0,1.0))
    return DrawScene(boxdata, :scene01, offset)
  elseif model == :dock
    @show file = joinpath(dirname(@__FILE__), ".." , "data", "models", "dock.obj")
    rov = load(file)
    rovdata = GeometryData(rov)
    rovdata.color = color
    offset = Translation(0.0,0,0) ∘ LinearMap(Rotations.Quat(1.0,0,0,0.0))
    return DrawScene(rovdata, :dock, offset)
  else
    error("Don't recognize requested $(string(model)) model.")
  end
end


# t∈[0,1], about
function parameterizeArcAffineMap(t, as::ArcPointsRangeSolve; initrot::Rotation=Rotations.Quat(1.0,0,0,0))
  the = t*as.angle
  rot = Rotations.AngleAxis(the, as.axis...)
  dp = as.x1-as.center
  arc = LinearMap(rot) ∘ Translation(dp...)

  cent = Translation(as.center)
  return cent ∘ arc ∘ LinearMap(initrot)
end



# as = ArcPointsRangeSolve(
#       [0.0;0;0.0],
#       [0.0;6.0;6.0],
#       [0.0;12.0;0.0], 6.0)
# findaxiscenter!(as)
# # @show as.center, as.axis, as.angle, as.r
# animatearc(vc, rovt, as, initrot=Rotations.AngleAxis(pi/2,0,0,1.0))
#
#
# as = ArcPointsRangeSolve(
#       [2.5;-1;0.0],
#       [-4.5;4.0;0.0],
#       [9.5;6.0;0.0], 7.0)
# findaxiscenter!(as)
# # @show as.center, as.axis, as.angle, as.r
# animatearc(vc, rovt, as, initrot=Rotations.AngleAxis(pi/2,0,0,1.0))
#





#
