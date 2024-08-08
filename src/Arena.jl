module Arena

# using Colors
import Manifolds as MJL
import GeometryBasics as GeoB

using DistributedFactorGraphs
using RoME
#TODO Caesar should be a package extention.
# using Caesar
# import Caesar._PCL as _PCL
# const _PCL = Caesar._PCL
# can switch to WGLMakie after https://github.com/SimonDanisch/JSServe.jl/issues/131
using GLMakie
#TODO allow switching backends using GLMakie #GLMakie.activate!()
# using CairoMakie

using ColorSchemes
using Colors
using TensorCast
using StaticArrays
using ProgressMeter
using DocStringExtensions

# NOTE a lot of legacy code has been moved to the attic

export plotGraph3d

# include("Exports.jl")
# include("services/PlotBoundingBox.jl")
include("services/PlotFeatureTracks.jl")
include("services/PlotHistogramGrid.jl")

# support weakdeps exports
include("../ext/Prototypes.jl")

include("services/PlotGraphGeneric.jl")


end # module
