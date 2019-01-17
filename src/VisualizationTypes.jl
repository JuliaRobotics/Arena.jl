# Types used in Arena.jl

const lmpoint = HyperSphere(Point(0.,0,0), 0.05)
const greenMat = MeshPhongMaterial(color=RGBA(0, 1, 0, 0.5))
const redMat = MeshPhongMaterial(color=RGBA(0, 1, 0, 0.5))

"""
	$(TYPEDEF)
Type for 2d visualization
"""
struct BotVis2
    vis::Visualizer
    # poses::Dict{Symbol, NTuple{3,Float64}}
    # landmarks::Dict{Symbol, NTuple{3,Float64}}
    cachevars::Dict{Symbol, Tuple{Symbol, Vector{Bool}, Vector{Float64}}}
end



mutable struct SubmapColorCheat
  colors
  SubmapColorCheat(;colors::Vector=
    [ RGB(0.651, 0.808, 0.890),
      RGB(0.122, 0.471, 0.706),
      RGB(0.698, 0.875, 0.541),
      RGB(0.200, 0.627, 0.172),
      RGB(0.984, 0.604, 0.600),
      RGB(0.890, 0.102, 0.110),
      RGB(0.992, 0.749, 0.043)]
  ) = new(colors)
end


mutable struct ArcPointsRangeSolve <: Function
  x1::Vector{Float64}
  x2::Vector{Float64}
  x3::Vector{Float64}
  r::Float64
  center::Vector{Float64}
  angle::Float64
  axis::Vector{Float64}
  ArcPointsRangeSolve(x1::Vector{Float64}, x2::Vector{Float64}, r::Float64) = new(x1,x2,zeros(0),r, zeros(2), 0.0, zeros(3))
  ArcPointsRangeSolve(x1::Vector{Float64}, x2::Vector{Float64}, x3::Vector{Float64}, r::Float64) = new(x1,x2,x3,r, zeros(3), 0.0, zeros(3))
end
