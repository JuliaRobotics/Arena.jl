using GraffSDK
using Arena

config = loadGraffConfig()
config.sessionId = "HexDemoSample1_d26eeef0e6c44099942074520607c6a0"

@info "Going to visualize once-off from $(config.sessionId)"
estimates = getEstimates()
ldict = sort(collect(keys(estimates)))
map(l -> println("$l -> $(estimates[l])"), ldict)

# Start the visualizer
initBotVis2()

# Get poses from DB and draw them
visualizeSession()

# testing
using Images, Colors, ImageShow, FileIO
imgForm = image_tToRgb(img)

bytes = rgbToJpeg(imgForm)
file = open("/home/gearsad/test.jpg", "w")
write(file, bytes)
close(file)
