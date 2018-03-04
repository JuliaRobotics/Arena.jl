module Arena

using
  DrakeVisualizer,
  Graphs,
  CloudGraphs,
  IncrementalInference,
  Caesar,
  RoMEPlotting,
  KernelDensityEstimatePlotting,
  NLsolve,
  TransformUtils,
  CoordinateTransformations,
  GeometryTypes,
  ColorTypes,
  MeshIO,
  ImageMagick,
  ImageView,
  Images,
  ProgressMeter

export
  drawdbdirector,
  drawPoses,
  drawPosesLandm,
  #drawsubmap
  plot,
  plotKDE,
  meshgrid,
  DepthCamera,
  buildmesh!,
  reconstruct,
  VisualizationContainer,
  startdefaultvisualization,
  newtriad!,
  visualize!,
  visualizetriads,
  visualizeallposes!,
  visualizeDensityMesh!,
  updaterealtime!,
  visualizerealtime,
  # new tree interface
  drawpose!,
  drawposepoints!,
  drawLine!,
  drawLineBetween!,
  drawAllOdometryEdges!,
  pointToColor,
  findAllBinaryFactors,
  drawAllBinaryFactorEdges!,
  loadmodel,
  DrawModel,
  DrawROV,
  DrawScene,
  #deleting functions
  deletemeshes!,

  # more drawing utils
  ArcPointsRangeSolve,
  findaxiscenter!,
  parameterizeArcAffineMap,
  animatearc

VoidUnion{T} = Union{Void, T}

function visualize!(fg::FactorGraph, kawgs...)
  error("visualize!(fg::FactorGraph, ...) not implemented yet")
end

include("ImageUtils.jl")
include("VisualizationUtils.jl")
include("ModelVisualizationUtils.jl")
include("DBVisualizationUtils.jl")
include("DirectorVisService.jl")



end
