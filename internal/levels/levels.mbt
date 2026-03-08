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

// ── Grid helpers ────────────────────────────────────────────

///|
fn make_grid(w : Int, h : Int) -> Array[Array[Char]] {
  Array::makei(h, fn(_i) { Array::make(w, '.') })
}

///|
fn grid_to_rows(g : Array[Array[Char]]) -> Array[String] {
  let rows : Array[String] = []
  for y in 0..<g.length() {
    let buf = StringBuilder::new()
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
fn hrun(
  g : Array[Array[Char]],
  x : Int,
  y : Int,
  len : Int,
  ch : Char
) -> Unit {
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
/// Place a short string of tile chars at (x, y). Spaces are skipped.
fn tiles(
  g : Array[Array[Char]],
  x : Int,
  y : Int,
  pattern : String
) -> Unit {
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
  for row in 5..=7 {
    hrun(g, x, row, 6, 'C')
  }
  hrun(g, x, 8, 6, 'C')
  set(g, x + 2, 8, 'D')
  set(g, x + 3, 8, 'D')
  for row in 9..=12 {
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
  for step in 1..=height {
    for row in 0..<step {
      set(g, x + height - step, 12 - row, '#')
    }
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
  pipe(g, 36, 10) // short pipe (3 tiles)
  pipe(g, 56, 9) // medium pipe (4 tiles)
  pipe(g, 78, 8) // tall pipe (5 tiles)
  pipe(g, 96, 10) // short pipe
  // Goombas — gradually more
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
  // Coins on ground path
  tiles(g, 53, 9, "?")
  // Staircase (8 blocks tall at cols 108-115)
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
  pipe(g, 86, 10)
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
  // Floating platforms (rows 6-12, made of ground tiles)
  // Section 1: easy jumps
  hrun(g, 12, 11, 3, '#')
  hrun(g, 18, 10, 3, '#')
  hrun(g, 24, 11, 4, '#')
  hrun(g, 31, 9, 3, '#')
  // Section 2: medium jumps with enemies
  hrun(g, 37, 10, 4, '#')
  hrun(g, 44, 8, 3, '#')
  hrun(g, 50, 10, 3, '#')
  hrun(g, 56, 6, 3, '#')
  hrun(g, 56, 11, 3, '#')
  // Section 3: harder jumps
  hrun(g, 62, 8, 3, '#')
  hrun(g, 68, 10, 3, '#')
  hrun(g, 74, 7, 3, '#')
  hrun(g, 80, 9, 4, '#')
  hrun(g, 87, 10, 3, '#')
  // Section 4: final stretch
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
  // Staircase (from ground level)
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
  // Solid block platforms (castle uses U instead of brick)
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
  pipe(g, 76, 10)
  pipe(g, 106, 10)
  // ? blocks (sparse, rewarding)
  set(g, 18, 8, '?')
  set(g, 52, 8, '?')
  set(g, 90, 4, 'M')
  set(g, 48, 4, '?')
  // Dense enemies — the gauntlet
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
  // Staircase
  staircase(g, 112, 6)
  // Flagpole
  flagpole(g, 122, 3)
  // Castle
  castle(g, 128)
  grid_to_rows(g)
}
