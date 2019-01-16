# code to help visualize poses and points


function drawpose!(viz, sym::Symbol;
      tf::CoordinateTransformations.AbstractAffineMap=Translation(0.0,0,0)∘LinearMap(CoordinateTransformations.AngleAxis(0.0,0,0,1.0)),
      session::AbstractString="",
      collection::Symbol=:poses)
  #
  if session == ""
    setgeometry!(viz[collection][sym], Triad())
    settransform!(viz[collection][sym], tf)
  else
    sesssym=Symbol(session)
    setgeometry!(viz[sesssym][collection][sym], Triad())
    settransform!(viz[sesssym][collection][sym], tf)
  end
  nothing
end

function drawpoint!(viz,
      sym::Symbol;
      tf=Translation(0.0,0,0),
      session::AbstractString="",
      scale=0.05,
      color=RGBA(0., 1, 0, 0.5),
      collection::Symbol=:landmarks  )
  #

  sphere = HyperSphere(Point(0., 0, 0), scale)
  csph = GeometryData(sphere, color)
  if session == ""
    setgeometry!(viz[collection][sym], csph)
    settransform!(viz[collection][sym], tf)
  else
    sesssym=Symbol(session)
    setgeometry!(viz[sesssym][collection][sym], csph)
    settransform!(viz[sesssym][collection][sym], tf)
  end
  nothing
end


function drawpose!(vc,
      vert::Graphs.ExVertex,
      topoint::Function,
      dotwo::Bool, dothree::Bool;
      session::AbstractString="NA"  )
  #
  den = getVertKDE(vert)
  p = Symbol(vert.label)
  pointval = topoint(den)
  tf = nothing
  if dothree
    q = convert(TransformUtils.Quaternion, Euler(pointval[4:6]...))
    tf = Translation(pointval[1:3]...)∘LinearMap(Quat(q.s,q.v...))
    drawpose!(vc, p, tf=tf, session=session)
  elseif dotwo
    tf = Translation(pointval[1],pointval[2],0.0)∘LinearMap(Rotations.AngleAxis(pointval[3],0,0,1.0))
    drawpose!(vc, p, tf=tf, session=session)
  end
  return tf
end

function drawpose!(vc,
      vert::Graphs.ExVertex;
      session::AbstractString="NA",
      drawtype::Symbol=:max )
  #

  topoint = gettopoint(drawtype)
  X = getVal(vert)
  dotwo, dothree = getdotwothree(Symbol(vert.label), X)
  drawpose!(vc, vert, topoint, dotwo, dothree, session=session)
end

function drawpoint!(vc,
      vert::Graphs.ExVertex,
      topoint::Function,
      dotwo::Bool, dothree::Bool;
      session::AbstractString="NA"  )
  #
  den = getVertKDE(vert)
  p = Symbol(vert.label)
  pointval = topoint(den)
  if dothree
    q = convert(TransformUtils.Quaternion, Euler(pointval[4:6]...))
    drawpoint!(vc, p, tf=Translation(pointval[1:3]...), session=session)
  elseif dotwo
    drawpoint!(vc, p, tf=Translation(pointval[1],pointval[2],0.0), session=session)
  end
  nothing
end


function drawpoint!(vc,
        vert::Graphs.ExVertex;
        session::AbstractString="NA",
        drawtype::Symbol=:max )
  #
  topoint = gettopoint(drawtype)
  X = getVal(vert)
  dotwo, dothree = getdotwothree(Symbol(vert.label), X)
  drawpoint!(vc, vert, topoint, dotwo, dothree, session=session)
  nothing
end
