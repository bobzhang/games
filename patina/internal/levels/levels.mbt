///|
/// Helper to create a pristine (undamaged) region.
fn p() -> @types.Region {
  @types.new_region([])
}

///|
/// Helper: single crack region.
fn crack() -> @types.Region {
  @types.new_region([Crack])
}

///|
/// Helper: single stain region.
fn stain() -> @types.Region {
  @types.new_region([Stain])
}

///|
/// Helper: single fade region.
fn fade() -> @types.Region {
  @types.new_region([Fade])
}

///|
/// Helper: single flake region.
fn flake() -> @types.Region {
  @types.new_region([Flake])
}

///|
/// Helper: crack + stain compound damage.
fn crack_stain() -> @types.Region {
  @types.new_region([Crack, Stain])
}

///|
/// Helper: crack + fade compound damage.
fn crack_fade() -> @types.Region {
  @types.new_region([Crack, Fade])
}

///|
/// Helper: stain + fade compound damage.
fn stain_fade() -> @types.Region {
  @types.new_region([Stain, Fade])
}

///|
/// Helper: flake + stain compound damage.
fn flake_stain() -> @types.Region {
  @types.new_region([Flake, Stain])
}

///|
/// Helper: flake + fade compound damage.
fn flake_fade() -> @types.Region {
  @types.new_region([Flake, Fade])
}

///|
/// Helper: crack + stain + fade compound damage.
fn crack_stain_fade() -> @types.Region {
  @types.new_region([Crack, Stain, Fade])
}

///|
/// Helper: flake + stain + fade compound damage.
fn flake_stain_fade() -> @types.Region {
  @types.new_region([Flake, Stain, Fade])
}

///|
/// Get all 20 levels.
pub fn get_all_levels() -> Array[@types.Level] {
  [
    level_1(),
    level_2(),
    level_3(),
    level_4(),
    level_5(),
    level_6(),
    level_7(),
    level_8(),
    level_9(),
    level_10(),
    level_11(),
    level_12(),
    level_13(),
    level_14(),
    level_15(),
    level_16(),
    level_17(),
    level_18(),
    level_19(),
    level_20(),
  ]
}

///|
/// Get a specific level by index (0-19).
pub fn get_level(index : Int) -> @types.Level {
  let levels = get_all_levels()
  levels[index]
}

// ============================================================
// TIER 1: SKETCHES (Levels 1-7) - Single damage types, learn tools
// ============================================================

///|
/// Level 1: "First Cracks" - Learn Fill tool on cracks
fn level_1() -> @types.Level {
  let regions = [
    p(),
    p(),
    p(),
    p(),
    p(),
    p(),
    p(),
    crack(),
    p(),
    p(),
    crack(),
    p(),
    p(),
    p(),
    p(),
    p(),
    p(),
    p(),
    p(),
    p(),
    p(),
    p(),
    p(),
    p(),
    p(),
    crack(),
    p(),
    p(),
    crack(),
    p(),
    p(),
    p(),
    p(),
    p(),
    p(),
    p(),
  ]
  @types.new_level(
    Sketches,
    "First Cracks",
    regions,
    @types.new_budget(0, 4, 0, 4),
    8,
  )
}

///|
/// Level 2: "Surface Stains" - Learn Clean tool
fn level_2() -> @types.Level {
  let regions = [
    p(),
    p(),
    p(),
    p(),
    p(),
    p(),
    p(),
    p(),
    stain(),
    stain(),
    p(),
    p(),
    p(),
    stain(),
    p(),
    p(),
    stain(),
    p(),
    p(),
    stain(),
    p(),
    p(),
    stain(),
    p(),
    p(),
    p(),
    stain(),
    stain(),
    p(),
    p(),
    p(),
    p(),
    p(),
    p(),
    p(),
    p(),
  ]
  @types.new_level(
    Sketches,
    "Surface Stains",
    regions,
    @types.new_budget(8, 0, 0, 8),
    16,
  )
}

