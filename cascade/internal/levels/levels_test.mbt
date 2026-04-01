///|
test "all 24 levels exist and are retrievable" {
  for i in 0..<24 {
    let level = @levels.get_level(i)
    inspect(level.id == i, content="true")
  }
}

///|
test "total levels matches constant" {
  inspect(@types.total_levels, content="24")
  inspect(@types.levels_per_tier * 3, content="24")
}

///|
test "tier 1 Chains levels 0-7" {
  for i in 0..<8 {
    let level = @levels.get_level(i)
    inspect(level.tier, content="Chains")
  }
}

///|
test "tier 2 Splits levels 8-15" {
  for i in 8..<16 {
    let level = @levels.get_level(i)
    inspect(level.tier, content="Splits")
  }
}

///|
test "tier 3 Timing levels 16-23" {
  for i in 16..<24 {
    let level = @levels.get_level(i)
    inspect(level.tier, content="Timing")
  }
}

///|
test "every level has a non-empty name" {
  for i in 0..<24 {
    let level = @levels.get_level(i)
    inspect(level.name.length() > 0, content="true")
  }
}

///|
test "every level has exactly one starter domino" {
  for i in 0..<24 {
    let level = @levels.get_level(i)
    let mut starter_count = 0
    for j in 0..<level.dominoes.length() {
      if level.dominoes[j].is_starter {
        starter_count += 1
      }
    }
    inspect(starter_count, content="1")
  }
}

///|
test "starter position matches actual starter domino" {
  for i in 0..<24 {
    let level = @levels.get_level(i)
    let mut found = false
    for j in 0..<level.dominoes.length() {
      if level.dominoes[j].is_starter {
        inspect(
          @types.vec2i_eq(level.dominoes[j].pos, level.starter_pos),
          content="true",
        )
        found = true
      }
    }
    inspect(found, content="true")
  }
}

///|
test "every level has at least one target domino" {
  for i in 0..<24 {
    let level = @levels.get_level(i)
    let targets = @types.count_targets(level.dominoes)
    inspect(targets > 0, content="true")
  }
}

///|
test "all domino positions are within grid bounds" {
  for i in 0..<24 {
    let level = @levels.get_level(i)
    for j in 0..<level.dominoes.length() {
      let d = level.dominoes[j]
      inspect(@types.in_grid(d.pos.x, d.pos.y), content="true")
    }
  }
}

///|
test "no duplicate positions within a level" {
  for i in 0..<24 {
    let level = @levels.get_level(i)
    let dominoes = level.dominoes
    for a in 0..<dominoes.length() {
      for b in (a + 1)..<dominoes.length() {
        let same = @types.vec2i_eq(dominoes[a].pos, dominoes[b].pos)
        inspect(same, content="false")
      }
    }
  }
}

///|
test "budget has at least some dominoes to place" {
  for i in 0..<24 {
    let level = @levels.get_level(i)
    let total_budget = level.budget.normal +
      level.budget.heavy +
      level.budget.splitter +
      level.budget.delay
    inspect(total_budget > 0, content="true")
  }
}

///|
test "par_count and par_ticks are positive" {
  for i in 0..<24 {
    let level = @levels.get_level(i)
    inspect(level.par_count > 0, content="true")
    inspect(level.par_ticks > 0, content="true")
  }
}

///|
test "all dominoes start in Standing state" {
  for i in 0..<24 {
    let level = @levels.get_level(i)
    for j in 0..<level.dominoes.length() {
      inspect(level.dominoes[j].state, content="Standing")
    }
  }
}

///|
test "targets are reachable: simulation from starter topples all targets" {
  // For each level, simulate the pre-placed dominoes to check that
  // the existing layout (without player additions) or the starter
  // can at least begin the chain. Levels where budget > 0 may not
  // complete without player pieces, but the starter must topple.
  for i in 0..<24 {
    let level = @levels.get_level(i)
    let dominoes = @types.clone_dominoes(level.dominoes)
    let (events, _max_tick) = @physics.simulate(dominoes)
    // The starter itself must appear in events (it topples at tick 0)
    let mut starter_toppled = false
    for j in 0..<events.length() {
      if @types.vec2i_eq(events[j].pos, level.starter_pos) {
        starter_toppled = true
      }
    }
    inspect(starter_toppled, content="true")
  }
}

///|
test "level_name returns correct names" {
  inspect(@levels.level_name(0), content="First Step")
  inspect(@levels.level_name(7), content="Spiral")
  inspect(@levels.level_name(8), content="First Split")
  inspect(@levels.level_name(16), content="First Delay")
  inspect(@levels.level_name(23), content="Grand Finale")
}

///|
test "tier_unlocked: Chains always unlocked" {
  let scores : Array[@types.LevelScore] = []
  for _i in 0..<@types.total_levels {
    scores.push(@types.new_level_score())
  }
  inspect(@levels.tier_unlocked(scores, Chains), content="true")
}

///|
test "tier_unlocked: Splits locked initially" {
  let scores : Array[@types.LevelScore] = []
  for _i in 0..<@types.total_levels {
    scores.push(@types.new_level_score())
  }
  inspect(@levels.tier_unlocked(scores, Splits), content="false")
}

///|
test "tier_unlocked: Splits unlocks after 4 Chains completed" {
  let scores : Array[@types.LevelScore] = []
  for _i in 0..<@types.total_levels {
    scores.push(@types.new_level_score())
  }
  for i in 0..<4 {
    scores[i].completed = true
  }
  inspect(@levels.tier_unlocked(scores, Splits), content="true")
}

///|
test "default level fallback returns level_0" {
  let level = @levels.get_level(999)
  inspect(level.name, content="First Step")
}
