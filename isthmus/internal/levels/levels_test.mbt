///|
test "all 20 levels load" {
  for i in 0..<20 {
    let level = @levels.get_level(i)
    inspect(
      level.heights.length() == level.grid_width * level.grid_height,
      content="true",
    )
    // All settlements within bounds
    for j in 0..<level.settlements.length() {
      let idx = level.settlements[j]
      inspect(idx >= 0 && idx < level.heights.length(), content="true")
    }
    inspect(level.max_sea_level > 0, content="true")
    inspect(level.sand_budget > 0, content="true")
    inspect(level.par_sand >= 0, content="true")
  }
}

///|
test "level tiers correct" {
  // Tier 1: levels 0-6 (Shores)
  for i in 0..<7 {
    let level = @levels.get_level(i)
    inspect(level.tier, content="Shores")
  }
  // Tier 2: levels 7-13 (Straits)
  for i in 7..<14 {
    let level = @levels.get_level(i)
    inspect(level.tier, content="Straits")
  }
  // Tier 3: levels 14-19 (Archipelago)
  for i in 14..<20 {
    let level = @levels.get_level(i)
    inspect(level.tier, content="Archipelago")
  }
}

///|
test "level_name returns non-empty" {
  for i in 0..<20 {
    let name = @levels.level_name(i)
    inspect(name.length() > 0, content="true")
  }
}

///|
test "level grid dimensions" {
  for i in 0..<20 {
    let level = @levels.get_level(i)
    inspect(level.grid_width, content="12")
    inspect(level.grid_height, content="10")
  }
}

///|
test "level settlements have positive height" {
  for i in 0..<20 {
    let level = @levels.get_level(i)
    for j in 0..<level.settlements.length() {
      let idx = level.settlements[j]
      let h = level.heights[idx]
      inspect(h > 0, content="true")
    }
  }
}

///|
test "level 1 specific values" {
  let level = @levels.get_level(0)
  inspect(level.name, content="First Steps")
  inspect(level.max_sea_level, content="3")
  inspect(level.sand_budget, content="12")
  inspect(level.settlements.length(), content="2")
}
