


# something like this later for botvis 3
# poses3::Dict{Symbol,Tuple{Point{3,Float32},Quat{Float64}}}



"""
    $(SIGNATURES)
Initialize empty visualizer
"""
function initBotVis2(;showLocal::Bool = true)::BotVis2
    vis = Visualizer()
    showLocal && open(vis)
    return BotVis2(vis, Dict{Symbol, NTuple{3,Float64}}(), Dict{Symbol, NTuple{3,Float64}}())
end
