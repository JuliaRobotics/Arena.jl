module ArenaCaesarExt

@info "Loading ArenaCaesarExt"

using GLMakie
using ColorSchemes
using TensorCast
using DocStringExtensions

using Caesar
import Caesar._PCL as _PCL

using Arena
import Arena: plotPointCloud, plotScatterAlign


include("services/PlotPointCloudMap.jl")
include("services/PlotScatterAlign.jl")



end