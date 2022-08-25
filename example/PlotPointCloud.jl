
using Makie, GLMakie
using Colors
using Caesar
import Caesar._PCL as _PCL

##

include(joinpath(@__DIR__, "CommonUtils.jl"))

##

# get a point cloud
# pc = ...

##

plotPointCloudPair(pc69, pc74)

plotPointCloudPair(pc69, pc74_)

##