///|
pub fn match_hull_to_target(
  hull : Array[@types.Point],
  target : @types.Polygon
) -> Float {
  let target_verts = target.vertices
  let tn = target_verts.length()
  let hn = hull.length()
  if tn == 0 {
    return 0.0
  }
  if hn == 0 {
    return 0.0
  }
  // Check each target edge - does the hull have a matching edge nearby?
  let mut matched_edges = 0
  for i in 0..<tn {
    let ta = target_verts[i]
    let tb = target_verts[(i + 1) % tn]
    if edge_matches_hull(ta, tb, hull) {
      matched_edges += 1
    }
  }
  Float::from_int(matched_edges) * 100.0 / Float::from_int(tn)
}

///|
fn edge_matches_hull(
  ta : @types.Point,
  tb : @types.Point,
  hull : Array[@types.Point]
) -> Bool {
  let hn = hull.length()
  if hn < 2 {
    return false
  }
  // For each hull edge, check if it overlaps well with this target edge
  for i in 0..<hn {
    let ha = hull[i]
    let hb = hull[(i + 1) % hn]
    if edges_match(ta, tb, ha, hb) {
      return true
    }
  }
  false
}

///|
fn edges_match(
  ta : @types.Point,
  tb : @types.Point,
  ha : @types.Point,
  hb : @types.Point
) -> Bool {
  // Both endpoints of target edge must be close to hull edge, and vice versa
  let tol = @types.tolerance
  let d_ta_h = @types.point_to_segment_dist(ta, ha, hb)
  let d_tb_h = @types.point_to_segment_dist(tb, ha, hb)
  let d_ha_t = @types.point_to_segment_dist(ha, ta, tb)
  let d_hb_t = @types.point_to_segment_dist(hb, ta, tb)
  d_ta_h < tol && d_tb_h < tol && d_ha_t < tol && d_hb_t < tol
}

///|
pub fn hull_matches_target(
  hull : Array[@types.Point],
  target : @types.Polygon
) -> Bool {
  let pct = match_hull_to_target(hull, target)
  pct >= 99.9
}

///|
pub fn count_hull_vertices(hull : Array[@types.Point]) -> Int {
  hull.length()
}
