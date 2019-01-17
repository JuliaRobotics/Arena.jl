# basic pin hole camera model

#TODO: create a package that defines a camera model, there are lots of different ones all over the place
"""
	$(TYPEDEF)
Data structure for a Camera model with parameters.
Use `CameraModel(width,height,fc,cc,skew,kc)` for easy construction.
"""
struct CameraModel
    width::Int		# image width
    height::Int		# image height
    fc::Vector{Float64}	# focal length in x and y
	f::Float64			# if one focal lenght is used
    cc::Vector{Float64}	# camera center
    skew::Float64	    # skew value
    kc::Vector{Float64} # distortion coefficients up to fifth order or NTuple{5,Float64}
    K::Matrix{Float64} # 3x3 camera calibration matrix (Camera intrinsics)
    Ki::Matrix{Float64} # inverse of a 3x3 camera calibratio matrix
end

"""
	$(SIGNATURES)
Constructor helper for creating a camera model.
"""
function CameraModel(width::Int,height::Int,fc::Vector{Float64},cc::Vector{Float64},skew::Float64,kc::Vector{Float64})::CameraModel
    KK = [fc[1]      skew  cc[1];
             0       fc[2] cc[2];
             0		    0     1]
    Ki = inv(KK)
    CameraModel(width,height,fc, mean(fc),cc,skew,kc,KK,Ki)
end

"""
	$(SIGNATURES)
Constructor helper for creating a camera model.
"""
function CameraModel(width::Int,height::Int,f::Float64,cc::Vector{Float64})::CameraModel
    KK = [f 0 cc[1];
          0 f cc[2];
          0	0     1.]
    Ki = inv(KK)
    return CameraModel(width,height,[f,f], f, cc, 0.0, [0.], KK,Ki)
end


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
