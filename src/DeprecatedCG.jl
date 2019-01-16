# Deprecated


function drawLineBetween!(vis,
        cgl::CloudGraph,
        session::AbstractString,
        fr::Symbol,
        to::Symbol;
        scale=0.01,
        name::Symbol=:edges,
        subname::Union{Nothing,Symbol}=nothing,
        color=RGBA(0,1.0,0,0.5)  )
  #

  cv1 = getCloudVert(cgl, session, sym=fr)
  v1 = cloudVertex2ExVertex(cv1)
  cv2 = getCloudVert(cgl, session, sym=to)
  v2 = cloudVertex2ExVertex(cv2)

  drawLineBetween!(vis,session,v1,v2,scale=scale,name=name,subname=subname,color=color   )
  nothing
end




function drawAllBinaryFactorEdges!(vis,
                                   cgl::CloudGraph,
                                   session::AbstractString;
                                   scale=0.01   )
  #

  sloth = findAllBinaryFactors(cgl, session)

  @showprogress 1 "Drawing all binary edges..." for (teeth, toe) in sloth
    color = pointToColor(toe[3])
    drawLineBetween!(vis, cgl, session, toe[1], toe[2], subname=toe[3], scale=scale, color=color)
  end
  nothing
end

function fetchdrawdepthcloudbycvid!(vis,
                                    cloudGraph::CloudGraphs.CloudGraph,
                                    cvid::Int,
                                    vsym::Symbol,
                                    poseswithdepth::Dict,
                                    param::Dict,
                                    sesssym::Symbol;
                                    depthcolormaps=Dict(),
                                    # imshape=(480,640),
                                    wTb::CoordinateTransformations.AbstractAffineMap=
                                            Translation(0,0,0.0) ∘ LinearMap(
                                            CoordinateTransformations.Quat(1.0, 0, 0, 0))   )
                                    # bTc::CoordinateTransformations.AbstractAffineMap=
                                    #       Translation(0,0,0.6) ∘ LinearMap(
                                    #       CoordinateTransformations.Quat(0.5, -0.5, 0.5, -0.5))  )
  #

  if !haskey(poseswithdepth, vsym)
    cache = Dict()

    # fetch copy of big data from CloudGraphs
    cv = CloudGraphs.get_vertex(cloudGraph, cvid, true )

    # depthcolormaps = could be one or more or these options
    # 0, 1 or 2+ color maps per pointcloud
    #  ("none" => "depthframe_image", "none" => "pointcloud")
    # or
    #  ("keyframe_rgb" => "depthframe_image",
    #  "keyframe_segnet" => "depthframe_image")
    # or
    #  ("colors" => "pointcloud")
    for (va, ke) in depthcolormaps
      # prep the detph pointcloud
      cachepointclouds!(cache, cv, ke, param)

      if haskey(cache, ke)
        rgb = Array{Colorant,2}()
        if va[1:4] != "none"
          rgb = retrievePointcloudColorInfo!(cv, va)
        end

        # add color information to the pointcloud
        pointcloud = prepcolordepthcloud!( cvid, cache[ke], rgb=rgb )

        # publish the pointcloud data to Director viewer
        if pointcloud != nothing
          drawpointcloud!(vis, poseswithdepth, vsym, pointcloud, va, param, sesssym, wTb=wTb)
        end
      end
    end
  end
  nothing
end


function fetchdrawposebycvid!(vis,
      cloudGraph::CloudGraphs.CloudGraph,
      cvid::Int,
      poseswithdepth::Dict,
      param::Dict;
      session::AbstractString="",
      depthcolormaps=Dict()  )
      # imshape=(480,640),
      # bTc::CoordinateTransformations.AbstractAffineMap=
      #       Translation(0,0,0.6) ∘ LinearMap(
      #       CoordinateTransformations.Quat(0.5, -0.5, 0.5, -0.5))  )
  #

  # skip big data elements at first
  cv = CloudGraphs.get_vertex(cloudGraph, cvid, false )
  vert = cloudVertex2ExVertex(cv)

  # extract and draw new poses
  wTb = drawpose!(vis, vert, session=session )
  # also draw pose points from variable marginal belief approximation KDE
  drawposepoints!(vis, vert, session=session )

  # also update any parallel transform paths, previous and new
  updateparallelposes!(vis, vert, poseswithdepth, wTb=wTb)

  # check if we can draw depth pointclouds, and add new ones to parallel transform paths
  fetchdrawdepthcloudbycvid!(vis,
        cloudGraph,
        cvid,
        Symbol(vert.label),
        poseswithdepth,
        param,
        Symbol(session),
        depthcolormaps=depthcolormaps,
        # imshape=imshape,
        wTb=wTb  )

  sleep(0.005)
  nothing
end

# dbcoll,
function drawdbsession(vis,
                       cloudGraph::CloudGraphs.CloudGraph,
                       addrdict,
                       param::Dict,
                       poseswithdepth::Dict )
                       # bTc::CoordinateTransformations.AbstractAffineMap=
                       #       Translation(0,0,0.6) ∘ LinearMap(
                       #       CoordinateTransformations.Quat(0.5, -0.5, 0.5, -0.5) )    )
  #

  @show session = addrdict["session"]
  sesssym = Symbol(session)
  DRAWDEPTH = addrdict["draw depth"]=="y" # not going to support just yet
  DRAWEDGES = addrdict["draw edges"]=="y" # not going to support just yet


  # fg = Caesar.initfg(sessionname=addrdict["session"], cloudgraph=cloudGraph)
  println("Fetching pose IDs to be drawn...")
  IDs = getExVertexNeoIDs(cloudGraph.neo4j.connection, label="POSE", session=session, reqbackendset=false);
  landmIDs = getExVertexNeoIDs(cloudGraph.neo4j.connection, label="LANDMARK", session=session, reqbackendset=false);

  @showprogress 1 "Drawing LANDMARK IDs..." for (vid,cvid) in landmIDs
    cv = nothing
    # skip big data elements
    cv = CloudGraphs.get_vertex(cloudGraph, cvid, false )
    vert = cloudVertex2ExVertex(cv)
    x = Symbol(vert.label)

    # vert = getVert(fg, x, api=localapi)
    drawpoint!(vis, vert, session=session)
    # drawposepoints!(vis, vert, session=session )
  end

  depthcolormaps = !DRAWDEPTH  ? Dict() : Dict("keyframe_rgb" => "depthframe_image", "keyframe_segnet" => "depthframe_image", "BSONcolors" => "BSONpointcloud", "none"=>"BSONpointcloud")

  @showprogress 1 "Drawing POSE IDs..." for (vid,cvid) in IDs
    fetchdrawposebycvid!(vis,
          cloudGraph,
          cvid,
          poseswithdepth,
          param,
          session=session,
          depthcolormaps=depthcolormaps  )
  end

  if DRAWEDGES
    println("Going to draw edges...")
    drawAllBinaryFactorEdges!(vis, cloudGraph, session)
  end
  nothing
end
