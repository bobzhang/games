///|
test "all_20_levels_exist" {
  let levels = @levels.get_all_levels()
  inspect(levels.length(), content="20")
}

///|
test "all_levels_have_valid_names" {
  let levels = @levels.get_all_levels()
  for i in 0..<levels.length() {
    assert_true(levels[i].name.length() > 0)
  }
}

///|
test "all_levels_have_36_regions" {
  // 6x6 grid = 36 regions
  let levels = @levels.get_all_levels()
  for i in 0..<levels.length() {
    inspect(levels[i].artwork.regions.length(), content="36")
  }
}

///|
test "all_levels_have_valid_damage_types" {
  let levels = @levels.get_all_levels()
  for i in 0..<levels.length() {
    let art = levels[i].artwork
    for j in 0..<art.regions.length() {
      let region = art.regions[j]
      for k in 0..<region.damage_types.length() {
        // Each damage type must be one of the known types
        let dmg = region.damage_types[k]
        let valid = match dmg {
          Crack | Stain | Fade | Flake => true
        }
        assert_true(valid)
      }
    }
  }
}

///|
test "all_levels_have_positive_budgets" {
  let levels = @levels.get_all_levels()
  for i in 0..<levels.length() {
    let b = levels[i].budget
    let total = b.clean + b.fill + b.retouch + b.seal
    assert_true(total > 0)
  }
}

///|
test "all_levels_have_positive_par" {
  let levels = @levels.get_all_levels()
  for i in 0..<levels.length() {
    assert_true(levels[i].par_tools > 0)
  }
}

///|
test "tier1_levels_correct_tier" {
  // Sketches: levels 0-6
  let levels = @levels.get_all_levels()
  for i in 0..<7 {
    inspect(levels[i].tier, content="Sketches")
  }
}

///|
test "tier2_levels_correct_tier" {
  // Paintings: levels 7-13
  let levels = @levels.get_all_levels()
  for i in 7..<14 {
    inspect(levels[i].tier, content="Paintings")
  }
}

///|
test "tier3_levels_correct_tier" {
  // Masterworks: levels 14-19
  let levels = @levels.get_all_levels()
  for i in 14..<20 {
    inspect(levels[i].tier, content="Masterworks")
  }
}

///|
test "all_levels_have_at_least_one_damaged_region" {
  let levels = @levels.get_all_levels()
  for i in 0..<levels.length() {
    let art = levels[i].artwork
    let mut damaged_count = 0
    for j in 0..<art.regions.length() {
      if art.regions[j].damage_types.length() > 0 {
        damaged_count = damaged_count + 1
      }
    }
    assert_true(damaged_count > 0)
  }
}

///|
test "budget_is_meaningful_for_each_level" {
  // Each level's total tool budget must allow meaningful progress:
  // - Total budget (all tools) must be >= number of damaged regions
  //   (at minimum one tool per damaged region to make progress)
  // - Budget per category must be > 0 if that damage type appears
  let levels = @levels.get_all_levels()
  for i in 0..<levels.length() {
    let art = levels[i].artwork
    let b = levels[i].budget
    let mut damaged_regions = 0
    let mut has_crack = false
    let mut has_stain = false
    let mut has_fade = false
    let mut has_flake = false
    for j in 0..<art.regions.length() {
      let region = art.regions[j]
      if region.damage_types.length() > 0 {
        damaged_regions = damaged_regions + 1
      }
      for k in 0..<region.damage_types.length() {
        match region.damage_types[k] {
          Crack => has_crack = true
          Stain => has_stain = true
          Fade => has_fade = true
          Flake => has_flake = true
        }
      }
    }
    let total_budget = b.clean + b.fill + b.retouch + b.seal
    // Total budget must be at least the number of damaged regions
    assert_true(total_budget >= damaged_regions)
    // If damage type appears, its corresponding tool must be available
    if has_crack || has_flake {
      assert_true(b.fill > 0)
    }
    if has_stain {
      assert_true(b.clean > 0)
    }
    if has_fade {
      assert_true(b.retouch > 0)
    }
    assert_true(b.seal > 0)
  }
}

///|
test "seal_budget_is_positive" {
  // Must have seal budget available
  let levels = @levels.get_all_levels()
  for i in 0..<levels.length() {
    let b = levels[i].budget
    assert_true(b.seal > 0)
  }
}

///|
test "crack_regions_are_restorable" {
  // A crack region should be restorable: Fill -> Seal
  let region = @types.new_region([Crack])
  let _ = @restoration.apply_tool(region, Fill)
  let _ = @restoration.apply_tool(region, Seal)
  inspect(region.state, content="Restored")
}

///|
test "stain_regions_are_restorable" {
  let region = @types.new_region([Stain])
  let _ = @restoration.apply_tool(region, Clean)
  let _ = @restoration.apply_tool(region, Seal)
  inspect(region.state, content="Restored")
}

