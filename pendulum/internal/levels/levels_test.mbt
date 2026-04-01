///|
test "all 25 levels are unique and have valid names" {
  let names : Array[String] = []
  for i = 0; i < @types.total_levels; i = i + 1 {
    let level = get_level(i)
    assert_true(level.name.length() > 0)
    // Check name is unique
    for j = 0; j < names.length(); j = j + 1 {
      assert_true(names[j] != level.name)
    }
    names.push(level.name)
  }
}

///|
test "all levels have valid anchor within grid bounds" {
  for i = 0; i < @types.total_levels; i = i + 1 {
    let level = get_level(i)
    assert_true(level.anchor_pos.x >= 0)
    assert_true(level.anchor_pos.x < @types.grid_cols)
    assert_true(level.anchor_pos.y >= 0)
    assert_true(level.anchor_pos.y < @types.grid_rows)
  }
}

///|
test "all levels have valid goal within grid bounds" {
  for i = 0; i < @types.total_levels; i = i + 1 {
    let level = get_level(i)
    assert_true(level.goal_pos.x >= 0)
    assert_true(level.goal_pos.x < @types.grid_cols)
    assert_true(level.goal_pos.y >= 0)
    assert_true(level.goal_pos.y < @types.grid_rows)
  }
}

///|
test "anchor and goal are at different positions" {
  for i = 0; i < @types.total_levels; i = i + 1 {
    let level = get_level(i)
    assert_true(
      level.anchor_pos.x != level.goal_pos.x ||
      level.anchor_pos.y != level.goal_pos.y,
    )
  }
}

///|
test "all levels have positive par ticks" {
  for i = 0; i < @types.total_levels; i = i + 1 {
    let level = get_level(i)
    assert_true(level.par_ticks > 0)
  }
}

///|
test "all levels have positive rope length" {
  for i = 0; i < @types.total_levels; i = i + 1 {
    let level = get_level(i)
    assert_true(level.rope_length > 0)
  }
}

///|
test "all pegs are within grid bounds" {
  for i = 0; i < @types.total_levels; i = i + 1 {
    let level = get_level(i)
    for j = 0; j < level.pegs.length(); j = j + 1 {
      let peg = level.pegs[j]
      assert_true(peg.x >= 0)
      assert_true(peg.x < @types.grid_cols)
      assert_true(peg.y >= 0)
      assert_true(peg.y < @types.grid_rows)
    }
  }
}

///|
test "all walls are within grid bounds" {
  for i = 0; i < @types.total_levels; i = i + 1 {
    let level = get_level(i)
    for j = 0; j < level.walls.length(); j = j + 1 {
      let wall = level.walls[j]
      assert_true(wall.x >= 0)
      assert_true(wall.x < @types.grid_cols)
      assert_true(wall.y >= 0)
      assert_true(wall.y < @types.grid_rows)
    }
  }
}

///|
test "all collectibles are within grid bounds" {
  for i = 0; i < @types.total_levels; i = i + 1 {
    let level = get_level(i)
    for j = 0; j < level.collectibles.length(); j = j + 1 {
      let c = level.collectibles[j]
      assert_true(c.x >= 0)
      assert_true(c.x < @types.grid_cols)
      assert_true(c.y >= 0)
      assert_true(c.y < @types.grid_rows)
    }
  }
}

///|
test "no element overlaps anchor or goal" {
  for i = 0; i < @types.total_levels; i = i + 1 {
    let level = get_level(i)
    let anc = level.anchor_pos
    let goal = level.goal_pos
    for j = 0; j < level.pegs.length(); j = j + 1 {
      let peg = level.pegs[j]
      assert_true(peg.x != anc.x || peg.y != anc.y)
      assert_true(peg.x != goal.x || peg.y != goal.y)
    }
    for j = 0; j < level.walls.length(); j = j + 1 {
      let wall = level.walls[j]
      assert_true(wall.x != anc.x || wall.y != anc.y)
      assert_true(wall.x != goal.x || wall.y != goal.y)
    }
    for j = 0; j < level.collectibles.length(); j = j + 1 {
      let c = level.collectibles[j]
      assert_true(c.x != anc.x || c.y != anc.y)
      assert_true(c.x != goal.x || c.y != goal.y)
    }
  }
}

///|
test "grid is correctly populated from level data" {
  for i = 0; i < @types.total_levels; i = i + 1 {
    let level = get_level(i)
    // Anchor cell
    assert_eq(level.grid[level.anchor_pos.y][level.anchor_pos.x], Anchor)
    // Goal cell
    assert_eq(level.grid[level.goal_pos.y][level.goal_pos.x], Goal)
    // Peg cells
    for j = 0; j < level.pegs.length(); j = j + 1 {
      assert_eq(level.grid[level.pegs[j].y][level.pegs[j].x], Peg)
    }
    // Wall cells
    for j = 0; j < level.walls.length(); j = j + 1 {
      assert_eq(level.grid[level.walls[j].y][level.walls[j].x], Wall)
    }
    // Collectible cells
    for j = 0; j < level.collectibles.length(); j = j + 1 {
      assert_eq(
        level.grid[level.collectibles[j].y][level.collectibles[j].x],
        Collectible,
      )
    }
  }
}

