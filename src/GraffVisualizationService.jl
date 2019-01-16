using GraffSDK
using Base64
using MeshCat
using CoordinateTransformations
import GeometryTypes: HyperRectangle, HyperSphere, Vec, Point, HomogenousMesh, SignedDistanceField, Point3f0
import ColorTypes: RGBA, RGB
using Colors: Color, Colorant, RGB, RGBA, alpha, hex
using JSON

# Internal transform functions
function projectPose2(renderObject, node::NodeDetailsResponse)::Nothing
    mapEst = node.properties["MAP_est"]
    rotZ = 0
    if "POSE" in node.labels
        rotZ = mapEst[3] # Pose2, otherwise it's a Point2
    end
    trans = Translation(mapEst[1],mapEst[2],0) ∘ LinearMap(RotZ(rotZ))
    settransform!(renderObject, trans)
    return nothing
end

function projectPose3(renderObject, node::NodeDetailsResponse)::Nothing
    mapEst = node.properties["MAP_est"]
     # one day when this changes to quaternions -- for now though Pose3 is using Euler angles during infinite product approximations (but convolutions are generally done on a proper rotation manifold)
     # yaw = convert(q).theta3
    trans = Translation(mapEst[1],mapEst[2],mapEst[3])
    settransform!(renderObject, LinearMap(RotZ(mapEst[6])) ∘ trans)
    return nothing
end

# Callbacks for pose transforms
# TODO -- MAKE OBSOLETE wishlist, use MultipleDispatch instead of global
global poseTransforms = Dict{String, Function}(
    "Pose2" => projectPose2,
    "Pose3" => projectPose3
)


function cacheVariablePointEst!(rose::Tuple{<:AbstractString, <:AbstractString},
                                cachevarsl::Dict{Symbol, Tuple{Symbol, Vector{Float64}}} )::Nothing
    #
    robotId   = string(rose[1])
    sessionId = string(rose[2])

    vars = GraffSDK.ls()

    for nod in vars.nodes

        # TODO fix hack -- use softtype instead, see http://www.github.com/GearsAD/GraffSDK.jl#72
        typesym = :Point2
        if length(nod.mapEst) == 3 && nod.label[1] == "x"
            typesym = :Pose2
        elseif length(nod.mapEst) == 3 && nod.label[1] == "l"
            typesym = :Point3
        elseif length(nod.mapEst) == 6 && nod.label[1] == "x"
            typesym = :Pose3
        else
            error("Unknown estimate dimension and naming")
        end

        cachevarsl[Symbol(nod.label)] = (typesym ,nod.mapEst)
    end

    return nothing
end
