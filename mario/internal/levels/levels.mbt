///|
/// Returns the normalized row data for the given level index.
pub fn level_rows(index : Int) -> Array[String] {
  match index {
    0 => build_1_1()
    1 => build_1_2()
    2 => build_1_3()
    _ => build_1_4()
  }
}

///|
/// Returns the bonus room row data for a given level.
pub fn bonus_room_rows(level_index : Int) -> Array[String] {
  match level_index {
    0 => build_bonus_1()
    1 => build_bonus_2()
    2 => build_bonus_3()
    _ => build_bonus_4()
  }
}

// ── Grid helpers ────────────────────────────────────────────

///|
fn make_grid(w : Int, h : Int) -> Array[Array[Char]] {
  Array::makei(h, fn(_i) { Array::make(w, '.') })
}

///|
fn grid_to_rows(g : Array[Array[Char]]) -> Array[String] {
  let rows : Array[String] = []
  for y in 0..<g.length() {
    let buf = StringBuilder()
    for x in 0..<g[y].length() {
      buf.write_char(g[y][x])
    }
    rows.push(buf.to_string())
  }
  rows
}

///|
fn set(g : Array[Array[Char]], x : Int, y : Int, ch : Char) -> Unit {
  if y >= 0 && y < g.length() && x >= 0 && x < g[0].length() {
    g[y][x] = ch
  }
}

///|
/// Fill a horizontal run of the same character.
fn hrun(g : Array[Array[Char]], x : Int, y : Int, len : Int, ch : Char) -> Unit {
  for i in 0..<len {
    set(g, x + i, y, ch)
  }
}

///|
/// Place ground on rows 13-14 from x_start to x_end (exclusive).
fn ground(g : Array[Array[Char]], x0 : Int, x1 : Int) -> Unit {
  for x in x0..<x1 {
    set(g, x, 13, '#')
    set(g, x, 14, '#')
  }
}

///|
/// Place a pipe at column x, top at row top_y, body extends to row 12.
fn pipe(g : Array[Array[Char]], x : Int, top_y : Int) -> Unit {
  set(g, x, top_y, '[')
  set(g, x + 1, top_y, ']')
  let mut y = top_y + 1
  while y <= 12 {
    set(g, x, y, '{')
    set(g, x + 1, y, '}')
    y = y + 1
  }
}

///|
/// Place a pipe entrance (enterable with Down key) at column x.
fn pipe_entrance(g : Array[Array[Char]], x : Int, top_y : Int) -> Unit {
  set(g, x, top_y, 'E')
  set(g, x + 1, top_y, ']')
  let mut y = top_y + 1
  while y <= 12 {
    set(g, x, y, '{')
    set(g, x + 1, y, '}')
    y = y + 1
  }
}

///|
/// Place a short string of tile chars at (x, y). Spaces are skipped.
fn tiles(g : Array[Array[Char]], x : Int, y : Int, pattern : String) -> Unit {
  for i in 0..<pattern.length() {
    let ch = Int::unsafe_to_char(pattern[i].to_int())
    if ch != ' ' {
      set(g, x + i, y, ch)
    }
  }
}

///|
/// Place a castle at column x (6 wide, rows 4-14).
fn castle(g : Array[Array[Char]], x : Int) -> Unit {
  hrun(g, x, 4, 6, 'T')
  for row in 5..<=7 {
    hrun(g, x, row, 6, 'C')
  }
  hrun(g, x, 8, 6, 'C')
  set(g, x + 2, 8, 'D')
  set(g, x + 3, 8, 'D')
  for row in 9..<=12 {
    hrun(g, x, row, 6, 'C')
    set(g, x + 2, row, 'D')
    set(g, x + 3, row, 'D')
  }
}

///|
/// Place a flagpole from top_y to row 13 at column x, with flag ball at top.
fn flagpole(g : Array[Array[Char]], x : Int, top_y : Int) -> Unit {
  set(g, x, top_y, '^')
  let mut y = top_y + 1
  while y <= 13 {
    set(g, x, y, '|')
    y = y + 1
  }
}

///|
/// Place an ascending staircase from right to left, base at (x, 12), height blocks tall.
fn staircase(g : Array[Array[Char]], x : Int, height : Int) -> Unit {
  for step in 1..<=height {
    for row in 0..<step {
      set(g, x + height - step, 12 - row, '#')
    }
  }
}

///|
/// Place a horizontal run of coins at the given row.
fn coin_run(g : Array[Array[Char]], x : Int, y : Int, len : Int) -> Unit {
  for i in 0..<len {
    set(g, x + i, y, 'c')
  }
}

