module Arena

# using Colors
using Caesar
# const Caesar._PCL = _PCL
# can switch to WGLMakie after https://github.com/SimonDanisch/JSServe.jl/issues/131
using GLMakie

# a lot of legacy code has been moved to the attic

export plotPointCloud, plotPointCloudPair, plotPointCloud2D
export plotGraphPointClouds

include("services/PlotPointCloudMap.jl")

end # module
