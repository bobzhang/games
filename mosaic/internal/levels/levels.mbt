///|
fn t(
  c : @types.TileColor,
  s : @types.TileShape,
  o : @types.Orientation,
) -> @types.Tile? {
  Some(@types.new_tile(c, s, o))
}

///|
fn ts(c : @types.TileColor, s : @types.TileShape) -> @types.Tile? {
  Some(@types.new_tile(c, s, N))
}

///|
fn build_level(
  tiles : Array[@types.Tile?],
  holes : Array[@types.Vec2i],
  sym : @types.SymmetryKind,
  par : Int,
  tier : @types.Tier,
  name : String,
) -> @types.Level {
  let grid : @types.MosaicGrid = {
    width: 8,
    height: 8,
    tiles: tiles.copy(),
    holes: holes.copy(),
  }
  // Remove tiles at hole positions to create the puzzle
  for i in 0..<holes.length() {
    let h = holes[i]
    grid.tiles[@types.grid_index(h.x, h.y, 8)] = None
  }
  { grid, symmetry: sym, par_errors: par, tier, name }
}

///|
fn v(x : Int, y : Int) -> @types.Vec2i {
  @types.vec2i(x, y)
}

// ===== Tier 1: REPAIR (Mirror symmetry, 4 colors, 4-8 holes) =====

///|
fn level_01() -> @types.Level {
  // Simple Mirror Vertical - checker pattern
  let tiles : Array[@types.Tile?] = Array::make(64, None)
  for y in 0..<8 {
    for x in 0..<8 {
      let c : @types.TileColor = if (x + y) % 2 == 0 { Red } else { Blue }
      tiles[@types.grid_index(x, y, 8)] = ts(c, Square)
    }
  }
  build_level(
    tiles,
    [v(0, 0), v(7, 0), v(0, 7), v(7, 7)],
    MirrorV,
    0,
    Repair,
    "First Steps",
  )
}

///|
fn level_02() -> @types.Level {
  // Mirror Horizontal - stripe pattern
  let tiles : Array[@types.Tile?] = Array::make(64, None)
  let colors : Array[@types.TileColor] = [Red, Blue, Green, Gold]
  for y in 0..<8 {
    let c = colors[if y < 4 { y } else { 7 - y }]
    for x in 0..<8 {
      tiles[@types.grid_index(x, y, 8)] = ts(c, Square)
    }
  }
  build_level(
    tiles,
    [v(2, 5), v(3, 6), v(5, 5), v(4, 7)],
    MirrorH,
    0,
    Repair,
    "Reflections",
  )
}

///|
fn level_03() -> @types.Level {
  // Mirror Vertical with triangles
  let tiles : Array[@types.Tile?] = Array::make(64, None)
  for y in 0..<8 {
    for x in 0..<8 {
      if x < 4 {
        tiles[@types.grid_index(x, y, 8)] = t(Red, Triangle, E)
      } else {
        tiles[@types.grid_index(x, y, 8)] = t(Red, Triangle, W)
      }
    }
  }
  // Add blue diamonds on symmetry axis neighbors
  for y in 0..<8 {
    tiles[@types.grid_index(3, y, 8)] = ts(Blue, Diamond)
    tiles[@types.grid_index(4, y, 8)] = ts(Blue, Diamond)
  }
  build_level(
    tiles,
    [v(0, 2), v(7, 2), v(1, 5), v(6, 5), v(0, 6), v(7, 6)],
    MirrorV,
    1,
    Repair,
    "Arrow Mirror",
  )
}

///|
fn level_04() -> @types.Level {
  // Mirror Horizontal - cross pattern
  let tiles : Array[@types.Tile?] = Array::make(64, None)
  for y in 0..<8 {
    for x in 0..<8 {
      if x == 3 || x == 4 {
        tiles[@types.grid_index(x, y, 8)] = ts(Gold, Cross)
      } else if y == 3 || y == 4 {
        tiles[@types.grid_index(x, y, 8)] = ts(Gold, Cross)
      } else {
        tiles[@types.grid_index(x, y, 8)] = ts(Blue, Square)
      }
    }
  }
  build_level(
    tiles,
    [v(3, 5), v(4, 5), v(3, 6), v(4, 6), v(1, 5), v(6, 5)],
    MirrorH,
    1,
    Repair,
    "Golden Cross",
  )
}

