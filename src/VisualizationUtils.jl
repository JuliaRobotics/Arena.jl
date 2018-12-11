# some drawing utils


function (as::ArcPointsRangeSolve)(res::Vector{Float64}, x::Vector{Float64})
  res[1] = norm(x-as.x1)^2 - as.r^2
  res[2] = norm(x-as.x2)^2 - as.r^2
  if length(res) == 3
    res[3] = norm(x-as.x3)^2 - as.r^2
  end
  nothing
end

function findaxiscenter!(as::ArcPointsRangeSolve)
  d = length(as.center)
  x0 = 0.5*(as.x1+as.x2)
  r = nlsolve(as, x0)
  as.center = r.zero
  vA, vB, vC = as.x1-as.center, as.x2-as.center, as.x3-as.center
  l1, l2 = norm(as.x1-as.x2), norm(as.x2-as.x3)
  halfl0 = 0.5*norm(as.x1-as.x3)
  axt = l1 < l2 ? Base.cross(vA,vB) : Base.cross(vB,vC)
  as.axis[1:3] = axt / norm(axt)
  ta = Base.cross(vA,vC)
  ta ./= norm(ta)
  alph = acos(halfl0/as.r)
  if norm(ta-as.axis) < 1e-4
    #accute
    as.angle = pi - 2*alph
  else
    # oblique
    as.angle = pi + 2*alph
  end
  r.f_converged
end

# as = ArcPointsRangeSolve([-1.0;0],[2.0;0],1.5)
# nlsolve(as, [1.0;1.0])


# find and set initial transform to project model in the world frame to the
# desired stating point and orientation
function findinitaffinemap!(as::ArcPointsRangeSolve; initrot::Rotation=Rotations.Quaternion(1.0,0,0,0))
  # how to go from origin to center to x1 of arc
  cent = Translation(as.center)
  rho = Translation(as.r, 0,0)
  return
end




# DrakeVisualizer.new_window()
# vctest = testtriaddrawing()




function gettopoint(drawtype::Symbol=:max)
  topoint = +
  if drawtype == :max
    topoint = getKDEMax
  elseif drawtype == :mean
    topoint = getKDEMean
  elseif drawtype == :fit
    topoint = (x) -> getKDEfit(x).μ
  else
    error("Unknown draw type")
  end
  return topoint
end

function getdotwothree(sym::Symbol, X::Array{Float64,2})
  dims = size(X,1)
  dotwo = dims == 2 || (dims == 3 && string(sym)[1] == 'x')
  dothree = dims == 6 || (string(sym)[1] == 'l' && dims != 2)
  (dotwo && dothree) || (!dotwo && !dothree) ? error("Unknown dimension for drawing points in viewer, $((dotwo, dothree))") : nothing
  return dotwo, dothree
end

function colorwheel(n::Int)
  # RGB(1.0, 1.0, 0)
  convert(RGB, HSV((n*30)%360, 1.0,0.5))
end


function drawLine!(vispath, from::Vector{Float64}, to::Vector{Float64}; scale=0.01,color=RGBA(0,1.0,0,0.5))
  vector = to-from
  len = norm(vector)
  buildline = Float64[len, 0, 0]

  v = norm(buildline-vector) > 1e-10 ? Base.cross(buildline, vector)  : [0,0,1.0]
  axis = v/norm(v)
  angle = acos(dot(vector, buildline)/(len^2) )
  rot = LinearMap( CoordinateTransformations.AngleAxis(angle, axis...) )

  mol = HyperRectangle(Vec(0.0,-scale,-scale), Vec(len,scale,scale))
  molbox = GeometryData(mol, color)

  setgeometry!(vispath, molbox)
  settransform!(vispath, Translation(from...) ∘ rot )
  nothing
end







function findAllBinaryFactors(fgl::FactorGraph; api::DataLayerAPI=dlapi)
  xx, ll = ls(fgl)

  slowly = Dict{Symbol, Tuple{Symbol, Symbol, Symbol}}()
  for x in xx
    facts = ls(fgl, x, api=localapi) # TODO -- known BUG on ls(api=dlapi)
    for fc in facts
      nodes = lsf(fgl, fc)
      if length(nodes) == 2
        # add to dictionary for later drawing
        if !haskey(slowly, fc)
          fv = getVert(fgl, fgl.fIDs[fc])
          slowly[fc] = (nodes[1], nodes[2], typeof(getfnctype(fv)).name.name)
        end
      end
    end
  end

  return slowly
