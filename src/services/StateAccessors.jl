
# Internal helper accessors bridging Arena plotting code to the DFG v0.29 State/belief API.

"""
    $SIGNATURES

Get the primary belief point (first principal element, i.e. mean) for a variable state.
Falls back to the first belief point if no principal elements (means) are stored.
"""
function _meanPoint(state::DFG.State)
  m = mean(getBelief(state))
  isempty(m) || return m[1]
#   pts = DFG.refPoints(state)
#   isempty(pts) || return pts[1]
  return error("State :$(state.label) has no belief means or points to plot")
end
_meanPoint(fg::AbstractDFG, vlb::Symbol, solveKey::Symbol = :parametric) = _meanPoint(getState(fg, vlb, solveKey))

"""
    $SIGNATURES

Get the primary covariance (first principal form) for a variable state.
"""
_covariance(state::DFG.State) = cov(getBelief(state))
_covariance(fg::AbstractDFG, vlb::Symbol, solveKey::Symbol = :parametric) = _covariance(getState(fg, vlb, solveKey))

# list variable labels matching a label regex (replaces old `ls(fg, r"^x")`)
_ls(fg::AbstractDFG, rgx::Regex) = ls(fg; whereLabel = contains(rgx))

# yaw (heading) angle from a 2D or 3D rotation matrix
_yaw(R::AbstractMatrix{<:Real}) = atan(R[2, 1], R[1, 1])
