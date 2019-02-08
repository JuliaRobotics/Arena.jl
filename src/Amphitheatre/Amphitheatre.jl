# module Amphitheatre
# TODO this can maybe be a module in Arena?
using MeshCat
using CoordinateTransformations
using Colors
using PlotUtils
using Sockets: @ip_str, IPAddr, IPv4, IPv6
using GraffSDK
using Caesar
using JSON2

using DocStringExtensions
# using Rotations
# using TransformUtils
# using FileIO
# using Base64

const CTs = CoordinateTransformations
const TUs = TransformUtils

# export
# 	BasicFactorGraphPose,
# 	AbstractAmphitheatre,
# 	visualize

include("core.jl")
include("amphis.jl")
include("pointclouds.jl")


global runAmphi = true

function stopAmphiVis!()
	global runAmphi
  	runAmphi = false
  	nothing
end


"""
    $(SIGNATURES)
Initialize empty visualizer window with home axis.  New browser window will be opened based on `show=true`.
"""
function startMeshCatVisualizer(;start_browser::Bool=true,
                                    draworigin::Bool=true,
                                    originscale::Float64=1.0  )
    #
    global drawtransform

    viz = MeshCat.Visualizer()
    if draworigin
      setobject!( viz[:origin], Triad(originscale) )
      # settransform!( viz[:origin], (Translation(0.0, 0.0, 0.0) ∘ LinearMap( CTs.Quat(1.0,0,0,0))) )
    end

    # open a new browser tab if required
    # open(viz, start_browser=start_browser, host=ip"0.0.0.0") #waiting for merge
	open(viz)#, host=ip"0.0.0.0")

    return viz
end


"""
   $(SIGNATURES)
High level interface to launch webserver process that draws a factor_graph_vis_type <: AbstractAmphitheatre, using Three.js and MeshCat.jl.
User factor_graph_vis_type should provide a visualize!(vis::Visualizer, factor_graph_vis_variables::T<:AbstractAmphitheatre ) function.
"""
function visualize(visdatasets::Vector{AbstractAmphitheatre};
                   show::Bool=true, trans=Translation(0.0,0.0,0.0), quat::Rotations.Quat=Quat(1.0,0.0,0.0,0.0))
    #
    global runAmphi

    runAmphi = true

    # the visualizer object itself
    vis = startMeshCatVisualizer()
	setGlobalDrawTransform!(vis, trans=trans, quat=quat)

    # run the visualization loop #TODO add is task done to avoid multiple tasks getting lost
    runAphiTask = @async begin
		while runAmphi
			# iterate through all datasets #vir wat staan rose_fgl?
			for rose_fgl in visdatasets
				# each dataset should provide an visualize function
				visualize!(vis, rose_fgl)
			end
			# take a break and repeat
			sleep(1)
		end
		@info "visualize is finalizing."
	end

    return vis, runAphiTask
end



# end