///|
test "fade_regions_are_restorable" {
  let region = @types.new_region([Fade])
  let _ = @restoration.apply_tool(region, Retouch)
  let _ = @restoration.apply_tool(region, Seal)
  inspect(region.state, content="Restored")
}

///|
test "flake_regions_are_restorable" {
  let region = @types.new_region([Flake])
  let _ = @restoration.apply_tool(region, Fill)
  let _ = @restoration.apply_tool(region, Retouch)
  let _ = @restoration.apply_tool(region, Seal)
  inspect(region.state, content="Restored")
}

///|
test "crack_stain_are_restorable" {
  // Crack+Stain: Fill -> Clean -> Seal
  let region = @types.new_region([Crack, Stain])
  let _ = @restoration.apply_tool(region, Fill)
  let _ = @restoration.apply_tool(region, Clean)
  let _ = @restoration.apply_tool(region, Seal)
  inspect(region.state, content="Restored")
}

///|
test "crack_fade_are_restorable" {
  // Crack+Fade: Fill -> Retouch -> Seal
  let region = @types.new_region([Crack, Fade])
  let _ = @restoration.apply_tool(region, Fill)
  let _ = @restoration.apply_tool(region, Retouch)
  let _ = @restoration.apply_tool(region, Seal)
  inspect(region.state, content="Restored")
}

///|
test "stain_fade_are_restorable" {
  // Stain+Fade: Clean -> Retouch -> Seal
  let region = @types.new_region([Stain, Fade])
  let _ = @restoration.apply_tool(region, Clean)
  let _ = @restoration.apply_tool(region, Retouch)
  let _ = @restoration.apply_tool(region, Seal)
  inspect(region.state, content="Restored")
}

///|
test "flake_stain_are_restorable" {
  // Flake+Stain: Fill -> Clean -> Retouch -> Seal
  let region = @types.new_region([Flake, Stain])
  let _ = @restoration.apply_tool(region, Fill)
  let _ = @restoration.apply_tool(region, Clean)
  let _ = @restoration.apply_tool(region, Retouch)
  let _ = @restoration.apply_tool(region, Seal)
  inspect(region.state, content="Restored")
}

///|
test "flake_fade_are_restorable" {
  // Flake+Fade: Fill -> Retouch -> Seal
  let region = @types.new_region([Flake, Fade])
  let _ = @restoration.apply_tool(region, Fill)
  let _ = @restoration.apply_tool(region, Retouch)
  let _ = @restoration.apply_tool(region, Seal)
  inspect(region.state, content="Restored")
}

///|
test "crack_stain_fade_are_restorable" {
  // Crack+Stain+Fade: Fill -> Clean -> Retouch -> Seal
  let region = @types.new_region([Crack, Stain, Fade])
  let _ = @restoration.apply_tool(region, Fill)
  let _ = @restoration.apply_tool(region, Clean)
  let _ = @restoration.apply_tool(region, Retouch)
  let _ = @restoration.apply_tool(region, Seal)
  inspect(region.state, content="Restored")
}

///|
test "flake_stain_fade_are_restorable" {
  // Flake+Stain+Fade: Fill -> Clean -> Retouch -> Seal
  let region = @types.new_region([Flake, Stain, Fade])
  let _ = @restoration.apply_tool(region, Fill)
  let _ = @restoration.apply_tool(region, Clean)
  let _ = @restoration.apply_tool(region, Retouch)
  let _ = @restoration.apply_tool(region, Seal)
  inspect(region.state, content="Restored")
}

///|
test "get_level_by_index" {
  let level = @levels.get_level(0)
  inspect(level.name, content="First Cracks")
  let level19 = @levels.get_level(19)
  inspect(level19.name, content="Magnum Opus")
}

///|
test "levels_regions_start_pristine_or_damaged" {
  // All regions must start as Pristine or Damaged, not Treated/Restored/etc
  let levels = @levels.get_all_levels()
  for i in 0..<levels.length() {
    let art = levels[i].artwork
    for j in 0..<art.regions.length() {
      let region = art.regions[j]
      let valid = match region.state {
        Pristine | Damaged => true
        _ => false
      }
      assert_true(valid)
    }
  }
}

///|
test "no_duplicate_damage_in_region" {
  // A region should not have the same damage type listed twice
  let levels = @levels.get_all_levels()
  for i in 0..<levels.length() {
    let art = levels[i].artwork
    for j in 0..<art.regions.length() {
      let region = art.regions[j]
      for k in 0..<region.damage_types.length() {
        for m in (k + 1)..<region.damage_types.length() {
          assert_false(region.damage_types[k] == region.damage_types[m])
        }
      }
    }
  }
}