///|
/// Place a coin arc over a gap (parabolic coin trail).
fn coin_arc(g : Array[Array[Char]], x : Int, base_y : Int, len : Int) -> Unit {
  for i in 0..<len {
    let mid = len / 2
    let dy = if i <= mid { mid - i } else { i - mid }
    set(g, x + i, base_y - dy, 'c')
  }
}

// ── Level builders ──────────────────────────────────────────

///|
/// World 1-1: Grassland — teaches walk, jump, stomp, blocks, pipes.
fn build_1_1() -> Array[String] {
  let w = 148
  let g = make_grid(w, 15)
  // Ground with gaps
  ground(g, 0, 52)
  ground(g, 54, 92)
  ground(g, 94, w)
  // Player start
  set(g, 5, 12, 'S')
  // First ? block — teaches jumping
  set(g, 16, 8, '?')
  // Question + brick row
  tiles(g, 28, 8, "?B?B?")
  // Mushroom block + bricks
  tiles(g, 42, 8, "B M B")
  // Floating ? blocks
  tiles(g, 68, 8, "? ? ?")
  // Upper brick platform
  tiles(g, 58, 5, "BB?BB")
  // Hidden 1-UP
  set(g, 48, 4, 'L')
  // Bonus ? blocks
  tiles(g, 84, 8, "?B?B")
  // Star block (reward for exploration)
  set(g, 60, 5, '*')
  // Pipes (increasing height)
  pipe(g, 36, 10)
  pipe_entrance(g, 56, 9) // secret pipe entrance
  pipe(g, 78, 8)
  pipe(g, 96, 10)
  // Goombas
  set(g, 22, 11, 'G')
  set(g, 32, 11, 'G')
  set(g, 34, 11, 'G')
  set(g, 46, 11, 'G')
  set(g, 48, 11, 'G')
  set(g, 64, 11, 'G')
  set(g, 66, 11, 'G')
  set(g, 72, 11, 'G')
  set(g, 88, 11, 'G')
  set(g, 90, 11, 'G')
  // Koopas
  set(g, 74, 11, 'K')
  set(g, 100, 11, 'K')
  // ── Coins ──
  // Coin trail guiding path from start
  coin_run(g, 10, 12, 4)
  // Coins above first ? block
  coin_run(g, 15, 6, 3)
  // Coin arc over first gap
  coin_arc(g, 52, 10, 3)
  // Coins along upper brick platform
  coin_run(g, 58, 3, 5)
  // Coin cluster in hard-to-reach area above pipes
  coin_run(g, 79, 5, 4)
  // Coins guiding through pipe section
  coin_run(g, 97, 12, 3)
  // Hidden bonus blocks
  set(g, 70, 4, 'h')
  set(g, 102, 4, 'n')
  // ── Checkpoint ──
  set(g, 60, 12, 'F')
  // Staircase
  staircase(g, 108, 8)
  // Flagpole
  flagpole(g, 120, 3)
  // Castle
  castle(g, 126)
  grid_to_rows(g)
}

