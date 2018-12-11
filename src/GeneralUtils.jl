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
