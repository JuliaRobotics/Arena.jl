# Types used in Arena.jl

mutable struct DepthCamera
  K::Array{Float64,2}
  shape::Tuple{Int, Int}
  skip::Int
  D::Vector{Float64}
  xs::Array{Float64}
  ys::Array{Float64}
  DepthCamera(K::Array{Float64,2};
      shape::Tuple{Int,Int}=(480,640),
      skip::Int=1,
      D::Vector{Float64}=zeros(5) ) = new( K, shape, skip, D, Array{Float64,2}(), Array{Float64,2}() )
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
