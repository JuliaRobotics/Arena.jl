# plotting tools for fields in factor graphs

const EMPTY_AXES_DICT = Dict{Symbol, Float64}(:xmin=>99999999,:xmax=>-99999999,:ymin=>99999999,:ymax=>-99999999)


_getBeliefRange(s::ManifoldKernelDensity; extend=0.1) = getKDERange(s;extend)
_getBeliefRange(s::MvNormal; extend=0.1) = [(s.μ[1]-3*s.Σ[1,1]) (s.μ[1]+3*s.Σ[1,1]); (s.μ[2]-3*s.Σ[2,2]) (s.μ[2]+3*s.Σ[2,2])]


"""
    $SIGNATURES

Get the cartesian range over which the factor graph variables span.

Notes:
- Optional `regexFilter` can be used to subselect, according to label, which variable IDs to use.

DevNotes
- TODO, allow `tags` as filter too.
"""
function getRangeCartesian(
  P::Union{<:ManifoldKernelDensity,<:MvNormal};
  xmin::Real=99999999,
  xmax::Real=-99999999,
  ymin::Real=99999999,
  ymax::Real=-99999999,
  extend::Float64=0.2,
  digits::Int=6,
  force::Bool=false,
)
  if force
    return [xmin xmax; ymin ymax]
  end

  lran = _getBeliefRange(P)
  xmin = lran[1,1] < xmin ? lran[1,1] : xmin
  ymin = lran[2,1] < ymin ? lran[2,1] : ymin
  xmax = xmax < lran[1,2] ? lran[1,2] : xmax
  ymax = ymax < lran[2,2] ? lran[2,2] : ymax

  # extend the range for looser bounds on plot
  xra = xmax-xmin; xra *= extend
  yra = ymax-ymin; yra *= extend
  xmin -= extend; xmax += extend
  ymin -= extend; ymax += extend

  # clamp to nearest digits
  xmin = floor(xmin, digits=digits); xmax = ceil(xmax, digits=digits)
  ymin = floor(ymin, digits=digits); ymax = ceil(ymax, digits=digits)

  return [xmin xmax; ymin ymax]
end

function getRangeCartesian(
  dfg::AbstractDFG,
  regexFilter::Union{Nothing, Regex}=nothing;
  varList = listVariables(dfg, regexFilter),
  factorList = Symbol[],
  xmin::Real=99999999,
  xmax::Real=-99999999,
  ymin::Real=99999999,
  ymax::Real=-99999999,
  force::Bool=false,
  kw...
)
  if force
    return [xmin xmax; ymin ymax]
  end

  # which variables to consider
  # find the cartesian range over all the varList variables
  for vsym in varList
    lran = getRangeCartesian(getVariable(dfg, vsym) |> getBelief; force, xmin,xmax,ymin,ymax,kw...)
    xmin = lran[1,1] < xmin ? lran[1,1] : xmin
    ymin = lran[2,1] < ymin ? lran[2,1] : ymin
    xmax = xmax < lran[1,2] ? lran[1,2] : xmax
    ymax = ymax < lran[2,2] ? lran[2,2] : ymax
  end

  # FIXME only works for very limited set of factors, has .Z and complies with Position{2}
  for fsym in factorList
    lran = getRangeCartesian(getFactorType(dfg, fsym).Z; force, xmin,xmax,ymin,ymax,kw...)
    xmin = lran[1,1] < xmin ? lran[1,1] : xmin
    ymin = lran[2,1] < ymin ? lran[2,1] : ymin
    xmax = xmax < lran[1,2] ? lran[1,2] : xmax
    ymax = ymax < lran[2,2] ? lran[2,2] : ymax
  end

  return [xmin xmax; ymin ymax]
end



function getRange(
  P::Union{<:ManifoldKernelDensity,<:MvNormal};
  extend::Float64=0.2,
)
  # Reuse a legacy method
  axes = getRangeCartesian(P; extend)
  
  coords = Dict{Symbol, Float64}()

  coords[:xmin] = axes[1,1]
  coords[:xmax] = axes[1,2]
  coords[:ymin] = axes[2,1]
  coords[:ymax] = axes[2,2]

  return coords
end

function getRange(
  dfg::AbstractDFG,
  regexFilter::Union{Nothing, Regex}=nothing;
  varList = listVariables(dfg, regexFilter),
  factorList = Symbol[],
  extend::Float64=0.2,
)
  # Reuse a legacy method
  axes = getRangeCartesian(dfg, regexFilter; varList, factorList, extend)
  
  coords = Dict{Symbol, Float64}()

  coords[:xmin] = axes[1,1]
  coords[:xmax] = axes[1,2]
  coords[:ymin] = axes[2,1]
  coords[:ymax] = axes[2,2]
  if 0 < length(varList)
    if typeof(getVariableType(dfg, varList[1])).name.name in [:Pose3; :Position3; :RotVelPos]
      coords[:zmin] = 99999999
      coords[:zmax] = -99999999
    end
  end

  return coords
end


function _makeDens2D(
  _P::ManifoldKernelDensity
)
  P_ = marginal(_P,[1;2])
  P__ = manikde!(
    Position2, # TODO, do better than just TranslationGroup(2)
    getPoints(P_,true),
    bw=getBW(P_)[:,1]
  )
  P__
end
function _makeDens2D(
  _P::MvNormal
)
  s->pdf(MvNormal(_P.μ[1:2], _P.Σ[1:2,1:2]),s[:])
end

