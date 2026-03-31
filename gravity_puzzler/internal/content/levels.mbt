///|
pub fn parse_level(
  data : String,
  world : Int,
  level_num : Int,
  name : String,
  par_moves : Int
) -> @types.Level {
  let rows = split_lines(data)
  let height = rows.length()
  let mut width = 0
  for i in 0..<height {
    let len = rows[i].length()
    if len > width {
      width = len
    }
  }
  let tiles : Array[@types.TileKind] = Array::make(width * height, Empty)
  let entities : Array[@types.Entity] = []
  let mut next_id = 0
  let mut gems_total = 0
  for y in 0..<height {
    let row = rows[y]
    for x in 0..<row.length() {
      let ch = Int::unsafe_to_char(row[x].to_int())
      let idx = y * width + x
      match ch {
        '#' => tiles[idx] = Wall
        'E' => tiles[idx] = Exit
        'S' => tiles[idx] = Spike
        'I' => tiles[idx] = Ice
        'C' => tiles[idx] = Crumble
        '1' => tiles[idx] = Portal(1)
        '2' => tiles[idx] = Portal(2)
        '3' => tiles[idx] = Portal(3)
        'W' => tiles[idx] = Switch(1)
        'X' => tiles[idx] = Switch(2)
        'D' => tiles[idx] = Gate(1)
        'F' => tiles[idx] = Gate(2)
        '<' => tiles[idx] = Conveyor(Left)
        '>' => tiles[idx] = Conveyor(Right)
        '^' => tiles[idx] = Conveyor(Up)
        'v' => tiles[idx] = Conveyor(Down)
        'P' => {
          entities.push(@types.Entity::new(next_id, Player, x, y))
          next_id = next_id + 1
        }
        'B' => {
          entities.push(@types.Entity::new(next_id, Box, x, y))
          next_id = next_id + 1
        }
        'R' => {
          entities.push(@types.Entity::new(next_id, Boulder, x, y))
          next_id = next_id + 1
        }
        'K' => {
          entities.push(@types.Entity::new(next_id, Key, x, y))
          next_id = next_id + 1
        }
        'G' => {
          entities.push(@types.Entity::new(next_id, Gem, x, y))
          next_id = next_id + 1
          gems_total = gems_total + 1
        }
        _ => ()
      }
    }
  }
  {
    width,
    height,
    tiles,
    entities,
    gravity: Down,
    moves: 0,
    gems_collected: 0,
    gems_total,
    keys_collected: 0,
    par_moves,
    world,
    level_num,
    name,
    completed: false,
    player_dead: false,
  }
}

///|
fn split_lines(s : String) -> Array[String] {
  let lines : Array[String] = []
  let buf = StringBuilder::new()
  for i in 0..<s.length() {
    let b = s[i]
    let ch = Int::unsafe_to_char(b.to_int())
    if ch == '\n' {
      lines.push(buf.to_string())
      buf.reset()
    } else if ch == '\r' {
      // skip carriage return
      ()
    } else {
      buf.write_char(ch)
    }
  }
  let last = buf.to_string()
  if last.length() > 0 {
    lines.push(last)
  }
  lines
}

