///|
test "all 25 levels exist" {
  let levels = @levels.get_levels()
  inspect(levels.length(), content="25")
}

///|
test "tier 1 levels are Launch tier" {
  let levels = @levels.get_levels()
  for i in 0..<8 {
    inspect(levels[i].tier, content="Launch")
  }
}

///|
test "tier 2 levels are Slingshot tier" {
  let levels = @levels.get_levels()
  for i in 8..<17 {
    inspect(levels[i].tier, content="Slingshot")
  }
}

///|
test "tier 3 levels are Navigation tier" {
  let levels = @levels.get_levels()
  for i in 17..<25 {
    inspect(levels[i].tier, content="Navigation")
  }
}

///|
test "tier 1 levels have 1 planet" {
  let levels = @levels.get_levels()
  for i in 0..<8 {
    inspect(levels[i].planets.length(), content="1")
  }
}

///|
test "tier 2 levels have 2 planets" {
  let levels = @levels.get_levels()
  for i in 8..<17 {
    inspect(levels[i].planets.length(), content="2")
  }
}

///|
test "tier 3 levels have 3+ planets" {
  let levels = @levels.get_levels()
  for i in 17..<25 {
    inspect(levels[i].planets.length() >= 3, content="true")
  }
}

///|
test "all levels have valid station" {
  let levels = @levels.get_levels()
  for i in 0..<levels.length() {
    let level = levels[i]
    inspect(level.station.radius > 0.0, content="true")
    inspect(
      level.station.pos.x >= 0.0 && level.station.pos.x <= 800.0,
      content="true",
    )
    inspect(
      level.station.pos.y >= 0.0 && level.station.pos.y <= 600.0,
      content="true",
    )
  }
}

///|
test "all levels have valid launch position" {
  let levels = @levels.get_levels()
  for i in 0..<levels.length() {
    let level = levels[i]
    inspect(
      level.launch_pos.x >= 0.0 && level.launch_pos.x <= 800.0,
      content="true",
    )
    inspect(
      level.launch_pos.y >= 0.0 && level.launch_pos.y <= 600.0,
      content="true",
    )
  }
}

///|
test "all levels have positive par_ticks" {
  let levels = @levels.get_levels()
  for i in 0..<levels.length() {
    inspect(levels[i].par_ticks > 0, content="true")
  }
}

///|
test "all levels have at least 1 waypoint" {
  let levels = @levels.get_levels()
  for i in 0..<levels.length() {
    inspect(levels[i].waypoints.length() >= 1, content="true")
  }
}

///|
test "level names are unique" {
  let levels = @levels.get_levels()
  for i in 0..<levels.length() {
    for j in (i + 1)..<levels.length() {
      inspect(levels[i].name == levels[j].name, content="false")
    }
  }
}