///|
fn level_05() -> @types.Level {
  // Mirror Vertical - diamond frame
  let tiles : Array[@types.Tile?] = Array::make(64, None)
  for y in 0..<8 {
    for x in 0..<8 {
      let on_border = x == 0 || x == 7 || y == 0 || y == 7
      if on_border {
        tiles[@types.grid_index(x, y, 8)] = ts(Green, Diamond)
      } else {
        tiles[@types.grid_index(x, y, 8)] = ts(Red, Circle)
      }
    }
  }
  build_level(
    tiles,
    [v(1, 0), v(6, 0), v(0, 3), v(7, 3), v(1, 7), v(6, 7), v(3, 3), v(4, 3)],
    MirrorV,
    1,
    Repair,
    "Framed",
  )
}

///|
fn level_06() -> @types.Level {
  // Mirror Horizontal with arrows pointing up/down
  let tiles : Array[@types.Tile?] = Array::make(64, None)
  for y in 0..<8 {
    for x in 0..<8 {
      if y < 4 {
        tiles[@types.grid_index(x, y, 8)] = t(Blue, Arrow, N)
      } else {
        tiles[@types.grid_index(x, y, 8)] = t(Blue, Arrow, S)
      }
    }
  }
  // center row is circles
  for x in 0..<8 {
    tiles[@types.grid_index(x, 3, 8)] = ts(Gold, Circle)
    tiles[@types.grid_index(x, 4, 8)] = ts(Gold, Circle)
  }
  build_level(
    tiles,
    [v(1, 5), v(3, 6), v(5, 5), v(7, 7), v(0, 4)],
    MirrorH,
    1,
    Repair,
    "Up and Down",
  )
}

///|
fn level_07() -> @types.Level {
  // Mirror Diagonal
  let tiles : Array[@types.Tile?] = Array::make(64, None)
  for y in 0..<8 {
    for x in 0..<8 {
      if x == y {
        tiles[@types.grid_index(x, y, 8)] = ts(Gold, Diamond)
      } else if x < y {
        tiles[@types.grid_index(x, y, 8)] = t(Red, Triangle, E)
      } else {
        tiles[@types.grid_index(x, y, 8)] = t(Red, Triangle, N)
      }
    }
  }
  build_level(
    tiles,
    [v(5, 1), v(1, 5), v(6, 2), v(2, 6), v(7, 0), v(0, 7)],
    MirrorD,
    1,
    Repair,
    "Diagonal",
  )
}

///|
fn level_08() -> @types.Level {
  // Mirror Vertical - alternating columns
  let tiles : Array[@types.Tile?] = Array::make(64, None)
  let colors : Array[@types.TileColor] = [Red, Blue, Green, Gold]
  for y in 0..<8 {
    for x in 0..<8 {
      let ci = if x < 4 { x } else { 7 - x }
      tiles[@types.grid_index(x, y, 8)] = ts(colors[ci], Square)
    }
  }
  build_level(
    tiles,
    [v(0, 1), v(7, 1), v(1, 4), v(6, 4), v(2, 6), v(5, 6), v(0, 7), v(7, 7)],
    MirrorV,
    1,
    Repair,
    "Spectrum",
  )
}

// ===== Tier 2: RESTORE (Rotational symmetry, more colors, 8-12 holes) =====

///|
fn level_09() -> @types.Level {
  // Rotate2 - simple 180 degree symmetry
  let tiles : Array[@types.Tile?] = Array::make(64, None)
  for y in 0..<8 {
    for x in 0..<8 {
      if (x + y) % 2 == 0 {
        tiles[@types.grid_index(x, y, 8)] = ts(Red, Square)
      } else {
        tiles[@types.grid_index(x, y, 8)] = ts(Blue, Square)
      }
    }
  }
  // corner accents
  tiles[@types.grid_index(0, 0, 8)] = ts(Gold, Diamond)
  tiles[@types.grid_index(7, 7, 8)] = ts(Gold, Diamond)
  tiles[@types.grid_index(7, 0, 8)] = ts(Green, Diamond)
  tiles[@types.grid_index(0, 7, 8)] = ts(Green, Diamond)
  build_level(
    tiles,
    [v(0, 0), v(7, 7), v(7, 0), v(0, 7), v(1, 1), v(6, 6), v(2, 0), v(5, 7)],
    Rotate2,
    1,
    Restore,
    "Half Turn",
  )
}

