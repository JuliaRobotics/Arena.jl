# image utils

"""
Convert a Vector{UInt8} to an image of RGB Vector{N0f8}.
"""
function rgbUint8ToRgb(width::Int64, height::Int64, data::Vector{UInt8})::Array{RGB{N0f8}, 2}
  r=data[1:3:end];g=data[2:3:end];b=data[3:3:end]
  imgForm = rand(RGB{N0f8}, height, width)
  for w in 1:width
      for h in 0:(height-1)
          l = w + h * width
          imgForm[h+1,w] = RGB{N0f8}(r[l]/255.0, g[l]/255.0, b[l]/255.0)
      end
  end
  return imgForm
end

"""
Converts an RGB image to a JPEG image, returns buffer of UInt8 data.
"""
function rgbToJpeg(rgb::Array{RGB{N0f8}, 2})::Vector{UInt8}
  io = IOBuffer()
  save(Stream(format"JPEG",io), rgb)
  bytes = take!(io)
  return bytes
end

"""
Converts an RGB image to a PNG image, returns buffer of UInt8 data.
"""
function rgbToPng(rgb::Array{RGB{N0f8}, 2})::Vector{UInt8}
  io = IOBuffer()
  save(Stream(format"PNG",io), rgb)
  bytes = take!(io)
  return bytes
end

function imshowhackpng(im)
  filename = joinpath("/tmp","tempimgcaesar.png")
  imf = open(filename, "w")
  write(imf, im)
  close(imf)
  run(`eog $(filename)`)
end
function imshowhack(img::Array{T}) where {T <: Colorant}
  filename = joinpath("/tmp","caesarimshowhack.png")
  ImageMagick.save_(filename, img)
  run(`eog $(filename)`)
end




function roi(img, row, col; fov=50)
  r, c = size(img)
  left = round(Int,col-fov)
  right = round(Int,col+fov)
  top = round(Int,row-fov)
  bottom = round(Int,row+fov)
  if c < left
    left = c
  end
  if left < 1
    left=1
  end
  if c < right
    right = c
  end
  if right < 1
    right=1
  end
  if c < top
    top = c
  end
  if top < 1
    top=1
  end
  if c < bottom
    bottom = c
  end
  if bottom < 1
    bottom=1
  end

  img[top:bottom,left:right]
end