///|
pub fn get_level(world : Int, level : Int) -> @types.Level {
  let index = world * @types.levels_per_world + level
  match index {
    0 => w1_l01()
    1 => w1_l02()
    2 => w1_l03()
    3 => w1_l04()
    4 => w1_l05()
    5 => w1_l06()
    6 => w1_l07()
    7 => w1_l08()
    8 => w1_l09()
    9 => w1_l10()
    10 => w2_l01()
    11 => w2_l02()
    12 => w2_l03()
    13 => w2_l04()
    14 => w2_l05()
    15 => w2_l06()
    16 => w2_l07()
    17 => w2_l08()
    18 => w2_l09()
    19 => w2_l10()
    20 => w3_l01()
    21 => w3_l02()
    22 => w3_l03()
    23 => w3_l04()
    24 => w3_l05()
    25 => w3_l06()
    26 => w3_l07()
    27 => w3_l08()
    28 => w3_l09()
    29 => w3_l10()
    30 => w4_l01()
    31 => w4_l02()
    32 => w4_l03()
    33 => w4_l04()
    34 => w4_l05()
    35 => w4_l06()
    36 => w4_l07()
    37 => w4_l08()
    38 => w4_l09()
    39 => w4_l10()
    40 => w5_l01()
    41 => w5_l02()
    42 => w5_l03()
    43 => w5_l04()
    44 => w5_l05()
    45 => w5_l06()
    46 => w5_l07()
    47 => w5_l08()
    48 => w5_l09()
    _ => w5_l10()
  }
}

// ══════════════════════════════════════════════════════════════
// World 1: Stone Ruins - Gravity basics
// ══════════════════════════════════════════════════════════════

///|
fn w1_l01() -> @types.Level {
  let data =
    #|########
    #|#P.....#
    #|#......#
    #|#......#
    #|#......#
    #|#......#
    #|#......#
    #|#....E.#
    #|########

  parse_level(
    data,
    0,
    0,
    "First Steps",
    2,
  )
}

///|
fn w1_l02() -> @types.Level {
  let data =
    #|########
    #|#P.....#
    #|#.####.#
    #|#......#
    #|#......#
    #|#.####.#
    #|#......#
    #|#....E.#
    #|########

  parse_level(
    data,
    0,
    1,
    "Over the Wall",
    3,
  )
}

///|
fn w1_l03() -> @types.Level {
  let data =
    #|##########
    #|#P.......#
    #|#..##....#
    #|#........#
    #|#........#
    #|#....##..#
    #|#........#
    #|#.G....E.#
    #|##########

  parse_level(
    data,
    0,
    2,
    "Gem Hunt",
    4,
  )
}

///|
fn w1_l04() -> @types.Level {
  let data =
    #|##########
    #|#P..#....#
    #|#...#....#
    #|#........#
    #|#........#
    #|#....#...#
    #|#....#...#
    #|#..G...E.#
    #|##########

  parse_level(
    data,
    0,
    3,
    "Corridors",
    4,
  )
}

///|
fn w1_l05() -> @types.Level {
  let data =
    #|##########
    #|#P....B..#
    #|#........#
    #|###......#
    #|#........#
    #|#......###
    #|#........#
    #|#......E.#
    #|##########

  parse_level(
    data,
    0,
    4,
    "Box Intro",
    5,
  )
}

///|
fn w1_l06() -> @types.Level {
  let data =
    #|##########
    #|#P.......#
    #|#..B.....#
    #|#..###...#
    #|#........#
    #|#...###..#
    #|#.....B..#
    #|#.G....E.#
    #|##########

  parse_level(
    data,
    0,
    5,
    "Push Around",
    6,
  )
}

///|
fn w1_l07() -> @types.Level {
  let data =
    #|##########
    #|#P.......#
    #|#..#.....#
    #|#..#..G..#
    #|#........#
    #|#..G..#..#
    #|#.....#..#
    #|#.......E#
    #|##########

  parse_level(
    data,
    0,
    6,
    "Twin Gems",
    5,
  )
}

///|
fn w1_l08() -> @types.Level {
  let data =
    #|##########
    #|#P....B..#
    #|#........#
    #|##.####..#
    #|#........#
    #|#..####.##
    #|#........#
    #|#B.....E.#
    #|##########

  parse_level(
    data,
    0,
    7,
    "Gravity Maze",
    7,
  )
}

///|
fn w1_l09() -> @types.Level {
  let data =
    #|############
    #|#P.........#
    #|#..##......#
    #|#......##..#
    #|#..........#
    #|#..##..G...#
    #|#......##..#
    #|#..........#
    #|#.....G..E.#
    #|############

  parse_level(
    data,
    0,
    8,
    "Zigzag",
    6,
  )
}

