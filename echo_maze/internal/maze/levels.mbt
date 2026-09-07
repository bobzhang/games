///|
pub fn get_all_levels() -> Array[@types.LevelDef] {
  let levels : Array[@types.LevelDef] = []
  // World 1: Foundations (8 levels) - Buttons + doors basics
  // Level 1-1: "First Steps" - Simple walk to exit
  levels.push({
    world: 0,
    level: 0,
    ascii: "#########\n#S......#\n#.######.#\n#.......X#\n##########",
    button_links: [],
    guard_patrols: [],
    timed_door_durations: [],
    par_loops: 1,
    name: "First Steps",
  })
  // Level 1-2: "One Button" - Press button to open door
  levels.push({
    world: 0,
    level: 1,
    ascii: "##########\n#S..B....#\n#...####.#\n#...D..X.#\n##########",
    button_links: [{ button_id: 0, door_id: 0, }],
    guard_patrols: [],
    timed_door_durations: [],
    par_loops: 2,
    name: "One Button",
  })
  // Level 1-3: "Hold Please" - Ghost must hold button
  levels.push({
    world: 0,
    level: 2,
    ascii: "###########\n#S........#\n###.####..#\n#B..D...X.#\n###########",
    button_links: [{ button_id: 0, door_id: 0, }],
    guard_patrols: [],
    timed_door_durations: [],
    par_loops: 2,
    name: "Hold Please",
  })
  // Level 1-4: "Two Doors" - Two button-door pairs
  levels.push({
    world: 0,
    level: 3,
    ascii: "############\n#S...B.....#\n####.####..#\n#....D..D..#\n#.B........#\n#.......X..#\n############",
    button_links: [{ button_id: 0, door_id: 0, }, { button_id: 1, door_id: 1, }],
    guard_patrols: [],
    timed_door_durations: [],
    par_loops: 2,
    name: "Two Doors",
  })
  // Level 1-5: "Fork in the Road" - Choose path
  levels.push({
    world: 0,
    level: 4,
    ascii: "#############\n#S..........#\n###.###.###.#\n#B..D.#.D.B.#\n###.###.###.#\n#.....X.....#\n#############",
    button_links: [{ button_id: 0, door_id: 0, }, { button_id: 1, door_id: 1, }],
    guard_patrols: [],
    timed_door_durations: [],
    par_loops: 2,
    name: "Fork in the Road",
  })
  // Level 1-6: "Chain Reaction" - Sequential doors
  levels.push({
    world: 0,
    level: 5,
    ascii: "##############\n#S..D..D...X.#\n#...#..#.....#\n#B..#..B.....#\n##############",
    button_links: [{ button_id: 0, door_id: 0, }, { button_id: 1, door_id: 1, }],
    guard_patrols: [],
    timed_door_durations: [],
    par_loops: 2,
    name: "Chain Reaction",
  })
  // Level 1-7: "The Collector" - Collectible intro
  levels.push({
    world: 0,
    level: 6,
    ascii: "#############\n#S.C........#\n###.####.##.#\n#B..D..C.##.#\n###.####.##.#\n#.......X.C.#\n#############",
    button_links: [{ button_id: 0, door_id: 0, }],
    guard_patrols: [],
    timed_door_durations: [],
    par_loops: 2,
    name: "The Collector",
  })
  // Level 1-8: "Double Ghost" - Need 2 ghosts
  levels.push({
    world: 0,
    level: 7,
    ascii: "##############\n#S...........#\n####.##.####.#\n#B...D..D..X.#\n####.##.####.#\n#.......B....#\n##############",
    button_links: [{ button_id: 0, door_id: 0, }, { button_id: 1, door_id: 1, }],
    guard_patrols: [],
    timed_door_durations: [],
    par_loops: 3,
    name: "Double Ghost",
  })
  // World 2: Timing (8 levels) - Timed doors, guard patrols
  // Level 2-1: "Tick Tock" - Timed door intro
  levels.push({
    world: 1,
    level: 0,
    ascii: "###########\n#S........#\n###.####..#\n#...T...X.#\n###########",
    button_links: [],
    guard_patrols: [],
    timed_door_durations: [(0, 8)],
    par_loops: 1,
    name: "Tick Tock",
  })
  // Level 2-2: "On Patrol" - Guard intro
  levels.push({
    world: 1,
    level: 1,
    ascii: "###########\n#S........#\n#.###.###.#\n#.#G....#.#\n#.###.###.#\n#........X#\n###########",
    button_links: [],
    guard_patrols: [
      [
        @types.vec2i(3, 3),
        @types.vec2i(4, 3),
        @types.vec2i(5, 3),
        @types.vec2i(6, 3),
      ],
    ],
    timed_door_durations: [],
    par_loops: 1,
    name: "On Patrol",
  })
  // Level 2-3: "Rush Hour" - Timed door + button combo
  levels.push({
    world: 1,
    level: 2,
    ascii: "############\n#S..B......#\n####.####..#\n#...D..T.X.#\n############",
    button_links: [{ button_id: 0, door_id: 0, }],
    guard_patrols: [],
    timed_door_durations: [(1, 6)],
    par_loops: 2,
    name: "Rush Hour",
  })
  // Level 2-4: "Dodge and Weave" - Guard patterns
  levels.push({
    world: 1,
    level: 3,
    ascii: "#############\n#S..........#\n#.##.####.#.#\n#.G.......#.#\n#.##.####.#.#\n#.........#X#\n#############",
    button_links: [],
    guard_patrols: [
      [
        @types.vec2i(2, 3),
        @types.vec2i(3, 3),
        @types.vec2i(4, 3),
        @types.vec2i(5, 3),
        @types.vec2i(6, 3),
        @types.vec2i(7, 3),
        @types.vec2i(8, 3),
        @types.vec2i(9, 3),
      ],
    ],
    timed_door_durations: [],
    par_loops: 1,
    name: "Dodge and Weave",
  })
  // Level 2-5: "Distraction" - Ghost distracts guard? Use ghost + button
  levels.push({
    world: 1,
    level: 4,
    ascii: "##############\n#S.....B.....#\n####.###.###.#\n#....D.G...X.#\n####.###.###.#\n#............#\n##############",
    button_links: [{ button_id: 0, door_id: 0, }],
    guard_patrols: [
      [
        @types.vec2i(6, 3),
        @types.vec2i(7, 3),
        @types.vec2i(8, 3),
        @types.vec2i(9, 3),
      ],
    ],
    timed_door_durations: [],
    par_loops: 2,
    name: "Distraction",
  })
  // Level 2-6: "Narrow Window" - Tight timed door
  levels.push({
    world: 1,
    level: 5,
    ascii: "#############\n#S..........#\n####.#.####.#\n#....T.T..X.#\n####.#.####.#\n#...........#\n#############",
    button_links: [],
    guard_patrols: [],
    timed_door_durations: [(0, 5), (1, 5)],
    par_loops: 1,
    name: "Narrow Window",
  })
  // Level 2-7: "Guard Duo" - Two guards
  levels.push({
    world: 1,
    level: 6,
    ascii: "##############\n#S.....C.....#\n#.####.####..#\n#.G........G.#\n#.####.####..#\n#.........X..#\n##############",
    button_links: [],
    guard_patrols: [
      [
        @types.vec2i(2, 3),
        @types.vec2i(3, 3),
        @types.vec2i(4, 3),
        @types.vec2i(5, 3),
      ],
      [
        @types.vec2i(11, 3),
        @types.vec2i(10, 3),
        @types.vec2i(9, 3),
        @types.vec2i(8, 3),
      ],
    ],
    timed_door_durations: [],
    par_loops: 1,
    name: "Guard Duo",
  })
  // Level 2-8: "Clock Work" - Timed doors + guards + button
  levels.push({
    world: 1,
    level: 7,
    ascii: "################\n#S...B.........#\n####.###.####..#\n#....D.G.T...X.#\n####.###.####..#\n#..............#\n################",
    button_links: [{ button_id: 0, door_id: 0, }],
    guard_patrols: [[@types.vec2i(7, 3), @types.vec2i(8, 3)]],
    timed_door_durations: [(1, 6)],
    par_loops: 2,
    name: "Clock Work",
  })
  // World 3: Mastery (8 levels) - All mechanics combined
  // Level 3-1: "Full House" - All mechanics together
  levels.push({
    world: 2,
    level: 0,
    ascii: "################\n#S...B.........#\n####.###.####..#\n#....D.....D.X.#\n####.###.####..#\n#........B.....#\n################",
    button_links: [{ button_id: 0, door_id: 0, }, { button_id: 1, door_id: 1, }],
    guard_patrols: [],
    timed_door_durations: [],
    par_loops: 3,
    name: "Full House",
  })
  // Level 3-2: "Triple Threat" - Three buttons
  levels.push({
    world: 2,
    level: 1,
    ascii: "################\n#S....B........#\n####.###.####..#\n#B...D..D..D.X.#\n####.###.####..#\n#.....B........#\n################",
    button_links: [
      { button_id: 0, door_id: 0, },
      { button_id: 1, door_id: 1, },
      { button_id: 2, door_id: 2, },
    ],
    guard_patrols: [],
    timed_door_durations: [],
    par_loops: 3,
    name: "Triple Threat",
  })
  // Level 3-3: "Guard Gauntlet" - Guards + doors
  levels.push({
    world: 2,
    level: 2,
    ascii: "################\n#S..B..........#\n####.####.####.#\n#....D..G....X.#\n####.####.####.#\n#.....G........#\n################",
    button_links: [{ button_id: 0, door_id: 0, }],
    guard_patrols: [
      [
        @types.vec2i(8, 3),
        @types.vec2i(9, 3),
        @types.vec2i(10, 3),
        @types.vec2i(11, 3),
      ],
      [
        @types.vec2i(6, 5),
        @types.vec2i(7, 5),
        @types.vec2i(8, 5),
        @types.vec2i(9, 5),
      ],
    ],
    timed_door_durations: [],
    par_loops: 2,
    name: "Guard Gauntlet",
  })
  // Level 3-4: "Time Crunch" - Timed doors + multi ghost
  levels.push({
    world: 2,
    level: 3,
    ascii: "################\n#S...B.........#\n####.###.####..#\n#....D...T.T.X.#\n####.###.####..#\n#..............#\n################",
    button_links: [{ button_id: 0, door_id: 0, }],
    guard_patrols: [],
    timed_door_durations: [(1, 5), (2, 4)],
    par_loops: 2,
    name: "Time Crunch",
  })
  // Level 3-5: "Labyrinth" - Large complex maze
  levels.push({
    world: 2,
    level: 4,
    ascii: "################\n#S.....C.......#\n#.####.####.##.#\n#.B..D.....D.#.#\n#.####.####.##.#\n#......B.....X.#\n################",
    button_links: [{ button_id: 0, door_id: 0, }, { button_id: 1, door_id: 1, }],
    guard_patrols: [],
    timed_door_durations: [],
    par_loops: 3,
    name: "Labyrinth",
  })
  // Level 3-6: "Precision" - Guards + timed doors
  levels.push({
    world: 2,
    level: 5,
    ascii: "################\n#S.............#\n#.####.####.##.#\n#.G..T.G.T...X.#\n#.####.####.##.#\n#..............#\n################",
    button_links: [],
    guard_patrols: [
      [@types.vec2i(2, 3), @types.vec2i(3, 3), @types.vec2i(4, 3)],
      [@types.vec2i(7, 3), @types.vec2i(8, 3)],
    ],
    timed_door_durations: [(0, 4), (1, 4)],
    par_loops: 1,
    name: "Precision",
  })
  // Level 3-7: "Grand Design" - Large multi-ghost puzzle
  levels.push({
    world: 2,
    level: 6,
    ascii: "################\n#S..B..C.......#\n####.####.####.#\n#B...D..D..D.X.#\n####.####.####.#\n#..........B.C.#\n################",
    button_links: [
      { button_id: 0, door_id: 0, },
      { button_id: 1, door_id: 1, },
      { button_id: 2, door_id: 2, },
    ],
    guard_patrols: [],
    timed_door_durations: [],
    par_loops: 3,
    name: "Grand Design",
  })
  // Level 3-8: "Echo Chamber" - Ultimate challenge
  // ASCII: D at col 5 (id 0), D at col 9 (id 1), T at col 11 (id 2)
  // Buttons: B0 links to D0, B1 links to D1, B2 links to T(but T is timed, not button-linked)
  // Fix: button_id 2 should not link to timed door; timed door is id 2
  levels.push({
    world: 2,
    level: 7,
    ascii: "################\n#S..B..........#\n####.####.####.#\n#B...D.G.D.T.X.#\n####.####.####.#\n#........B..C..#\n################",
    button_links: [{ button_id: 0, door_id: 0, }, { button_id: 1, door_id: 1, }],
    guard_patrols: [[@types.vec2i(7, 3), @types.vec2i(8, 3)]],
    timed_door_durations: [(2, 5)],
    par_loops: 3,
    name: "Echo Chamber",
  })
  levels
}

///|
pub fn get_level(world : Int, level : Int) -> @types.LevelDef? {
  let all = get_all_levels()
  for l in all {
    if l.world == world && l.level == level {
      return Some(l)
    }
  }
  None
}
