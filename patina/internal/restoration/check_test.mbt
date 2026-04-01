///|
// Test: Completion check counts correctly
test "completion_check_counts" {
  let regions = [
    @types.new_region([]),
    @types.new_region([Crack]),
    @types.new_region([Stain]),
  ]
  let artwork = @types.new_artwork(3, 1, regions)
  // Initially: 1 pristine, 2 damaged
  let score = check_completion(artwork)
  assert_eq!(score.restored_count, 0)
  assert_eq!(score.worsened_count, 0)
  assert_eq!(score.sealed_count, 0)
}

///|
// Test: Level complete when all regions addressed
test "level_complete_check" {
  let regions = [
    @types.new_region([]),
    @types.new_region([Crack]),
  ]
  let artwork = @types.new_artwork(2, 1, regions)
  // Not complete yet
  assert_false!(is_level_complete(artwork))
  // Fix the crack
  let _ = apply_tool(regions[1], Fill)
  let _ = apply_tool(regions[1], Seal)
  assert_true!(is_level_complete(artwork))
}

///|
// Test: Star calculation - 3 stars
test "three_stars_no_worsened_within_par" {
  let regions = [
    @types.new_region([Crack]),
    @types.new_region([Stain]),
  ]
  let artwork = @types.new_artwork(2, 1, regions)
  // Perfect restoration
  let _ = apply_tool(regions[0], Fill)
  let _ = apply_tool(regions[0], Seal)
  let _ = apply_tool(regions[1], Clean)
  let _ = apply_tool(regions[1], Seal)
  let stars = calculate_stars(artwork, 4, 5)
  assert_eq!(stars, 3)
}

///|
// Test: Star calculation - 2 stars (over par)
test "two_stars_no_worsened_over_par" {
  let regions = [
    @types.new_region([Crack]),
    @types.new_region([Stain]),
  ]
  let artwork = @types.new_artwork(2, 1, regions)
  let _ = apply_tool(regions[0], Fill)
  let _ = apply_tool(regions[0], Seal)
  let _ = apply_tool(regions[1], Clean)
  let _ = apply_tool(regions[1], Seal)
  let stars = calculate_stars(artwork, 10, 5)
  assert_eq!(stars, 2)
}

///|
// Test: Star calculation - 1 star (has sealed region from worsening)
test "one_star_with_sealed" {
  let regions = [
    @types.new_region([Crack]),
    @types.new_region([Stain]),
  ]
  let artwork = @types.new_artwork(2, 1, regions)
  // Worsen crack with Clean, then seal it (becomes Sealed, not Restored)
  let _ = apply_tool(regions[0], Clean)
  let _ = apply_tool(regions[0], Seal)
  // Properly fix stain
  let _ = apply_tool(regions[1], Clean)
  let _ = apply_tool(regions[1], Seal)
  // One region is Sealed (improperly), so only 1 star
  let stars = calculate_stars(artwork, 4, 5)
  assert_eq!(stars, 1)
}

///|
// Test: count_states function
test "count_states_works" {
  let regions = [
    @types.new_region([]),
    @types.new_region([Crack]),
    @types.new_region([Stain]),
  ]
  let artwork = @types.new_artwork(3, 1, regions)
  let (pristine, damaged, _treated, _restored, _worsened, _sealed_n) = count_states(
    artwork,
  )
  assert_eq!(pristine, 1)
  assert_eq!(damaged, 2)
}

///|
// Test: Tool budget enforcement (via types utils)
test "budget_enforcement" {
  let budget = @types.new_budget(1, 0, 0, 0)
  assert_eq!(@types.get_budget_for_tool(budget, Clean), 1)
  @types.use_budget(budget, Clean)
  assert_eq!(@types.get_budget_for_tool(budget, Clean), 0)
  @types.restore_budget(budget, Clean)
  assert_eq!(@types.get_budget_for_tool(budget, Clean), 1)
}