end




function pointToColor(nm::Symbol)
  if nm == :PartialPose3XYYaw
    return RGBA(0.6,0.8,0.9,0.5)
  elseif nm == :Pose3Pose3NH
    return RGBA(1.0,1.0,0,0.5)
  else
    # println("pointToColor(..) -- warning, using default color for edges")
    return RGBA(0.0,1,0.0,0.5)
  end
end


function submapcolor(idx::Int, len::Int;
        submapcolors=SubmapColorCheat() )
  #
  n = idx%length(submapcolors.colors)+1
  smc = submapcolors.colors[n]
  return [smc for g in 1:len]
end


meshgrid(v::AbstractVector) = meshgrid(v, v)

function meshgrid(vx::AbstractVector{T}, vy::AbstractVector{T}) where T
    m, n = length(vy), length(vx)
    vx = reshape(vx, 1, n)
    vy = reshape(vy, m, 1)
    (repmat(vx, m, 1), repmat(vy, 1, n))
end


# Construct mesh for quick reconstruction
function buildmesh!(dc::DepthCamera)
  H, W = dc.shape
  xs,ys = collect(1:W), collect(1:H)
  fxinv = 1.0 / dc.K[1,1];
  fyinv = 1.0 / dc.K[2,2];

  xs = (xs-dc.K[1,3]) * fxinv
  xs = xs[1:dc.skip:end]
  ys = (ys-dc.K[2,3]) * fyinv
  ys = ys[1:dc.skip:end]

  dc.xs, dc.ys = meshgrid(xs, ys);
  nothing
end


function reconstruct(dc::DepthCamera, depth::Array{Float64})
  s = dc.skip
  depth_sampled = depth[1:s:end,1:s:end]
  # assert(depth_sampled.shape == self.xs.shape)
  r,c = size(dc.xs)

  ret = Array{Float64,3}(r,c,3)
  ret[:,:,1] = dc.xs .* depth_sampled
  ret[:,:,2] = dc.ys .* depth_sampled
  ret[:,:,3] = depth_sampled
  return ret
end


# function prepcolordepthcloud!{T <: ColorTypes.Colorant}( X::Array;
#       rgb::Array{T, 2}=Array{Colorant,2}(),
#       skip::Int=4,
#       maxrange::Float64=4.5 )
function prepcolordepthcloud!( cvid::Int,
      X::Array;
      rgb::Array=Array{Colorant,2}(),
      skip::Int=4,
      maxrange::Float64=4.5 )
  #
  pointcloud = nothing
  pccols = nothing
  havecolor = size(rgb,1) > 0
  if typeof(X) == Array{Float64,3}
    r,c,h = size(X)
    Xd = X[1:skip:r,1:skip:c,:]
    rd,cd,hd = size(Xd)
    mask = Xd[:,:,:] .> maxrange
    Xd[mask] = Inf

    rgbss = havecolor ? rgb[1:skip:r,1:skip:c] : nothing
    # rgbss = rgb[1:4:r,1:4:c,:]./255.0
    pts = Vector{Vector{Float64}}()
    pccols = Vector()
    for i in 1:rd, j in 1:cd
      if !isnan(Xd[i,j,1]) && Xd[i,j,3] != Inf
        push!(pts, vec(Xd[i,j,:]) )
        havecolor ? push!(pccols, rgbss[i,j] ) : nothing
        # push!(pccols, RGB(rgbss[i,j,3], rgbss[i,j,2], rgbss[i,j,1]) )
      end
    end
    pointcloud = PointCloud(pts)
  elseif typeof(X) == Array{Array{Float64,1},1}
    pointcloud = PointCloud(X)
    pccols = rgb # TODO: refactor
  elseif size(X,1)==0
    return nothing
  else
    error("dont know how to deal with data type=$(typeof(X)),size=$(size(X))")
  end
  if havecolor
    pointcloud.channels[:rgb] = pccols
  else
    #submap colors
    smc = submapcolor(cvid, length(X))
    pointcloud.channels[:rgb] = smc
  end
  return pointcloud
end


#