///|
fn w1_l10() -> @types.Level {
  let data =
    #|############
    #|#P...B.....#
    #|#..###.....#
    #|#..........#
    #|#.....###..#
    #|#..........#
    #|#..###.....#
    #|#......B...#
    #|#.G......E.#
    #|############

  parse_level(
    data,
    0,
    9,
    "Stone Summit",
    8,
  )
}

// ══════════════════════════════════════════════════════════════
// World 2: Crystal Caverns - Ice, portals, sliding
// ══════════════════════════════════════════════════════════════

///|
fn w2_l01() -> @types.Level {
  let data =
    #|##########
    #|#P.......#
    #|#........#
    #|#..IIII..#
    #|#........#
    #|#........#
    #|#........#
    #|#......E.#
    #|##########

  parse_level(
    data,
    1,
    0,
    "Ice Floor",
    3,
  )
}

///|
fn w2_l02() -> @types.Level {
  let data =
    #|##########
    #|#P.......#
    #|#..##....#
    #|#..II....#
    #|#........#
    #|#....II..#
    #|#....##..#
    #|#......E.#
    #|##########

  parse_level(
    data,
    1,
    1,
    "Frozen Path",
    4,
  )
}

///|
fn w2_l03() -> @types.Level {
  let data =
    #|##########
    #|#P....1..#
    #|#........#
    #|#..####..#
    #|#........#
    #|#..####..#
    #|#........#
    #|#.1....E.#
    #|##########

  parse_level(
    data,
    1,
    2,
    "Portal Leap",
    3,
  )
}

///|
fn w2_l04() -> @types.Level {
  let data =
    #|##########
    #|#P.......#
    #|#..1.....#
    #|#..###...#
    #|#........#
    #|#...###..#
    #|#.....1..#
    #|#..G...E.#
    #|##########

  parse_level(
    data,
    1,
    3,
    "Warp Gem",
    5,
  )
}

///|
fn w2_l05() -> @types.Level {
  let data =
    #|##########
    #|#P...II..#
    #|#........#
    #|#..1..#..#
    #|#.....#..#
    #|#..#..1..#
    #|#..#.....#
    #|#......E.#
    #|##########

  parse_level(
    data,
    1,
    4,
    "Ice Portal",
    5,
  )
}

///|
fn w2_l06() -> @types.Level {
  let data =
    #|##########
    #|#P.......#
    #|#.1..II..#
    #|#..####..#
    #|#........#
    #|#..####..#
    #|#..II..1.#
    #|#.G....E.#
    #|##########

  parse_level(
    data,
    1,
    5,
    "Crystal Slide",
    6,
  )
}

///|
fn w2_l07() -> @types.Level {
  let data =
    #|############
    #|#P.........#
    #|#..1.......#
    #|#..###..II.#
    #|#..........#
    #|#.II..###..#
    #|#.......1..#
    #|#....G...E.#
    #|############

  parse_level(
    data,
    1,
    6,
    "Mirror Cave",
    6,
  )
}

///|
fn w2_l08() -> @types.Level {
  let data =
    #|############
    #|#P..II.....#
    #|#....##....#
    #|#..1.......#
    #|#..........#
    #|#.......1..#
    #|#....##....#
    #|#.....II.E.#
    #|############

  parse_level(
    data,
    1,
    7,
    "Slip Stream",
    7,
  )
}

///|
fn w2_l09() -> @types.Level {
  let data =
    #|############
    #|#P.........#
    #|#.1..II..2.#
    #|#..########
    #|#..........#
    #|########..#
    #|#.2..II..1.#
    #|#.G......E.#
    #|############

  parse_level(
    data,
    1,
    8,
    "Dual Portals",
    7,
  )
}

