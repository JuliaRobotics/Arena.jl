# Gets the robot config for the specified robot
# This contains params like camera matrices etc.

"""
    $(SIGNATURES)

Plugin callback for fetching and caching a robot config for use by other plugins.
"""
function getRobotConfiguration(vis::MeshCat.Visualizer,
                        params::Dict{Symbol, Any},
                        rose_fgl::Tuple{<:AbstractString, <:AbstractString} )
    if !haskey(params, :robotConfig)
		@info "Getting robot config for robot $(getGraffConfig().robotId)..."
		params[:robotConfig] = getRobotConfig()
	end
    return nothing
end

"""
    $(SIGNATURES)

Plugin callback for fetching robot config in the case of a local graph.
User must specify params[:robotConfig] beforehand in this case.
"""
function getRobotConfiguration(vis::MeshCat.Visualizer,
                        params::Dict{Symbol, Any},
                        rose_fgl::FactorGraph )
    #
	if !haskey(params, :robotConfig)
		error("For local graphs, please manually specify your robot config as a parameter params[:robotConfig]...")
	end
    return nothing
end
