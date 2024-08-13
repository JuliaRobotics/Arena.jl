

@deprecate plotGraph3d(w...;kw...) plot3d!(w...;kw...)

@deprecate plot3d(w...;kw...) plot3d!(w...;kw...)


# function plot3d!(fg;
#   linewidth = 0.025,
#   lengthscale=0.15f0,
#   arrowsize = Vec3f(0.05, 0.05, 0.1),
#   solveKey=:parametric,
#   vsyms = ls(fg, r"^x"),
# )


#   ps = map(enumerate(vsyms)) do (i,v)
#       val = getVal(fg, v; solveKey)[1]
#       Point3f(val[1:3])
#   end

#   nxs = map(vsyms) do v
#       val = getVal(fg, v; solveKey)[1] 
#       Point3f(val.x[2][:,1])
#   end
#   nys = map(vsyms) do v
#       val = getVal(fg, v; solveKey)[1] 
#       Point3f(val.x[2][:,2])
#   end
#   nzs = map(vsyms) do v
#       val = getVal(fg, v; solveKey)[1] 
#       Point3f(val.x[2][:,3])
#   end

#   Makie.arrows!(ps, nxs; color=:red, linewidth, lengthscale, arrowsize)
#   Makie.arrows!(ps, nys; color=:green, linewidth, lengthscale, arrowsize)
#   Makie.arrows!(ps, nzs; color=:blue , linewidth, lengthscale, arrowsize)

#   lines!(ps)
# end



# function plot3d(fg;
#   linewidth = 0.025,
#   lengthscale=0.15f0,
#   arrowsize = Vec3f(0.05, 0.05, 0.1),
#   solveKey=:parametric,
#   vsyms = ls(fg, r"^x"),
# )

#   ps = map(enumerate(vsyms)) do (i,v)
#       val = getVal(fg, v; solveKey)[1]
#       if getVariableType(fg, v) == RotVelPos() 
#           Point3f(val.x[3][1:3])
#       else
#           Point3f(val[1:3])
#       end
#   end

#   nxs = map(vsyms) do v
#       val = getVal(fg, v; solveKey)[1]
#       if getVariableType(fg, v) == RotVelPos() 
#           Point3f(val.x[1][:,1])
#       else
#           Point3f(val.x[2][:,1])
#       end
#   end
#   nys = map(vsyms) do v
#       val = getVal(fg, v; solveKey)[1]
#       if getVariableType(fg, v) == RotVelPos() 
#           Point3f(val.x[1][:,2])
#       else
#           Point3f(val.x[2][:,2])
#       end
#   end
#   nzs = map(vsyms) do v
#       val = getVal(fg, v; solveKey)[1] 
#       if getVariableType(fg, v) == RotVelPos() 
#           Point3f(val.x[1][:,3])
#       else
#           Point3f(val.x[2][:,3])
#       end
#   end

#   fig = Makie.arrows(ps, nxs; color=:red, linewidth, lengthscale, arrowsize)
#   Makie.arrows!(ps, nys; color=:green, linewidth, lengthscale, arrowsize)
#   Makie.arrows!(ps, nzs; color=:blue , linewidth, lengthscale, arrowsize)

#   lines!(ps)
#   fig
# end