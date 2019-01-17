# Standard plugin template

function pluginCallback(vis::MeshCat.Visualizer,
                        params::Dict{Symbol, Any},
                        rose_fgl::Union{FactorGraph, Tuple{<:AbstractString, <:AbstractString}} )
    #
    @show length(params[:cachevars])

    @error "Implement the plugin functionality here"

    nothing
end