function histBelief2D!(
  img::AbstractMatrix, 
  i::Integer, 
  x::Real, 
  j::Integer, 
  y::Real, 
  P::Union{<:ManifoldKernelDensity, <:MvNormal}
)
  P_ = _makeDens2D(P)
  roi = _getBeliefRange(P_; extend=0.3)
  if (roi[1,1] <= x <= roi[1,2]) && (roi[2,1] <= y <= roi[2,2])
    ev = zeros(2,1)
    ev[1,1] = x
    ev[2,1] = y
    img[i,j] += P_(ev)[1]
  end
  nothing
end

function histBeliefs2D!(
  PP::AbstractVector{T};
  N::Integer = 100,
  verbose::Bool=true,
  extend::Real=0.2,
  img::AbstractMatrix = zeros(N,N),
  coords = 0 < length(PP) ? getRange(PP[1]; extend) : EMPTY_AXES_DICT,
) where {T<:Union{<:ManifoldKernelDensity,<:MvNormal}}
  #
  for P in PP
    _c = getRange(P; extend)
    coords[:xmin] = _c[:xmin] < coords[:xmin] ? _c[:xmin] : coords[:xmin]
    coords[:xmax] = coords[:xmax] < _c[:xmax] ? _c[:xmax] : coords[:xmax]
    coords[:ymin] = _c[:ymin] < coords[:ymin] ? _c[:ymin] : coords[:ymin]
    coords[:ymax] = coords[:ymax] < _c[:ymax] ? _c[:ymax] : coords[:ymax]
  end
  
  NN = N*N*length(PP)
  p = if verbose
    Progress(NN; dt=1, desc="computing belief histogram")
  end
  tasks = Vector{Task}(undef, NN)
  n = 0

  for _P in PP,
      (i,x) in enumerate(range(coords[:xmin],coords[:xmax];length=N)), 
      (j,y) in enumerate(range(coords[:ymin],coords[:ymax];length=N))
    #
    n += 1
    tasks[n] = Threads.@spawn begin
      histBelief2D!(img, $i, $x, $j, $y, $_P)
      verbose && next!(p)
    end
    # histBelief2D!(img, i, x, j, y, _P) # non threaded version
  end

  wait.(tasks)
  verbose && finish!(p)

  return img, coords
end

histBeliefs2D!(
  PP::AbstractVector;
  N::Integer = 100,
  verbose::Bool=true,
  extend::Real=0.2,
  img::AbstractMatrix = zeros(N,N),
  coords::Dict{Symbol, Float64} = EMPTY_AXES_DICT,
) = img, coords

function histBeliefs2D(
  dfg::AbstractDFG;
  varList = listVariables(dfg),
  factorList = Symbol[],
  N::Integer = 100,
  verbose::Bool=true
)
  #

  NNv = N*N*length(varList)
  verbose && @info("# hist tasks = $NNv")
  # p = Progress(NNv; dt=1, desc="computing variable's histogram")
  # tasks = Vector{Task}(undef, NNv)
  # n = 0
  PP = getBelief.(getVariable.(dfg,varList))
  img, coords = histBeliefs2D!(PP; N, verbose)

  P2 = (getFactorType.(dfg,factorList) .|> s->s.Z)
  img, coords = histBeliefs2D!(P2; N, verbose, img, coords)
  # @showprogress desc="computing factor's histogram" dt=1 for 
  #                                                   (i,x) in enumerate(range(coords[:xmin],coords[:xmax];length=N)), 
  #                                                   (j,y) in enumerate(range(coords[:ymin],coords[:ymax];length=N))
  #   P__ = _makeDens2D(P)
  #   roi = _getBeliefRange(P__; extend=0.3)
  #   if (roi[1,1] <= x <= roi[1,2]) && (roi[2,1] <= y <= roi[2,2])
  #     ev = zeros(2,1)
  #     ev[1,1] = x
  #     ev[2,1] = y
  #     img[i,j] += P__(ev)
  #   end
  # end

  return img, coords
end


function plotBelief_Histogram(
  PP::AbstractVector{T};
  N::Integer=200,
  verbose::Bool=true,
  colormap=:dense, #:viridis,
  colorscale=sqrt, #identity, #log,
  title="Histogram, N=$N, of $(length(PP)) beliefs",
  xlabel="x-axis",
  ylabel="y-axis",
) where {T<: Union{<:ManifoldKernelDensity, <:MvNormal}}
  #
  img,coords = histBeliefs2D(PP; N, verbose)
  xrg = range(coords[:xmin],coords[:xmax];length=N)
  yrg = range(coords[:ymin],coords[:ymax];length=N)
  image(
    xrg, 
    yrg, 
    img; 
    colorscale, 
    colormap,
    axis=(;title,xlabel,ylabel)
  )
end

const plotBeliefs_Histogram(w...;kw...) = plotBelief_Histogram(w...;kw...)

plotBelief_Histogram(
  P::T,
  w...;
  kw...
) where {T<:Union{<:ManifoldKernelDensity, <:MvNormal}} = plotBeliefs_Histogram(
  T[P;],
  w...;
  kw...
)


function plotSLAM2D_Histogram(
  dfg::AbstractDFG;
  varList::AbstractVector{Symbol}=listVariables(dfg),
  factorList = Symbol[],
  N::Integer=200,
  verbose::Bool=true,
  colormap=:dense, #:viridis,
  colorscale=sqrt, #identity, #log,
  title=dfg.sessionLabel,
  xlabel="x-axis",
  ylabel="y-axis",
)
  verbose && @show(varList)
  img,coords = histBeliefs2D(dfg;varList, factorList, N, verbose)
  xrg = range(coords[:xmin],coords[:xmax];length=N)
  yrg = range(coords[:ymin],coords[:ymax];length=N)
  image(
    xrg, 
    yrg, 
    img; 
    colorscale, 
    colormap,
    axis=(;title,xlabel,ylabel)
  )
end


##