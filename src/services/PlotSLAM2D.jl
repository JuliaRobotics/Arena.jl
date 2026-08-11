"""
    $SIGNATURES

Mutating 2D SLAM plot into an existing `Makie.Axis`.  Draws the pose trajectory,
heading markers (every `headingStride`-th pose), start/end markers, optional
landmarks, and optional variable label text.

See also: [`plotSLAM2D`](@ref)
"""
function plotSLAM2D!(
  ax,
  fg::AbstractDFG;
  poseRegex::Regex = r"^x",
  labels::AbstractVector{Symbol} = sortDFG(_ls(fg, poseRegex)),
  landmarkRegex::Union{Nothing, Regex} = nothing,
  landmarkLabels::AbstractVector{Symbol} = isnothing(landmarkRegex) ? Symbol[] : sortDFG(_ls(fg, landmarkRegex)),
  solveKey::Symbol = :parametric,
  drawTrajectory::Bool = true,
  drawHeadings::Bool = true,
  headingStride::Integer = 1,
  drawTrajectoryMarkers::Bool = true,
  drawVarLabels::Bool = false,
  drawPriors::Bool = false,
  markersize = 15,
  color = Makie.wong_colors()[1],
)
  pnts = points2(fg, labels; solveKey)

  if drawTrajectory
    lines!(ax, pnts; color, label = "trajectory ($(length(labels)))")
  end

  if drawHeadings
    θs = headings(fg, labels; solveKey)
    scatter!(
      ax, pnts[1:headingStride:end];
      rotation = θs[1:headingStride:end],
      markersize, marker = '➤', color,
      label = "heading",
    )
  end

  if drawTrajectoryMarkers && !isempty(pnts)
    scatter!(ax, pnts[1]; markersize = 20, marker = '✪', color = :green, label = "start $(labels[1])")
    scatter!(ax, pnts[end]; markersize = 20, marker = '⊙', color = :red, label = "end $(labels[end])")
  end

  if !isempty(landmarkLabels)
    lpnts = points2(fg, landmarkLabels; solveKey)
    scatter!(ax, lpnts; marker = '⊕', markersize, color = Makie.wong_colors()[2], label = "landmarks ($(length(landmarkLabels)))")
  end

  if drawPriors
    plotPriorPoints2!(ax, fg)
  end

  if drawVarLabels
    text!(ax, pnts; text = string.(labels), fontsize = 9, align = (:left, :bottom))
  end

  return ax
end

"""
    $SIGNATURES

Generic 2D SLAM figure of a factor graph: pose trajectory with heading markers,
start/end markers, optional landmarks, prior measurement points, and variable
labels.  Axis uses `DataAspect` with a title derived from the graph label.

Example
```julia
fig = plotSLAM2D(fg; landmarkRegex=r"^l", drawPriors=true)
```

See also: [`plotSLAM2D!`](@ref), [`plotPriorPoints2!`](@ref)
"""
function plotSLAM2D(
  fg::AbstractDFG;
  fig = Figure(),
  solveKey::Symbol = :parametric,
  title::AbstractString = string(getGraphLabel(fg), ",  solveKey: ", solveKey),
  xlabel::AbstractString = "x [m]",
  ylabel::AbstractString = "y [m]",
  legend::Bool = true,
  kwargs...,
)
  ax = Axis(fig[1, 1]; aspect = DataAspect(), title, xlabel, ylabel)
  plotSLAM2D!(ax, fg; solveKey, kwargs...)
  legend && axislegend(ax; merge = true, unique = true)
  return fig
end

"""
    $SIGNATURES

Scatter the 2D measurement means of prior factors (e.g. GPS/satnav priors) into
an existing axis.  Select the factors via `factor_labels`, e.g.
`lsfPriors(fg)` (default) or `listFactors(fg; whereTags = ⊇([:GPS_PRIOR]))`.
"""
function plotPriorPoints2!(
  ax,
  fg::AbstractDFG,
  factor_labels::AbstractVector{Symbol} = DFG.lsfPriors(fg);
  label = "priors ($(length(factor_labels)))",
  color = Makie.wong_colors()[3],
  markersize = 5,
  kwargs...,
)
  pnts = map(factor_labels) do f
    μ = mean(getObservation(fg, f).Z)
    Point2f(μ[1], μ[2])
  end
  return scatter!(ax, pnts; color, markersize, label, kwargs...)
end

"""
    $SIGNATURES

Plot accelerometer (components 1:3) and gyroscope (components 4:6) bias
trajectories of the `b*` bias variables in two stacked axes with per-axis
x/y/z legends.
"""
function plotBiases(
  fg::AbstractDFG,
  varlabels::AbstractVector{Symbol} = sortDFG(_ls(fg, r"^b"));
  fig = Figure(),
  solveKey::Symbol = :parametric,
)
  vals = map(v -> _meanPoint(fg, v, solveKey), varlabels)
  cols = Makie.wong_colors()[1:3]

  ax1 = Axis(fig[1, 1]; title = "Accelerometer bias", xlabel = "variable index", ylabel = "bias [m/s²]")
  ax2 = Axis(fig[2, 1]; title = "Gyroscope bias", xlabel = "variable index", ylabel = "bias [rad/s]")
  for (i, lbl) in enumerate(("x", "y", "z"))
    lines!(ax1, getindex.(vals, i); color = cols[i], label = lbl)
    lines!(ax2, getindex.(vals, i + 3); color = cols[i], label = lbl)
  end
  axislegend(ax1)
  axislegend(ax2)

  return fig
end
