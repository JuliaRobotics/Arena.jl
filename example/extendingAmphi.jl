using Arena.Amphitheatre
#Extending the functionallity of Amphitheatre requires 2 things
# 1. A type definition of the object to draw inhereting from AbstractAmphitheatre, eg. DrawSphereAmphi <: AbstractAmphitheatre
# 2. A visualize! function of the form `function visualize!(vis::Visualizer, object_to_draw::DrawSphereAmphi)::Nothing` to do the drawing
import Arena.Amphitheatre: visualize!

# using some usefull drawing functions
using MeshCat, GeometryTypes, CoordinateTransformations
# ============================================================
# --------------------DrawSphereInMeshCat--------------------
# ============================================================

# 1. the object to draw
struct DrawSphereAmphi <: AbstractAmphitheatre
	robotId::String
	sessionId::String
	spheres::Dict{Symbol, Vector{Float64}}
	isdrawn::Dict{Symbol, Bool}
	sphereScale::Float64
end
# a helpfull constructor
DrawSphereAmphi(robotId::String, sessionId::String, spheres::Dict{Symbol, Vector{Float64}}, sphereScale::Float64 = 0.1) =
	DrawSphereAmphi(robotId, sessionId, spheres, Dict{Symbol, Bool}(), sphereScale)

# 2. The visualize! function that does the drawing
function visualize!(vis::Visualizer, sa::DrawSphereAmphi)::Nothing

	for key in keys(sa.spheres)

		if !get(sa.isdrawn, key, false)
			haskey(sa.isdrawn, key) ? sa.isdrawn[key] = true : push!(sa.isdrawn, key=>true)

			sphere = HyperSphere(Point(0., 0, 0), sa.sphereScale)
			matcolor = MeshPhongMaterial(color=RGBA(0,1,0,0.5))
			setobject!(vis[sa.robotId][sa.sessionId][key], sphere, matcolor)
		end
		tform = Translation(sa.spheres[key][1:3]...)
		settransform!(vis[sa.robotId][sa.sessionId][key], tform)
	end
end

## thats it, now lets test or new visualizer

#create the object
balVis = DrawSphereAmphi("robot", "session1", Dict(:s0=>[0.,0,0], :s1=>[1.,0,0]))

# add it to the object to draw array of type AbstractAmphitheatre
visdatasets = AbstractAmphitheatre[balVis]

#start the visualizer
vis, vistask = visualize(visdatasets, start_browser=true)

#now push in a few more spheres and see them pop up
push!(balVis.spheres, :s2=>[2.,0,0])
push!(balVis.spheres, :s3=>[2.,1,1])
push!(balVis.spheres, :s4=>[1.,1,1])

# you can easily create a second one
push!(visdatasets, DrawSphereAmphi("robot", "session2", Dict(:s0=>[0.,-1,0], :s1=>[1.,-1,0]), 0.2))

## finally run stopAmphiVis!() to stop the visualizer
stopAmphiVis!()