///|
fn level_10() -> @types.Level {
  // Rotate2 with directional tiles
  let tiles : Array[@types.Tile?] = Array::make(64, None)
  for y in 0..<8 {
    for x in 0..<8 {
      let in_top = y < 4
      if in_top {
        tiles[@types.grid_index(x, y, 8)] = t(Purple, Arrow, N)
      } else {
        tiles[@types.grid_index(x, y, 8)] = t(Purple, Arrow, S)
      }
    }
  }
  // center cross
  for i in 0..<8 {
    tiles[@types.grid_index(i, 3, 8)] = ts(White, Circle)
    tiles[@types.grid_index(i, 4, 8)] = ts(White, Circle)
    tiles[@types.grid_index(3, i, 8)] = ts(White, Circle)
    tiles[@types.grid_index(4, i, 8)] = ts(White, Circle)
  }
  build_level(
    tiles,
    [
      v(0, 0),
      v(7, 7),
      v(1, 1),
      v(6, 6),
      v(2, 2),
      v(5, 5),
      v(0, 2),
      v(7, 5),
      v(6, 0),
      v(1, 7),
    ],
    Rotate2,
    2,
    Restore,
    "Spin Cycle",
  )
}

///|
fn level_11() -> @types.Level {
  // Rotate4 - 4-fold rotational
  let tiles : Array[@types.Tile?] = Array::make(64, None)
  for y in 0..<8 {
    for x in 0..<8 {
      tiles[@types.grid_index(x, y, 8)] = ts(Blue, Square)
    }
  }
  // 4 symmetric quadrant accents
  let accent_positions : Array[(Int, Int, @types.TileColor)] = [
    (1, 1, Red),
    (6, 1, Red),
    (1, 6, Red),
    (6, 6, Red),
    (2, 1, Green),
    (6, 2, Green),
    (5, 6, Green),
    (1, 5, Green),
    (1, 2, Gold),
    (5, 1, Gold),
    (6, 5, Gold),
    (2, 6, Gold),
  ]
  for i in 0..<accent_positions.length() {
    let (ax, ay, ac) = accent_positions[i]
    tiles[@types.grid_index(ax, ay, 8)] = ts(ac, Diamond)
  }
  build_level(
    tiles,
    [v(1, 1), v(6, 1), v(1, 6), v(6, 6), v(2, 1), v(6, 2), v(5, 6), v(1, 5)],
    Rotate4,
    2,
    Restore,
    "Pinwheel",
  )
}

///|
fn level_12() -> @types.Level {
  // Rotate2 with mixed shapes
  let tiles : Array[@types.Tile?] = Array::make(64, None)
  for y in 0..<8 {
    for x in 0..<8 {
      let dist_center = (x - 3) * (x - 3) + (y - 3) * (y - 3)
      if dist_center <= 4 {
        tiles[@types.grid_index(x, y, 8)] = ts(Gold, Circle)
      } else if dist_center <= 9 {
        tiles[@types.grid_index(x, y, 8)] = ts(Green, Diamond)
      } else {
        tiles[@types.grid_index(x, y, 8)] = ts(Blue, Square)
      }
    }
  }
  build_level(
    tiles,
    [
      v(0, 0),
      v(7, 7),
      v(1, 0),
      v(6, 7),
      v(0, 1),
      v(7, 6),
      v(2, 2),
      v(5, 5),
      v(3, 1),
      v(4, 6),
    ],
    Rotate2,
    2,
    Restore,
    "Rings",
  )
}

