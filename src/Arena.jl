module Arena

include("Amphitheatre/Amphitheatre.jl")
using .Amphitheatre

#=
# due to issue with ImageMagick and Pkg importing, the order is very sensitive here!
# see https://github.com/JuliaIO/ImageMagick.jl/issues/142
using ImageMagick
using PlotUtils
using Caesar, ImageView, Images, MeshIO, MeshCat

using Rotations, CoordinateTransformations
using TransformUtils
using Graphs, NLsolve
using GeometryTypes, ColorTypes
using DocStringExtensions, ProgressMeter
# using CaesarLCMTypes
using Requires
using FileIO
using JSON
using Base64


const CTs = CoordinateTransformations
const TUs = TransformUtils

export
  meshgrid,
  DepthCamera,
  buildmesh!,
  reconstruct,
  VisualizationContainer,
  startDefaultVisualization,
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
  # image_tToRgb,
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
  cloudFromDepthImage,

  # point clouds
  visPointCloudOnPose!,
  drawPointCloudonPose!,
  cloudFromDepthImage,

  # colour gradients
  # re-exports
  cgrad,
  clibraries,
  cgradients


const NothingUnion{T} = Union{Nothing, T}


# Minimal globals
global loopvis = true
global drawtransform = Translation(0.0,0.0,0.0) ∘ LinearMap(Quat(1.0,0.0,0.0,0.0))


# types and models
include("Common/CameraModel.jl")
include("VisualizationTypes.jl")
include("RobotSceneModels.jl")

# Common
include("Common/DepthImages.jl")
# utils
include("GeneralUtils.jl")
include("ColorUtils.jl")
include("VisualizeLines.jl")
include("MeshUtils.jl")
include("BigDataUtils.jl")
include("ImageUtils.jl")
include("AnimationUtils.jl")
include("VisualizationUtils.jl")
include("VisualizePosesPoints.jl")
include("ModelVisualizationUtils.jl")
include("deprecated/Deprecated.jl")

# user interaction
include("HighLevelAPI.jl")
include("Amphitheatre/Amphitheatre.jl")
using .Amphitheatre

# plugins

# Developer tools
include("BotVis.jl")


# Used by Requires.jl to check if packages are imported. Much cleaner than janky isdefined().
function __init__()
  @info "Conditionally importing RoMEPlotting, GraffSDK, and Director..."
  # Checking what to import from the calling module
  @require GraffSDK="d47733cc-d211-5467-9efc-951b5b83f246" begin
    @info "--- GraffSDK is defined in the calling namespace, importing Graff functions..."
    include("plugins/GraffVisualizationService.jl")
    include("deprecated/DeprecatedGraff.jl")
    # Graff exports
    export visualizeSession
  end
  @require RoMEPlotting="238d586b-a4bf-555c-9891-eda6fc5e55a2" begin
    @info "--- RoMEPlotting is defined in the calling namespace, importing RoMEPlotting functions..."
  end
  @require DrakeVisualizer="49c7015b-b8db-5bc5-841b-fcb31c578176" begin
    @info "--- DrakeVisualizer is defined in the calling namespace, importing DrakeVisualizer functions..."
    include("DirectorVisService.jl")
    # DrakeVisualizer exports
    export drawdbdirector
    end
  end


# load the internal plugins that may or may not depend on the @requires above
include("plugins/VisualizationDefault.jl")
include("plugins/GetRobotConfiguration.jl")
include("plugins/ReprojectBearingRange.jl")
include("plugins/PointClouds.jl")





=#
end # module
