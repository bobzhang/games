///|
/// Level 18: Stronghold
pub fn level_18() -> @types.LevelData {
  let g : Array[Array[@types.TileKind]] = []
  for _r in 0..<@types.grid_rows {
    g.push(e10())
  }
  g[0][0] = Transmitter
  g[7][9] = Receiver
  g[0][9] = Receiver
  g[7][0] = Receiver
  // Dense mountain barriers
  g[1][2] = Mountain
  g[2][2] = Mountain
  g[3][2] = Mountain
  g[1][4] = Mountain
  g[2][4] = Mountain
  g[4][5] = Mountain
  g[5][5] = Mountain
  g[6][5] = Mountain
  g[4][7] = Mountain
  g[5][7] = Mountain
  g[6][7] = Mountain
  g[7][7] = Mountain
  let e : Array[Array[Int]] = []
  for _r in 0..<@types.grid_rows {
    e.push(z10())
  }
  e[0][3] = 2
  e[3][5] = 3
  e[7][8] = 1
  {
    id: 18,
    name: "Stronghold",
    tier: 3,
    par_towers: 4,
    par_chain: 3,
    budget: 5,
    grid: g,
    elevations: e,
  }
}

///|
/// Level 19: Tight Budget
pub fn level_19() -> @types.LevelData {
  let g : Array[Array[@types.TileKind]] = []
  for _r in 0..<@types.grid_rows {
    g.push(e10())
  }
  g[0][0] = Transmitter
  g[0][9] = Receiver
  g[7][0] = Receiver
  g[7][9] = Receiver
  g[4][5] = Receiver
  g[2][3] = Mountain
  g[2][4] = Mountain
  g[3][6] = Mountain
  g[5][3] = Mountain
  g[5][4] = Mountain
  g[6][7] = Mountain
  let e : Array[Array[Int]] = []
  for _r in 0..<@types.grid_rows {
    e.push(z10())
  }
  e[4][2] = 2
  e[3][8] = 2
  e[1][5] = 1
  {
    id: 19,
    name: "Tight Budget",
    tier: 3,
    par_towers: 4,
    par_chain: 3,
    budget: 5,
    grid: g,
    elevations: e,
  }
}

///|
/// Level 20: Mountain King
pub fn level_20() -> @types.LevelData {
  let g : Array[Array[@types.TileKind]] = []
  for _r in 0..<@types.grid_rows {
    g.push(e10())
  }
  g[4][5] = Transmitter
  g[0][0] = Receiver
  g[0][9] = Receiver
  g[7][0] = Receiver
  g[7][9] = Receiver
  g[4][0] = Receiver
  // Heavy mountain coverage
  g[1][3] = Mountain
  g[2][3] = Mountain
  g[3][3] = Mountain
  g[1][7] = Mountain
  g[2][7] = Mountain
  g[3][7] = Mountain
  g[5][2] = Mountain
  g[6][2] = Mountain
  g[5][8] = Mountain
  g[6][8] = Mountain
  g[3][5] = Mountain
  g[5][5] = Mountain
  let e : Array[Array[Int]] = []
  for _r in 0..<@types.grid_rows {
    e.push(z10())
  }
  e[4][5] = 1
  e[2][5] = 3
  e[6][5] = 3
  e[4][1] = 2
  e[4][9] = 2
  {
    id: 20,
    name: "Mountain King",
    tier: 3,
    par_towers: 5,
    par_chain: 3,
    budget: 6,
    grid: g,
    elevations: e,
  }
}

///|
/// Level 21: The Gauntlet
pub fn level_21() -> @types.LevelData {
  let g : Array[Array[@types.TileKind]] = []
  for _r in 0..<@types.grid_rows {
    g.push(e10())
  }
  g[0][0] = Transmitter
  g[7][9] = Receiver
  g[0][9] = Receiver
  g[7][0] = Receiver
  g[3][5] = Receiver
  // Alternating walls
  g[1][2] = Mountain
  g[2][2] = Mountain
  g[3][2] = Mountain
  g[4][2] = Mountain
  g[3][4] = Mountain
  g[4][4] = Mountain
  g[5][4] = Mountain
  g[6][4] = Mountain
  g[1][6] = Mountain
  g[2][6] = Mountain
  g[3][6] = Mountain
  g[4][6] = Mountain
  g[5][8] = Mountain
  g[6][8] = Mountain
  let e : Array[Array[Int]] = []
  for _r in 0..<@types.grid_rows {
    e.push(z10())
  }
  e[0][3] = 2
  e[5][3] = 1
  e[7][7] = 3
  e[2][8] = 1
  {
    id: 21,
    name: "The Gauntlet",
    tier: 3,
    par_towers: 5,
    par_chain: 4,
    budget: 6,
    grid: g,
    elevations: e,
  }
}