///|
/// Level 3: "Faded Colors" - Learn Retouch tool
fn level_3() -> @types.Level {
  let regions = [
    p(),
    p(),
    p(),
    p(),
    p(),
    p(),
    p(),
    fade(),
    fade(),
    p(),
    p(),
    p(),
    p(),
    fade(),
    fade(),
    fade(),
    p(),
    p(),
    p(),
    p(),
    fade(),
    fade(),
    fade(),
    p(),
    p(),
    p(),
    p(),
    fade(),
    fade(),
    p(),
    p(),
    p(),
    p(),
    p(),
    p(),
    p(),
  ]
  @types.new_level(
    Sketches,
    "Faded Colors",
    regions,
    @types.new_budget(0, 0, 10, 10),
    20,
  )
}

///|
/// Level 4: "Flaking Paint" - Learn Fill+Retouch sequence for flakes
fn level_4() -> @types.Level {
  let regions = [
    p(),
    p(),
    p(),
    p(),
    p(),
    p(),
    p(),
    flake(),
    p(),
    p(),
    flake(),
    p(),
    p(),
    p(),
    flake(),
    flake(),
    p(),
    p(),
    p(),
    p(),
    flake(),
    flake(),
    p(),
    p(),
    p(),
    flake(),
    p(),
    p(),
    flake(),
    p(),
    p(),
    p(),
    p(),
    p(),
    p(),
    p(),
  ]
  @types.new_level(
    Sketches,
    "Flaking Paint",
    regions,
    @types.new_budget(0, 8, 8, 8),
    24,
  )
}

///|
/// Level 5: "Cracked Frame" - More cracks in a pattern
fn level_5() -> @types.Level {
  let regions = [
    crack(),
    crack(),
    crack(),
    crack(),
    crack(),
    crack(),
    crack(),
    p(),
    p(),
    p(),
    p(),
    crack(),
    crack(),
    p(),
    p(),
    p(),
    p(),
    crack(),
    crack(),
    p(),
    p(),
    p(),
    p(),
    crack(),
    crack(),
    p(),
    p(),
    p(),
    p(),
    crack(),
    crack(),
    crack(),
    crack(),
    crack(),
    crack(),
    crack(),
  ]
  @types.new_level(
    Sketches,
    "Cracked Frame",
    regions,
    @types.new_budget(0, 20, 0, 20),
    40,
  )
}

///|
/// Level 6: "Spotted Canvas" - Mix of stains and fades
fn level_6() -> @types.Level {
  let regions = [
    p(),
    stain(),
    p(),
    p(),
    fade(),
    p(),
    stain(),
    p(),
    stain(),
    fade(),
    p(),
    fade(),
    p(),
    stain(),
    p(),
    p(),
    fade(),
    p(),
    p(),
    fade(),
    p(),
    p(),
    stain(),
    p(),
    fade(),
    p(),
    fade(),
    stain(),
    p(),
    stain(),
    p(),
    fade(),
    p(),
    p(),
    stain(),
    p(),
  ]
  @types.new_level(
    Sketches,
    "Spotted Canvas",
    regions,
    @types.new_budget(6, 0, 6, 12),
    24,
  )
}

///|
/// Level 7: "Mixed Singles" - All four single damage types
fn level_7() -> @types.Level {
  let regions = [
    p(),
    crack(),
    p(),
    stain(),
    p(),
    p(),
    fade(),
    p(),
    p(),
    p(),
    p(),
    flake(),
    p(),
    p(),
    crack(),
    p(),
    stain(),
    p(),
    p(),
    stain(),
    p(),
    fade(),
    p(),
    p(),
    flake(),
    p(),
    p(),
    p(),
    p(),
    crack(),
    p(),
    p(),
    fade(),
    p(),
    flake(),
    p(),
  ]
  @types.new_level(
    Sketches,
    "Mixed Singles",
    regions,
    @types.new_budget(3, 6, 6, 12),
    27,
  )
}

// ============================================================
// TIER 2: PAINTINGS (Levels 8-14) - Mixed damage, order matters
// ============================================================

