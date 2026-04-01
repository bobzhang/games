// Campaign level validation tests

///|
test "all 12 campaign levels load without error" {
  for i in 0..<@types.total_campaign_levels {
    let level = @levels.get_campaign_level(i)
    // Must have a non-empty name
    inspect(level.name.length() > 0, content="true")
    // Must have a non-empty description
    inspect(level.description.length() > 0, content="true")
  }
}

///|
test "campaign level dimensions match terrain array" {
  for i in 0..<@types.total_campaign_levels {
    let level = @levels.get_campaign_level(i)
    let expected = level.width * level.height
    inspect(level.terrain.length() == expected, content="true")
  }
}

///|
test "campaign level terrain values are valid" {
  // Terrain codes: 0=Plains, 1=Forest, 2=Hills, 3=Water
  for i in 0..<@types.total_campaign_levels {
    let level = @levels.get_campaign_level(i)
    for t in 0..<level.terrain.length() {
      let v = level.terrain[t]
      inspect(v >= 0 && v <= 3, content="true")
    }
  }
}

///|
test "campaign levels have player units" {
  for i in 0..<@types.total_campaign_levels {
    let level = @levels.get_campaign_level(i)
    inspect(level.player_units.length() > 0, content="true")
  }
}

///|
test "campaign levels have enemy units" {
  for i in 0..<@types.total_campaign_levels {
    let level = @levels.get_campaign_level(i)
    inspect(level.enemy_units.length() > 0, content="true")
  }
}

///|
test "campaign unit placements are within map bounds" {
  for i in 0..<@types.total_campaign_levels {
    let level = @levels.get_campaign_level(i)
    for j in 0..<level.player_units.length() {
      let (_, col, row) = level.player_units[j]
      inspect(col >= 0 && col < level.width, content="true")
      inspect(row >= 0 && row < level.height, content="true")
    }
    for j in 0..<level.enemy_units.length() {
      let (_, col, row) = level.enemy_units[j]
      inspect(col >= 0 && col < level.width, content="true")
      inspect(row >= 0 && row < level.height, content="true")
    }
  }
}

///|
test "campaign units not placed on water" {
  for i in 0..<@types.total_campaign_levels {
    let level = @levels.get_campaign_level(i)
    for j in 0..<level.player_units.length() {
      let (_, col, row) = level.player_units[j]
      let idx = row * level.width + col
      inspect(level.terrain[idx] != 3, content="true")
    }
    for j in 0..<level.enemy_units.length() {
      let (_, col, row) = level.enemy_units[j]
      let idx = row * level.width + col
      inspect(level.terrain[idx] != 3, content="true")
    }
  }
}

///|
test "campaign units have no overlapping positions" {
  for i in 0..<@types.total_campaign_levels {
    let level = @levels.get_campaign_level(i)
    let positions : Array[(Int, Int)] = []
    for j in 0..<level.player_units.length() {
      let (_, col, row) = level.player_units[j]
      positions.push((col, row))
    }
    for j in 0..<level.enemy_units.length() {
      let (_, col, row) = level.enemy_units[j]
      positions.push((col, row))
    }
    // Check for duplicates
    for a in 0..<positions.length() {
      for b = a + 1; b < positions.length(); b = b + 1 {
        let (ax, ay) = positions[a]
        let (bx, by) = positions[b]
        let same = ax == bx && ay == by
        inspect(same, content="false")
      }
    }
  }
}

///|
test "campaign capture-flag levels have valid flag positions" {
  for i in 0..<@types.total_campaign_levels {
    let level = @levels.get_campaign_level(i)
    match level.victory {
      CaptureFlag(fc, fr) => {
        // Flag must be within bounds
        inspect(fc >= 0 && fc < level.width, content="true")
        inspect(fr >= 0 && fr < level.height, content="true")
        // Flag must not be on water
        let idx = fr * level.width + fc
        inspect(level.terrain[idx] != 3, content="true")
      }
      EliminateAll => ()
    }
  }
}

///|
test "campaign victory conditions are solvable - player can reach enemies" {
  // For EliminateAll levels, verify there exists a land path between player
  // and enemy sides (no full water barrier blocking all routes)
  for i in 0..<@types.total_campaign_levels {
    let level = @levels.get_campaign_level(i)
    // Get a player start position
    let (_, pc, pr) = level.player_units[0]
    // BFS from player start to find all reachable non-water tiles
    let w = level.width
    let h = level.height
    let total = w * h
    let visited : Array[Bool] = Array::new(capacity=total)
    for _k in 0..<total {
      visited.push(false)
    }
    let queue : Array[(Int, Int)] = [(pc, pr)]
    let start_idx = pr * w + pc
    visited[start_idx] = true
    let mut qi = 0
    while qi < queue.length() {
      let (cc, cr) = queue[qi]
      qi = qi + 1
      let coord = @types.hex(cc, cr)
      let neighbors = @types.hex_neighbors(coord)
      for n in 0..<neighbors.length() {
        let nb = neighbors[n]
        if nb.col >= 0 && nb.col < w && nb.row >= 0 && nb.row < h {
          let nb_idx = nb.row * w + nb.col
          if !visited[nb_idx] && level.terrain[nb_idx] != 3 {
            visited[nb_idx] = true
            queue.push((nb.col, nb.row))
          }
        }
      }
    }
    // Check that at least one enemy position is reachable
    let mut any_reachable = false
    for j in 0..<level.enemy_units.length() {
      let (_, ec, er) = level.enemy_units[j]
      let eidx = er * w + ec
      if visited[eidx] {
        any_reachable = true
      }
    }
    inspect(any_reachable, content="true")
  }
}

///|
test "campaign level progressive difficulty - enemy count increases" {
  let level0 = @levels.get_campaign_level(0)
  let level11 = @levels.get_campaign_level(11)
  // Final level should have more or equal enemies than first level
  inspect(
    level11.enemy_units.length() >= level0.enemy_units.length(),
    content="true",
  )
}

///|
test "campaign level names are all unique" {
  let names : Array[String] = []
  for i in 0..<@types.total_campaign_levels {
    let level = @levels.get_campaign_level(i)
    names.push(level.name)
  }
  for a in 0..<names.length() {
    for b = a + 1; b < names.length(); b = b + 1 {
      let same = names[a] == names[b]
      inspect(same, content="false")
    }
  }
}

///|
test "campaign level 01 first contact" {
  let level = @levels.get_campaign_level(0)
  inspect(level.name, content="First Contact")
  inspect(level.width, content="10")
  inspect(level.height, content="8")
  inspect(level.player_units.length(), content="3")
  inspect(level.enemy_units.length(), content="2")
  inspect(level.victory, content="EliminateAll")
}

///|
test "campaign level 07 capture the flag" {
  let level = @levels.get_campaign_level(6)
  inspect(level.name, content="Capture the Flag")
  inspect(level.victory, content="CaptureFlag(9, 3)")
}

///|
test "campaign level 12 final battle" {
  let level = @levels.get_campaign_level(11)
  inspect(level.name, content="Final Battle")
  inspect(level.player_units.length(), content="8")
  inspect(level.enemy_units.length(), content="9")
  inspect(level.victory, content="CaptureFlag(9, 3)")
}

///|
test "campaign out-of-range index returns level_01" {
  let fallback = @levels.get_campaign_level(99)
  inspect(fallback.name, content="First Contact")
}
