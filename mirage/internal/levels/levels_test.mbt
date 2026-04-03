///|
test "get_level returns valid level 0" {
  let level = @levels.get_level(0)
  inspect(level.name, content="First Steps")
  inspect(level.tier, content="Reflection")
  inspect(level.index, content="0")
  inspect(level.par_swaps, content="0")
  inspect(level.player_start_x, content="1")
  inspect(level.player_start_y, content="6")
  inspect(level.player_start_layer, content="Foreground")
}

///|
test "get_level grid sizes correct" {
  for i in 0..<20 {
    let level = @levels.get_level(i)
    inspect(level.fg.length(), content="96")
    inspect(level.bg.length(), content="96")
  }
}

///|
test "all levels have valid exit" {
  for i in 0..<20 {
    let level = @levels.get_level(i)
    let mut has_exit = false
    for j in 0..<level.fg.length() {
      if level.fg[j] == Exit {
        has_exit = true
      }
    }
    for j in 0..<level.bg.length() {
      if level.bg[j] == Exit {
        has_exit = true
      }
    }
    inspect(has_exit, content="true")
  }
}

///|
test "all levels have wall border top row" {
  for i in 0..<20 {
    let level = @levels.get_level(i)
    // Top row of foreground should be all walls
    for col in 0..<12 {
      let tile = level.fg[col]
      let is_wall : Bool = tile == Wall
      inspect(is_wall, content="true")
    }
  }
}

///|
test "all levels have wall border bottom row" {
  for i in 0..<20 {
    let level = @levels.get_level(i)
    for col in 0..<12 {
      let tile = level.fg[7 * 12 + col]
      let is_wall : Bool = tile == Wall
      inspect(is_wall, content="true")
    }
  }
}

///|
test "level tier assignments correct" {
  // Tier 1: levels 0-6
  for i in 0..<7 {
    let level = @levels.get_level(i)
    inspect(level.tier, content="Reflection")
  }
  // Tier 2: levels 7-13
  for i in 7..<14 {
    let level = @levels.get_level(i)
    inspect(level.tier, content="Overlap")
  }
  // Tier 3: levels 14-19
  for i in 14..<20 {
    let level = @levels.get_level(i)
    inspect(level.tier, content="Illusion")
  }
}

///|
test "level 1 first steps is simple" {
  let level = @levels.get_level(0)
  // Player starts at (1,6), exit somewhere accessible
  inspect(level.player_start_x, content="1")
  inspect(level.player_start_y, content="6")
  // Par is 0 - no swaps needed
  inspect(level.par_swaps, content="0")
}

///|
test "player start positions within bounds" {
  for i in 0..<20 {
    let level = @levels.get_level(i)
    inspect(
      level.player_start_x >= 0 && level.player_start_x < 12,
      content="true",
    )
    inspect(
      level.player_start_y >= 0 && level.player_start_y < 8,
      content="true",
    )
  }
}

///|
test "level names are unique" {
  let names : Array[String] = []
  for i in 0..<20 {
    let level = @levels.get_level(i)
    let mut duplicate = false
    for j in 0..<names.length() {
      if names[j] == level.name {
        duplicate = true
      }
    }
    inspect(duplicate, content="false")
    names.push(level.name)
  }
}

///|
test "par swaps increase with difficulty" {
  // Tier 1 pars should generally be lower than tier 3
  let t1_max = {
    let mut m = 0
    for i in 0..<7 {
      let level = @levels.get_level(i)
      if level.par_swaps > m {
        m = level.par_swaps
      }
    }
    m
  }
  let t3_min = {
    let mut m = 999
    for i in 14..<20 {
      let level = @levels.get_level(i)
      if level.par_swaps < m {
        m = level.par_swaps
      }
    }
    m
  }
  inspect(t3_min >= t1_max, content="true")
}
