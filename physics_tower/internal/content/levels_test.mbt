///|
test "get_levels returns 20 levels" {
  let levels = @content.get_levels()
  inspect(levels.length(), content="20")
}

///|
test "all levels have valid world_index" {
  let levels = @content.get_levels()
  let worlds = @content.get_worlds()
  for level in levels {
    let valid = level.world_index >= 0 && level.world_index < worlds.length()
    inspect(valid, content="true")
  }
}

///|
test "world 1 has 7 levels" {
  let count = @content.world_level_count(0)
  inspect(count, content="7")
}

///|
test "world 2 has 7 levels" {
  let count = @content.world_level_count(1)
  inspect(count, content="7")
}

///|
test "world 3 has 6 levels" {
  let count = @content.world_level_count(2)
  inspect(count, content="6")
}

///|
test "world_for_level returns correct world" {
  // Level 0 is in world 0
  inspect(@content.world_for_level(0), content="0")
  // Level 6 is in world 0
  inspect(@content.world_for_level(6), content="0")
  // Level 7 is in world 1
  inspect(@content.world_for_level(7), content="1")
  // Level 13 is in world 1
  inspect(@content.world_for_level(13), content="1")
  // Level 14 is in world 2
  inspect(@content.world_for_level(14), content="2")
  // Level 19 is in world 2
  inspect(@content.world_for_level(19), content="2")
}

///|
test "world unlock logic" {
  // World 0 always unlocked (0 stars required)
  inspect(@content.is_world_unlocked(0, 0), content="true")
  // World 1 needs 8 stars
  inspect(@content.is_world_unlocked(1, 7), content="false")
  inspect(@content.is_world_unlocked(1, 8), content="true")
  inspect(@content.is_world_unlocked(1, 20), content="true")
  // World 2 needs 18 stars
  inspect(@content.is_world_unlocked(2, 17), content="false")
  inspect(@content.is_world_unlocked(2, 18), content="true")
}

///|
test "worlds have valid theme colors" {
  let worlds = @content.get_worlds()
  for w in worlds {
    // Background colors should be reasonable
    inspect(w.bg_r >= 0 && w.bg_r <= 255, content="true")
    inspect(w.bg_g >= 0 && w.bg_g <= 255, content="true")
    inspect(w.bg_b >= 0 && w.bg_b <= 255, content="true")
  }
}

///|
test "world gravity modifiers are positive" {
  for i in 0..<3 {
    let gm = @content.world_gravity_mult(i)
    inspect(gm > 0.0, content="true")
  }
}

///|
test "arctic peaks has higher gravity" {
  // World 2 (Arctic) has gravity_mult 1.3
  let arctic_grav = @content.world_gravity_mult(2)
  let fortress_grav = @content.world_gravity_mult(0)
  inspect(arctic_grav > fortress_grav, content="true")
}

///|
test "desert ruins has higher wind" {
  let desert_wind = @content.world_wind_mult(1)
  let fortress_wind = @content.world_wind_mult(0)
  inspect(desert_wind > fortress_wind, content="true")
}

///|
test "arctic peaks has lower friction" {
  let arctic_fric = @content.world_friction_mult(2)
  let fortress_fric = @content.world_friction_mult(0)
  inspect(arctic_fric < fortress_fric, content="true")
}

///|
test "all levels have positive target height" {
  let levels = @content.get_levels()
  for level in levels {
    inspect(level.target_height > 0.0, content="true")
  }
}

///|
test "all levels have positive budget" {
  let levels = @content.get_levels()
  for level in levels {
    inspect(level.budget > 0, content="true")
  }
}

///|
test "all levels have available pieces" {
  let levels = @content.get_levels()
  for level in levels {
    inspect(level.available_pieces.length() > 0, content="true")
  }
}

///|
test "sandbox inventory has many pieces" {
  let inv = @content.get_sandbox_inventory()
  inspect(inv.length() > 5, content="true")
  // All sandbox items should have 99 count
  for item in inv {
    let (_, _, count) = item
    inspect(count, content="99")
  }
}

///|
test "get_worlds returns 3 worlds" {
  let worlds = @content.get_worlds()
  inspect(worlds.length(), content="3")
}

///|
test "world names are non-empty" {
  let worlds = @content.get_worlds()
  for w in worlds {
    inspect(w.name.length() > 0, content="true")
  }
}
