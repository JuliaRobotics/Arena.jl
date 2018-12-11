module Arena

using ImageMagick

using
  MeshCat,
  Graphs,
  IncrementalInference,
  Caesar,
  RoMEPlotting,
  KernelDensityEstimatePlotting,
  NLsolve,
  TransformUtils,
  Rotations,
  CoordinateTransformations,
  GeometryTypes,
  ColorTypes,
  MeshIO,
  ImageCore,
  ImageView,
  Images,
  ProgressMeter,
  DocStringExtensions
  # CloudGraphs,
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


include("VisualizationTypes.jl")
include("GeneralUtils.jl")
include("ImageUtils.jl")
include("VisualizationUtils.jl")
include("ModelVisualizationUtils.jl")
# include("DBVisualizationUtils.jl")
# include("DirectorVisService.jl")

include("HighLevelAPI.jl")


end
