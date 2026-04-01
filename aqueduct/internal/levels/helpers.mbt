///|
/// Create a flat grid filled with a single elevation value.
pub fn make_flat_grid(cols : Int, rows : Int, elev : Int) -> Array[Int] {
  Array::make(cols * rows, elev)
}

///|
/// Set a specific row of elevations.
pub fn set_row(
  elevations : Array[Int],
  cols : Int,
  row : Int,
  values : Array[Int]
) -> Unit {
  let offset = row * cols
  for i, v in values {
    if i < cols {
      elevations[offset + i] = v
    }
  }
}

///|
/// Create all levels across all tiers.
pub fn create_all_levels() -> Array[@types.Level] {
  let levels : Array[@types.Level] = []
  for lv in create_tier1() {
    levels.push(lv)
  }
  for lv in create_tier2() {
    levels.push(lv)
  }
  for lv in create_tier3() {
    levels.push(lv)
  }
  levels
}
