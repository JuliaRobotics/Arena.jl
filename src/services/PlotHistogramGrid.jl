# plotting tools for fields in factor graphs



"""
    $SIGNATURES

Get the cartesian range over which the factor graph variables span.

Notes:
- Optional `regexFilter` can be used to subselect, according to label, which variable IDs to use.

DevNotes
- TODO, allow `tags` as filter too.
"""
function getRangeCartesian(
  dfg::AbstractDFG,
  regexFilter::Union{Nothing, Regex}=nothing;
  varList = listVariables(dfg, regexFilter),
  factorList = Symbol[],
  extend::Float64=0.2,
  digits::Int=6,
  xmin::Real=99999999,
  xmax::Real=-99999999,
  ymin::Real=99999999,
  ymax::Real=-99999999,
  force::Bool=false,
)
  #

  if !force
    # which variables to consider

    # find the cartesian range over all the varList variables
    for vsym in varList
      lran = getKDERange(getVariable(dfg, vsym) |> getBelief)
      xmin = lran[1,1] < xmin ? lran[1,1] : xmin
      ymin = lran[2,1] < ymin ? lran[2,1] : ymin
      xmax = xmax < lran[1,2] ? lran[1,2] : xmax
      ymax = ymax < lran[2,2] ? lran[2,2] : ymax
    end

    _getBeliefRange(s::ManifoldKernelDensity;extend=0.1) = getKDERange(s;extend)
    _getBeliefRange(s::MvNormal;extend=0.1) = [(s.μ[1]-3*s.Σ[1,1]) (s.μ[1]+3*s.Σ[1,1]); (s.μ[2]-3*s.Σ[2,2]) (s.μ[2]+3*s.Σ[2,2])]

    # FIXME only works for very limited set of factors, has .Z and complies with Position{2}
    for fsym in factorList
      lran = _getBeliefRange(getFactorType(dfg, fsym).Z)
      xmin = lran[1,1] < xmin ? lran[1,1] : xmin
      ymin = lran[2,1] < ymin ? lran[2,1] : ymin
      xmax = xmax < lran[1,2] ? lran[1,2] : xmax
      ymax = ymax < lran[2,2] ? lran[2,2] : ymax
    end

    # extend the range for looser bounds on plot
    xra = xmax-xmin; xra *= extend
    yra = ymax-ymin; yra *= extend
    xmin -= extend; xmax += extend
    ymin -= extend; ymax += extend

    # clamp to nearest integers
    xmin = floor(xmin, digits=digits); xmax = ceil(xmax, digits=digits)
    ymin = floor(ymin, digits=digits); ymax = ceil(ymax, digits=digits)
  end

  return [xmin xmax; ymin ymax]
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
      coords[:zmin] = 9e10
      coords[:zmax] = -9e10
    end
  end

  return coords
end


function histGrid(
  dfg::AbstractDFG;
  varList = listVariables(dfg),
  factorList = Symbol[],
  N = 100,
)
  #
  coords = getRange(dfg; varList, factorList)

  img = zeros(N,N)
  
  ev = zeros(2,1)

  _makeDens2D(_P::ManifoldKernelDensity) = begin
    P_ = marginal(_P,[1;2])
    P__ = manikde!(
      Position2, #getManifold(P_),
      getPoints(P_,true),
      bw=getBW(P_)
    )
    P__
  end
  _makeDens2D(_P::MvNormal) = begin
    s->pdf(MvNormal(_P.μ[1:2], _P.Σ[1:2,1:2]),s[:])
  end
  _getBeliefRange(s::ManifoldKernelDensity; extend=0.1) = getKDERange(s;extend)
  _getBeliefRange(s::MvNormal; extend=0.1) = [(s.μ[1]-3*s.Σ[1,1]) (s.μ[1]+3*s.Σ[1,1]); (s.μ[2]-3*s.Σ[2,2]) (s.μ[2]+3*s.Σ[2,2])]

  @showprogress desc="computing variable's histogram" dt=1 for P in getBelief.(getVariable.(dfg,varList)), 
                                                    (i,x) in enumerate(range(coords[:xmin],coords[:xmax];length=N)), 
                                                    (j,y) in enumerate(range(coords[:ymin],coords[:ymax];length=N))
    P__ = _makeDens2D(P)
    roi = _getBeliefRange(P__; extend=0.3)
    if (roi[1,1] <= x <= roi[1,2]) && (roi[2,1] <= y <= roi[2,2])
      ev[1,1] = x
      ev[2,1] = y
      img[i,j] += P__(ev)[1]
    end
  end

  @showprogress desc="computing factor's histogram" dt=1 for P in (getFactorType.(dfg,factorList) .|> s->s.Z), 
                                                    (i,x) in enumerate(range(coords[:xmin],coords[:xmax];length=N)), 
                                                    (j,y) in enumerate(range(coords[:ymin],coords[:ymax];length=N))
    P__ = _makeDens2D(P)
    roi = _getBeliefRange(P__; extend=0.3)
    if (roi[1,1] <= x <= roi[1,2]) && (roi[2,1] <= y <= roi[2,2])
      ev[1,1] = x
      ev[2,1] = y
      img[i,j] += P__(ev)
    end
  end

  return img, coords
end


function plotSLAM2D_Histogram(
  dfg::AbstractDFG;
  varList::AbstractVector{Symbol}=listVariables(dfg),
  N::Integer=200,
  verbose::Bool=true,
  colormap=:dense, #:viridis,
  colorscale=sqrt, #identity, #log,
  title=dfg.sessionLabel,
  xlabel="x-axis",
  ylabel="y-axis",
)
  verbose && @show(varList)
  img,coords = histGrid(dfg;varList,N)
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