///|
/// World 1-2: Underground — brick labyrinths, coins, tighter spacing.
fn build_1_2() -> Array[String] {
  let w = 140
  let g = make_grid(w, 15)
  // Ceiling (row 1, bricks)
  hrun(g, 3, 1, w - 16, 'B')
  // Ground
  ground(g, 0, 48)
  ground(g, 50, 88)
  ground(g, 90, w)
  // Player start
  set(g, 4, 12, 'S')
  // Coin rows in ceiling gaps
  tiles(g, 14, 4, "? ? ?")
  tiles(g, 38, 4, "? ? ?")
  // Brick platforms
  tiles(g, 12, 7, "BBB")
  tiles(g, 26, 7, "BB?BB B B B")
  tiles(g, 52, 7, "BBB")
  tiles(g, 60, 7, "B?B?B")
  tiles(g, 78, 7, "BB BB BB BB")
  // Mushroom block
  set(g, 34, 8, 'M')
  // More ? blocks
  tiles(g, 70, 8, "? ? ?")
  tiles(g, 92, 4, "?")
  // Pipes
  pipe(g, 44, 10)
  pipe_entrance(g, 86, 10) // secret pipe entrance
  // Goombas
  set(g, 18, 11, 'G')
  set(g, 22, 11, 'G')
  set(g, 24, 11, 'G')
  set(g, 32, 11, 'G')
  set(g, 36, 11, 'G')
  set(g, 54, 11, 'G')
  set(g, 56, 11, 'G')
  set(g, 62, 11, 'G')
  set(g, 66, 11, 'G')
  set(g, 72, 11, 'G')
  set(g, 82, 11, 'G')
  set(g, 84, 11, 'G')
  set(g, 96, 11, 'G')
  set(g, 98, 11, 'G')
  // Koopas
  set(g, 42, 11, 'K')
  set(g, 76, 11, 'K')
  set(g, 102, 11, 'K')
  // PiranhaPlants (in pipes)
  set(g, 44, 9, 'P')
  set(g, 86, 9, 'P')
  // BuzzyBeetles (hopping enemies)
  set(g, 40, 11, 'Z')
  set(g, 68, 11, 'Z')
  set(g, 94, 11, 'Z')
  // ── Coins ──
  // Coin trail along the ground
  coin_run(g, 7, 12, 5)
  // Coins on brick platforms
  coin_run(g, 12, 5, 3)
  coin_run(g, 26, 5, 5)
  // Coin arc over gap
  coin_arc(g, 48, 10, 3)
  // Underground coin clusters (reward exploration)
  coin_run(g, 60, 5, 5)
  coin_run(g, 78, 5, 4)
  // Hidden bonus blocks
  set(g, 46, 4, 'h')
  set(g, 80, 4, 'n')
  // ── Checkpoint ──
  set(g, 58, 12, 'F')
  // Staircase
  staircase(g, 108, 6)
  // Flagpole
  flagpole(g, 118, 4)
  // Castle
  castle(g, 124)
  grid_to_rows(g)
}

///|
/// World 1-3: Athletic heights — floating platforms, precision jumping.
fn build_1_3() -> Array[String] {
  let w = 140
  let g = make_grid(w, 15)
  // Only ground at start and end
  ground(g, 0, 8)
  ground(g, 120, w)
  // Player start
  set(g, 4, 12, 'S')
  // Floating platforms
  hrun(g, 12, 11, 3, '#')
  hrun(g, 18, 10, 3, '#')
  hrun(g, 24, 11, 4, '#')
  hrun(g, 31, 9, 3, '#')
  hrun(g, 37, 10, 4, '#')
  hrun(g, 44, 8, 3, '#')
  hrun(g, 50, 10, 3, '#')
  hrun(g, 56, 6, 3, '#')
  hrun(g, 56, 11, 3, '#')
  hrun(g, 62, 8, 3, '#')
  hrun(g, 68, 10, 3, '#')
  hrun(g, 74, 7, 3, '#')
  hrun(g, 80, 9, 4, '#')
  hrun(g, 87, 10, 3, '#')
  hrun(g, 93, 8, 3, '#')
  hrun(g, 99, 10, 3, '#')
  hrun(g, 105, 7, 3, '#')
  hrun(g, 111, 9, 3, '#')
  hrun(g, 116, 11, 4, '#')
  // ? blocks as stepping stones
  set(g, 15, 8, '?')
  set(g, 40, 6, '?')
  set(g, 70, 6, '?')
  set(g, 96, 5, '?')
  // Mushroom
  set(g, 47, 5, 'M')
  // Star (hidden)
  set(g, 76, 4, '*')
  // Koopas on platforms
  set(g, 26, 10, 'K')
  set(g, 51, 9, 'K')
  set(g, 81, 8, 'K')
  set(g, 100, 9, 'K')
  // Goombas
  set(g, 38, 9, 'G')
  set(g, 63, 7, 'G')
  set(g, 88, 9, 'G')
  set(g, 112, 8, 'G')
  // BuzzyBeetles (hopping on platforms)
  set(g, 25, 10, 'Z')
  set(g, 50, 9, 'Z')
  set(g, 80, 8, 'Z')
  set(g, 99, 9, 'Z')
  // ── Coins ──
  // Coin trails between platforms
  coin_run(g, 13, 9, 2)
  coin_run(g, 19, 8, 2)
  coin_run(g, 32, 7, 2)
  // Coins over the abyss (teach where to jump)
  coin_arc(g, 34, 8, 4)
  coin_arc(g, 58, 9, 4)
  coin_arc(g, 84, 8, 4)
  // High coins (reward skilled jumping)
  coin_run(g, 56, 4, 3)
  coin_run(g, 74, 4, 3)
  // Hidden bonus blocks on platforms
  set(g, 44, 5, 'h')
  set(g, 105, 4, 'n')
  // ── Checkpoint ──
  set(g, 62, 7, 'F')
  // Staircase
  staircase(g, 124, 5)
  // Flagpole
  flagpole(g, 132, 4)
  // Castle
  castle(g, 135)
  grid_to_rows(g)
}