///|
fn w2_l10() -> @types.Level {
  let data =
    #|############
    #|#P...B.....#
    #|#..1..II...#
    #|#..###.....#
    #|#..........#
    #|#.....###..#
    #|#...II..1..#
    #|#.G..B...E.#
    #|############

  parse_level(
    data,
    1,
    9,
    "Crystal Peak",
    9,
  )
}

// ══════════════════════════════════════════════════════════════
// World 3: Void Expanse - Crumble tiles, switches, gates
// ══════════════════════════════════════════════════════════════

///|
fn w3_l01() -> @types.Level {
  let data =
    #|##########
    #|#P.......#
    #|#........#
    #|#..CCCC..#
    #|#........#
    #|#........#
    #|#........#
    #|#......E.#
    #|##########

  parse_level(
    data,
    2,
    0,
    "Crumble Walk",
    3,
  )
}

///|
fn w3_l02() -> @types.Level {
  let data =
    #|##########
    #|#P.......#
    #|#..CC....#
    #|#..##....#
    #|#........#
    #|#....##..#
    #|#....CC..#
    #|#......E.#
    #|##########

  parse_level(
    data,
    2,
    1,
    "Fragile Floor",
    4,
  )
}

///|
fn w3_l03() -> @types.Level {
  let data =
    #|##########
    #|#P.......#
    #|#........#
    #|#..W.D...#
    #|#........#
    #|#........#
    #|#........#
    #|#......E.#
    #|##########

  parse_level(
    data,
    2,
    2,
    "Switch Intro",
    4,
  )
}

///|
fn w3_l04() -> @types.Level {
  let data =
    #|##########
    #|#P.......#
    #|#..###...#
    #|#..W.....#
    #|#......D.#
    #|#.....###
    #|#........#
    #|#.G....E.#
    #|##########

  parse_level(
    data,
    2,
    3,
    "Gate Keeper",
    5,
  )
}

///|
fn w3_l05() -> @types.Level {
  let data =
    #|##########
    #|#P...C...#
    #|#..###...#
    #|#........#
    #|#........#
    #|#...###..#
    #|#...C....#
    #|#......E.#
    #|##########

  parse_level(
    data,
    2,
    4,
    "Void Path",
    5,
  )
}

///|
fn w3_l06() -> @types.Level {
  let data =
    #|##########
    #|#P.......#
    #|#..CC....#
    #|#..W.D...#
    #|#........#
    #|#...D.W..#
    #|#....CC..#
    #|#......E.#
    #|##########

  parse_level(
    data,
    2,
    5,
    "Dual Switch",
    6,
  )
}

///|
fn w3_l07() -> @types.Level {
  let data =
    #|############
    #|#P.........#
    #|#..CCC.....#
    #|#..###..D..#
    #|#..........#
    #|#..D..###..#
    #|#.....CCC..#
    #|#..W.....E.#
    #|############

  parse_level(
    data,
    2,
    6,
    "Void Maze",
    7,
  )
}

///|
fn w3_l08() -> @types.Level {
  let data =
    #|############
    #|#P..CC.....#
    #|#....###...#
    #|#..W.......#
    #|#.....D....#
    #|#.......W..#
    #|#...###....#
    #|#.....CC.E.#
    #|############

  parse_level(
    data,
    2,
    7,
    "Chain React",
    7,
  )
}

///|
fn w3_l09() -> @types.Level {
  let data =
    #|############
    #|#P.........#
    #|#.CC.W..D..#
    #|#..####....#
    #|#..........#
    #|#....####..#
    #|#..D..W.CC.#
    #|#.G......E.#
    #|############

  parse_level(
    data,
    2,
    8,
    "Dark Matter",
    8,
  )
}

///|
fn w3_l10() -> @types.Level {
  let data =
    #|############
    #|#P...B.....#
    #|#..CCC..D..#
    #|#..###..W..#
    #|#..........#
    #|#..W..###..#
    #|#..D..CCC..#
    #|#.G..B...E.#
    #|############

  parse_level(
    data,
    2,
    9,
    "Void Heart",
    10,
  )
}

