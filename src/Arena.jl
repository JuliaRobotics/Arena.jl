module Arena

# using Colors
import Manifolds as MJL
import GeometryBasics as GeoB

using DistributedFactorGraphs
# also brings in the DFG public/unstable API (ls, sortDFG, getGraphLabel, ...) during v1 transition
DFG.@usingDFG true
using IncrementalInferenceTypes
using RoMETypes
using LieGroups
using Distributions: MvNormal, pdf, mean
using RecursiveArrayTools: ArrayPartition
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
using LinearAlgebra
using ProgressMeter
using DocStringExtensions
import JSON

import ApproxManifoldProducts: HomotopyDensity

# NOTE a lot of legacy code has been moved to the attic

export plotPoints
export plot3d!

# include("Exports.jl")
include("services/StateAccessors.jl")
include("services/PlotManifolds.jl")
# include("services/PlotBoundingBox.jl")
include("services/PlotFeatureTracks.jl")
include("services/PlotHistogramGrid.jl")

# support weakdeps exports
include("../ext/Prototypes.jl")

include("services/TodoConsolidate.jl")
include("services/PlotSLAM2D.jl")
include("services/PlotGraphGeneric.jl")

# include("Deprecated.jl")


end # module
