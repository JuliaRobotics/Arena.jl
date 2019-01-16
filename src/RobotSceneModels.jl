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
