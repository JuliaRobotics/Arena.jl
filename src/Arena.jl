module Arena

using
  MeshCat,
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
  ImageCore,
  ImageView,
  Images,
  ProgressMeter,
  DocStringExtensions
  # DrakeVisualizer,

if false

export
  drawdbdirector

end

export
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
  animatearc,

  # ImageUtils
  imshowhackpng,
  cloudimshow,
  imshowhack,
  roi

const NothingUnion{T} = Union{Nothing, T}

function visualize!(fg::FactorGraph, kawgs...)
  error("visualize!(fg::FactorGraph, ...) not implemented yet")
end

include("VisualizationTypes.jl")
include("GeneralUtils.jl")
include("ImageUtils.jl")
include("VisualizationUtils.jl")
include("ModelVisualizationUtils.jl")
include("DBVisualizationUtils.jl")
# include("DirectorVisService.jl")



end
