using GraffSDK
using Arena

# config = loadGraffConfig()
config = loadGraffConfig("/home/gearsad/.graffsdkdev.json")

config.sessionId = "GreenMonster_81e5e9cbaeaf435eb65aac88a2f09a05"

getStatus()

# getSessions()
@info "Going to visualize once-off from $(config.sessionId)"
estimates = getEstimates()
ldict = sort(collect(keys(estimates)))
map(l -> println("$l -> $(estimates[l])"), ldict)

# Start the visualizer
vis = initBotVis2()

# Get poses from DB and draw them
Arena.visualizeSession(vis, "", "")

# testing
using Images, Colors, ImageShow, FileIO
imgForm = image_tToRgb(img)

bytes = rgbToJpeg(imgForm)
file = open("/home/gearsad/test.jpg", "w")
write(file, bytes)
close(file)
