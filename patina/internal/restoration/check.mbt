///|
/// Check the artwork completion and calculate score.
pub fn check_completion(artwork : @types.Artwork) -> @types.LevelScore {
  let score = @types.new_score()
  let mut all_done = true
  for i in 0..<artwork.regions.length() {
    let r = artwork.regions[i]
    match r.state {
      Pristine => ()
      Restored => score.restored_count = score.restored_count + 1
      Worsened => score.worsened_count = score.worsened_count + 1
      Sealed => score.sealed_count = score.sealed_count + 1
      Damaged | Treated => all_done = false
    }
  }
  // Count damaged regions that need work
  let damaged_count = count_damaged(artwork)
  if damaged_count > 0 {
    all_done = false
  }
  // Ignore all_done for star calculation - it's only used for display
  ignore(all_done)
  score
}

///|
/// Check if the level is complete (all non-pristine regions are restored, sealed, or worsened).
pub fn is_level_complete(artwork : @types.Artwork) -> Bool {
  for i in 0..<artwork.regions.length() {
    let r = artwork.regions[i]
    match r.state {
      Damaged | Treated => return false
      _ => ()
    }
  }
  true
}

///|
/// Calculate stars for a completed level.
pub fn calculate_stars(
  artwork : @types.Artwork,
  tools_used : Int,
  par_tools : Int,
) -> Int {
  let score = check_completion(artwork)
  // Must have some restored or sealed regions
  let total_damaged = score.restored_count +
    score.worsened_count +
    score.sealed_count
  if total_damaged == 0 {
    return 0
  }
  // 1 star: all regions restored or sealed (no remaining damaged/treated)
  let mut has_remaining = false
  for i in 0..<artwork.regions.length() {
    match artwork.regions[i].state {
      Damaged | Treated => {
        has_remaining = true
        break
      }
      _ => ()
    }
  }
  if has_remaining {
    return 0
  }
  // At least 1 star: level is complete
  let mut stars = 1
  // 2 stars: no worsened or improperly sealed regions (all must be Restored or Pristine)
  if score.worsened_count == 0 && score.sealed_count == 0 {
    stars = 2
  }
  // 3 stars: perfect restoration + within par tool uses
  if score.worsened_count == 0 &&
    score.sealed_count == 0 &&
    tools_used <= par_tools {
    stars = 3
  }
  stars
}

///|
/// Count regions that still have damage.
pub fn count_damaged(artwork : @types.Artwork) -> Int {
  let mut count = 0
  for i in 0..<artwork.regions.length() {
    match artwork.regions[i].state {
      Damaged => count = count + 1
      _ => ()
    }
  }
  count
}

///|
/// Count regions in each state.
pub fn count_states(artwork : @types.Artwork) -> (Int, Int, Int, Int, Int, Int) {
  let mut pristine = 0
  let mut damaged = 0
  let mut treated = 0
  let mut restored = 0
  let mut worsened = 0
  let mut sealed_n = 0
  for i in 0..<artwork.regions.length() {
    match artwork.regions[i].state {
      Pristine => pristine = pristine + 1
      Damaged => damaged = damaged + 1
      Treated => treated = treated + 1
      Restored => restored = restored + 1
      Worsened => worsened = worsened + 1
      Sealed => sealed_n = sealed_n + 1
    }
  }
  (pristine, damaged, treated, restored, worsened, sealed_n)
}
