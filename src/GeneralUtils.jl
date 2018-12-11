# general utilities

function getPointCloudFromKinect(data, dcamjl, imshape)
  ri,ci = imshape[1], imshape[2] # TODO -- hack should be removed since depth is array and should have rows and columns stored in Mongo
  arr = bin2arr(data, dtype=Float32) # should also store dtype for arr in Mongo
  img = reshape(arr, ci, ri)'
  reconstruct(dcamjl, Array{Float64,2}(img))
end

function getPointCloudFromBSON(data)
  buf = IOBuffer(data)
  st = takebuf_string(buf)
  bb = BSONObject(st)
  return map(x -> convert(Array, x), bb["pointcloud"])
end



function robotsetup(cg::CloudGraph, session::AbstractString)
  resp = fetchrobotdatafirstpose(cg, session)

  if haskey(resp, "CAMK")
    # CAMK = [[ 570.34222412; 0.0; 319.5]';
    #  [   0.0; 570.34222412; 239.5]';
    #  [   0.0; 0.0; 1.0]'];
    dcamjl = DepthCamera(resp["CAMK"])
    buildmesh!(dcamjl)
    resp["dcamjl"] = dcamjl
  end

  if haskey(resp, "bTc")
    bTc = Translation(0.0,0,0) ∘ LinearMap( CoordinateTransformations.Quat(1.0,0,0,0) )
    if resp["bTc_format"] == "xyzqwqxqyqz"
      bTc = Translation(resp["bTc"][1:3]...) ∘ LinearMap( CoordinateTransformations.Quat(resp["bTc"][4:7]...) )
    else
      warn("Unknown bTc_format, assuming identity for bTc")
    end
    resp["bTc"] = bTc
  end
  resp
end
