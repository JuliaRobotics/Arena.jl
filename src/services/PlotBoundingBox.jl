##


function makeWireframeHyperRectangle(
  org,
  wdt
)
  @error("Obsolete: makeWireframeHyperRectangle, use getCorners instead.")
  x_, y_ = org[1], org[2]
  dx, dy = wdt[1], wdt[2]
  x = [x_; x_+dx; x_+dx; x_; x_]
  y = [y_; y_; y_+dy; y_+dy; y_]
  z = wdt[3]*ones(5,5) .+ org[3]

  xx = [x;x]
  yy = [y;y]

  zz = zeros(10,10)
  zz[1:5,1:5] = org[3]*ones(5,5)
  zz[6:10,6:10] = z

  xx, yy, zz
end



function calcBoxWireframe(
  org,
  wdt;
  xx=Observable(zeros(5)),
  yy=Observable(zeros(5)),
  zz=Observable(zeros(10,10))
)

  xx[], yy[], zz[] = makeWireframeHyperRectangle(org, wdt)
  # x_, y_ = org[1], org[2]
  # dx, dy = wdt[1], wdt[2]
  # x = [x_; x_+dx; x_+dx; x_; x_]
  # y = [y_; y_; y_+dy; y_+dy; y_]
  # z = wdt[3]*ones(5,5) .+ org[3]
  # xx[] = [x;x]
  # yy[] = [y;y]
  # zz[][1:5,1:5] = org[3]*ones(5,5)
  # zz[][6:10,6:10] = z

  xx, yy, zz
end

function plotBoundingBoxHack(
  org,
  wdt;
  ax=nothing,
  plotfnc::Function = isnothing(ax) ? wireframe : wireframe!,
  xx=Observable(zeros(5)),
  yy=Observable(zeros(5)),
  zz=Observable(zeros(10,10))
)
  @info "doplot" org
  _cappairs(;kw...) = kw
  
  calcBoxWireframe(org, wdt; xx,yy,zz )
  
  plotfnc(
    (isnothing(ax) ? () : (ax,))...,
    xx, 
    yy, 
    zz;
    color=:black,
    (isnothing(ax) ? _cappairs(;axis=(type=Axis3,)) : ())..., # axis=(type=Axis3,), 
  )
end

plotBoundingBoxHack!(
  ax,
  w...;
  plotfnc::Function = wireframe!,
  kw...
) = plotBoundingBoxHack(w...; ax, plotfnc, kw...)

##

function plotBoundingBoxTool(
  _pc::Base.RefValue{<:_PCL.PointCloud};
  markersize=2
)
  orxyz = [0;0;0.]
  wdxyz = [5;5;5.]
  xx = Observable(zeros(5))
  yy = Observable(zeros(5))
  zz = Observable(zeros(10,10))
  
  fig = Figure()
  
  ax = Axis3(fig[1, 1])
  
  fig[2,1] = tbgrid = GridLayout(tellwidth=false)
  tbgrid = tbgrid[1,1:6] = [
    Textbox(fig, placeholder = string(orxyz[1]));
    Textbox(fig, placeholder = string(orxyz[2]));
    Textbox(fig, placeholder = string(orxyz[3]));
    Textbox(fig, placeholder = string(wdxyz[1]));
    Textbox(fig, placeholder = string(wdxyz[2]));
    Textbox(fig, placeholder = string(wdxyz[3]));
  ]
  
  tbox = tbgrid[1]
  tboy = tbgrid[2]
  tboz = tbgrid[3]
  tbwx = tbgrid[4]
  tbwy = tbgrid[5]
  tbwz = tbgrid[6]

  on(tbox.stored_string) do s
    orxyz[1] = parse(Float64,s) |> float
    calcBoxWireframe(orxyz, wdxyz; xx, yy, zz)
    # sg.sliders[2].value[] -= 0.1
  end
  on(tboy.stored_string) do s
    orxyz[2] = parse(Float64,s) |> float
    calcBoxWireframe(orxyz, wdxyz; xx, yy, zz)
  end
  on(tboz.stored_string) do s
    orxyz[3] = parse(Float64,s) |> float
    calcBoxWireframe(orxyz, wdxyz; xx, yy, zz)
  end
  on(tbwx.stored_string) do s
    wdxyz[1] = parse(Float64,s) |> float
    calcBoxWireframe(orxyz, wdxyz; xx, yy, zz)
  end
  on(tbwy.stored_string) do s
    wdxyz[2] = parse(Float64,s) |> float
    calcBoxWireframe(orxyz, wdxyz; xx, yy, zz)
  end
  on(tbwz.stored_string) do s
    wdxyz[3] = parse(Float64,s) |> float
    calcBoxWireframe(orxyz, wdxyz; xx, yy, zz)
  end

  # sliderobservables = [s.value for s in sg.sliders]
  # bars = lift(sliderobservables...) do slvalues...
  #     [slvalues...]
  # end
  
  dmin, dmax = 0., 150.0
  sg = SliderGrid(
    fig[1, 2],
    (label = "min", range = 0:0.5:dmax, format = "{:.1f}m", startvalue = dmin),
    (label = "max", range = 0:0.5:dmax, format = "{:.1f}m", startvalue = dmax),
    width = 350,
    tellheight = false
  )

  # pc_ = getDataPointCloud(nfg, vlp[], Regex("PCLPointCloud2")) |> _PCL.PointCloud |> Ref
  _getxyz(s) = Point3f(s.x,s.y,s.z)
  ptf_ = _getxyz.(_pc[].points) |> Ref

  rangeobservables = [s.value for s in sg.sliders[1:2]]
  @show typeof(rangeobservables)
  ptf = lift(rangeobservables...) do rnvalues...
    ax.limits[] = ((-rnvalues[2],rnvalues[2]),(-rnvalues[2],rnvalues[2]),(-10,10))
    Caesar._PCL._filterMinRange(ptf_[], rnvalues[1], rnvalues[2])
  end

  
  # plotPointCloud(_pc[]; ax, plotfnc=scatter!)
  scatter!(ptf; color=:blue, markersize)
  plotBoundingBoxHack!(ax, orxyz, wdxyz; xx,yy,zz)
  # barplot!(ax, bars, color = [:yellow, :orange, :red])
  # ylims!(ax, 0, 30)
  
  fig
