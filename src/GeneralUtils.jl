# general utilities

# create a new Director window with home axis
function startdefaultvisualization(;newwindow::Bool=true,
                                    draworigin::Bool=true,
                                    vismodule=MeshCat)
  # Visualizer.any_open_windows() || Visualizer.new_window(); #Visualizer.new_window()
  viz = vismodule.Visualizer()
  if draworigin
    setgeometry!(viz[:origin], Triad())
    settransform!(viz[:origin], Translation(0.0, 0.0, 0.0) ∘ LinearMap(Rotations.Quat(1.0,0,0,0)))
  end

  # realtime, rttfs = Dict{Symbol, Any}(), Dict{Symbol, AbstractAffineMap}()
  # dc = VisualizationContainer(Dict{Symbol, Visualizer}(), triads, trposes, meshes, realtime, rttfs)
  # visualizetriads!(dc)
  return viz
end




function animatearc(vc,
                    drmodel::DrawObject,
                    as::ArcPointsRangeSolve;
                    N::Int=100,
                    delaytime::Float64=0.05,
                    initrot::Rotation=Rotations.Quat(1.0,0,0,0),
                    from::Number=0,
                    to::Number=1  )
  #
  for t in linspace(from,to,N)
    am = parameterizeArcAffineMap(t, as, initrot=initrot )
    drmodel(vc, am )
    sleep(delaytime)
  end
  nothing
end
