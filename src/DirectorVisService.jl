




function drawpointcloud!(vis::DrakeVisualizer.Visualizer,
        poseswithdepth::Dict,
        vsym::Symbol,
        pointcloud,
        va,
        param::Dict,
        sesssym::Symbol;
        # imshape=(480,640),
        wTb::CoordinateTransformations.AbstractAffineMap=
              Translation(0,0,0.0) ∘ LinearMap(
              CoordinateTransformations.Quat(1.0, 0, 0, 0))   )
        # bTc::CoordinateTransformations.AbstractAffineMap=
        #       Translation(0,0,0.6) ∘ LinearMap(
        #       CoordinateTransformations.Quat(0.5, -0.5, 0.5, -0.5))  )
  #

  pcsym = Symbol(string("pc_", va != "none" ? va : "ID"))
  setgeometry!(vis[sesssym][pcsym][vsym][:pose], Triad())
  settransform!(vis[sesssym][pcsym][vsym][:pose], wTb) # also updated as parallel track
  setgeometry!(vis[sesssym][pcsym][vsym][:pose][:cam], Triad())
  settransform!(vis[sesssym][pcsym][vsym][:pose][:cam], param["bTc"] )
  setgeometry!(vis[sesssym][pcsym][vsym][:pose][:cam][:pc], pointcloud )

  # these poses need to be update if the point cloud is to be moved
  if !haskey(poseswithdepth,vsym)
    thetype = typeof(vis[sesssym][pcsym][vsym][:pose])
    poseswithdepth[vsym] = Vector{ thetype }()
  end
  push!(poseswithdepth[vsym], vis[sesssym][pcsym][vsym][:pose])

  nothing
end


function fetchdrawdepthcloudbycvid!(vis::DrakeVisualizer.Visualizer,
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

"""
    $(SIGNATURES)

Update all triads listed in poseswithdepth[Symbol(vert.label)] with wTb. Prevents cycles in
remote tree viewer of DrakeVisualizer.
"""
function updateparallelposes!(vis::DrakeVisualizer.Visualizer,
      vert::Graphs.ExVertex,
      poseswithdepth::Dict;
      wTb::CoordinateTransformations.AbstractAffineMap=
            Translation(0,0,0.0) ∘ LinearMap(
            CoordinateTransformations.Quat(1.0, 0, 0, 0))    )
  #

  if haskey(poseswithdepth, Symbol(vert.label))
    for cp in poseswithdepth[Symbol(vert.label)]
      settransform!(cp, wTb)
    end
  end
  nothing
end

function fetchdrawposebycvid!(vis::DrakeVisualizer.Visualizer,
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
function drawdbsession(vis::DrakeVisualizer.Visualizer,
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


function drawdbdirector(;addrdict::NothingUnion{Dict{AbstractString, AbstractString}}=nothing)
  # Uncomment out for command line operation
  cloudGraph, addrdict = standardcloudgraphsetup(addrdict=addrdict,drawdepth=true, drawedges=true)
  session = addrdict["session"]

  poseswithdepth = Dict()
  # poseswithdepth[:x1] = 0 # skip this pose -- there is no big data before ICRA

  vis = startdefaultvisualization()
  sleep(1.0)

  param = Dict()
  try
    param = robotsetup(cloudGraph, session)
  catch
    warn("No robot parameters found for the session, continuing with basic visualization only")
  end

  drawloop = Bool[true]
  println("Starting draw loop...")
  while drawloop[1]
    drawdbsession(vis, cloudGraph, addrdict, param, poseswithdepth) #,  db[collection]
    println(".")
    sleep(0.5)
  end

  println("Finishing askdrawdirectordb.")
  nothing
end
