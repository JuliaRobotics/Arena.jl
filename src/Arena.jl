module Arena

using Caesar
# can switch to WGLMakie after https://github.com/SimonDanisch/JSServe.jl/issues/131
using GLMakie

# using ImageView, Images
## moved to and remove from legacy/LegacyAPI.jl when restored
# due to issue with ImageMagick and Pkg importing, the order is very sensitive here!
# see https://github.com/JuliaIO/ImageMagick.jl/issues/142
# using ImageMagick
# using PlotUtils
# using MeshIO, MeshCat
# using LinearAlgebra

# using Rotations, CoordinateTransformations
# using TransformUtils
# using Graphs, NLsolve
# using GeometryTypes, ColorTypes
# using DocStringExtensions, ProgressMeter
# # using CaesarLCMTypes
# using Requires
# using FileIO
# using JSON
# using Base64
# const CTs = CoordinateTransformations
# const TUs = TransformUtils
include("legacy/LegacyAPI.jl")



end # module
