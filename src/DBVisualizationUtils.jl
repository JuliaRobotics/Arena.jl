

function getmongokeys(fgl::FactorGraph, x::Symbol, IDs)
  cvid = -1
  # TODO -- could likely just use existing mapping already in fgl
  for id in IDs
    if Symbol(fgl.g.vertices[id[1]].label) == x
      cvid = id[2]
      break
    end
  end
  if cvid == -1
    warn("getmongokeys is not finding $(x)")
    return Dict{AbstractString, Any}(), cvid
  end
  # @show cvid
  cv = CloudGraphs.get_vertex(fgl.cg, cvid)
  if haskey(cv.properties, "mongo_keys")
    jsonstr = cv.properties["mongo_keys"]
    return JSON.parse(jsonstr), cvid
  else
    return Dict{AbstractString, Any}(), cvid
  end
end

function fetchmongorgbimg(cg::CloudGraph, key::AbstractString)
  myKeyToFind = BSONOID(key)
  findsomthing = find(cg.mongo.cgBindataCollection, ("_id" => eq(myKeyToFind)))
  myFavouriteKey = first( findsomthing );
  data = myFavouriteKey["val"]
  img = ImageMagick.readblob(data);

  # r, c = size(img)
  # imgA = zeros(r,c,3);
  # for i in 1:r, j in 1:c
  #   imgA[i,j,1] = img[i,j].r
  #   imgA[i,j,2] = img[i,j].g
  #   imgA[i,j,3] = img[i,j].b
  # end
  return img
end

function bin2arr(data::Vector{UInt8}; dtype::DataType=Float64)
  len = length(data)
  dl = sizeof(dtype)
  alen = round(Int,len/dl)

  ptrT = pointer(data)  # Ptr{UInt8}
  ptrTf = convert(Ptr{dtype}, ptrT)  # Ptr{Float32}
  arr = Vector{dtype}(alen);

  unsafe_copy!(pointer(arr),ptrTf,alen)

  return arr
end

function fetchmongodepthimg(cg::CloudGraph, key::AbstractString; dtype::DataType=Float64)
  myKeyToFind = BSONOID(key) # some valid numbers

  findsomthing = find(cg.mongo.cgBindataCollection, ("_id" => eq(myKeyToFind)))
  myFavouriteKey = first( findsomthing );
  mfkv = myFavouriteKey["val"];

  return bin2arr(mfkv, dtype=dtype)
  # len = length(mfkv)
  # dl = sizeof(dtype)
  # alen = round(Int,len/dl)
  #
  # ptrT = pointer(mfkv)  # Ptr{UInt8}
  # ptrTf = convert(Ptr{dtype}, ptrT)  # Ptr{Float32}
  # arr = Vector{dtype}(alen);
  #
  # unsafe_copy!(pointer(arr),ptrTf,alen)
  #
  # return arr
end






function findAllBinaryFactors(cgl::CloudGraph, session::AbstractString)
  xx = ls(cgl, session)

  slowly = Dict{Symbol, Tuple{Symbol, Symbol, Symbol}}()
  @showprogress 1 "Finding all binary edges..." for (x,va) in xx
    facts = ls(cgl, session, sym=x)
    for (fc, va2) in facts
      nodesdict = ls(cgl, session, sym=fc)
      if length(nodesdict) == 2
        # add to dictionary for later drawing
        nodes = collect(keys(nodesdict))
        if !haskey(slowly, fc) && !haselement(nodesdict[nodes[1]][3],:FACTOR) && !haselement(nodesdict[nodes[2]][3],:FACTOR)
          # fv = getVert(fgl, fgl.fIDs[fc])
          # vty = typeof(getfnctype(fv)).name.name
          slowly[fc] = (nodes[1], nodes[2], Symbol("NEEDCACHING"))
        end
      end
    end
  end

  return slowly
end





function cachepointclouds!(cache::Dict, cv::CloudVertex, ke::AbstractString, param::Dict)
  if !haskey(cache, ke)
    data = getBigDataElement(cv,ke)
    if typeof(data) == Nothing
      # warn("unable to load $(ke) from Mongo, gives data type Nothing")
      return nothing
    end
    data = data.data
    if ke == "depthframe_image"
      cache[ke] = getPointCloudFromKinect(data, param["dcamjl"], param["imshape"])
      # ri,ci = param["imshape"][1], param["imshape"][2] # TODO -- hack should be removed since depth is array and should have rows and columns stored in Mongo
      # # arrdata = data.data
      # arr = bin2arr(data, dtype=Float32) # should also store dtype for arr in Mongo
      # img = reshape(arr, ci, ri)'
      # X = reconstruct(param["dcamjl"], Array{Float64,2}(img))
      # cache[ke] = X
    elseif ke == "BSONpointcloud"
      # deserialize BSON-encoded pointcloud
      cache[ke] = getPointCloudFromBSON(data)
      # buf = IOBuffer(data)
      # st = takebuf_string(buf)
      # bb = BSONObject(st)
      # ptarr = map(x -> convert(Array, x), bb["pointcloud"])
      # cache[ke] = ptarr
    end
  end
  nothing
end


function retrievePointcloudColorInfo!(cv::CloudVertex, va::AbstractString)
  rgb = Array{Colorant,2}()
  if !hasBigDataElement(cv, va)
    warn("could not find color map in mongo, $(va)")
    return rgb
  end
  data = getBigDataElement(cv, va).data
  if va == "keyframe_rgb" || va == "keyframe_segnet"
    rgb = ImageMagick.readblob(data);
  elseif va == "BSONcolors"
    buffer = IOBuffer(data)
    str = takebuf_string(buffer)
    bb = BSONObject(str)
    # TODO -- maybe better to do: map(f, x), where f(x),
    # see http://docs.julialang.org/en/stable/manual/style-guide/#do-no-write-x-f-x
    carr = map(x -> convert(Array{UInt8}, x), bb["colors"])
    # typeof(rgb) = Array{Array{Colorant,1},1}
    rgb = carr
  end

  return rgb
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


#
