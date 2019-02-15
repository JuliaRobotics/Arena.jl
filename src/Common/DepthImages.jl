"""
    $(SIGNATURES)
Create a {Float32} point cloud from a depth image clampin the z-axis to [clampz]. Note: rotated to Forward Starboard Down
"""
function cloudFromDepthImageClampZ(depths::Array{UInt16,2},
                                   cm::CameraModel,
                                   trans::AffineMap;
                                   depthscale = 0.001f0,
                                   skip::Int = 1,
                                   maxrange::Float32 = 5f0,
                                   clampz = [0f0,1f0],
								   colmap::ColorGradient = cgrad(:bgy,:colorcet))::PointCloud
	  							   # colmap::ColorGradient = ColorGradient([RGBA(0,1,0,1)], [1.0]))::PointCloud # I prever default to be pretty

    #
	cx = Float32(cm.cc[1])
	cy = Float32(cm.cc[2])
	fx = Float32(cm.fc[1])
	fy = Float32(cm.fc[2])
    (row,col) = size(depths)
    cloud = Point3f0[]
    cloudCol = RGB{Float32}[]

    for u = 1:skip:row, v = 1:skip:col
        z = depths[u,v]*depthscale
        if  0 < z < maxrange
            x = (v-cx)/fx * z
            y = (u-cy)/fy * z
            p = trans(Point3f0(z,x,y))
			if clampz[1] <= p[3] <= clampz[2]
            	push!(cloud, p) #NOTE rotated to Forward Starboard Down, TODO: maybe leave in camera frame?
				cmlength = length(colmap.colors)
				push!(cloudCol, colmap.colors[round(Int,((p[3]-clampz[1])/(clampz[2]-clampz[1]))*Float32(cmlength-1))+1])
			end
        end
    end
    pointcloud = PointCloud(cloud, cloudCol)

    return pointcloud
end



"""
    $(SIGNATURES)
Create a {Float32} point cloud from a depth image, repeating every [colmapz = 1f0]. Note: rotated to Forward Starboard Down
""" #TODO fix color map
function cloudFromDepthImage(depths::Array{UInt16,2},
							 cm::CameraModel,
							 trans::AffineMap=Translation(0,0,0);
							 depthscale = 0.001f0,
							 skip::Int = 1,
							 maxrange::Float32 = 5f0,
							 colmapz::Float32 = 1f0,
							 colmap::ColorGradient = cgrad(:bgy,:colorcet))::PointCloud
							 # colmap::ColorGradient = ColorGradient([RGBA(0,1,0,1)], [1.0]))::PointCloud # I prever default to be pretty

	cx = Float32(cm.cc[1])
	cy = Float32(cm.cc[2])
	fx = Float32(cm.fc[1])
	fy = Float32(cm.fc[2])
    (row,col) = size(depths)

    cloud = Point3f0[]
    cloudCol = RGB{Float32}[]

	cmlength = length(colmap.colors)

    for u = 1:skip:row, v = 1:skip:col
        z = depths[u,v]*depthscale
        if  0 < z < maxrange
            x = (v-cx)/fx * z
			y = (u-cy)/fy * z
			p = trans(Point3f0(z,x,y))
            push!(cloud, p) #NOTE rotated to Forward Starboard Down, TODO: maybe leave in camera frame?
			push!(cloudCol, colmap.colors[round(Int,(mod(p[3],colmapz))*Float32(cmlength-1))+1])
        end
    end
    pointcloud = PointCloud(cloud, cloudCol)

    return pointcloud
end
