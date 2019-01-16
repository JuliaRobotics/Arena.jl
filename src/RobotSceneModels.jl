# Robot and scene models

abstract type DrawObject <: Function end

# Modified ROV model from GrabCAD
# http://grabcad.com/library/rov-7
mutable struct DrawROV <: DrawObject
  data
  visid::Int
  symbol::Symbol
  offset::AffineMap
end

mutable struct DrawScene <: DrawObject
  data
  symbol::Symbol
  offset::AffineMap
end



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
