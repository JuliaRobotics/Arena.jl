# image utils



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