///|
fn level_13() -> @types.Level {
  // Rotate4 with arrows
  let tiles : Array[@types.Tile?] = Array::make(64, None)
  for y in 0..<8 {
    for x in 0..<8 {
      tiles[@types.grid_index(x, y, 8)] = ts(White, Square)
    }
  }
  // Place arrows pointing outward from center in 4-fold symmetry
  tiles[@types.grid_index(3, 1, 8)] = t(Red, Arrow, N)
  tiles[@types.grid_index(6, 3, 8)] = t(Red, Arrow, E)
  tiles[@types.grid_index(4, 6, 8)] = t(Red, Arrow, S)
  tiles[@types.grid_index(1, 4, 8)] = t(Red, Arrow, W)
  tiles[@types.grid_index(4, 1, 8)] = t(Blue, Arrow, N)
  tiles[@types.grid_index(6, 4, 8)] = t(Blue, Arrow, E)
  tiles[@types.grid_index(3, 6, 8)] = t(Blue, Arrow, S)
  tiles[@types.grid_index(1, 3, 8)] = t(Blue, Arrow, W)
  // center
  tiles[@types.grid_index(3, 3, 8)] = ts(Gold, Cross)
  tiles[@types.grid_index(4, 3, 8)] = ts(Gold, Cross)
  tiles[@types.grid_index(3, 4, 8)] = ts(Gold, Cross)
  tiles[@types.grid_index(4, 4, 8)] = ts(Gold, Cross)
  build_level(
    tiles,
    [
      v(4, 1),
      v(6, 4),
      v(3, 6),
      v(1, 3),
      v(3, 3),
      v(4, 4),
      v(3, 1),
      v(6, 3),
      v(4, 6),
      v(1, 4),
    ],
    Rotate4,
    2,
    Restore,
    "Compass",
  )
}

///|
fn level_14() -> @types.Level {
  // Rotate2 - zigzag pattern
  let tiles : Array[@types.Tile?] = Array::make(64, None)
  for y in 0..<8 {
    for x in 0..<8 {
      let wave = (x + y) % 4
      let c : @types.TileColor = match wave {
        0 => Red
        1 => Blue
        2 => Green
        _ => Purple
      }
      tiles[@types.grid_index(x, y, 8)] = ts(c, Square)
    }
  }
  build_level(
    tiles,
    [
      v(0, 0),
      v(7, 7),
      v(1, 0),
      v(6, 7),
      v(2, 1),
      v(5, 6),
      v(0, 3),
      v(7, 4),
      v(3, 2),
      v(4, 5),
      v(6, 0),
      v(1, 7),
    ],
    Rotate2,
    2,
    Restore,
    "Zigzag",
  )
}

///|
fn level_15() -> @types.Level {
  // Rotate4 - diamond ring
  let tiles : Array[@types.Tile?] = Array::make(64, None)
  for y in 0..<8 {
    for x in 0..<8 {
      let dx = if x > 3 { x - 3 } else { 3 - x }
      let dy = if y > 3 { y - 3 } else { 3 - y }
      let manhattan = dx + dy
      if manhattan <= 2 {
        tiles[@types.grid_index(x, y, 8)] = ts(Gold, Diamond)
      } else if manhattan <= 4 {
        tiles[@types.grid_index(x, y, 8)] = ts(Purple, Circle)
      } else {
        tiles[@types.grid_index(x, y, 8)] = ts(Blue, Square)
      }
    }
  }
  build_level(
    tiles,
    [
      v(3, 1),
      v(6, 3),
      v(4, 6),
      v(1, 4),
      v(3, 0),
      v(7, 3),
      v(4, 7),
      v(0, 4),
      v(2, 2),
      v(5, 2),
      v(5, 5),
      v(2, 5),
    ],
    Rotate4,
    2,
    Restore,
    "Mandala",
  )
}

///|
fn level_16() -> @types.Level {
  // Rotate2 with triangles
  let tiles : Array[@types.Tile?] = Array::make(64, None)
  for y in 0..<8 {
    for x in 0..<8 {
      if y < 4 {
        if x < 4 {
          tiles[@types.grid_index(x, y, 8)] = t(Red, Triangle, N)
        } else {
          tiles[@types.grid_index(x, y, 8)] = t(Green, Triangle, N)
        }
      } else if x < 4 {
        tiles[@types.grid_index(x, y, 8)] = t(Green, Triangle, S)
      } else {
        tiles[@types.grid_index(x, y, 8)] = t(Red, Triangle, S)
      }
    }
  }
  build_level(
    tiles,
    [
      v(0, 0),
      v(7, 7),
      v(1, 1),
      v(6, 6),
      v(5, 0),
      v(2, 7),
      v(7, 2),
      v(0, 5),
      v(3, 0),
      v(4, 7),
    ],
    Rotate2,
    2,
    Restore,
    "Bowtie",
  )
}

