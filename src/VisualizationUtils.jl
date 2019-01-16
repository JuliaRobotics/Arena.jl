# General visualization utils


# find and set initial transform to project model in the world frame to the
# desired stating point and orientation
function findinitaffinemap!(as::ArcPointsRangeSolve; initrot::Rotation=Rotations.Quaternion(1.0,0,0,0))
  # how to go from origin to center to x1 of arc
  cent = Translation(as.center)
  rho = Translation(as.r, 0,0)
  return
end



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




function visualizeVariableCache!(vis::Visualizer,
                                 cachevars::Dict{Symbol, Tuple{Symbol,Vector{Float64}}};
                                 sessionId::String="Session"  )::Nothing
    #

    for (vsym, valpair) in cachevars
        # TODO -- consider upgrading to MultipleDispatch with actual softtypes
        if valpair[1] == :Point2
            visPoint2!(vis, sessionId, vsym, valpair[2])
        elseif valpair[1] == :Pose2
            visPose2!(vis, sessionId, vsym, valpair[2])
        elseif valpair[1] == :Point3
            visPoint3!(vis, sessionId, vsym, valpair[2])
        elseif valpair[1] == :Pose3
            visPose3!(vis, sessionId, vsym, valpair[2])
        else
            error("Unknown softtype symbol to visualize from cache.")
        end

    end

    return nothing
end





#
