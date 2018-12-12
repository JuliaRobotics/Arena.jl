module Arena


# due to issue with ImageMagick and Pkg importing, the order is very sensitive here!
# see https://github.com/JuliaIO/ImageMagick.jl/issues/142
using ImageMagick
using Caesar, ImageView, Images, MeshIO, MeshCat

#using RoMEPlotting # results in error

using Rotations, CoordinateTransformations, TransformUtils

using Graphs, NLsolve

using GeometryTypes

using ColorTypes

using DocStringExtensions, ProgressMeter

# CloudGraphs,
# DrakeVisualizer,


export
  drawPoses,
  drawPosesLandm,
  #drawsubmap

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
include("HighLevelAPI.jl")

# include("DBVisualizationUtils.jl")

try
    getfield(Main, :RoMEPlotting)

    export
      plot,
      plotKDE

    @info "Including RoMEPlotting functionality..."
catch e

end


try
    getfield(Main, :DrakeVisualizer)

    export
      drawdbdirector

    include("DirectorVisService.jl")

    @show "Including DrakeVisualizer functionality..."
catch e

end





end