///|
fn level_17() -> @types.Level {
  // Rotate4 - spiral hint
  let tiles : Array[@types.Tile?] = Array::make(64, None)
  for y in 0..<8 {
    for x in 0..<8 {
      tiles[@types.grid_index(x, y, 8)] = ts(White, Square)
    }
  }
  // Spiral arms in 4-fold symmetry
  let arm : Array[(Int, Int, @types.Orientation)] = [
    (3, 0, N),
    (3, 1, N),
    (3, 2, N),
  ]
  for i in 0..<arm.length() {
    let (ax, ay, ao) = arm[i]
    tiles[@types.grid_index(ax, ay, 8)] = t(Purple, Arrow, ao)
    // 90 rotation: (x,y) -> (7-y, x) and orient +90
    tiles[@types.grid_index(7 - ay, ax, 8)] = t(
      Purple,
      Arrow,
      @types.rotate_orientation(ao, 1),
    )
    // 180 rotation
    tiles[@types.grid_index(7 - ax, 7 - ay, 8)] = t(
      Purple,
      Arrow,
      @types.rotate_orientation(ao, 2),
    )
    // 270 rotation
    tiles[@types.grid_index(ay, 7 - ax, 8)] = t(
      Purple,
      Arrow,
      @types.rotate_orientation(ao, 3),
    )
  }
  build_level(
    tiles,
    [
      v(3, 0),
      v(7, 3),
      v(4, 7),
      v(0, 4),
      v(3, 1),
      v(6, 3),
      v(4, 6),
      v(1, 4),
      v(3, 2),
      v(5, 3),
      v(4, 5),
      v(2, 4),
    ],
    Rotate4,
    3,
    Restore,
    "Spiral",
  )
}

// ===== Tier 3: MASTER (Glide reflection + all symmetries, 12-16 holes) =====

///|
fn level_18() -> @types.Level {
  // Glide reflection - shifted mirror
  let tiles : Array[@types.Tile?] = Array::make(64, None)
  for y in 0..<8 {
    for x in 0..<8 {
      let shifted = (x + 4) % 8
      if y < 4 {
        let c : @types.TileColor = if x % 2 == 0 { Red } else { Blue }
        tiles[@types.grid_index(x, y, 8)] = ts(c, Square)
        // Glide: shift by half + mirror
        let mirror_y = 7 - y
        tiles[@types.grid_index(shifted, mirror_y, 8)] = ts(c, Square)
      }
    }
  }
  build_level(
    tiles,
    [
      v(0, 0),
      v(4, 7),
      v(1, 0),
      v(5, 7),
      v(2, 1),
      v(6, 6),
      v(3, 1),
      v(7, 6),
      v(0, 2),
      v(4, 5),
      v(1, 3),
      v(5, 4),
    ],
    Glide,
    2,
    Master,
    "Shift",
  )
}

///|
fn level_19() -> @types.Level {
  // Glide with colored stripes
  let tiles : Array[@types.Tile?] = Array::make(64, None)
  let colors : Array[@types.TileColor] = [Red, Blue, Green, Gold, Purple, White]
  for y in 0..<8 {
    for x in 0..<8 {
      let ci = x % 6
      tiles[@types.grid_index(x, y, 8)] = ts(colors[ci], Square)
    }
  }
  // Apply glide: shift by 4 columns + mirror horizontally
  for y in 4..<8 {
    for x in 0..<8 {
      let src_x = (x + 4) % 8
      let src_y = 7 - y
      match tiles[@types.grid_index(src_x, src_y, 8)] {
        Some(st) => tiles[@types.grid_index(x, y, 8)] = ts(st.color, st.shape)
        None => ()
      }
    }
  }
  build_level(
    tiles,
    [
      v(0, 5),
      v(4, 2),
      v(1, 6),
      v(5, 1),
      v(2, 7),
      v(6, 0),
      v(3, 5),
      v(7, 2),
      v(0, 4),
      v(4, 3),
      v(1, 7),
      v(5, 0),
      v(6, 6),
      v(2, 1),
    ],
    Glide,
    3,
    Master,
    "Slide",
  )
}

