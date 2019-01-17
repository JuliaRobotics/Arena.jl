# General visualization utils


"""
    $(SIGNATURES)
Initialize empty visualizer window with home axis.  New browser window will be opened based on `show=true`.
"""
function startDefaultVisualization(;show::Bool=true,
                                    draworigin::Bool=true,
                                    originscale::Float64=1.0  )
    #
    global drawtransform

    viz = MeshCat.Visualizer()
    if draworigin
      setobject!( viz[:origin], Triad(originscale) )
      settransform!( viz[:origin], drawtransform ∘ (Translation(0.0, 0.0, 0.0) ∘ LinearMap( CTs.Quat(1.0,0,0,0))) )
    end

    # open a new browser tab if required
    show && open(viz)

    return viz
end







# tagsOnPoses = Dict{Symbol, Vector{TagkTl}}()



#
