module Arena

# due to issue with ImageMagick and Pkg importing, the order is very sensitive here!
# see https://github.com/JuliaIO/ImageMagick.jl/issues/142
using ImageMagick
using Caesar, ImageView, Images, MeshIO, MeshCat

using Rotations, CoordinateTransformations, TransformUtils
using Graphs, NLsolve
using GeometryTypes, ColorTypes
using DocStringExtensions, ProgressMeter
using CaesarLCMTypes
using Requires
using FileIO
#using RoMEPlotting # results in error similar to ordering error


export
  meshgrid,
  DepthCamera,
  buildmesh!,
  reconstruct,
  VisualizationContainer,
  startdefaultvisualization,
  newtriad!,
  visualize,
  stopVis!,
  setGlobalDrawTransform!,
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
  image_tToRgb,
  rgbUint8ToRgb,
  rgbToJpeg,
  rgbToPng,
  imshowhackpng,
  cloudimshow,
  imshowhack,
  roi,

  # BotVis
  CameraModel,
  initBotVis2,
  drawPoses2!,
  cloudFromDepthImage


const NothingUnion{T} = Union{Nothing, T}


include("VisualizationTypes.jl")
include("GeneralUtils.jl")
include("ImageUtils.jl")
include("VisualizationUtils.jl")
include("ModelVisualizationUtils.jl")
include("HighLevelAPI.jl")
include("BotVis.jl")

# Used by Requires.jl to check if packages are imported. Much cleaner than janky isdefined().
function __init__()
  @info "Conditionally importing RoMEPlotting, GraffSDK, and Director..."
  # Checking what to import from the calling module
  @require GraffSDK="d47733cc-d211-5467-9efc-951b5b83f246" begin
    @info "--- GraffSDK is defined in the calling namespace, importing Graff functions..."
    include("GraffVisualizationService.jl")
  end
  @require RoMEPlotting="238d586b-a4bf-555c-9891-eda6fc5e55a2" begin
    @info "--- RoMEPlotting is defined in the calling namespace, importing RoMEPlotting functions..."
  end
  @require DrakeVisualizer="49c7015b-b8db-5bc5-841b-fcb31c578176" begin
    @info "--- DrakeVisualizer is defined in the calling namespace, importing DrakeVisualizer functions..."
    include("DirectorVisService.jl")
  end
end

# Graff exports
export
  visualizeSession
# DrakeVisualizer exports
export
  drawdbdirector
end