///|
fn level_20() -> @types.Level {
  // Mixed: MirrorV with more complexity
  let tiles : Array[@types.Tile?] = Array::make(64, None)
  for y in 0..<8 {
    for x in 0..<8 {
      let dist_to_center = if x < 4 { 3 - x } else { x - 4 }
      let c : @types.TileColor = match dist_to_center {
        0 => Gold
        1 => Red
        2 => Blue
        _ => Purple
      }
      let s : @types.TileShape = if y % 2 == 0 { Diamond } else { Circle }
      tiles[@types.grid_index(x, y, 8)] = ts(c, s)
    }
  }
  build_level(
    tiles,
    [
      v(0, 0),
      v(7, 0),
      v(1, 1),
      v(6, 1),
      v(0, 3),
      v(7, 3),
      v(2, 4),
      v(5, 4),
      v(1, 5),
      v(6, 5),
      v(0, 6),
      v(7, 6),
      v(3, 7),
      v(4, 7),
    ],
    MirrorV,
    3,
    Master,
    "Symmetria",
  )
}

///|
fn level_21() -> @types.Level {
  // Rotate4 complex - many holes
  let tiles : Array[@types.Tile?] = Array::make(64, None)
  for y in 0..<8 {
    for x in 0..<8 {
      let in_ring1 = (x == 0 || x == 7) && y >= 0 && y <= 7
      let in_ring2 = (y == 0 || y == 7) && x >= 0 && x <= 7
      if in_ring1 || in_ring2 {
        tiles[@types.grid_index(x, y, 8)] = ts(Purple, Cross)
      } else {
        let dx = if x > 3 { x - 3 } else { 3 - x }
        let dy = if y > 3 { y - 3 } else { 3 - y }
        if dx + dy <= 2 {
          tiles[@types.grid_index(x, y, 8)] = ts(Gold, Diamond)
        } else {
          tiles[@types.grid_index(x, y, 8)] = ts(White, Circle)
        }
      }
    }
  }
  build_level(
    tiles,
    [
      v(0, 0),
      v(7, 0),
      v(0, 7),
      v(7, 7),
      v(3, 0),
      v(7, 3),
      v(4, 7),
      v(0, 4),
      v(2, 2),
      v(5, 2),
      v(5, 5),
      v(2, 5),
      v(3, 3),
      v(4, 4),
    ],
    Rotate4,
    3,
    Master,
    "Fortress",
  )
}

///|
fn level_22() -> @types.Level {
  // Glide with arrows
  let tiles : Array[@types.Tile?] = Array::make(64, None)
  for y in 0..<8 {
    for x in 0..<8 {
      if y < 4 {
        let c : @types.TileColor = if x % 2 == 0 { Red } else { Green }
        tiles[@types.grid_index(x, y, 8)] = t(c, Arrow, N)
      } else {
        // Glide: shift 4 + mirror H
        let src_x = (x + 4) % 8
        let c : @types.TileColor = if src_x % 2 == 0 { Red } else { Green }
        tiles[@types.grid_index(x, y, 8)] = t(c, Arrow, S)
      }
    }
  }
  build_level(
    tiles,
    [
      v(0, 0),
      v(4, 7),
      v(1, 1),
      v(5, 6),
      v(2, 0),
      v(6, 7),
      v(3, 2),
      v(7, 5),
      v(0, 3),
      v(4, 4),
      v(5, 1),
      v(1, 6),
      v(6, 0),
      v(2, 7),
      v(7, 2),
      v(3, 5),
    ],
    Glide,
    3,
    Master,
    "Wave",
  )
}

