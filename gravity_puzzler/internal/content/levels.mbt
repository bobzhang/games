///|
pub fn parse_level(
  data : String,
  world : Int,
  level_num : Int,
  name : String,
  par_moves : Int,
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
        'N' => {
          entities.push(@types.Entity::new(next_id, Enemy, x, y))
          next_id = next_id + 1
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

///|
/// Get a hint text for a specific level
pub fn get_level_hint(world : Int, level : Int) -> String {
  let index = world * @types.levels_per_world + level
  match index {
    // World 1: Stone Ruins
    0 => "Try rotating gravity left to reach the exit"
    1 => "Use gravity rotation to get over the walls"
    2 => "Collect the gem before reaching the exit"
    3 => "Navigate through the corridors with gravity shifts"
    4 => "Push the box out of your path with gravity"
    5 => "Use boxes as stepping stones after rotation"
    6 => "Collect both gems by planning your gravity rotations"
    7 => "Alternate between gravity directions to navigate the maze"
    8 => "Use a zigzag pattern with gravity changes"
    9 => "Combine box pushing with gravity rotation"
    // World 2: Crystal Caverns
    10 => "Ice tiles are slippery - plan your path carefully"
    11 => "Use ice and walls together to control your slide"
    12 => "Portals teleport you - use them to bypass walls"
    13 => "Combine portals with gravity to reach the gem"
    14 => "Ice and portals together create tricky paths"
    15 => "Watch for ice near portals - you might slide past"
    16 => "Mirror Cave has tricky portal and ice combos"
    17 => "Slip Stream requires careful ice navigation"
    18 => "Two portal pairs - plan which to use first"
    19 => "Crystal Peak combines all Crystal Cavern mechanics"
    // World 3: Void Expanse
    20 => "Crumble tiles break after you leave - no going back"
    21 => "Plan your path over crumble tiles carefully"
    22 => "Hit the switch to open the gate"
    23 => "Get to the switch before the gate blocks your path"
    24 => "Crumble tiles limit your options - choose wisely"
    25 => "Two switches control two gates"
    26 => "Combine crumble paths with switch timing"
    27 => "Chain reactions: switches open paths to more switches"
    28 => "Dark Matter requires precise crumble and switch play"
    29 => "Void Heart is the ultimate crumble-switch challenge"
    // World 4: Magma Depths
    30 => "Avoid spikes - they are instant death"
    31 => "Route around spikes using gravity rotation"
    32 => "Conveyors push you automatically - use them wisely"
    33 => "Boulders roll and can block spikes"
    34 => "Conveyors and spikes together - time your moves"
    35 => "Drop the boulder to clear a path"
    36 => "Watch out for enemies - they chase you!"
    37 => "Enemies can be crushed by boulders"
    38 => "Lure enemies into boulders for a safe path"
    39 => "Magma Core combines all dangers - stay sharp"
    // World 5: Sky Citadel
    40 => "All mechanics combined - use what you have learned"
    41 => "Crumble and gates together require planning"
    42 => "Spikes with portals - teleport past the danger"
    43 => "Ice and crumble are a dangerous combination"
    44 => "Keys and portals unlock new possibilities"
    45 => "Watch out for the enemy while dodging hazards"
    46 => "Complex puzzles need step-by-step thinking"
    47 => "Enemies add pressure - crush them with boulders"
    48 => "The Citadel tests everything you know"
    _ => "Use all your skills to complete the Final Ascent"
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

  parse_level(data, 0, 0, "First Steps", 2)
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

  parse_level(data, 0, 1, "Over the Wall", 3)
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

  parse_level(data, 0, 2, "Gem Hunt", 4)
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

  parse_level(data, 0, 3, "Corridors", 4)
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

  parse_level(data, 0, 4, "Box Intro", 5)
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

  parse_level(data, 0, 5, "Push Around", 6)
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

  parse_level(data, 0, 6, "Twin Gems", 5)
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

  parse_level(data, 0, 7, "Gravity Maze", 7)
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

  parse_level(data, 0, 8, "Zigzag", 6)
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

  parse_level(data, 0, 9, "Stone Summit", 8)
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

  parse_level(data, 1, 0, "Ice Floor", 3)
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

  parse_level(data, 1, 1, "Frozen Path", 4)
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

  parse_level(data, 1, 2, "Portal Leap", 3)
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

  parse_level(data, 1, 3, "Warp Gem", 5)
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

  parse_level(data, 1, 4, "Ice Portal", 5)
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

  parse_level(data, 1, 5, "Crystal Slide", 6)
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

  parse_level(data, 1, 6, "Mirror Cave", 6)
}

///|
fn w2_l08() -> @types.Level {
  let data =
    #|############
    #|#P..II.....#
    #|#....##....#
    #|#..1....N..#
    #|#..........#
    #|#.......1..#
    #|#....##....#
    #|#.....II.E.#
    #|############

  parse_level(data, 1, 7, "Slip Stream", 7)
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

  parse_level(data, 1, 8, "Dual Portals", 7)
}

///|
fn w2_l10() -> @types.Level {
  let data =
    #|############
    #|#P...B.....#
    #|#..1..II...#
    #|#..###..N..#
    #|#..........#
    #|#.....###..#
    #|#...II..1..#
    #|#.G..B...E.#
    #|############

  parse_level(data, 1, 9, "Crystal Peak", 9)
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

  parse_level(data, 2, 0, "Crumble Walk", 3)
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

  parse_level(data, 2, 1, "Fragile Floor", 4)
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

  parse_level(data, 2, 2, "Switch Intro", 4)
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

  parse_level(data, 2, 3, "Gate Keeper", 5)
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

  parse_level(data, 2, 4, "Void Path", 5)
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

  parse_level(data, 2, 5, "Dual Switch", 6)
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

  parse_level(data, 2, 6, "Void Maze", 7)
}

///|
fn w3_l08() -> @types.Level {
  let data =
    #|############
    #|#P..CC.....#
    #|#....###...#
    #|#..W....N..#
    #|#.....D....#
    #|#.......W..#
    #|#...###....#
    #|#.....CC.E.#
    #|############

  parse_level(data, 2, 7, "Chain React", 7)
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

  parse_level(data, 2, 8, "Dark Matter", 8)
}

///|
fn w3_l10() -> @types.Level {
  let data =
    #|############
    #|#P...B.....#
    #|#..CCC..D..#
    #|#..###..W..#
    #|#.....N....#
    #|#..W..###..#
    #|#..D..CCC..#
    #|#.G..B...E.#
    #|############

  parse_level(data, 2, 9, "Void Heart", 10)
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

  parse_level(data, 3, 0, "Spike Intro", 3)
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

  parse_level(data, 3, 1, "Lava Dodge", 4)
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

  parse_level(data, 3, 2, "Conveyor Belt", 4)
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

  parse_level(data, 3, 3, "Rolling Rock", 5)
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

  parse_level(data, 3, 4, "Hot Conveyor", 6)
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

  parse_level(data, 3, 5, "Boulder Drop", 6)
}

///|
fn w4_l07() -> @types.Level {
  let data =
    #|############
    #|#P.........#
    #|#..>>..SS..#
    #|#..###.....#
    #|#.......N..#
    #|#.....###..#
    #|#..SS..<<..#
    #|#........E.#
    #|############

  parse_level(data, 3, 6, "Magma Flow", 7)
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

  parse_level(data, 3, 7, "Danger Zone", 8)
}

///|
fn w4_l09() -> @types.Level {
  let data =
    #|############
    #|#P.........#
    #|#.R..>>..S.#
    #|#..####....#
    #|#.....N....#
    #|#....####..#
    #|#.S..<<..R.#
    #|#.G......E.#
    #|############

  parse_level(data, 3, 8, "Inferno Run", 9)
}

///|
fn w4_l10() -> @types.Level {
  let data =
    #|############
    #|#P...R..B..#
    #|#..>>..SS..#
    #|#..###.....#
    #|#.........N#
    #|#.....###..#
    #|#..SS..<<..#
    #|#.G..B...E.#
    #|############

  parse_level(data, 3, 9, "Magma Core", 10)
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

  parse_level(data, 4, 0, "Sky Gate", 5)
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

  parse_level(data, 4, 1, "Crumble Gate", 6)
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

  parse_level(data, 4, 2, "Spike Warp", 6)
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

  parse_level(data, 4, 3, "Ice Crumble", 7)
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

  parse_level(data, 4, 4, "Key Master", 8)
}

///|
fn w5_l06() -> @types.Level {
  let data =
    #|############
    #|#P.........#
    #|#..R..>>...#
    #|#..###..SS.#
    #|#....CC.N..#
    #|#.SS..###..#
    #|#...<<..R..#
    #|#.G......E.#
    #|############

  parse_level(data, 4, 5, "Gauntlet", 8)
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

  parse_level(data, 4, 6, "Complex", 9)
}

///|
fn w5_l08() -> @types.Level {
  let data =
    #|############
    #|#P..R..B...#
    #|#..CC..>>..#
    #|#..###..SS.#
    #|#..N..D....#
    #|#.SS..###..#
    #|#..<<..CC..#
    #|#.G..K...E.#
    #|############

  parse_level(data, 4, 7, "Sky Fortress", 10)
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

  parse_level(data, 4, 8, "Citadel", 11)
}

///|
fn w5_l10() -> @types.Level {
  let data =
    #|############
    #|#P..R..B...#
    #|#.1.CC.>>.D#
    #|#..###.W.SS#
    #|#..SS.D..N.#
    #|#....W.###.#
    #|#D.<<.CC.1.#
    #|#G.B.K.G.E.#
    #|############

  parse_level(data, 4, 9, "Final Ascent", 12)
}

// ══════════════════════════════════════════════════════════════
// Level design helper data: tile and entity legend
// ══════════════════════════════════════════════════════════════
// Tiles:
//   # = Wall, E = Exit, S = Spike, I = Ice, C = Crumble
//   1/2/3 = Portal(id), W/X = Switch(1/2), D/F = Gate(1/2)
//   < > ^ v = Conveyor(dir), p = PressurePlate
//   O = GravityWell, L = TimedLava, ~ = WindGust
// Entities:
//   P = Player, B = Box, R = Boulder, K = Key, G = Gem, N = Enemy
// ══════════════════════════════════════════════════════════════

///|
/// Get par moves for a specific level (useful for persistence)
pub fn get_par_moves(world : Int, level : Int) -> Int {
  let index = world * @types.levels_per_world + level
  match index {
    // World 1
    0 => 2
    1 => 3
    2 => 4
    3 => 4
    4 => 5
    5 => 6
    6 => 5
    7 => 7
    8 => 6
    9 => 8
    // World 2
    10 => 3
    11 => 4
    12 => 3
    13 => 5
    14 => 5
    15 => 6
    16 => 6
    17 => 7
    18 => 7
    19 => 9
    // World 3
    20 => 3
    21 => 4
    22 => 4
    23 => 5
    24 => 5
    25 => 6
    26 => 7
    27 => 7
    28 => 8
    29 => 10
    // World 4
    30 => 3
    31 => 4
    32 => 4
    33 => 5
    34 => 6
    35 => 6
    36 => 7
    37 => 8
    38 => 9
    39 => 10
    // World 5
    40 => 5
    41 => 6
    42 => 6
    43 => 7
    44 => 8
    45 => 8
    46 => 9
    47 => 10
    48 => 11
    _ => 12
  }
}

///|
/// Get level name by index
pub fn get_level_name(world : Int, level : Int) -> String {
  let index = world * @types.levels_per_world + level
  match index {
    0 => "First Steps"
    1 => "Over the Wall"
    2 => "Gem Hunt"
    3 => "Corridors"
    4 => "Box Intro"
    5 => "Push Around"
    6 => "Twin Gems"
    7 => "Gravity Maze"
    8 => "Zigzag"
    9 => "Stone Summit"
    10 => "Ice Floor"
    11 => "Frozen Path"
    12 => "Portal Leap"
    13 => "Warp Gem"
    14 => "Ice Portal"
    15 => "Crystal Slide"
    16 => "Mirror Cave"
    17 => "Slip Stream"
    18 => "Dual Portals"
    19 => "Crystal Peak"
    20 => "Crumble Walk"
    21 => "Fragile Floor"
    22 => "Switch Intro"
    23 => "Gate Keeper"
    24 => "Void Path"
    25 => "Dual Switch"
    26 => "Void Maze"
    27 => "Chain React"
    28 => "Dark Matter"
    29 => "Void Heart"
    30 => "Spike Intro"
    31 => "Lava Dodge"
    32 => "Conveyor Belt"
    33 => "Rolling Rock"
    34 => "Hot Conveyor"
    35 => "Boulder Drop"
    36 => "Magma Flow"
    37 => "Danger Zone"
    38 => "Inferno Run"
    39 => "Magma Core"
    40 => "Sky Gate"
    41 => "Crumble Gate"
    42 => "Spike Warp"
    43 => "Ice Crumble"
    44 => "Key Master"
    45 => "Gauntlet"
    46 => "Complex"
    47 => "Sky Fortress"
    48 => "Citadel"
    _ => "Final Ascent"
  }
}

///|
/// Validate that a level has required elements (player and exit)
pub fn validate_level(level : @types.Level) -> Bool {
  let has_player = match @types.find_player(level) {
    Some(_) => true
    None => false
  }
  let mut has_exit = false
  for y in 0..<level.height {
    for x in 0..<level.width {
      if @types.get_tile(level, x, y) == Exit {
        has_exit = true
      }
    }
  }
  has_player && has_exit
}

///|
/// Count total entities of each kind in a level
pub fn count_entities_by_kind(
  level : @types.Level,
) -> (Int, Int, Int, Int, Int, Int) {
  let mut players = 0
  let mut boxes = 0
  let mut boulders = 0
  let mut keys = 0
  let mut gems = 0
  let mut enemies = 0
  for i in 0..<level.entities.length() {
    let e = level.entities[i]
    if e.active {
      match e.kind {
        Player => players = players + 1
        Box => boxes = boxes + 1
        Boulder => boulders = boulders + 1
        Key => keys = keys + 1
        Gem => gems = gems + 1
        Enemy => enemies = enemies + 1
      }
    }
  }
  (players, boxes, boulders, keys, gems, enemies)
}

///|
/// Count total tiles of each special kind in a level
pub fn count_special_tiles(
  level : @types.Level,
) -> (Int, Int, Int, Int, Int, Int) {
  let mut portals = 0
  let mut switches = 0
  let mut gates = 0
  let mut ice = 0
  let mut spikes = 0
  let mut crumble = 0
  for y in 0..<level.height {
    for x in 0..<level.width {
      match @types.get_tile(level, x, y) {
        Portal(_) => portals = portals + 1
        Switch(_) => switches = switches + 1
        Gate(_) => gates = gates + 1
        Ice => ice = ice + 1
        Spike => spikes = spikes + 1
        Crumble => crumble = crumble + 1
        _ => ()
      }
    }
  }
  (portals, switches, gates, ice, spikes, crumble)
}
