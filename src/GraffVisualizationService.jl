using .GraffSDK
using Base64
using MeshCat
using CoordinateTransformations
import GeometryTypes: HyperRectangle, HyperSphere, Vec, Point, HomogenousMesh, SignedDistanceField, Point3f0
import ColorTypes: RGBA, RGB
using Colors: Color, Colorant, RGB, RGBA, alpha, hex




function cacheVariablePointEst!(dummyvis,
                                cachevarsl::Dict{Symbol, Tuple{Symbol, Vector{Bool}, Vector{Float64}}},
                                rose::Tuple{<:AbstractString, <:AbstractString},
                                params  )::Nothing
    #
    robotId   = string(rose[1])
    sessionId = string(rose[2])

    vars = GraffSDK.ls()

    for nod in vars.nodes

        # TODO fix hack -- use softtype instead, see http://www.github.com/GearsAD/GraffSDK.jl#72
        typesym = :Point2
        if nod.mapEst == nothing
            continue
        end
        if length(nod.mapEst) == 2
            nothing
        elseif length(nod.mapEst) == 3 && nod.label[1] == 'x'
            typesym = :Pose2
        elseif length(nod.mapEst) == 3 && nod.label[1] == 'l'
            typesym = :Point3
        elseif length(nod.mapEst) == 6 && nod.label[1] == 'x'
            typesym = :Pose3
        else
            error("Unknown estimate dimension and naming")
        end

        cachevarsl[Symbol(nod.label)] = (typesym, [false;], nod.mapEst)
    end

    return nothing
end
