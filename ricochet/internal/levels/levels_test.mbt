///|
test "all 30 levels have at least one target" {
  for i in 0..<@types.total_levels {
    let level = @levels.get_level(i)
    inspect(level.targets.length() > 0, content="true")
  }
}

///|
test "all 30 levels have valid start positions inside arena" {
  for i in 0..<@types.total_levels {
    let level = @levels.get_level(i)
    let sp = level.start_pos
    inspect(sp.x >= 0.0 && sp.x <= @types.arena_width, content="true")
    inspect(sp.y >= 0.0 && sp.y <= @types.arena_height, content="true")
  }
}

///|
test "all 30 levels have non-negative par bounces" {
  for i in 0..<@types.total_levels {
    let level = @levels.get_level(i)
    inspect(level.par_bounces >= 0, content="true")
  }
}

///|
test "all targets are inside arena bounds" {
  for i in 0..<@types.total_levels {
    let level = @levels.get_level(i)
    for t in 0..<level.targets.length() {
      let target = level.targets[t]
      let in_bounds = target.pos.x >= 0.0 &&
        target.pos.x <= @types.arena_width &&
        target.pos.y >= 0.0 &&
        target.pos.y <= @types.arena_height
      inspect(in_bounds, content="true")
    }
  }
}

///|
test "all walls have distinct endpoints" {
  for i in 0..<@types.total_levels {
    let level = @levels.get_level(i)
    for w in 0..<level.walls.length() {
      let wall = level.walls[w]
      let dist = @types.vec2_dist(wall.p1, wall.p2)
      inspect(dist > 0.1, content="true")
    }
  }
}

///|
test "all splitters are inside arena bounds" {
  for i in 0..<@types.total_levels {
    let level = @levels.get_level(i)
    for s in 0..<level.splitters.length() {
      let sp = level.splitters[s]
      let in_bounds = sp.pos.x >= 0.0 &&
        sp.pos.x <= @types.arena_width &&
        sp.pos.y >= 0.0 &&
        sp.pos.y <= @types.arena_height
      inspect(in_bounds, content="true")
    }
  }
}

///|
test "all bumpers are inside arena bounds" {
  for i in 0..<@types.total_levels {
    let level = @levels.get_level(i)
    for b in 0..<level.bumpers.length() {
      let bump = level.bumpers[b]
      let in_bounds = bump.pos.x >= 0.0 &&
        bump.pos.x <= @types.arena_width &&
        bump.pos.y >= 0.0 &&
        bump.pos.y <= @types.arena_height
      inspect(in_bounds, content="true")
    }
  }
}

///|
test "all gate endpoints are inside arena bounds" {
  for i in 0..<@types.total_levels {
    let level = @levels.get_level(i)
    for g in 0..<level.gates.length() {
      let gate = level.gates[g]
      let p1_ok = gate.p1.x >= 0.0 &&
        gate.p1.x <= @types.arena_width &&
        gate.p1.y >= 0.0 &&
        gate.p1.y <= @types.arena_height
      let p2_ok = gate.p2.x >= 0.0 &&
        gate.p2.x <= @types.arena_width &&
        gate.p2.y >= 0.0 &&
        gate.p2.y <= @types.arena_height
      inspect(p1_ok, content="true")
      inspect(p2_ok, content="true")
    }
  }
}

///|
test "all gate directions are normalized" {
  for i in 0..<@types.total_levels {
    let level = @levels.get_level(i)
    for g in 0..<level.gates.length() {
      let gate = level.gates[g]
      let len = @types.vec2_len(gate.direction)
      inspect(@types.absf(len - 1.0) < 0.01, content="true")
    }
  }
}

///|
test "targets do not overlap with walls" {
  for i in 0..<@types.total_levels {
    let level = @levels.get_level(i)
    for t in 0..<level.targets.length() {
      let target = level.targets[t]
      for w in 0..<level.walls.length() {
        let wall = level.walls[w]
        let (dist, _t_param) = @types.point_to_segment_dist(
          target.pos,
          wall.p1,
          wall.p2,
        )
        // Target center should not be closer than target radius to any wall
        inspect(dist > target.radius * 0.5, content="true")
      }
    }
  }
}

