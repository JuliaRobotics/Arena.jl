

"""
    $SIGNATURES

Plot name tuple output from [`overlayScatter`](@ref)

See also: [`overlayScatterMutate`](@ref)
"""
function plotScatterAlign(snt::NamedTuple; title::String="")
  fig = Figure(size=(1200, 400))

  ax1 = GLMakie.Axis(fig[1,1]; title="body frame data."*title, aspect=1)
  scatter!(ax1, snt.pP1[1,:], snt.pP1[2,:], color=:blue,   label="pP1")
  scatter!(ax1, snt.qP2[1,:], snt.qP2[2,:], color=:red,    label="qP2")
  axislegend(ax1)

  ax2 = GLMakie.Axis(fig[1,2]; title="User transform: $(round.(snt.user_coords,digits=3))\nu_score=$(snt.u_score)", aspect=1)
  scatter!(ax2, snt.pP1[1,:],   snt.pP1[2,:],   color=:blue,  label="pP1")
  scatter!(ax2, snt.pP2_u[1,:], snt.pP2_u[2,:], color=:green, label="pP2_u")
  axislegend(ax2)

  ax3 = GLMakie.Axis(fig[1,3]; title="Best fit: $(snt.best_coords)\nb_score=$(snt.b_score)", aspect=1)
  scatter!(ax3, snt.pP1[1,:],   snt.pP1[2,:],   color=:blue,   label="pP1")
  scatter!(ax3, snt.pP2_b[1,:], snt.pP2_b[2,:], color=:orange, label="pP2_b")
  axislegend(ax3)

  fig
end



plotScatterAlign( 
  sap::ScatterAlignPose2;
  sample_count::Integer = sap.align.sample_count,
  bw::Real = sap.align.bw,
  kw...
) = 
  plotScatterAlign(
    overlayScatterMutate(
      sap; 
      sample_count, 
      bw
    ); 
    kw...
  )
