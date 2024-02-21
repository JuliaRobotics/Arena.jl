
using Arena
using Caesar
using Downloads
using DelimitedFiles
using LasIO
using Test

##

function downloadTestData(datafile, url)
  if 0 === Base.filesize(datafile)
    Base.mkpath(dirname(datafile))
    @info "Downloading $url"
    Downloads.download(url, datafile)
  end
  return datafile
end

testdatafolder = joinpath(tempdir(), "caesar", "testdata") # "/tmp/caesar/testdata/"

lidar_terr1_file = joinpath(testdatafolder,"lidar","simpleICP","terrestrial_lidar1.xyz")
if !isfile(lidar_terr1_file)
  lidar_terr1_url = "https://github.com/JuliaRobotics/CaesarTestData.jl/raw/main/data/lidar/simpleICP/terrestrial_lidar1.xyz"
  downloadTestData(lidar_terr1_file,lidar_terr1_url)
end

# load the data to memory
X_fix = readdlm(lidar_terr1_file, Float32)
# convert data to PCL types
pc_fix = Caesar._PCL.PointCloud(X_fix);


##
@testset "test plotPointCloud" begin
##

pl = Arena.plotPointCloud(pc_fix);

##
end
##