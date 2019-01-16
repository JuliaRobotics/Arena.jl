# visualization service calls (based on previous similar Collections and Director visualizations)


function cacheVariablePointEst!(fgl::FactorGraph,
                                cachevarsl::Dict{Symbol, Tuple{Symbol, Vector{Float64}}};
                                meanmax=:max  )::Nothing
    #

    # get all variables
    xx, ll = IIF.ls()
    vars = union(xx, ll)

    # update the variable point-estimate cache
    for vsym in vars

        # get vertex and estimate from the factor graph object
        vert = getVert(fgl, vsym)
        X = getKDE(vert)
        xmx = meanmax == :max ? getKDEMax(X) : getKDEMean(X)

        # get the variable type
        typesym = getData(vert).softtype |> typeof |> Symbol

        # cache variable type and estimated value (slightly memory intensive)
        cachevarsl[vsym] = (typesym, xmx)
    end

    return nothing
end








#