///|
test "tier 1 levels have correct tier tag" {
  for i = 0; i < @types.tier1_count; i = i + 1 {
    let level = get_level(i)
    assert_eq(level.tier, Swing)
  }
}

///|
test "tier 2 levels have correct tier tag" {
  for i = @types.tier1_count; i < @types.tier1_count + @types.tier2_count; i = i + 1 {
    let level = get_level(i)
    assert_eq(level.tier, Wrap)
  }
}

///|
test "tier 3 levels have correct tier tag" {
  let start = @types.tier1_count + @types.tier2_count
  for i = start; i < start + @types.tier3_count; i = i + 1 {
    let level = get_level(i)
    assert_eq(level.tier, Launch)
  }
}

///|
test "tier counts sum to total levels" {
  assert_eq(
    @types.tier1_count + @types.tier2_count + @types.tier3_count,
    @types.total_levels,
  )
}

///|
test "level ids match their index" {
  for i = 0; i < @types.total_levels; i = i + 1 {
    let level = get_level(i)
    assert_eq(level.id, i)
  }
}

///|
test "goal is reachable: not blocked by walls on all sides" {
  for i = 0; i < @types.total_levels; i = i + 1 {
    let level = get_level(i)
    let gx = level.goal_pos.x
    let gy = level.goal_pos.y
    // At least one adjacent cell must not be a wall (or goal is on boundary)
    let mut open_neighbors = 0
    let dirs : Array[@types.Vec2i] = [
      @types.vec2i(1, 0),
      @types.vec2i(-1, 0),
      @types.vec2i(0, 1),
      @types.vec2i(0, -1),
    ]
    for d = 0; d < dirs.length(); d = d + 1 {
      let nx = gx + dirs[d].x
      let ny = gy + dirs[d].y
      if nx < 0 || nx >= @types.grid_cols || ny < 0 || ny >= @types.grid_rows {
        open_neighbors = open_neighbors + 1 // boundary counts as open (can enter from outside)
      } else if level.grid[ny][nx] != Wall {
        open_neighbors = open_neighbors + 1
      }
    }
    assert_true(open_neighbors >= 1)
  }
}

///|
test "rope length allows arc to produce points" {
  for i = 0; i < @types.total_levels; i = i + 1 {
    let level = get_level(i)
    let arc = @types.compute_arc_points(level.anchor_pos, level.rope_length)
    assert_true(arc.length() > 0)
  }
}

///|
test "fallback level is level_1_1" {
  let fallback = get_level(999)
  let first = get_level(0)
  assert_eq(fallback.name, first.name)
  assert_eq(fallback.tier, first.tier)
}

///|
test "get_all_levels returns correct count" {
  let levels = get_all_levels()
  assert_eq(levels.length(), @types.total_levels)
}

///|
test "par ticks are within reasonable range" {
  // All par ticks should be between 5 and 100 ticks
  for i = 0; i < @types.total_levels; i = i + 1 {
    let level = get_level(i)
    assert_true(level.par_ticks >= 5)
    assert_true(level.par_ticks <= 100)
  }
  // Later tiers should have higher max par (more complex puzzles)
  let mut max_t1 = 0
  for i = 0; i < @types.tier1_count; i = i + 1 {
    let level = get_level(i)
    if level.par_ticks > max_t1 {
      max_t1 = level.par_ticks
    }
  }
  let mut max_t3 = 0
  let t3_start = @types.tier1_count + @types.tier2_count
  for i = t3_start; i < t3_start + @types.tier3_count; i = i + 1 {
    let level = get_level(i)
    if level.par_ticks > max_t3 {
      max_t3 = level.par_ticks
    }
  }
  assert_true(max_t3 >= max_t1)
}

///|
test "tier 1 swing levels have no pegs" {
  for i = 0; i < @types.tier1_count; i = i + 1 {
    let level = get_level(i)
    assert_eq(level.pegs.length(), 0)
  }
}

///|
test "tier 2 and 3 levels generally have pegs" {
  // At least some tier 2+ levels should have pegs
  let mut has_pegs = 0
  for i = @types.tier1_count; i < @types.total_levels; i = i + 1 {
    let level = get_level(i)
    if level.pegs.length() > 0 {
      has_pegs = has_pegs + 1
    }
  }
  assert_true(has_pegs > 0)
}
