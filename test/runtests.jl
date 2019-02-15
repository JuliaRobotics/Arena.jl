
# workaround is to load ImageMagick.jl first, front and center
# see https://github.com/JuliaIO/ImageMagick.jl/issues/142
# and https://github.com/JuliaIO/ImageMagick.jl/issues/130
using ImageMagick

using Pkg
# for now add GraffSDK all the time
Pkg.add(PackageSpec(url = "https://github.com/GearsAD/GraffSDK.jl.git"))

using GraffSDK
using Arena
using Test


include("testBasicAnimations.jl")