///|
/// World 1-4: Castle — dense enemies, tricky jumps, the final challenge.
fn build_1_4() -> Array[String] {
  let w = 140
  let g = make_grid(w, 15)
  // Ceiling (row 1, solid blocks)
  hrun(g, 3, 1, w - 16, 'U')
  // Ground with gaps
  ground(g, 0, 30)
  ground(g, 32, 58)
  ground(g, 60, 82)
  ground(g, 84, w)
  // Player start
  set(g, 4, 12, 'S')
  // Solid block platforms
  tiles(g, 16, 7, "UUU")
  tiles(g, 36, 4, "UUU")
  tiles(g, 50, 7, "UUU")
  tiles(g, 64, 4, "UUU")
  tiles(g, 44, 8, "UUU")
  tiles(g, 72, 7, "UUU")
  tiles(g, 58, 10, "UU")
  tiles(g, 88, 7, "UUU")
  tiles(g, 96, 4, "UUU")
  tiles(g, 100, 8, "UUU")
  // Pipes
  pipe_entrance(g, 76, 10) // secret pipe entrance
  pipe(g, 106, 10)
  // ? blocks (sparse, rewarding)
  set(g, 18, 8, '?')
  set(g, 52, 8, '?')
  set(g, 90, 4, 'M')
  set(g, 48, 4, '?')
  // Dense enemies
  set(g, 14, 11, 'G')
  set(g, 16, 11, 'G')
  set(g, 20, 11, 'K')
  set(g, 26, 11, 'G')
  set(g, 28, 11, 'G')
  set(g, 34, 11, 'G')
  set(g, 36, 11, 'G')
  set(g, 38, 11, 'K')
  set(g, 42, 11, 'G')
  set(g, 46, 11, 'G')
  set(g, 48, 11, 'K')
  set(g, 54, 11, 'G')
  set(g, 56, 11, 'G')
  set(g, 62, 11, 'G')
  set(g, 64, 11, 'G')
  set(g, 68, 11, 'K')
  set(g, 72, 11, 'G')
  set(g, 74, 11, 'G')
  set(g, 86, 11, 'G')
  set(g, 88, 11, 'K')
  set(g, 92, 11, 'G')
  set(g, 94, 11, 'G')
  set(g, 98, 11, 'K')
  set(g, 104, 11, 'G')
  // PiranhaPlants (in pipes)
  set(g, 76, 9, 'P')
  set(g, 106, 9, 'P')
  // Firebars (rotating hazards)
  set(g, 24, 12, 'R')
  set(g, 44, 7, 'R')
  set(g, 66, 12, 'R')
  // BowserLite (boss at the end)
  set(g, 116, 12, 'W')
  // ── Collapsing bridge before Bowser ──
  // Bridge spans columns 109-115 at row 12, over a gap
  // First clear existing ground tiles in that range at rows 12-13
  for bx in 109..<=115 {
    set(g, bx, 13, '.')
    set(g, bx, 14, '.')
  }
  // Place bridge tiles at row 12
  hrun(g, 109, 12, 7, 'b')
  // ── Coins ──
  // Sparse coins in the castle (more valuable since dangerous)
  coin_run(g, 36, 2, 3)
  coin_run(g, 64, 2, 3)
  coin_run(g, 96, 2, 3)
  // Coins over gaps
  coin_arc(g, 30, 10, 3)
  coin_arc(g, 58, 8, 3)
  coin_arc(g, 82, 10, 3)
  // Hidden bonus blocks
  set(g, 40, 4, 'h')
  set(g, 70, 4, 'n')
  // ── Checkpoint ──
  set(g, 54, 12, 'F')
  // Staircase
  staircase(g, 112, 6)
  // Flagpole
  flagpole(g, 122, 3)
  // Castle
  castle(g, 128)
  grid_to_rows(g)
}

// ── Bonus rooms ──────────────────────────────────────────

///|
/// Bonus room for level 1-1: small coin-filled underground room.
fn build_bonus_1() -> Array[String] {
  let w = 20
  let g = make_grid(w, 15)
  // Ceiling
  hrun(g, 0, 0, w, '#')
  hrun(g, 0, 1, w, 'B')
  // Ground
  ground(g, 0, w)
  // Walls
  for y in 2..<=12 {
    set(g, 0, y, '#')
    set(g, w - 1, y, '#')
  }
  // Player spawn in bonus room
  set(g, 2, 12, 'S')
  // Lots of coins
  coin_run(g, 3, 10, 14)
  coin_run(g, 3, 8, 14)
  coin_run(g, 5, 6, 10)
  coin_run(g, 7, 4, 6)
  // Exit pipe on the right
  pipe(g, w - 4, 10)
  set(g, w - 4, 10, 'E')
  grid_to_rows(g)
}