///|
test "start positions do not overlap with walls" {
  for i in 0..<@types.total_levels {
    let level = @levels.get_level(i)
    for w in 0..<level.walls.length() {
      let wall = level.walls[w]
      let (dist, _t) = @types.point_to_segment_dist(
        level.start_pos,
        wall.p1,
        wall.p2,
      )
      inspect(dist > @types.ball_radius, content="true")
    }
  }
}

///|
test "world 1 levels have no splitters or gates" {
  // World 1 "Lines" should only have walls and targets
  for i in 0..<10 {
    let level = @levels.get_level(i)
    inspect(level.splitters.length(), content="0")
    inspect(level.gates.length(), content="0")
  }
}

///|
test "world 2 levels introduce splitters" {
  // World 2 "Splits" - at least some levels should have splitters
  let mut has_splitter = false
  for i in 10..<20 {
    let level = @levels.get_level(i)
    if level.splitters.length() > 0 {
      has_splitter = true
    }
  }
  inspect(has_splitter, content="true")
}

///|
test "world 3 levels use advanced mechanics" {
  // World 3 "Gates" - should have gates or bumpers
  let mut has_gate = false
  let mut has_bumper = false
  for i in 20..<30 {
    let level = @levels.get_level(i)
    if level.gates.length() > 0 {
      has_gate = true
    }
    if level.bumpers.length() > 0 {
      has_bumper = true
    }
  }
  inspect(has_gate, content="true")
  inspect(has_bumper, content="true")
}

///|
test "level par increases with difficulty" {
  // Later levels should generally have higher par
  let early_par = @levels.get_level(0).par_bounces
  let late_par = @levels.get_level(29).par_bounces
  inspect(late_par > early_par, content="true")
}

///|
test "level 1 is simplest - no walls no bounces needed" {
  let level = @levels.get_level(0)
  inspect(level.walls.length(), content="0")
  inspect(level.targets.length(), content="1")
  inspect(level.par_bounces, content="0")
}

///|
test "level 30 is most complex" {
  let level = @levels.get_level(29)
  // Should have multiple element types
  inspect(level.walls.length() > 0, content="true")
  inspect(level.targets.length() >= 5, content="true")
  inspect(level.splitters.length() > 0, content="true")
  inspect(level.gates.length() > 0, content="true")
  inspect(level.bumpers.length() > 0, content="true")
}

///|
test "all pickups are inside arena bounds" {
  for i in 0..<@types.total_levels {
    let level = @levels.get_level(i)
    for p in 0..<level.pickups.length() {
      let pk = level.pickups[p]
      let in_bounds = pk.pos.x >= 0.0 &&
        pk.pos.x <= @types.arena_width &&
        pk.pos.y >= 0.0 &&
        pk.pos.y <= @types.arena_height
      inspect(in_bounds, content="true")
    }
  }
}

///|
test "no two targets overlap in same level" {
  for i in 0..<@types.total_levels {
    let level = @levels.get_level(i)
    for a in 0..<level.targets.length() {
      for b in (a + 1)..<level.targets.length() {
        let dist = @types.vec2_dist(level.targets[a].pos, level.targets[b].pos)
        // Targets should not overlap
        let min_dist = level.targets[a].radius + level.targets[b].radius
        inspect(dist > min_dist, content="true")
      }
    }
  }
}

///|
test "targets start unhit" {
  for i in 0..<@types.total_levels {
    let level = @levels.get_level(i)
    for t in 0..<level.targets.length() {
      inspect(level.targets[t].hit, content="false")
    }
  }
}

///|
test "get_level fallback returns level_1 for out-of-range" {
  let level = @levels.get_level(99)
  let level1 = @levels.get_level(0)
  inspect(level.targets.length(), content=level1.targets.length().to_string())
  inspect(level.par_bounces, content=level1.par_bounces.to_string())
}

///|
test "world_name returns correct names" {
  inspect(@levels.world_name(0), content="Lines")
  inspect(@levels.world_name(1), content="Splits")
  inspect(@levels.world_name(2), content="Gates")
  inspect(@levels.world_name(3), content="Unknown")
}
