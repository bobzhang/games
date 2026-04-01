///|
/// Corporate Tier - Level 1: "Lobby Infiltration"
/// Teaches movement, shadow tiles, and single guard avoidance.
/// Generous shadows line the left corridor; one guard patrols a
/// corridor with a clear gap for timing. Terminal and exit on right.
fn level_1() -> @types.Level {
  let ascii : Array[String] = [
    "####################",
    "#S..~..........#...#",
    "#..~...........#.T.#",
    "#..~...G.......#...#",
    "#..~...########D...#",
    "#..~..........##...#",
    "#..~..........#....#",
    "#..~..G.......#..X.#",
    "#..~..........#....#",
    "#..~..........######",
    "#..~..........T....#",
    "#..~...G...........#",
    "#..~...............#",
    "#..~...............#",
    "####################",
  ]
  parse_level("Lobby Infiltration", Corporate, ascii, 45.0)
}

///|
/// Corporate Tier - Level 2: "Server Room"
/// Introduces power nodes, doors, and lasers. One guard patrols
/// each half. A power node clearly gates a laser blocking the path.
fn level_2() -> @types.Level {
  let ascii : Array[String] = [
    "####################",
    "#S.......#.....T..##",
    "#........#........##",
    "#~~......D......G.##",
    "#~~......#........##",
    "####L#####........##",
    "#........#..P.....##",
    "#...G....#........##",
    "#........####D#####.",
    "#........#........##",
    "#....P...#..~..~..##",
    "#........#..~..~..##",
    "#........D..~..~..##",
    "#....T...#..~..X..##",
    "####################",
  ]
  parse_level("Server Room", Corporate, ascii, 60.0)
}

///|
/// Corporate Tier - Level 3: "Executive Floor"
/// Introduces sentinel guards who rotate in place. No hack minigame
/// yet - just avoidance and timing around stationary vision cones.
fn level_3() -> @types.Level {
  let ascii : Array[String] = [
    "####################",
    "#S...#.....#......##",
    "#....#..N..#......##",
    "#....D.....D...T..##",
    "#....#.....#......##",
    "######.....########",
    "#....#.....#......##",
    "#.T..D.....D......##",
    "#....#.....#..N...##",
    "######..P..########",
    "#~~..#.....#..~~..##",
    "#~~..D.....D..~~..##",
    "#~~..#.....#..~~..##",
    "#~~..#..T..#..~~X.##",
    "####################",
  ]
  parse_level("Executive Floor", Corporate, ascii, 75.0)
}

///|
/// Corporate Tier - Level 4: "Data Center"
/// Introduces cameras and high-security terminals (hack minigame).
/// Combines all corporate mechanics for a capstone challenge.
fn level_4() -> @types.Level {
  let ascii : Array[String] = [
    "####################",
    "#S.~.#....C....#T.##",
    "#..~.#.........#..##",
    "#..~.D...G.....D..##",
    "#..~.#.........#..##",
    "#..~.######L####..##",
    "#..~.#....P....#..##",
    "#....#.........#..##",
    "#....D.........D..##",
    "#....#....N....#..##",
    "#..~.######D####..##",
    "#..~.#~~~~~....#..##",
    "#..~.#~~~~~.H..#..##",
    "#..~.#~~~~~....#.X##",
    "####################",
  ]
  parse_level("Data Center", Corporate, ascii, 90.0)
}

///|
/// Military Tier - Level 5: "Perimeter Breach"
/// Introduces hunter guards. More guards overall, but layout
/// offers shadow corridors. First encounter with a hunter.
fn level_5() -> @types.Level {
  let ascii : Array[String] = [
    "####################",
    "#S..~~#....#....#.##",
    "#...~~#.G..#.T..#.##",
    "#.....D....D....D.##",
    "#.....#....#....#.##",
    "####L######L#####.##",
    "#.....#....#......##",
    "#..U..#.N..#...G..##",
    "#.....#....#......##",
    "#.....D....D......##",
    "#.....#....####D####",
    "#..P..#.C..#~~..~~##",
    "#.....#....#~~..~~##",
    "#.....#..T.#~~..X.##",
    "####################",
  ]
  parse_level("Perimeter Breach", Military, ascii, 80.0)
}

///|
/// Military Tier - Level 6: "Command Bunker"
/// Heavy guard presence
fn level_6() -> @types.Level {
  let ascii : Array[String] = [
    "####################",
    "#S.~..#.G..#...G..##",
    "#..~..#....#......##",
    "#..~..D....D...T..##",
    "#..~..#....#......##",
    "###D########D######",
    "#.....#.P..#......##",
    "#..N..#....#..U...##",
    "#.....#....#......##",
    "###D##########D####",
    "#~~...#..C.#.~~...##",
    "#~~.T.#....#.~~...##",
    "#~~...D.H..D.~~...##",
    "#~~...#....#.~~.X.##",
    "####################",
  ]
  parse_level("Command Bunker", Military, ascii, 100.0)
}

///|
/// Military Tier - Level 7: "Weapons Lab"
/// Multiple power systems
fn level_7() -> @types.Level {
  let ascii : Array[String] = [
    "####################",
    "#S~~..#....#....#.##",
    "#.~~..#.N..#.G..#.##",
    "#.....D....D....D.##",
    "#.P...#.L..#....#.##",
    "####D######D#####.##",
    "#.....#....#.T....##",
    "#..G..#.C..#......##",
    "#.....#....####D####",
    "#.....D....#~~..~~##",
    "####D######.~~..~~##",
    "#..H..#..P.#~~..~~##",
    "#..U..#....D~~..~~##",
    "#..T..#....#~~..X.##",
    "####################",
  ]
  parse_level("Weapons Lab", Military, ascii, 110.0)
}

///|
/// Military Tier - Level 8: "War Room"
/// Final level, maximum challenge
fn level_8() -> @types.Level {
  let ascii : Array[String] = [
    "####################",
    "#S~~.#.G..#..G.#..##",
    "#.~~.#....#....#..##",
    "#....D....D....D..##",
    "#.P..#.N..#.C..#..##",
    "##D########D####L##",
    "#~~..#.P..#....#..##",
    "#~~..#....#.U..#..##",
    "#~~..D....D....D..##",
    "##D########D####D##",
    "#....#..C.#~~.T#..##",
    "#.G..#....#~~..#..##",
    "#....D.H..D~~..D..##",
    "#..T.#....#~~.X#..##",
    "####################",
  ]
  parse_level("War Room", Military, ascii, 120.0)
}

///|
pub fn load_level(index : Int) -> @types.Level {
  match index {
    0 => level_1()
    1 => level_2()
    2 => level_3()
    3 => level_4()
    4 => level_5()
    5 => level_6()
    6 => level_7()
    7 => level_8()
    _ => level_1()
  }
}

///|
pub fn level_name(index : Int) -> String {
  match index {
    0 => "1: Lobby Infiltration"
    1 => "2: Server Room"
    2 => "3: Executive Floor"
    3 => "4: Data Center"
    4 => "5: Perimeter Breach"
    5 => "6: Command Bunker"
    6 => "7: Weapons Lab"
    7 => "8: War Room"
    _ => "Unknown"
  }
}

///|
pub fn level_tier(index : Int) -> @types.Tier {
  if index < 4 {
    Corporate
  } else {
    Military
  }
}
