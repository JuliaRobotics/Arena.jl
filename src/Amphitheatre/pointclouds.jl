"""
    $(SIGNATURES)
Draw point cloud on pose.
xTc -> pose to camera transform, # Use material to set size of particles or other propeties
""" #TODO: confirm xTc or cTx
function visPointCloudOnPose!(vis::Visualizer, pointcloud::PointCloud; xTc::SE3 = SE3([0,0,0],I), material = PointsMaterial(size=0.02) )::Nothing
	setobject!(vis, pointcloud, material)
	trans = Translation(xTc.t[1], xTc.t[2], xTc.t[3])∘LinearMap(Quat(xTc.R.R))
	settransform!(vis, trans)
	return nothing
end