///|
/// Level 8: "Old Portrait" - Crack+Stain combos (must Fill before Clean)
fn level_8() -> @types.Level {
  let regions = [
    p(),
    p(),
    p(),
    p(),
    p(),
    p(),
    p(),
    crack_stain(),
    p(),
    p(),
    crack_stain(),
    p(),
    p(),
    p(),
    crack(),
    stain(),
    p(),
    p(),
    p(),
    p(),
    stain(),
    crack(),
    p(),
    p(),
    p(),
    crack_stain(),
    p(),
    p(),
    crack_stain(),
    p(),
    p(),
    p(),
    p(),
    p(),
    p(),
    p(),
  ]
  @types.new_level(
    Paintings,
    "Old Portrait",
    regions,
    @types.new_budget(6, 6, 0, 8),
    20,
  )
}

///|
/// Level 9: "Faded Landscape" - Flakes and fades
fn level_9() -> @types.Level {
  let regions = [
    p(),
    flake(),
    fade(),
    p(),
    p(),
    p(),
    flake(),
    flake_fade(),
    p(),
    p(),
    fade(),
    p(),
    fade(),
    p(),
    flake(),
    fade(),
    p(),
    flake(),
    p(),
    fade(),
    p(),
    flake_fade(),
    flake(),
    fade(),
    p(),
    p(),
    flake_fade(),
    p(),
    p(),
    p(),
    p(),
    p(),
    p(),
    p(),
    p(),
    p(),
  ]
  @types.new_level(
    Paintings,
    "Faded Landscape",
    regions,
    @types.new_budget(0, 8, 10, 12),
    30,
  )
}

///|
/// Level 10: "Stained Mural" - Stains with other damage
fn level_10() -> @types.Level {
  let regions = [
    stain(),
    p(),
    stain_fade(),
    p(),
    stain(),
    p(),
    p(),
    crack_stain(),
    p(),
    crack_stain(),
    p(),
    stain(),
    stain_fade(),
    p(),
    stain(),
    p(),
    stain_fade(),
    p(),
    p(),
    stain(),
    p(),
    stain(),
    p(),
    stain_fade(),
    stain(),
    p(),
    crack_stain(),
    p(),
    stain(),
    p(),
    p(),
    stain_fade(),
    p(),
    stain_fade(),
    p(),
    stain(),
  ]
  @types.new_level(
    Paintings,
    "Stained Mural",
    regions,
    @types.new_budget(14, 4, 6, 20),
    44,
  )
}

///|
/// Level 11: "Weathered Still Life" - All damage pairs
fn level_11() -> @types.Level {
  let regions = [
    crack_stain(),
    p(),
    crack_fade(),
    p(),
    p(),
    p(),
    p(),
    flake_stain(),
    p(),
    stain_fade(),
    p(),
    p(),
    crack_fade(),
    p(),
    p(),
    p(),
    flake_fade(),
    p(),
    p(),
    stain_fade(),
    p(),
    p(),
    p(),
    crack_stain(),
    p(),
    p(),
    flake_fade(),
    p(),
    flake_stain(),
    p(),
    p(),
    p(),
    p(),
    crack_fade(),
    p(),
    crack_stain(),
  ]
  @types.new_level(
    Paintings,
    "Weathered Still Life",
    regions,
    @types.new_budget(6, 8, 8, 12),
    34,
  )
}

///|
/// Level 12: "Damaged Fresco" - Dense damage pattern
fn level_12() -> @types.Level {
  let regions = [
    crack(),
    stain(),
    crack(),
    stain(),
    crack(),
    stain(),
    fade(),
    flake(),
    fade(),
    flake(),
    fade(),
    flake(),
    crack(),
    stain(),
    crack_stain(),
    crack_stain(),
    stain(),
    crack(),
    flake(),
    fade(),
    flake_fade(),
    flake_fade(),
    fade(),
    flake(),
    stain(),
    crack(),
    stain(),
    crack(),
    stain(),
    crack(),
    fade(),
    flake(),
    fade(),
    flake(),
    fade(),
    flake(),
  ]
  @types.new_level(
    Paintings,
    "Damaged Fresco",
    regions,
    @types.new_budget(12, 18, 12, 36),
    78,
  )
}

