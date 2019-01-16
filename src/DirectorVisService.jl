


function visualizeDensityMesh!(vc, fgl::FactorGraph, lbl::Symbol; levels=3, meshid::Int=2)

  pl1 = marginal(getVertKDE(fgl,lbl),[1;2;3])

  gg = (x, a=0.0) -> evaluateDualTree(pl1, [x[1] x[2] x[3]]')[1]-a  #([x[1];x[2];x[3]]')'

  x = getKDEMax(pl1)
  maxval = gg(x)

  vv = getKDERange(pl1)
  lower_bound = Vec(vec(vv[:,1])...)
  upper_bound = Vec(vec(vv[:,2])...)

  levels = linspace(0.0,maxval,levels+2)

  # MD = []
  for val in levels[2:(end-1)]
    meshdata = GeometryData(contour_mesh(x -> gg(x,val), lower_bound, upper_bound))
    meshdata.color = RGBA( val/(1.5*maxval),0.0,1.0,val/(1.5*maxval))
    # push!(MD, meshdata)
    setgeometry!(vc[:meshes][lbl][Symbol("lev$(val)")], meshdata)
  end
  # mptr = Any(MD)
  # vc.meshes[lbl] = mptr
  # Visualizer(mptr, meshid) # meshdata
  nothing
end



function drawgt!(vc, sym::Symbol,
      gtval::Tuple{Symbol, Vector{Float64}};
      session::AbstractString="NA"  )
  #
  if gtval[1] == :XYZ
    drawpoint!(vc, sym, tf=Translation(gtval[2][1],gtval[2][2],gtval[2][3]),
          session=session,
          color=RGBA(1.0,0,0,0.5),
          collection=:gt_landm  )
  elseif gtval[1] == :XYZqWXYZ
    drawpose!(vc, sym,
          tf = Translation(gtval[2][1],gtval[2][2],gtval[2][3]) ∘
               LinearMap(CoordinateTransformations.Quat(gtval[2][4],gtval[2][5],gtval[2][6],gtval[2][7])),
          session=session,
          collection=:gt_poses  )
  else
    warn("unknown ground truth drawing type $(gtval[1])")
  end

  nothing
end

# TODO -- maybe we need RemoteFactorGraph type
function visualizeallposes!(vc,
    fgl::FactorGraph;
    drawlandms::Bool=true,
    drawtype::Symbol=:max,
    gt::Dict{Symbol, Tuple{Symbol,Vector{Float64}}}=Dict{Symbol, Tuple{Symbol,Vector{Float64}}}(),
    api::DataLayerAPI=localapi )
  #
  session = fgl.sessionname
  topoint = gettopoint(drawtype)

  dotwo = false
  dothree = false
  po,ll = ls(fgl)
  if length(po) > 0
    sym = po[1]
    X = getVal(fgl, sym, api=api )
    dotwo, dothree = getdotwothree(sym, X)
  end

  # TODO -- move calls higher in abstraction to be more similar to drawdbdirector()
  for p in po
    vert = getVert(fgl, p, api=api )
    drawpose!(vc, vert, topoint, dotwo, dothree, session=session)
    if haskey(gt, p)
      drawgt!(vc, p, gt[p], session=session)
    end
  end
  if drawlandms
    for l in ll
      den = getVertKDE(fgl, l, api=api)
      pointval = topoint(den)
      drawpoint!(vc, l, tf=Translation(pointval[1:3]...), session=session)
      if haskey(gt, l)
        drawgt!(vc, l, gt[l], session=session)
      end
    end
  end

  nothing
end



function drawposepoints!(vis,
      vert::Graphs.ExVertex;
      session::AbstractString="NA"  )
  #
  vsym = Symbol(vert.label)
  X = getVal(vert)

  dotwo, dothree = getdotwothree(vsym, X)
  makefromX = (X::Array{Float64,2}, i::Int) -> X[1:3,i]
  if dotwo
    makefromX = (X::Array{Float64,2}, i::Int) -> Float64[X[1:2,i];0.0]
  end

  XX = Vector{Vector{Float64}}()
  for i in 1:size(X,2)
    push!(XX, makefromX(X,i))
  end
  pointcloud = PointCloud(XX)
  if string(vsym)[1] == 'l'
    pointcloud.channels[:rgb] = [RGB(1.0, 1.0, 0) for i in 1:length(XX)]
  elseif string(vsym)[1] == 'x'
    pointcloud.channels[:rgb] = [colorwheel(vert.index) for i in 1:length(XX)]
  end
  setgeometry!(vis[Symbol(session)][:posepts][vsym], pointcloud)
  nothing
end

function drawposepoints!(vis,
      fgl::FactorGraph,
      sym::Symbol;
      session::AbstractString="NA",
      api::DataLayerAPI=dlapi  )
  #
  vert = getVert(fgl, sym, api=api)
  drawposepoints!(vis, vert, session=session, api=localapi) # definitely use localapi
  nothing
end



function deletemeshes!(vc)
  delete!(vc[:meshes])
end



