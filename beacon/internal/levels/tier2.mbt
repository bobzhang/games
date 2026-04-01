///|
/// Level 9: Mountain Pass
pub fn level_09() -> @types.LevelData {
  let g : Array[Array[@types.TileKind]] = []
  for _r in 0..<@types.grid_rows {
    g.push(e10())
  }
  g[3][0] = Transmitter
  g[3][9] = Receiver
  // Mountain wall with gap
  g[3][4] = Mountain
  g[3][5] = Mountain
  g[2][4] = Mountain
  g[4][5] = Mountain
  let e : Array[Array[Int]] = []
  for _r in 0..<@types.grid_rows {
    e.push(z10())
  }
  e[1][3] = 2
  {
    id: 9,
    name: "Mountain Pass",
    tier: 2,
    par_towers: 2,
    par_chain: 2,
    budget: 4,
    grid: g,
    elevations: e,
  }
}

///|
/// Level 10: High Ground
pub fn level_10() -> @types.LevelData {
  let g : Array[Array[@types.TileKind]] = []
  for _r in 0..<@types.grid_rows {
    g.push(e10())
  }
  g[4][1] = Transmitter
  g[4][8] = Receiver
  g[0][8] = Receiver
  g[2][4] = Mountain
  g[3][4] = Mountain
  g[4][4] = Mountain
  g[5][4] = Mountain
  let e : Array[Array[Int]] = []
  for _r in 0..<@types.grid_rows {
    e.push(z10())
  }
  e[1][4] = 2
  e[6][5] = 1
  {
    id: 10,
    name: "High Ground",
    tier: 2,
    par_towers: 3,
    par_chain: 2,
    budget: 5,
    grid: g,
    elevations: e,
  }
}

///|
/// Level 11: Valley Relay
pub fn level_11() -> @types.LevelData {
  let g : Array[Array[@types.TileKind]] = []
  for _r in 0..<@types.grid_rows {
    g.push(e10())
  }
  g[0][0] = Transmitter
  g[7][9] = Receiver
  // Mountain ridges
  g[2][2] = Mountain
  g[2][3] = Mountain
  g[2][4] = Mountain
  g[5][5] = Mountain
  g[5][6] = Mountain
  g[5][7] = Mountain
  let e : Array[Array[Int]] = []
  for _r in 0..<@types.grid_rows {
    e.push(z10())
  }
  e[3][5] = 2
  e[4][3] = 1
  {
    id: 11,
    name: "Valley Relay",
    tier: 2,
    par_towers: 3,
    par_chain: 3,
    budget: 5,
    grid: g,
    elevations: e,
  }
}

///|
/// Level 12: Fortress Walls
pub fn level_12() -> @types.LevelData {
  let g : Array[Array[@types.TileKind]] = []
  for _r in 0..<@types.grid_rows {
    g.push(e10())
  }
  g[4][0] = Transmitter
  g[4][9] = Receiver
  // Two walls
  g[1][3] = Mountain
  g[2][3] = Mountain
  g[3][3] = Mountain
  g[4][3] = Mountain
  g[5][3] = Mountain
  g[6][3] = Mountain
  g[2][6] = Mountain
  g[3][6] = Mountain
  g[4][6] = Mountain
  g[5][6] = Mountain
  g[6][6] = Mountain
  g[7][6] = Mountain
  let e : Array[Array[Int]] = []
  for _r in 0..<@types.grid_rows {
    e.push(z10())
  }
  e[0][4] = 1
  e[7][5] = 1
  {
    id: 12,
    name: "Fortress Walls",
    tier: 2,
    par_towers: 3,
    par_chain: 3,
    budget: 5,
    grid: g,
    elevations: e,
  }
}

///|
/// Level 13: Hilltop Network
pub fn level_13() -> @types.LevelData {
  let g : Array[Array[@types.TileKind]] = []
  for _r in 0..<@types.grid_rows {
    g.push(e10())
  }
  g[0][5] = Transmitter
  g[7][0] = Receiver
  g[7][9] = Receiver
  g[0][0] = Receiver
  g[3][3] = Mountain
  g[3][7] = Mountain
  g[5][5] = Mountain
  let e : Array[Array[Int]] = []
  for _r in 0..<@types.grid_rows {
    e.push(z10())
  }
  e[2][5] = 3
  e[5][2] = 2
  e[5][8] = 2
  {
    id: 13,
    name: "Hilltop Network",
    tier: 2,
    par_towers: 3,
    par_chain: 2,
    budget: 5,
    grid: g,
    elevations: e,
  }
}

