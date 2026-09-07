// World 2: Switches - Switches + doors coordination puzzles

///|
pub fn level_2_1() -> @types.Level {
  // Intro to switches: step on switch to open door
  let floor = [
    "############", "#@.........#", "#..........#", "#....0.....#", "#..........#",
    "#........a.#", "#.........X#", "############",
  ]
  let ceiling = [
    "############", "#.........@#", "#..........#", "#.....0....#", "#..........#",
    "#.a........#", "#X.........#", "############",
  ]
  make_level(
    1,
    0,
    floor,
    ceiling,
    [{ switch_id: 0, door_id: 0, }],
    BothExit,
    15,
  )
}

///|
pub fn level_2_2() -> @types.Level {
  // Two switches, two doors
  let floor = [
    "############", "#@....a....#", "#..........#", "#..0.......#", "#..........#",
    "#.....b..1.#", "#.........X#", "############",
  ]
  let ceiling = [
    "############", "#....a....@#", "#..........#", "#.......0..#", "#..........#",
    "#.1..b.....#", "#X.........#", "############",
  ]
  make_level(
    1,
    1,
    floor,
    ceiling,
    [{ switch_id: 0, door_id: 0, }, { switch_id: 1, door_id: 1, }],
    BothExit,
    18,
  )
}

///|
pub fn level_2_3() -> @types.Level {
  // Switch in one world opens door in both
  let floor = [
    "############", "#@.........#", "#..a.......#", "#..........#", "#......0...#",
    "#..........#", "#.........X#", "############",
  ]
  let ceiling = [
    "############", "#.........@#", "#.......a..#", "#..........#", "#...0......#",
    "#..........#", "#X.........#", "############",
  ]
  make_level(
    1,
    2,
    floor,
    ceiling,
    [{ switch_id: 0, door_id: 0, }],
    BothExit,
    16,
  )
}

///|
pub fn level_2_4() -> @types.Level {
  // Both must stand on switches
  let floor = [
    "############", "#@.........#", "#..........#", "#..........#", "#....0.....#",
    "#..........#", "############", "############",
  ]
  let ceiling = [
    "############", "#.........@#", "#..........#", "#..........#", "#.....0....#",
    "#..........#", "############", "############",
  ]
  make_level(1, 3, floor, ceiling, [], BothSwitch, 12)
}

///|
pub fn level_2_5() -> @types.Level {
  // Chain: switch opens door to reach another switch
  let floor = [
    "############", "#@....a....#", "#..........#", "#..0...b...#", "#..........#",
    "#.....1....#", "#.........X#", "############",
  ]
  let ceiling = [
    "############", "#....a....@#", "#..........#", "#...b...0..#", "#..........#",
    "#....1.....#", "#X.........#", "############",
  ]
  make_level(
    1,
    4,
    floor,
    ceiling,
    [{ switch_id: 0, door_id: 0, }, { switch_id: 1, door_id: 1, }],
    BothExit,
    20,
  )
}

///|
pub fn level_2_6() -> @types.Level {
  // Door maze with gems
  let floor = [
    "############", "#@..a......#", "#...#..G...#", "#..0...a...#", "#..........#",
    "#......1...#", "#.........X#", "############",
  ]
  let ceiling = [
    "############", "#......a..@#", "#...G..#...#", "#...a...0..#", "#..........#",
    "#...1......#", "#X.........#", "############",
  ]
  make_level(
    1,
    5,
    floor,
    ceiling,
    [{ switch_id: 0, door_id: 0, }, { switch_id: 1, door_id: 0, }],
    BothExit,
    20,
  )
}

///|
pub fn level_2_7() -> @types.Level {
  // Complex switch puzzle
  let floor = [
    "############", "#@..a..b...#", "#..........#", "#.0........#", "#..........#",
    "#.....1..a.#", "#........bX#", "############",
  ]
  let ceiling = [
    "############", "#...b..a..@#", "#..........#", "#........0.#", "#..........#",
    "#.a..1.....#", "#Xb........#", "############",
  ]
  make_level(
    1,
    6,
    floor,
    ceiling,
    [{ switch_id: 0, door_id: 0, }, { switch_id: 1, door_id: 1, }],
    BothExit,
    22,
  )
}
