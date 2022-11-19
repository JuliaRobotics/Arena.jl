# ============================================================
# --------------------GraffCloudOnPose--------------------
# ============================================================
# import Arena.Amphitheatre: visualize!

struct GraffCloudOnPose <: AbstractAmphitheatre
	robotId::String
	sessionId::String
	config::GraffConfig

	# pclouds::Dict{Symbol, PointCloud} #TODO do we want to store this here as well?
	isdrawn::Dict{Symbol, Bool}
	dcam::CameraModel
	colmap::ColorGradient
end


GraffCloudOnPose(config::GraffConfig, dcam::CameraModel, colmap::ColorGradient = cgrad(:bgy,:colorcet)) =
			GraffCloudOnPose(config.robotId, config.sessionId, config, Dict{Symbol, Bool}(), dcam, colmap)


"""
    $(SIGNATURES)
Basic visualizer object visualize! function.
"""
function visualize!(vis::Visualizer, pcop::GraffCloudOnPose)::Nothing

	# only read and update from graff once
	isdrawn = pcop.isdrawn

	if length(isdrawn) == 0

		robotId = pcop.robotId
		sessionId = pcop.sessionId
		config = pcop.config


		sessionDataEntries = getSessionDataEntries(config.robotId, config.sessionId)

		for nodeKey = keys(sessionDataEntries)

			dataEntries = sessionDataEntries[nodeKey]

			!("rawdepth" in [de.id for de in dataEntries]) && continue

			elem = GraffSDK.getData(robotId, sessionId, dataEntries[1].neoNodeId, "rawdepth")

			if elem == nothing
				# @info "no rawdepth for $vsym"
				continue
			end

			depthImage = JSON2.read(elem.data)
			# es = String(copy(elem.data[1:findfirst(elem.data .== 0x00)]));

			kTc = (SE3([0,0,0], Quaternion(Float64.(depthImage.kQi[1:4]))))
			trans = Translation([0,0,0])∘LinearMap(Quat(kTc.R.R))

			w = depthImage.width
			h = depthImage.height

			depthim = reshape(reinterpret(UInt16,base64decode(depthImage.data[1].base64)), (w, h))'[:,:]

			pointcloud = cloudFromDepthImageClampZ(depthim, pcop.dcam, trans, maxrange=3f0, clampz = [-0.5f0,0.5f0], colmap=pcop.colmap)
			# pointcloud = cloudFromDepthImage(depthim, pcop.dcam, trans, maxrange=3f0)

			nodesym = Symbol(depthImage.node_name)

			if !get(isdrawn, nodesym, false)
				haskey(isdrawn, nodesym) ? isdrawn[nodesym] = true : push!(isdrawn, nodesym=>true)
				visPointCloudOnPose!(vis[robotId][sessionId][:poses][nodesym][:pc], pointcloud)
			end
		end
	end
    return nothing
end