///|
/// Level 14: The Maze
pub fn level_14() -> @types.LevelData {
  let g : Array[Array[@types.TileKind]] = []
  for _r in 0..<@types.grid_rows {
    g.push(e10())
  }
  g[0][0] = Transmitter
  g[7][9] = Receiver
  g[0][9] = Receiver
  // Maze walls
  g[0][3] = Mountain
  g[1][3] = Mountain
  g[2][3] = Mountain
  g[3][3] = Mountain
  g[4][6] = Mountain
  g[5][6] = Mountain
  g[6][6] = Mountain
  g[7][6] = Mountain
  g[2][8] = Mountain
  g[6][2] = Mountain
  let e : Array[Array[Int]] = []
  for _r in 0..<@types.grid_rows {
    e.push(z10())
  }
  e[4][4] = 1
  e[1][7] = 2
  {
    id: 14,
    name: "The Maze",
    tier: 2,
    par_towers: 4,
    par_chain: 3,
    budget: 6,
    grid: g,
    elevations: e,
  }
}

///|
/// Level 15: Peak to Peak
pub fn level_15() -> @types.LevelData {
  let g : Array[Array[@types.TileKind]] = []
  for _r in 0..<@types.grid_rows {
    g.push(e10())
  }
  g[4][0] = Transmitter
  g[4][9] = Receiver
  g[0][5] = Receiver
  g[7][5] = Receiver
  g[2][3] = Mountain
  g[3][3] = Mountain
  g[5][3] = Mountain
  g[6][3] = Mountain
  g[2][7] = Mountain
  g[3][7] = Mountain
  g[5][7] = Mountain
  g[6][7] = Mountain
  let e : Array[Array[Int]] = []
  for _r in 0..<@types.grid_rows {
    e.push(z10())
  }
  e[4][5] = 3
  e[1][5] = 1
  e[6][5] = 1
  {
    id: 15,
    name: "Peak to Peak",
    tier: 2,
    par_towers: 3,
    par_chain: 2,
    budget: 5,
    grid: g,
    elevations: e,
  }
}

///|
/// Level 16: Canyon Run
pub fn level_16() -> @types.LevelData {
  let g : Array[Array[@types.TileKind]] = []
  for _r in 0..<@types.grid_rows {
    g.push(e10())
  }
  g[0][0] = Transmitter
  g[0][9] = Receiver
  g[7][0] = Receiver
  g[7][9] = Receiver
  // Central mountain block
  g[3][3] = Mountain
  g[3][4] = Mountain
  g[3][5] = Mountain
  g[3][6] = Mountain
  g[4][3] = Mountain
  g[4][4] = Mountain
  g[4][5] = Mountain
  g[4][6] = Mountain
  let e : Array[Array[Int]] = []
  for _r in 0..<@types.grid_rows {
    e.push(z10())
  }
  e[1][5] = 2
  e[6][4] = 2
  e[2][2] = 1
  {
    id: 16,
    name: "Canyon Run",
    tier: 2,
    par_towers: 4,
    par_chain: 3,
    budget: 6,
    grid: g,
    elevations: e,
  }
}

///|
/// Level 17: Elevation Master
pub fn level_17() -> @types.LevelData {
  let g : Array[Array[@types.TileKind]] = []
  for _r in 0..<@types.grid_rows {
    g.push(e10())
  }
  g[4][5] = Transmitter
  g[0][0] = Receiver
  g[0][9] = Receiver
  g[7][0] = Receiver
  g[7][9] = Receiver
  g[2][2] = Mountain
  g[2][7] = Mountain
  g[5][2] = Mountain
  g[5][7] = Mountain
  g[1][5] = Mountain
  g[6][5] = Mountain
  let e : Array[Array[Int]] = []
  for _r in 0..<@types.grid_rows {
    e.push(z10())
  }
  e[4][5] = 2
  e[0][5] = 3
  e[7][5] = 3
  e[4][0] = 2
  e[4][9] = 2
  {
    id: 17,
    name: "Elevation Master",
    tier: 2,
    par_towers: 4,
    par_chain: 2,
    budget: 6,
    grid: g,
    elevations: e,
  }
}
