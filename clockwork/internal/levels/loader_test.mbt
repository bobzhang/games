///|
test "get_level returns valid levels" {
  for i in 0..<20 {
    let def = @levels.get_level(i)
    inspect(def.id, content=i.to_string())
    inspect(def.name.length() > 0, content="true")
    inspect(def.fixed_components.length() > 0, content="true")
    inspect(def.bell_targets.length() > 0, content="true")
  }
}

///|
test "get_level out of range returns level 1" {
  let def = @levels.get_level(99)
  inspect(def.id, content="0")
}

///|
test "level_tier" {
  inspect(@levels.level_tier(0), content="Ticks")
  inspect(@levels.level_tier(6), content="Ticks")
  inspect(@levels.level_tier(7), content="Timing")
  inspect(@levels.level_tier(13), content="Timing")
  inspect(@levels.level_tier(14), content="Clockwork")
  inspect(@levels.level_tier(19), content="Clockwork")
}

///|
test "levels_in_tier" {
  let (s1, e1) = @levels.levels_in_tier(Ticks)
  inspect(s1, content="0")
  inspect(e1, content="7")
  let (s2, e2) = @levels.levels_in_tier(Timing)
  inspect(s2, content="7")
  inspect(e2, content="14")
  let (s3, e3) = @levels.levels_in_tier(Clockwork)
  inspect(s3, content="14")
  inspect(e3, content="20")
}

///|
test "tier_unlocked initial" {
  let game = @types.new_game()
  inspect(@levels.tier_unlocked(game, Ticks), content="true")
  inspect(@levels.tier_unlocked(game, Timing), content="false")
  inspect(@levels.tier_unlocked(game, Clockwork), content="false")
}

///|
test "tier_unlocked after earning stars" {
  let game = @types.new_game()
  // Earn 4 stars in tier 1
  game.level_stars[0] = 2
  game.level_stars[1] = 2
  inspect(@levels.tier_unlocked(game, Timing), content="true")
  // Earn 4 stars in tier 2
  game.level_stars[7] = 3
  game.level_stars[8] = 1
  inspect(@levels.tier_unlocked(game, Clockwork), content="true")
}

///|
test "load_level sets up game state" {
  let game = @types.new_game()
  @levels.load_level(game, 0)
  inspect(game.current_level, content="0")
  inspect(game.level_def.name, content="First Chime")
  // Should have fixed components placed
  inspect(game.components.length() > 0, content="true")
  // All fixed
  let mut all_fixed = true
  for i in 0..<game.components.length() {
    if !game.components[i].fixed {
      all_fixed = false
    }
  }
  inspect(all_fixed, content="true")
}

///|
test "load_level places components on grid" {
  let game = @types.new_game()
  @levels.load_level(game, 0)
  // Level 1: drive gear at (1,3), bell at (3,3)
  let drive_idx = @types.grid_get(game, 1, 3)
  inspect(drive_idx >= 0, content="true")
  let bell_idx = @types.grid_get(game, 3, 3)
  inspect(bell_idx >= 0, content="true")
}

///|
test "level_name" {
  inspect(@levels.level_name(0), content="First Chime")
  inspect(@levels.level_name(7), content="Push Bell")
  inspect(@levels.level_name(14), content="Grand Clock")
  inspect(@levels.level_name(19), content="Masterwork")
}

///|
test "all levels have bells" {
  for i in 0..<20 {
    let def = @levels.get_level(i)
    let mut has_bell = false
    for j in 0..<def.fixed_components.length() {
      match def.fixed_components[j].kind {
        Bell => has_bell = true
        _ => ()
      }
    }
    inspect(has_bell, content="true")
  }
}

///|
test "all levels have drive gears" {
  for i in 0..<20 {
    let def = @levels.get_level(i)
    let mut has_drive = false
    for j in 0..<def.fixed_components.length() {
      match def.fixed_components[j].kind {
        Gear(_) => has_drive = true
        _ => ()
      }
    }
    inspect(has_drive, content="true")
  }
}

///|
test "all levels have palette items" {
  for i in 0..<20 {
    let def = @levels.get_level(i)
    inspect(def.palette.available.length() > 0, content="true")
  }
}
