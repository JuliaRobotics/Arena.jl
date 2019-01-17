# visualization service calls (based on previous similar Collections and Director visualizations)


function cacheVariablePointEst!(dummyvis,
                                cachevarsl::Dict{Symbol, Tuple{Symbol, Vector{Bool}, Vector{Float64}}},
                                fgl::FactorGraph,
                                params;
                                meanmax=:max  )::Nothing
    #

    # get all variables
    xx, ll = IIF.ls(fgl)
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
        cachevarsl[vsym] = (typesym, [false;], xmx)
    end

    return nothing
end




function findAllBinaryFactors(fgl::FactorGraph; api::DataLayerAPI=dlapi)
  xx, ll = ls(fgl)

  slowly = Dict{Symbol, Tuple{Symbol, Symbol, Symbol}}()
  for x in xx
    facts = ls(fgl, x, api=localapi) # TODO -- known BUG on ls(api=dlapi)
    for fc in facts
      nodes = lsf(fgl, fc)
      if length(nodes) == 2
        # add to dictionary for later drawing
        if !haskey(slowly, fc)
          fv = getVert(fgl, fgl.fIDs[fc])
          slowly[fc] = (nodes[1], nodes[2], typeof(getfnctype(fv)).name.name)
        end
      end
    end
  end

  return slowly
end






#