"""
    $(SIGNATURES)

Draw a line segment between to vertices.
"""
function drawLineBetween!(vis,
        session::AbstractString,
        fr::Graphs.ExVertex,
        to::Graphs.ExVertex;
        scale=0.01,
        name::Symbol=:edges,
        subname::Union{Nothing,Symbol}=nothing,
        color=RGBA(0,1.0,0,0.5)   )
  #
  dotwo, dothree = getdotwothree(Symbol(fr.label), getVal(fr))

  xipt = zeros(3); xjpt = zeros(3);
  if dothree
    xi = marginal(getVertKDE( fr ),[1;2;3] )
    xj = marginal(getVertKDE( to ),[1;2;3] )
    xipt[1:3] = getKDEMax(xi)
    xjpt[1:3] = getKDEMax(xj)
  elseif dotwo
    xi = marginal(getVertKDE( fr ),[1;2] )
    xj = marginal(getVertKDE( to ),[1;2] )
    xipt[1:2] = getKDEMax(xi)
    xjpt[1:2] = getKDEMax(xj)
  end

  lbl = Symbol(string(fr.label,to.label))
  place = vis[Symbol(session)][name][lbl]
  if subname != nothing
    place = vis[Symbol(session)][name][subname][lbl]
  end
  drawLine!(place, xipt, xjpt, color=color, scale=scale )
  nothing
end


"""
    $(SIGNATURES)

Draw a line segment between to nodes in the factor graph.
"""
function drawLineBetween!(vis,
        fgl::FactorGraph,
        fr::Symbol,
        to::Symbol;
        scale=0.01,
        name::Symbol=:edges,
        subname::Union{Nothing,Symbol}=nothing,
        color=RGBA(0,1.0,0,0.5),
        api::DataLayerAPI=dlapi  )
  #
  v1 = getVert(fgl, fr, api=api)
  v2 = getVert(fgl, to, api=api)

  drawLineBetween!(vis,fgl.sessionname, v1,v2,scale=scale,name=name,subname=subname,color=color   )
end


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

"""
    $(SIGNATURES)

Assume odometry chain and draw edges between subsequent poses. Use keyword arguments to change colors, etc.
"""
function drawAllOdometryEdges!(vis,
      fgl::FactorGraph;
      scale=0.01,
      name::Symbol=:edges,
      color=RGBA(0,1.0,0,0.5),
      api::DataLayerAPI=dlapi  )
  #
  xx, ll = ls(fgl)

  for i in 1:(length(xx)-1)
    drawLineBetween!(vis, fgl, xx[i],xx[i+1], api=api , color=color, scale=scale, name=name )
  end

  nothing
end


function drawAllBinaryFactorEdges!(vis,
      fgl::FactorGraph;
      scale=0.01,
      api::DataLayerAPI=dlapi )
  #
  sloth = findAllBinaryFactors(fgl, api=api)

  for (teeth, toe) in sloth
    color = pointToColor(toe[3])
    drawLineBetween!(vis, fgl, toe[1], toe[2], subname=toe[3], scale=scale, color=color)
  end
  nothing
end




function drawAllBinaryFactorEdges!(vis,
      cgl::CloudGraph,
      session::AbstractString;
      scale=0.01  )
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

"""
    $(SIGNATURES)

Update all triads listed in poseswithdepth[Symbol(vert.label)] with wTb. Prevents cycles in
remote tree viewer of Visualizer.
"""
function updateparallelposes!(vis,
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


#syntax support lost in 0.5, but see conversation at
# function (dmdl::DrawObject)(vc::VisualizationContainer)
# issue  https://github.com/JuliaLang/julia/issues/14919

function (dmdl::DrawROV)(vc,
        am::AbstractAffineMap  )
  #
  settransform!(vc[:models][dmdl.symbol], am ∘ dmdl.offset)
  nothing
end
function (dmdl::DrawROV)(vc,
        t::Translation,
        R::Rotation  )
  #
  dmdl(vc, Translation ∘ LinearMap(R))
end
function (dmdl::DrawROV)(vc)
  setgeometry!(vc[:models][dmdl.symbol], dmdl.data)
  dmdl(vc, Translation(0.,0,0) ∘ LinearMap(Rotations.Quat(1.0,0,0,0)) )
  nothing
end


function (dmdl::DrawScene)(vc,
        am::AbstractAffineMap  )
  #
  settransform!(vc[:env][dmdl.symbol], am ∘ dmdl.offset)
  nothing
end
function (dmdl::DrawScene)(vc,
        t::Translation,
        R::Rotation  )
  #
  dmdl(vc, Translation ∘ LinearMap(R))
end
function (dmdl::DrawScene)(vc)
  setgeometry!(vc[:env][dmdl.symbol], dmdl.data)
  dmdl(vc, Translation(0.,0,0) ∘ LinearMap(Rotations.Quat(1.0,0,0,0)) )
  nothing
end


function animatearc(vc,
            drmodel::DrawObject,
            as::ArcPointsRangeSolve;
            N::Int=100,
            delaytime::Float64=0.05,
            initrot::Rotation=Rotations.Quat(1.0,0,0,0),
            from::Number=0,
            to::Number=1  )
  #
  for t in linspace(from,to,N)
    am = parameterizeArcAffineMap(t, as, initrot=initrot )
    drmodel(vc, am )
    sleep(delaytime)
  end
  nothing
end