///|
fn level_23() -> @types.Level {
  // MirrorD complex
  let tiles : Array[@types.Tile?] = Array::make(64, None)
  for y in 0..<8 {
    for x in 0..<8 {
      if x == y {
        tiles[@types.grid_index(x, y, 8)] = ts(Gold, Diamond)
      } else if x < y {
        let ring = y - x
        let c : @types.TileColor = match ring % 3 {
          0 => Red
          1 => Blue
          _ => Green
        }
        tiles[@types.grid_index(x, y, 8)] = t(c, Triangle, E)
        tiles[@types.grid_index(y, x, 8)] = t(c, Triangle, N)
      }
    }
  }
  build_level(
    tiles,
    [
      v(0, 1),
      v(1, 0),
      v(0, 3),
      v(3, 0),
      v(1, 4),
      v(4, 1),
      v(2, 5),
      v(5, 2),
      v(0, 7),
      v(7, 0),
      v(3, 6),
      v(6, 3),
      v(1, 6),
      v(6, 1),
    ],
    MirrorD,
    3,
    Master,
    "Cascade",
  )
}

///|
fn level_24() -> @types.Level {
  // Rotate2 complex with many shapes
  let tiles : Array[@types.Tile?] = Array::make(64, None)
  let shapes : Array[@types.TileShape] = [
    Square,
    Triangle,
    Arrow,
    Diamond,
    Circle,
    Cross,
  ]
  for y in 0..<8 {
    for x in 0..<8 {
      let si = (x + y * 3) % 6
      let ci = (x * 2 + y) % 5
      let c = @types.index_to_tile_color(ci)
      let s = shapes[si]
      tiles[@types.grid_index(x, y, 8)] = ts(c, s)
    }
  }
  // Enforce 180 symmetry
  for y in 0..<4 {
    for x in 0..<8 {
      let mx = 7 - x
      let my = 7 - y
      match tiles[@types.grid_index(x, y, 8)] {
        Some(st) => tiles[@types.grid_index(mx, my, 8)] = ts(st.color, st.shape)
        None => ()
      }
    }
  }
  build_level(
    tiles,
    [
      v(0, 0),
      v(7, 7),
      v(1, 0),
      v(6, 7),
      v(2, 1),
      v(5, 6),
      v(3, 2),
      v(4, 5),
      v(0, 3),
      v(7, 4),
      v(6, 0),
      v(1, 7),
      v(5, 1),
      v(2, 6),
      v(7, 3),
      v(0, 4),
    ],
    Rotate2,
    3,
    Master,
    "Kaleidoscope",
  )
}

///|
fn level_25() -> @types.Level {
  // Glide complex - the finale
  let tiles : Array[@types.Tile?] = Array::make(64, None)
  let colors : Array[@types.TileColor] = [Red, Blue, Green, Gold, Purple, White]
  for y in 0..<4 {
    for x in 0..<8 {
      let ci = (x + y) % 6
      tiles[@types.grid_index(x, y, 8)] = ts(colors[ci], Diamond)
    }
  }
  // Glide: shift 4, mirror
  for y in 4..<8 {
    for x in 0..<8 {
      let src_x = (x + 4) % 8
      let src_y = 7 - y
      match tiles[@types.grid_index(src_x, src_y, 8)] {
        Some(st) => tiles[@types.grid_index(x, y, 8)] = ts(st.color, Diamond)
        None => tiles[@types.grid_index(x, y, 8)] = ts(colors[0], Diamond)
      }
    }
  }
  build_level(
    tiles,
    [
      v(0, 0),
      v(4, 7),
      v(1, 0),
      v(5, 7),
      v(2, 1),
      v(6, 6),
      v(3, 1),
      v(7, 6),
      v(0, 2),
      v(4, 5),
      v(1, 3),
      v(5, 4),
      v(6, 0),
      v(2, 7),
      v(7, 1),
      v(3, 6),
    ],
    Glide,
    3,
    Master,
    "Finale",
  )
}

///|
pub fn create_all_levels() -> Array[@types.Level] {
  [
    level_01(),
    level_02(),
    level_03(),
    level_04(),
    level_05(),
    level_06(),
    level_07(),
    level_08(),
    level_09(),
    level_10(),
    level_11(),
    level_12(),
    level_13(),
    level_14(),
    level_15(),
    level_16(),
    level_17(),
    level_18(),
    level_19(),
    level_20(),
    level_21(),
    level_22(),
    level_23(),
    level_24(),
    level_25(),
  ]
}
