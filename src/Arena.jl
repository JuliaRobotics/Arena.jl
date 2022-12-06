module Arena

# using Colors
import Manifolds as MJL
using Caesar
# const Caesar._PCL = _PCL
# can switch to WGLMakie after https://github.com/SimonDanisch/JSServe.jl/issues/131
using GLMakie
using ColorSchemes
using TensorCast

# a lot of legacy code has been moved to the attic

include("Exports.jl")
include("services/PlotPointCloudMap.jl")

end # module