///|
/// Level 13: "Gallery Piece" - Strategic ordering required
fn level_13() -> @types.Level {
  let regions = [
    p(),
    crack_stain(),
    p(),
    flake_stain(),
    p(),
    p(),
    crack_stain(),
    p(),
    crack_fade(),
    p(),
    flake_stain(),
    p(),
    p(),
    stain_fade(),
    p(),
    p(),
    p(),
    crack_stain(),
    flake_stain(),
    p(),
    p(),
    stain_fade(),
    p(),
    p(),
    p(),
    crack_fade(),
    p(),
    p(),
    crack_stain(),
    p(),
    p(),
    p(),
    flake_stain(),
    p(),
    p(),
    crack_fade(),
  ]
  @types.new_level(
    Paintings,
    "Gallery Piece",
    regions,
    @types.new_budget(8, 10, 6, 14),
    38,
  )
}

///|
/// Level 14: "Forgotten Masterpiece" - Heavy compound damage
fn level_14() -> @types.Level {
  let regions = [
    crack_stain(),
    flake_fade(),
    p(),
    p(),
    crack_stain(),
    flake_fade(),
    flake_fade(),
    crack_stain(),
    p(),
    p(),
    flake_fade(),
    crack_stain(),
    p(),
    p(),
    crack_stain(),
    flake_fade(),
    p(),
    p(),
    p(),
    p(),
    flake_fade(),
    crack_stain(),
    p(),
    p(),
    crack_stain(),
    flake_fade(),
    p(),
    p(),
    crack_stain(),
    flake_fade(),
    flake_fade(),
    crack_stain(),
    p(),
    p(),
    flake_fade(),
    crack_stain(),
  ]
  @types.new_level(
    Paintings,
    "Forgotten Masterpiece",
    regions,
    @types.new_budget(10, 16, 10, 16),
    52,
  )
}

// ============================================================
// TIER 3: MASTERWORKS (Levels 15-20) - Complex sequences, tight budgets
// ============================================================

///|
/// Level 15: "Renaissance Revival" - Triple damage regions
fn level_15() -> @types.Level {
  let regions = [
    p(),
    crack_stain_fade(),
    p(),
    p(),
    p(),
    p(),
    crack_stain_fade(),
    p(),
    crack_stain(),
    p(),
    flake_fade(),
    p(),
    p(),
    crack_stain(),
    p(),
    stain_fade(),
    p(),
    crack_stain_fade(),
    p(),
    p(),
    stain_fade(),
    p(),
    crack_stain(),
    p(),
    p(),
    flake_fade(),
    p(),
    crack_stain(),
    p(),
    crack_stain_fade(),
    p(),
    p(),
    p(),
    p(),
    crack_stain_fade(),
    p(),
  ]
  @types.new_level(
    Masterworks,
    "Renaissance Revival",
    regions,
    @types.new_budget(8, 10, 8, 14),
    40,
  )
}

///|
/// Level 16: "Baroque Restoration" - Dense triple damage
fn level_16() -> @types.Level {
  let regions = [
    crack_stain_fade(),
    p(),
    flake_stain_fade(),
    p(),
    crack_stain_fade(),
    p(),
    p(),
    flake_stain(),
    p(),
    crack_fade(),
    p(),
    flake_stain(),
    flake_stain_fade(),
    p(),
    crack_stain_fade(),
    p(),
    flake_stain_fade(),
    p(),
    p(),
    crack_fade(),
    p(),
    flake_stain(),
    p(),
    crack_fade(),
    crack_stain_fade(),
    p(),
    flake_stain_fade(),
    p(),
    crack_stain_fade(),
    p(),
    p(),
    flake_stain(),
    p(),
    crack_fade(),
    p(),
    flake_stain(),
  ]
  @types.new_level(
    Masterworks,
    "Baroque Restoration",
    regions,
    @types.new_budget(12, 14, 12, 18),
    56,
  )
}

