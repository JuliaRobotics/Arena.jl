# utils for setting or finding colors


function colorwheel(n::Int)
  # RGB(1.0, 1.0, 0)
  convert(RGB, HSV((n*30)%360, 1.0,0.5))
end




function pointToColor(nm::Symbol)
  if nm == :PartialPose3XYYaw
    return RGBA(0.6,0.8,0.9,0.5)
  elseif nm == :Pose3Pose3NH
    return RGBA(1.0,1.0,0,0.5)
  else
    # println("pointToColor(..) -- warning, using default color for edges")
    return RGBA(0.0,1,0.0,0.5)
  end
end


function submapcolor(idx::Int, len::Int;
        submapcolors=SubmapColorCheat() )
  #
  n = idx%length(submapcolors.colors)+1
  smc = submapcolors.colors[n]
  return [smc for g in 1:len]
end