end




function plotWireframeHyperRectangle(
  org,
  wdt;
  ax=nothing,
  plotfnc::Function = isnothing(ax) ? wireframe : wireframe!,
  xx=zeros(5),
  yy=zeros(5),
  zz=zeros(10,10)
)
  @info "doplot" org
  _cappairs(;kw...) = kw
  
  calcBoxWireframe(org, wdt; xx,yy,zz )
  
  plotfnc(
    (isnothing(ax) ? () : (ax,))...,
    xx, 
    yy, 
    zz;
    color=:black,
    (isnothing(ax) ? _cappairs(;axis=(type=Axis3,)) : ())..., # axis=(type=Axis3,), 
  )
end






# ## some dev testing

# BB = _PCL.AxisAlignedBoundingBox([0;0;0.], [1;1;1.]) 
# plotBoundingBox(BB)


# using StaticArrays, Manifolds

# ##

# Mr = SpecialOrthogonal(3)
# R0 = SMatrix{3,3}(diagm([1;1;1.]))

# OBB = _PCL.OrientedBoundingBox([0;0;0.], [1;1;1.], [0;0;0.], exp(Mr, R0, hat(Mr, R0, [0;0;pi/4]))) 
# plotBoundingBox(OBB)


# ##


# ##

# plotBoundingBoxTool(Ref(pc))

# ## 

# # pc = _PCL.PointCloud(20*rand(100,3))
# # using NavAbilityCaesarExtensions
# # pc = _PCL.getDataPointCloud(nfg, :x1, r"PCLPointCloud2") |> _PCL.PointCloud


# ##

# plotBoundingBoxHack([0;0;-0.5], [5;5;1.0])

# ##

# x = Observable(collect(-8:0.5:8))
# y = Observable(collect(-8:0.5:8))
# z = Observable([sinc(√(X^2 + Y^2) / π) for X ∈ x[], Y ∈ y[]])

# wireframe(x, y, z, axis=(type=Axis3,), color=:black)


# x[] = 2 .+ collect(-8:0.5:8)

# ##

# # import GeometryBasics as GeoB

# ##

# pts = 2*rand(100,3) .- 1

# hr = _PCL.AxisAlignedBoundingBox( [-2,-4,-1.0], [6,5,3.] )


# pct = _PCL.PointCloud(pts)
# spc = _PCL.getSubcloud(pct, hr)

# spt_z = (s->s.data[3]).(spc.points)


# ##


# hr = OBB.hr

# x_, y_, z_ = hr.origin[1], hr.origin[2], hr.origin[3]
# dx, dy, dz = hr.widths[1], hr.widths[2], hr.widths[3]

# p1 = [x_;y_;z_]
# p2 = [x_;y_+dy;z_]
# p4 = [x_+dx;y_;z_]
# p3 = [x_+dx;y_+dy;z_]

# p5 = [x_;y_;z_+dz]
# p6 = [x_;y_+dy;z_+dz]
# p8 = [x_+dx;y_;z_+dz]
# p7 = [x_+dx;y_+dy;z_+dz]

# ##

# fig = Figure()
# ax = Axis3(fig[1,1])

# _line3d!(ax, a, b) = lines!(ax, [b[1];a[1]], [b[2];a[2]], [b[3];a[3]]; color=:red)

# _line3d!(ax, p1, p2)
# _line3d!(ax, p1, p4)
# _line3d!(ax, p2, p3)
# _line3d!(ax, p4, p3)

# _line3d!(ax, p5, p6)
# _line3d!(ax, p5, p8)
# _line3d!(ax, p6, p7)
# _line3d!(ax, p8, p7)

# _line3d!(ax, p1, p5)
# _line3d!(ax, p2, p6)
# _line3d!(ax, p3, p7)
# _line3d!(ax, p4, p8)

# fig


##


# function makeWireframeHyperRectangle(aabb::_PCL.AxisAlignedBoundingBox) 
#   makeWireframeHyperRectangle(aabb.origin, aabb.widths)
# end

# function makeWireframeHyperRectangle(obb::_PCL.OrientedBoundingBox) 
#   @error("Obsolete: makeWireframeHyperRectangle, use getCorners instead.")
#   x,y,zz = makeWireframeHyperRectangle(obb.hr.origin, obb.hr.widths)

#   X = zeros(size(x))
#   Y = zeros(size(y))
#   ZZ = zeros(size(zz))

#   @show r_H_bb = inv(obb.bb_H_r)
#   for i in 1:length(X), j in 1:length(Y)
#     xyz1 = r_H_bb*SA[x[i];y[j];zz[i,j];1]
#     X[i] = xyz1[1]
#     Y[j] = xyz1[2]
#     ZZ[i,j] = xyz1[3]
#   end

#   X,Y,ZZ
# end