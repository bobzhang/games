///|
// Test: Correct sequence for Crack -> Fill -> Seal
test "crack_fill_seal_restores" {
  let region = @types.new_region([Crack])
  let applied = apply_tool(region, Fill)
  assert_true(applied)
  assert_eq(region.state, Treated)
  assert_eq(region.damage_types.length(), 0)
  let sealed_ok = apply_tool(region, Seal)
  assert_true(sealed_ok)
  assert_eq(region.state, Restored)
}

///|
// Test: Correct sequence for Stain -> Clean -> Seal
test "stain_clean_seal_restores" {
  let region = @types.new_region([Stain])
  let applied = apply_tool(region, Clean)
  assert_true(applied)
  assert_eq(region.state, Treated)
  let sealed_ok = apply_tool(region, Seal)
  assert_true(sealed_ok)
  assert_eq(region.state, Restored)
}

///|
// Test: Correct sequence for Fade -> Retouch -> Seal
test "fade_retouch_seal_restores" {
  let region = @types.new_region([Fade])
  let applied = apply_tool(region, Retouch)
  assert_true(applied)
  assert_eq(region.state, Treated)
  let sealed_ok = apply_tool(region, Seal)
  assert_true(sealed_ok)
  assert_eq(region.state, Restored)
}

///|
// Test: Correct sequence for Flake -> Fill -> Retouch -> Seal
test "flake_fill_retouch_seal_restores" {
  let region = @types.new_region([Flake])
  let applied = apply_tool(region, Fill)
  assert_true(applied)
  assert_eq(region.state, Treated)
  // After fill, flake damage removed but needs retouch
  let retouched = apply_tool(region, Retouch)
  assert_true(retouched)
  let sealed_ok = apply_tool(region, Seal)
  assert_true(sealed_ok)
  assert_eq(region.state, Restored)
}

///|
// Test: Clean on Crack worsens to Flake
test "clean_on_crack_worsens" {
  let region = @types.new_region([Crack])
  let applied = apply_tool(region, Clean)
  assert_true(applied)
  assert_eq(region.state, Worsened)
  // Crack should now be Flake
  assert_true(@types.region_has_damage(region, Flake))
  assert_false(@types.region_has_damage(region, Crack))
}

///|
// Test: Fill on Stain sets stain permanently
test "fill_on_stain_worsens" {
  let region = @types.new_region([Stain])
  let applied = apply_tool(region, Fill)
  assert_true(applied)
  assert_eq(region.state, Worsened)
  assert_true(region.stain_permanent)
}

///|
// Test: Retouch on Flake is fragile (cosmetic only)
test "retouch_on_flake_is_fragile" {
  let region = @types.new_region([Flake])
  let applied = apply_tool(region, Retouch)
  assert_true(applied)
  assert_true(region.fragile)
  // Sealing fragile region -> sealed, not restored
  let sealed_ok = apply_tool(region, Seal)
  assert_true(sealed_ok)
  assert_eq(region.state, Sealed)
}

///|
// Test: Seal on unrepaired damage seals in the damage
test "seal_on_damaged_seals_damage" {
  let region = @types.new_region([Crack])
  let applied = apply_tool(region, Seal)
  assert_true(applied)
  assert_eq(region.state, Sealed)
}

///|
// Test: Cannot apply tool to pristine region
test "cannot_apply_to_pristine" {
  let region = @types.new_region([])
  let applied = apply_tool(region, Clean)
  assert_false(applied)
}

///|
// Test: Cannot apply tool to already restored region
test "cannot_apply_to_restored" {
  let region = @types.new_region([Stain])
  let _ = apply_tool(region, Clean)
  let _ = apply_tool(region, Seal)
  assert_eq(region.state, Restored)
  let applied = apply_tool(region, Clean)
  assert_false(applied)
}

///|
// Test: Cannot apply tool to sealed region
test "cannot_apply_to_sealed" {
  let region = @types.new_region([Crack])
  let _ = apply_tool(region, Seal)
  assert_eq(region.state, Sealed)
  let applied = apply_tool(region, Fill)
  assert_false(applied)
}

///|
// Test: Crack+Stain correct order: Fill -> Clean -> Seal
test "crack_stain_fill_clean_seal" {
  let region = @types.new_region([Crack, Stain])
  // Must fill first to fix crack, then clean stain
  let filled = apply_tool(region, Fill)
  assert_true(filled)
  assert_eq(region.state, Treated)
  let cleaned = apply_tool(region, Clean)
  assert_true(cleaned)
  assert_eq(region.state, Treated)
  let sealed_ok = apply_tool(region, Seal)
  assert_true(sealed_ok)
  assert_eq(region.state, Restored)
}

///|
// Test: Crack+Stain wrong order: Clean first worsens
test "crack_stain_clean_first_worsens" {
  let region = @types.new_region([Crack, Stain])
  let cleaned = apply_tool(region, Clean)
  assert_true(cleaned)
  assert_eq(region.state, Worsened)
}
