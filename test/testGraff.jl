using GraffSDK
using Arena

# config = loadGraffConfig()
config = loadGraffConfig()

config.sessionId = "GreenMonster_81e5e9cbaeaf435eb65aac88a2f09a05"

getStatus()

# getSessions()
# @info "Going to visualize once-off from $(config.sessionId)"
# estimates = getEstimates()
# ldict = sort(collect(keys(estimates)))
# map(l -> println("$l -> $(estimates[l])"), ldict)

# Start the visualizer
botVis = initBotVis2()

# Get poses from DB and draw them
Arena.visualizeSession(botVis.vis; dataImageKey="", pointCloudKey="Depth")


# Testing JPG -> PNG conversion
entries = getDataEntries(getNode("x40"))
imData = getData(getNode("x40"), entries[3].id)

using Base64, FileIO
rawData = base64decode(imData.data)
iob = IOBuffer(rawData)
im = load(Stream(format"JPEG", iob))
pngBytes = rgbToPng(im)
# Now give this to images lib.

# Depth cloud
# cameraModel = CameraModel(640,480, 1.0, [0.0, 0.0]) #TODO: Fix
# depthData = getData(getNode("x40"), entries[2].id)
# dData = base64decode(depthData.data)
# # iob = IOBuffer(depthData.data)
# c = reinterpret(UInt16, dData)
# depths = collect(reshape(c, (640, 480)))
# pointCloud = cloudFromDepthImage(depths, cameraModel)
# # Now put this on a pose.