///|
/// Bonus room for level 1-2: Star power bonus — hidden star block + scattered coins.
fn build_bonus_2() -> Array[String] {
  let w = 22
  let g = make_grid(w, 15)
  hrun(g, 0, 0, w, '#')
  hrun(g, 0, 1, w, 'B')
  ground(g, 0, w)
  for y in 2..<=12 {
    set(g, 0, y, '#')
    set(g, w - 1, y, '#')
  }
  set(g, 2, 12, 'S')
  // Star block (hidden among bricks)
  tiles(g, 8, 5, "B*B")
  tiles(g, 7, 8, "B?B?B")
  // Coin clusters at different heights
  coin_run(g, 3, 11, 6)
  coin_run(g, 12, 11, 6)
  coin_run(g, 5, 8, 3)
  coin_run(g, 13, 8, 3)
  coin_run(g, 7, 3, 7)
  // Platforms to reach coins and star
  hrun(g, 4, 10, 3, '#')
  hrun(g, 14, 10, 3, '#')
  hrun(g, 6, 7, 2, '#')
  hrun(g, 13, 7, 2, '#')
  // Exit pipe
  pipe(g, w - 4, 10)
  set(g, w - 4, 10, 'E')
  grid_to_rows(g)
}

///|
/// Bonus room for level 1-3: Sky coin heaven — vertical room with coins going up.
fn build_bonus_3() -> Array[String] {
  let w = 18
  let g = make_grid(w, 15)
  // Walls only, no ceiling (open sky feel)
  for y in 0..<=14 {
    set(g, 0, y, '#')
    set(g, w - 1, y, '#')
  }
  // Ground
  ground(g, 0, w)
  set(g, 2, 12, 'S')
  // Ascending platforms with coins — zigzag pattern
  hrun(g, 2, 11, 3, '#')
  coin_run(g, 3, 10, 2)
  hrun(g, 12, 10, 3, '#')
  coin_run(g, 13, 9, 2)
  hrun(g, 5, 9, 3, '#')
  coin_run(g, 6, 8, 2)
  hrun(g, 10, 8, 3, '#')
  coin_run(g, 11, 7, 2)
  hrun(g, 3, 7, 3, '#')
  coin_run(g, 4, 6, 2)
  hrun(g, 11, 6, 3, '#')
  coin_run(g, 12, 5, 2)
  hrun(g, 5, 5, 3, '#')
  coin_run(g, 6, 4, 2)
  hrun(g, 9, 4, 3, '#')
  coin_run(g, 10, 3, 2)
  // Reward at the top
  set(g, 7, 3, 'M')
  coin_run(g, 6, 2, 5)
  // Exit pipe at top-right
  hrun(g, 14, 3, 2, '#')
  hrun(g, 14, 4, 2, '#')
  pipe(g, 14, 2)
  set(g, 14, 2, 'E')
  grid_to_rows(g)
}

///|
/// Bonus room for level 1-4: Fire flower + coin stash (reward room before boss).
fn build_bonus_4() -> Array[String] {
  let w = 24
  let g = make_grid(w, 15)
  hrun(g, 0, 0, w, '#')
  hrun(g, 0, 1, w, 'U')
  ground(g, 0, w)
  for y in 2..<=12 {
    set(g, 0, y, '#')
    set(g, w - 1, y, '#')
  }
  set(g, 2, 12, 'S')
  // Central fire flower pedestal
  hrun(g, 9, 8, 5, 'U')
  set(g, 11, 7, 'M')
  // Coin arcs on each side
  coin_run(g, 3, 10, 5)
  coin_run(g, 16, 10, 5)
  coin_run(g, 4, 6, 4)
  coin_run(g, 15, 6, 4)
  coin_run(g, 6, 4, 3)
  coin_run(g, 14, 4, 3)
  // 1-UP hidden in the corner
  set(g, 2, 3, '1')
  // Large coin collection at floor level
  coin_run(g, 3, 12, 18)
  // Exit pipe
  pipe(g, w - 4, 10)
  set(g, w - 4, 10, 'E')
  grid_to_rows(g)
}
