///|
pub fn check_match(current : @types.Shape, target : @types.Shape) -> Bool {
  @types.shape_exact_match(current, target)
}

///|
pub fn match_percentage(current : @types.Shape, target : @types.Shape) -> Int {
  if target.cells.length() == 0 {
    return 100
  }
  let matching = @types.shape_match_count(current, target)
  let total = @types.maxi(current.cells.length(), target.cells.length())
  if total == 0 {
    return 100
  }
  matching * 100 / total
}

///|
pub fn calculate_stars(
  cost : Int,
  par : Int,
  min_cost : Int,
) -> @types.StarRating {
  if cost <= min_cost {
    Three
  } else if cost <= par {
    Two
  } else {
    One
  }
}
