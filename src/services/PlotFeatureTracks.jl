

# visualization aid

function plotBlobsImageTracks!(
  dfg::AbstractDFG,
  vlb::Symbol,
  key = r"IMG_FEATURE_TRACKS_FWDBCK";
  fig = GLMakie.Figure(),
  ax = GLMakie.Axis(fig[1,1]),
  resolution::Union{Nothing,<:Tuple} = nothing,
  img::Union{Nothing,<:AbstractMatrix{<:Colorant}} = nothing,
  linewidth = 5
)

  height = 0
  if !isnothing(img)
    image!(ax, rotr90(img))
    height = size(img,1)
  end

  eb = getData(dfg,vlb,key)
  img_tracks = JSON3.read(String(eb[2]), Dict{Int, Vector{Vector{Float32}}})
  
  len = length(img_tracks)
  UU = [Vector{Float64}() for k in 1:len]
  VV = [Vector{Float64}() for k in 1:len]

  fbk = floor(Int, (len-1)/2)
  for k in 1:len
    for i in -fbk:fbk
      push!(UU[k],  img_tracks[i][k][1])  
      push!(VV[k], height-img_tracks[i][k][2])
    end
    lines!(ax, UU[k], VV[k]; color=RGBf(rand(3)...), linewidth)
  end
  if !isnothing(resolution)
    xlims!(ax, 0, resolution[1])
    ylims!(ax, height - resolution[2], height)
    # ylims!(ax, -resolution[2], 0)
  end

  fig
end