///|
/// Helper: create a row of Empty tiles
fn e10() -> Array[@types.TileKind] {
  [Empty, Empty, Empty, Empty, Empty, Empty, Empty, Empty, Empty, Empty]
}

///|
/// Helper: create a row of zero elevations
fn z10() -> Array[Int] {
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
}

///|
/// Level 1: First Signal - simple horizontal relay
pub fn level_01() -> @types.LevelData {
  let g : Array[Array[@types.TileKind]] = []
  for _r in 0..<@types.grid_rows {
    g.push(e10())
  }
  g[3][1] = Transmitter
  g[3][8] = Receiver
  let e : Array[Array[Int]] = []
  for _r in 0..<@types.grid_rows {
    e.push(z10())
  }
  {
    id: 1,
    name: "First Signal",
    tier: 1,
    par_towers: 2,
    par_chain: 2,
    budget: 4,
    grid: g,
    elevations: e,
  }
}

///|
/// Level 2: Two Ways - signal must reach two receivers
pub fn level_02() -> @types.LevelData {
  let g : Array[Array[@types.TileKind]] = []
  for _r in 0..<@types.grid_rows {
    g.push(e10())
  }
  g[4][0] = Transmitter
  g[1][5] = Receiver
  g[7][5] = Receiver
  let e : Array[Array[Int]] = []
  for _r in 0..<@types.grid_rows {
    e.push(z10())
  }
  {
    id: 2,
    name: "Two Ways",
    tier: 1,
    par_towers: 2,
    par_chain: 2,
    budget: 4,
    grid: g,
    elevations: e,
  }
}

///|
/// Level 3: Corner to Corner
pub fn level_03() -> @types.LevelData {
  let g : Array[Array[@types.TileKind]] = []
  for _r in 0..<@types.grid_rows {
    g.push(e10())
  }
  g[0][0] = Transmitter
  g[7][9] = Receiver
  let e : Array[Array[Int]] = []
  for _r in 0..<@types.grid_rows {
    e.push(z10())
  }
  {
    id: 3,
    name: "Corner to Corner",
    tier: 1,
    par_towers: 2,
    par_chain: 2,
    budget: 5,
    grid: g,
    elevations: e,
  }
}

///|
/// Level 4: The T-Split
pub fn level_04() -> @types.LevelData {
  let g : Array[Array[@types.TileKind]] = []
  for _r in 0..<@types.grid_rows {
    g.push(e10())
  }
  g[0][5] = Transmitter
  g[4][0] = Receiver
  g[4][9] = Receiver
  g[7][5] = Receiver
  let e : Array[Array[Int]] = []
  for _r in 0..<@types.grid_rows {
    e.push(z10())
  }
  {
    id: 4,
    name: "The T-Split",
    tier: 1,
    par_towers: 3,
    par_chain: 2,
    budget: 5,
    grid: g,
    elevations: e,
  }
}

///|
/// Level 5: Zigzag
pub fn level_05() -> @types.LevelData {
  let g : Array[Array[@types.TileKind]] = []
  for _r in 0..<@types.grid_rows {
    g.push(e10())
  }
  g[0][0] = Transmitter
  g[7][0] = Receiver
  g[0][9] = Receiver
  let e : Array[Array[Int]] = []
  for _r in 0..<@types.grid_rows {
    e.push(z10())
  }
  {
    id: 5,
    name: "Zigzag",
    tier: 1,
    par_towers: 3,
    par_chain: 3,
    budget: 5,
    grid: g,
    elevations: e,
  }
}

///|
/// Level 6: Grid Coverage
pub fn level_06() -> @types.LevelData {
  let g : Array[Array[@types.TileKind]] = []
  for _r in 0..<@types.grid_rows {
    g.push(e10())
  }
  g[4][5] = Transmitter
  g[0][0] = Receiver
  g[0][9] = Receiver
  g[7][0] = Receiver
  g[7][9] = Receiver
  let e : Array[Array[Int]] = []
  for _r in 0..<@types.grid_rows {
    e.push(z10())
  }
  {
    id: 6,
    name: "Grid Coverage",
    tier: 1,
    par_towers: 4,
    par_chain: 2,
    budget: 6,
    grid: g,
    elevations: e,
  }
}

///|
/// Level 7: The Chain
pub fn level_07() -> @types.LevelData {
  let g : Array[Array[@types.TileKind]] = []
  for _r in 0..<@types.grid_rows {
    g.push(e10())
  }
  g[4][0] = Transmitter
  g[4][9] = Receiver
  g[0][9] = Receiver
  g[7][9] = Receiver
  let e : Array[Array[Int]] = []
  for _r in 0..<@types.grid_rows {
    e.push(z10())
  }
  {
    id: 7,
    name: "The Chain",
    tier: 1,
    par_towers: 3,
    par_chain: 3,
    budget: 5,
    grid: g,
    elevations: e,
  }
}

///|
/// Level 8: Full Broadcast
pub fn level_08() -> @types.LevelData {
  let g : Array[Array[@types.TileKind]] = []
  for _r in 0..<@types.grid_rows {
    g.push(e10())
  }
  g[4][5] = Transmitter
  g[0][5] = Receiver
  g[7][5] = Receiver
  g[4][0] = Receiver
  g[4][9] = Receiver
  g[0][0] = Receiver
  let e : Array[Array[Int]] = []
  for _r in 0..<@types.grid_rows {
    e.push(z10())
  }
  {
    id: 8,
    name: "Full Broadcast",
    tier: 1,
    par_towers: 4,
    par_chain: 2,
    budget: 7,
    grid: g,
    elevations: e,
  }
}