// ══════════════════════════════════════════════════════════════
// World 4: Magma Depths - Spikes, conveyors, boulders
// ══════════════════════════════════════════════════════════════

///|
fn w4_l01() -> @types.Level {
  let data =
    #|##########
    #|#P.......#
    #|#........#
    #|#..SS....#
    #|#........#
    #|#........#
    #|#........#
    #|#......E.#
    #|##########

  parse_level(
    data,
    3,
    0,
    "Spike Intro",
    3,
  )
}

///|
fn w4_l02() -> @types.Level {
  let data =
    #|##########
    #|#P.......#
    #|#..##....#
    #|#..SS....#
    #|#........#
    #|#....SS..#
    #|#....##..#
    #|#......E.#
    #|##########

  parse_level(
    data,
    3,
    1,
    "Lava Dodge",
    4,
  )
}

///|
fn w4_l03() -> @types.Level {
  let data =
    #|##########
    #|#P.......#
    #|#........#
    #|#..>>....#
    #|#........#
    #|#....<<..#
    #|#........#
    #|#......E.#
    #|##########

  parse_level(
    data,
    3,
    2,
    "Conveyor Belt",
    4,
  )
}

///|
fn w4_l04() -> @types.Level {
  let data =
    #|##########
    #|#P.......#
    #|#..R.....#
    #|#..###...#
    #|#........#
    #|#...###..#
    #|#........#
    #|#......E.#
    #|##########

  parse_level(
    data,
    3,
    3,
    "Rolling Rock",
    5,
  )
}

///|
fn w4_l05() -> @types.Level {
  let data =
    #|##########
    #|#P.......#
    #|#..>>..S.#
    #|#..###...#
    #|#........#
    #|#...###..#
    #|#.S..<<..#
    #|#..G...E.#
    #|##########

  parse_level(
    data,
    3,
    4,
    "Hot Conveyor",
    6,
  )
}

///|
fn w4_l06() -> @types.Level {
  let data =
    #|##########
    #|#P...R...#
    #|#..###...#
    #|#........#
    #|#..SS....#
    #|#........#
    #|#...###..#
    #|#......E.#
    #|##########

  parse_level(
    data,
    3,
    5,
    "Boulder Drop",
    6,
  )
}

///|
fn w4_l07() -> @types.Level {
  let data =
    #|############
    #|#P.........#
    #|#..>>..SS..#
    #|#..###.....#
    #|#..........#
    #|#.....###..#
    #|#..SS..<<..#
    #|#........E.#
    #|############

  parse_level(
    data,
    3,
    6,
    "Magma Flow",
    7,
  )
}

///|
fn w4_l08() -> @types.Level {
  let data =
    #|############
    #|#P..R......#
    #|#....###...#
    #|#..>>..SS..#
    #|#..........#
    #|#..SS..<<..#
    #|#...###....#
    #|#.G......E.#
    #|############

  parse_level(
    data,
    3,
    7,
    "Danger Zone",
    8,
  )
}

///|
fn w4_l09() -> @types.Level {
  let data =
    #|############
    #|#P.........#
    #|#.R..>>..S.#
    #|#..####....#
    #|#..........#
    #|#....####..#
    #|#.S..<<..R.#
    #|#.G......E.#
    #|############

  parse_level(
    data,
    3,
    8,
    "Inferno Run",
    9,
  )
}

///|
fn w4_l10() -> @types.Level {
  let data =
    #|############
    #|#P...R..B..#
    #|#..>>..SS..#
    #|#..###.....#
    #|#..........#
    #|#.....###..#
    #|#..SS..<<..#
    #|#.G..B...E.#
    #|############

  parse_level(
    data,
    3,
    9,
    "Magma Core",
    10,
  )
}

// ══════════════════════════════════════════════════════════════
// World 5: Sky Citadel - Everything combined, hard puzzles
// ══════════════════════════════════════════════════════════════