///|
/// Level 22: Crossfire
pub fn level_22() -> @types.LevelData {
  let g : Array[Array[@types.TileKind]] = []
  for _r in 0..<@types.grid_rows {
    g.push(e10())
  }
  g[4][5] = Transmitter
  g[0][0] = Receiver
  g[0][5] = Receiver
  g[0][9] = Receiver
  g[7][0] = Receiver
  g[7][5] = Receiver
  g[7][9] = Receiver
  // Cross pattern mountains
  g[2][3] = Mountain
  g[2][7] = Mountain
  g[6][3] = Mountain
  g[6][7] = Mountain
  g[3][5] = Mountain
  g[5][5] = Mountain
  g[4][3] = Mountain
  g[4][7] = Mountain
  let e : Array[Array[Int]] = []
  for _r in 0..<@types.grid_rows {
    e.push(z10())
  }
  e[1][5] = 3
  e[7][5] = 2
  e[4][1] = 2
  e[4][9] = 2
  {
    id: 22,
    name: "Crossfire",
    tier: 3,
    par_towers: 5,
    par_chain: 3,
    budget: 6,
    grid: g,
    elevations: e,
  }
}

///|
/// Level 23: Iron Curtain
pub fn level_23() -> @types.LevelData {
  let g : Array[Array[@types.TileKind]] = []
  for _r in 0..<@types.grid_rows {
    g.push(e10())
  }
  g[0][0] = Transmitter
  g[4][9] = Receiver
  g[0][9] = Receiver
  g[7][9] = Receiver
  g[7][0] = Receiver
  // Three walls
  g[0][3] = Mountain
  g[1][3] = Mountain
  g[2][3] = Mountain
  g[3][3] = Mountain
  g[4][3] = Mountain
  g[3][5] = Mountain
  g[4][5] = Mountain
  g[5][5] = Mountain
  g[6][5] = Mountain
  g[7][5] = Mountain
  g[0][7] = Mountain
  g[1][7] = Mountain
  g[2][7] = Mountain
  g[3][7] = Mountain
  g[4][7] = Mountain
  let e : Array[Array[Int]] = []
  for _r in 0..<@types.grid_rows {
    e.push(z10())
  }
  e[5][3] = 2
  e[2][5] = 3
  e[5][8] = 2
  e[6][1] = 1
  {
    id: 23,
    name: "Iron Curtain",
    tier: 3,
    par_towers: 5,
    par_chain: 4,
    budget: 6,
    grid: g,
    elevations: e,
  }
}

///|
/// Level 24: Signal Storm
pub fn level_24() -> @types.LevelData {
  let g : Array[Array[@types.TileKind]] = []
  for _r in 0..<@types.grid_rows {
    g.push(e10())
  }
  g[4][5] = Transmitter
  g[0][0] = Receiver
  g[0][5] = Receiver
  g[0][9] = Receiver
  g[4][0] = Receiver
  g[4][9] = Receiver
  g[7][0] = Receiver
  g[7][9] = Receiver
  // Scattered mountains
  g[1][2] = Mountain
  g[2][4] = Mountain
  g[1][6] = Mountain
  g[2][8] = Mountain
  g[3][3] = Mountain
  g[3][7] = Mountain
  g[5][2] = Mountain
  g[5][8] = Mountain
  g[6][4] = Mountain
  g[6][6] = Mountain
  let e : Array[Array[Int]] = []
  for _r in 0..<@types.grid_rows {
    e.push(z10())
  }
  e[4][5] = 2
  e[2][5] = 3
  e[6][5] = 3
  e[4][2] = 1
  e[4][8] = 1
  {
    id: 24,
    name: "Signal Storm",
    tier: 3,
    par_towers: 5,
    par_chain: 3,
    budget: 6,
    grid: g,
    elevations: e,
  }
}

///|
/// Level 25: Final Beacon
pub fn level_25() -> @types.LevelData {
  let g : Array[Array[@types.TileKind]] = []
  for _r in 0..<@types.grid_rows {
    g.push(e10())
  }
  g[4][5] = Transmitter
  g[0][0] = Receiver
  g[0][5] = Receiver
  g[0][9] = Receiver
  g[4][0] = Receiver
  g[4][9] = Receiver
  g[7][0] = Receiver
  g[7][5] = Receiver
  g[7][9] = Receiver
  // Dense mountain field
  g[1][2] = Mountain
  g[1][4] = Mountain
  g[1][6] = Mountain
  g[1][8] = Mountain
  g[3][1] = Mountain
  g[3][3] = Mountain
  g[3][5] = Mountain
  g[3][7] = Mountain
  g[3][9] = Mountain
  g[5][0] = Mountain
  g[5][2] = Mountain
  g[5][4] = Mountain
  g[5][6] = Mountain
  g[5][8] = Mountain
  g[6][3] = Mountain
  g[6][7] = Mountain
  let e : Array[Array[Int]] = []
  for _r in 0..<@types.grid_rows {
    e.push(z10())
  }
  e[4][5] = 3
  e[2][3] = 2
  e[2][7] = 2
  e[6][1] = 2
  e[6][5] = 3
  e[6][9] = 2
  e[0][3] = 1
  e[7][3] = 1
  {
    id: 25,
    name: "Final Beacon",
    tier: 3,
    par_towers: 6,
    par_chain: 3,
    budget: 7,
    grid: g,
    elevations: e,
  }
}