///|
/// Level 17: "Cathedral Ceiling" - Tight budget challenge
fn level_17() -> @types.Level {
  let regions = [
    crack_stain(),
    flake_fade(),
    crack_stain(),
    flake_fade(),
    crack_stain(),
    flake_fade(),
    flake_fade(),
    crack_stain(),
    flake_fade(),
    crack_stain(),
    flake_fade(),
    crack_stain(),
    crack(),
    stain(),
    fade(),
    flake(),
    crack(),
    stain(),
    fade(),
    flake(),
    crack(),
    stain(),
    fade(),
    flake(),
    crack_stain(),
    flake_fade(),
    crack_stain(),
    flake_fade(),
    crack_stain(),
    flake_fade(),
    flake_fade(),
    crack_stain(),
    flake_fade(),
    crack_stain(),
    flake_fade(),
    crack_stain(),
  ]
  @types.new_level(
    Masterworks,
    "Cathedral Ceiling",
    regions,
    @types.new_budget(14, 22, 14, 36),
    86,
  )
}

///|
/// Level 18: "Museum Centerpiece" - Every region damaged
fn level_18() -> @types.Level {
  let regions = [
    crack(),
    stain(),
    fade(),
    flake(),
    crack_stain(),
    stain_fade(),
    stain(),
    fade(),
    flake(),
    crack(),
    stain_fade(),
    crack_fade(),
    fade(),
    flake(),
    crack(),
    stain(),
    crack_fade(),
    flake_stain(),
    flake(),
    crack(),
    stain(),
    fade(),
    flake_stain(),
    flake_fade(),
    crack_stain(),
    stain_fade(),
    crack_fade(),
    flake_stain(),
    crack_stain_fade(),
    flake_stain_fade(),
    stain_fade(),
    crack_fade(),
    flake_stain(),
    flake_fade(),
    flake_stain_fade(),
    crack_stain_fade(),
  ]
  @types.new_level(
    Masterworks,
    "Museum Centerpiece",
    regions,
    @types.new_budget(16, 20, 16, 36),
    88,
  )
}

///|
/// Level 19: "The Lost Vermeer" - Precise ordering with minimal budget
fn level_19() -> @types.Level {
  let regions = [
    crack_stain_fade(),
    flake_stain_fade(),
    crack_stain(),
    flake_fade(),
    p(),
    p(),
    flake_stain_fade(),
    crack_stain_fade(),
    flake_fade(),
    crack_stain(),
    p(),
    p(),
    crack_stain(),
    flake_fade(),
    crack_stain_fade(),
    flake_stain_fade(),
    crack_stain(),
    flake_fade(),
    flake_fade(),
    crack_stain(),
    flake_stain_fade(),
    crack_stain_fade(),
    flake_fade(),
    crack_stain(),
    p(),
    p(),
    crack_stain(),
    flake_fade(),
    crack_stain_fade(),
    flake_stain_fade(),
    p(),
    p(),
    flake_fade(),
    crack_stain(),
    flake_stain_fade(),
    crack_stain_fade(),
  ]
  @types.new_level(
    Masterworks,
    "The Lost Vermeer",
    regions,
    @types.new_budget(16, 20, 16, 28),
    80,
  )
}

///|
/// Level 20: "Magnum Opus" - Ultimate challenge
fn level_20() -> @types.Level {
  let regions = [
    crack_stain_fade(),
    flake_stain_fade(),
    crack_stain_fade(),
    flake_stain_fade(),
    crack_stain_fade(),
    flake_stain_fade(),
    flake_stain_fade(),
    crack_stain_fade(),
    flake_stain_fade(),
    crack_stain_fade(),
    flake_stain_fade(),
    crack_stain_fade(),
    crack_stain_fade(),
    flake_stain_fade(),
    crack_stain_fade(),
    flake_stain_fade(),
    crack_stain_fade(),
    flake_stain_fade(),
    flake_stain_fade(),
    crack_stain_fade(),
    flake_stain_fade(),
    crack_stain_fade(),
    flake_stain_fade(),
    crack_stain_fade(),
    crack_stain_fade(),
    flake_stain_fade(),
    crack_stain_fade(),
    flake_stain_fade(),
    crack_stain_fade(),
    flake_stain_fade(),
    flake_stain_fade(),
    crack_stain_fade(),
    flake_stain_fade(),
    crack_stain_fade(),
    flake_stain_fade(),
    crack_stain_fade(),
  ]
  @types.new_level(
    Masterworks,
    "Magnum Opus",
    regions,
    @types.new_budget(36, 36, 36, 36),
    120,
  )
}