///|
fn w5_l01() -> @types.Level {
  let data =
    #|############
    #|#P.........#
    #|#..II..1...#
    #|#..###.....#
    #|#..........#
    #|#.....###..#
    #|#...1..II..#
    #|#........E.#
    #|############

  parse_level(
    data,
    4,
    0,
    "Sky Gate",
    5,
  )
}

///|
fn w5_l02() -> @types.Level {
  let data =
    #|############
    #|#P.........#
    #|#..CC..W...#
    #|#..###..D..#
    #|#..........#
    #|#..D..###..#
    #|#...W..CC..#
    #|#........E.#
    #|############

  parse_level(
    data,
    4,
    1,
    "Crumble Gate",
    6,
  )
}

///|
fn w5_l03() -> @types.Level {
  let data =
    #|############
    #|#P.........#
    #|#..SS..>>..#
    #|#..###..1..#
    #|#..........#
    #|#..1..###..#
    #|#..<<..SS..#
    #|#........E.#
    #|############

  parse_level(
    data,
    4,
    2,
    "Spike Warp",
    6,
  )
}

///|
fn w5_l04() -> @types.Level {
  let data =
    #|############
    #|#P...R.....#
    #|#..II..CC..#
    #|#..###.....#
    #|#..........#
    #|#.....###..#
    #|#..CC..II..#
    #|#.G......E.#
    #|############

  parse_level(
    data,
    4,
    3,
    "Ice Crumble",
    7,
  )
}

///|
fn w5_l05() -> @types.Level {
  let data =
    #|############
    #|#P...B.....#
    #|#..W..1..D.#
    #|#..###.....#
    #|#..........#
    #|#.....###..#
    #|#.D..1..W..#
    #|#.G..B...E.#
    #|############

  parse_level(
    data,
    4,
    4,
    "Key Master",
    8,
  )
}

///|
fn w5_l06() -> @types.Level {
  let data =
    #|############
    #|#P.........#
    #|#..R..>>...#
    #|#..###..SS.#
    #|#....CC....#
    #|#.SS..###..#
    #|#...<<..R..#
    #|#.G......E.#
    #|############

  parse_level(
    data,
    4,
    5,
    "Gauntlet",
    8,
  )
}

///|
fn w5_l07() -> @types.Level {
  let data =
    #|############
    #|#P...B..R..#
    #|#..1..II...#
    #|#..###..W..#
    #|#.....D....#
    #|#..W..###..#
    #|#...II..1..#
    #|#.G..B...E.#
    #|############

  parse_level(
    data,
    4,
    6,
    "Complex",
    9,
  )
}

///|
fn w5_l08() -> @types.Level {
  let data =
    #|############
    #|#P..R..B...#
    #|#..CC..>>..#
    #|#..###..SS.#
    #|#.....D....#
    #|#.SS..###..#
    #|#..<<..CC..#
    #|#.G..K...E.#
    #|############

  parse_level(
    data,
    4,
    7,
    "Sky Fortress",
    10,
  )
}

///|
fn w5_l09() -> @types.Level {
  let data =
    #|############
    #|#P..R....B.#
    #|#.1..II.CC.#
    #|#..###..W..#
    #|#..SS..D...#
    #|#...D..###.#
    #|#.CC.II..1.#
    #|#.G..B.K.E.#
    #|############

  parse_level(
    data,
    4,
    8,
    "Citadel",
    11,
  )
}

///|
fn w5_l10() -> @types.Level {
  let data =
    #|############
    #|#P..R..B...#
    #|#.1.CC.>>.D#
    #|#..###.W.SS#
    #|#..SS.D....#
    #|#....W.###.#
    #|#D.<<.CC.1.#
    #|#G.B.K.G.E.#
    #|############

  parse_level(
    data,
    4,
    9,
    "Final Ascent",
    12,
  )
}
