///|
pub(all) struct CheckResult {
  silhouette_match : Bool
  layers_match : Bool
  checks_detail : Array[Bool]
} derive(Debug)

///|
pub extend CheckResult with Debug::{to_repr}

///|
pub fn check_completion(
  paper : @types.Paper,
  level : @types.Level,
) -> CheckResult {
  let sil = @types.paper_matches_silhouette(paper, level.target_silhouette)
  let details : Array[Bool] = Array::new(capacity=level.layer_checks.length())
  let mut all_layers = true
  for i in 0..<level.layer_checks.length() {
    let ok = @types.single_layer_check_ok(paper, level.layer_checks[i])
    details.push(ok)
    if !ok {
      all_layers = false
    }
  }
  if level.layer_checks.length() == 0 {
    all_layers = true
  }
  { silhouette_match: sil, layers_match: all_layers, checks_detail: details, }
}

///|
pub fn compute_stars(
  result : CheckResult,
  folds_used : Int,
  par_folds : Int,
) -> @types.StarRating {
  if !result.silhouette_match {
    return Zero
  }
  if !result.layers_match {
    return One
  }
  if folds_used <= par_folds {
    Three
  } else {
    Two
  }
}
