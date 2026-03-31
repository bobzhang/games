///|
pub fn get_level_def(world : Int, index : Int) -> @types.LevelDef {
  match (world, index) {
    // ========================================
    // WORLD 1: BASICS (Move, TurnLeft, TurnRight)
    // ========================================
    (0, 0) =>
      // Level 1-1: "First Step" - just move forward to goal
      {
        world: 0,
        index: 0,
        name: "First Step",
        ascii: [
          "############", "############", "############", "#...S..G.###",
          "############", "############", "############", "############",
          "############",
        ],
        start_x: 4,
        start_y: 3,
        start_dir: East,
        par: 4,
        optimal: 3,
        hint: "Move forward to reach the goal!",
        available_commands: [Move, TurnLeft, TurnRight],
      }
    (0, 1) =>
      // Level 1-2: "Right Turn" - turn and move
      {
        world: 0,
        index: 1,
        name: "Right Turn",
        ascii: [
          "############", "############", "####.G######", "####..######",
          "####S.######", "############", "############", "############",
          "############",
        ],
        start_x: 4,
        start_y: 4,
        start_dir: North,
        par: 4,
        optimal: 3,
        hint: "Turn right then move to the goal.",
        available_commands: [Move, TurnLeft, TurnRight],
      }
    (0, 2) =>
      // Level 1-3: "L-Shape"
      {
        world: 0,
        index: 2,
        name: "L-Shape",
        ascii: [
          "############", "############", "####..G#####", "####..######",
          "####S.######", "############", "############", "############",
          "############",
        ],
        start_x: 4,
        start_y: 4,
        start_dir: North,
        par: 6,
        optimal: 4,
        hint: "Move north, turn, then go east.",
        available_commands: [Move, TurnLeft, TurnRight],
      }
    (0, 3) =>
      // Level 1-4: "Zigzag"
      {
        world: 0,
        index: 3,
        name: "Zigzag",
        ascii: [
          "############", "#####.G#####", "#####.######", "###...######",
          "###.########", "###...######", "#####.######", "#####S######",
          "############",
        ],
        start_x: 5,
        start_y: 7,
        start_dir: North,
        par: 12,
        optimal: 10,
        hint: "Navigate the zigzag path upward.",
        available_commands: [Move, TurnLeft, TurnRight],
      }
    (0, 4) =>
      // Level 1-5: "Two Goals"
      {
        world: 0,
        index: 4,
        name: "Two Goals",
        ascii: [
          "############", "############", "###G....G###", "###.....####",
          "###..S..####", "############", "############", "############",
          "############",
        ],
        start_x: 5,
        start_y: 4,
        start_dir: North,
        par: 10,
        optimal: 8,
        hint: "Collect both goals - plan your route!",
        available_commands: [Move, TurnLeft, TurnRight],
      }
    (0, 5) =>
      // Level 1-6: "Around the Wall"
      {
        world: 0,
        index: 5,
        name: "Around Wall",
        ascii: [
          "############", "############", "###.....####", "###.###.####",
          "###S###G####", "############", "############", "############",
          "############",
        ],
        start_x: 3,
        start_y: 4,
        start_dir: North,
        par: 10,
        optimal: 8,
        hint: "Go around the wall to reach the goal.",
        available_commands: [Move, TurnLeft, TurnRight],
      }
    (0, 6) =>
      // Level 1-7: "Spiral"
      {
        world: 0,
        index: 6,
        name: "Spiral",
        ascii: [
          "############", "##.......###", "##.#####.###", "##.###G#.###",
          "##.###...###", "##.###.####", "##S....#####", "############",
          "############",
        ],
        start_x: 2,
        start_y: 6,
        start_dir: East,
        par: 16,
        optimal: 14,
        hint: "Follow the spiral path inward.",
        available_commands: [Move, TurnLeft, TurnRight],
      }
    (0, 7) =>
      // Level 1-8: "Three Goals"
      {
        world: 0,
        index: 7,
        name: "Three Goals",
        ascii: [
          "############", "############", "##G......G##", "##........##",
          "##...S....##", "##........##", "##G.......##", "############",
          "############",
        ],
        start_x: 5,
        start_y: 4,
        start_dir: North,
        par: 16,
        optimal: 12,
        hint: "Collect all three goals efficiently.",
        available_commands: [Move, TurnLeft, TurnRight],
      }
    (0, 8) =>
      // Level 1-9: "Maze"
      {
        world: 0,
        index: 8,
        name: "Maze",
        ascii: [
          "############", "##S.#..G.###", "##..#..#.###", "##.##..#.###",
          "##.....#.###", "##.######.##", "##........##", "############",
          "############",
        ],
        start_x: 2,
        start_y: 1,
        start_dir: East,
        par: 20,
        optimal: 18,
        hint: "Find the shortest path through the maze.",
        available_commands: [Move, TurnLeft, TurnRight],
      }
    // ========================================
    // WORLD 2: LEAPS (+ Jump)
    // ========================================
    (1, 0) =>
      // Level 2-1: "First Jump"
      {
        world: 1,
        index: 0,
        name: "First Jump",
        ascii: [
          "############", "############", "############", "###S._.G####",
          "############", "############", "############", "############",
          "############",
        ],
        start_x: 3,
        start_y: 3,
        start_dir: East,
        par: 4,
        optimal: 3,
        hint: "Use Jump to leap over the gap!",
        available_commands: [Move, TurnLeft, TurnRight, Jump],
      }
    (1, 1) =>
      // Level 2-2: "Double Gap"
      {
        world: 1,
        index: 1,
        name: "Double Gap",
        ascii: [
          "############", "############", "############", "##S._._.G###",
          "############", "############", "############", "############",
          "############",
        ],
        start_x: 2,
        start_y: 3,
        start_dir: East,
        par: 6,
        optimal: 5,
        hint: "Jump over two gaps to reach the goal.",
        available_commands: [Move, TurnLeft, TurnRight, Jump],
      }
    (1, 2) =>
      // Level 2-3: "Jump the Wall"
      {
        world: 1,
        index: 2,
        name: "Jump Wall",
        ascii: [
          "############", "############", "############", "###S.#.G####",
          "############", "############", "############", "############",
          "############",
        ],
        start_x: 3,
        start_y: 3,
        start_dir: East,
        par: 4,
        optimal: 3,
        hint: "Jump can leap over walls too!",
        available_commands: [Move, TurnLeft, TurnRight, Jump],
      }
    (1, 3) =>
      // Level 2-4: "Gap Turn"
      {
        world: 1,
        index: 3,
        name: "Gap Turn",
        ascii: [
          "############", "############", "####.G######", "####.#######",
          "##S._.######", "############", "############", "############",
          "############",
        ],
        start_x: 2,
        start_y: 4,
        start_dir: East,
        par: 6,
        optimal: 5,
        hint: "Jump the gap, turn, then move to goal.",
        available_commands: [Move, TurnLeft, TurnRight, Jump],
      }
    (1, 4) =>
      // Level 2-5: "Island Hop"
      {
        world: 1,
        index: 4,
        name: "Island Hop",
        ascii: [
          "############", "############", "############", "##S._._._G##",
          "############", "############", "############", "############",
          "############",
        ],
        start_x: 2,
        start_y: 3,
        start_dir: East,
        par: 7,
        optimal: 6,
        hint: "Hop across the islands!",
        available_commands: [Move, TurnLeft, TurnRight, Jump],
      }
    (1, 5) =>
      // Level 2-6: "Jump Corner"
      {
        world: 1,
        index: 5,
        name: "Jump Corner",
        ascii: [
          "############", "############", "####..G#####", "####.##.####",
          "####_##.####", "##S..##.####", "############", "############",
          "############",
        ],
        start_x: 2,
        start_y: 5,
        start_dir: East,
        par: 10,
        optimal: 8,
        hint: "Combine jumps and turns.",
        available_commands: [Move, TurnLeft, TurnRight, Jump],
      }
    (1, 6) =>
      // Level 2-7: "Gauntlet"
      {
        world: 1,
        index: 6,
        name: "Gauntlet",
        ascii: [
          "############", "############", "############", "#S._.#._.G##",
          "############", "############", "############", "############",
          "############",
        ],
        start_x: 1,
        start_y: 3,
        start_dir: East,
        par: 7,
        optimal: 5,
        hint: "Jump over gaps and walls in sequence.",
        available_commands: [Move, TurnLeft, TurnRight, Jump],
      }
    (1, 7) =>
      // Level 2-8: "Two Path"
      {
        world: 1,
        index: 7,
        name: "Two Path",
        ascii: [
          "############", "############", "###..G..####", "###.##_.####",
          "###S##..####", "###..__.####", "###.....####", "############",
          "############",
        ],
        start_x: 3,
        start_y: 4,
        start_dir: North,
        par: 8,
        optimal: 5,
        hint: "Find the optimal path with jumps!",
        available_commands: [Move, TurnLeft, TurnRight, Jump],
      }
    (1, 8) =>
      // Level 2-9: "Leap of Faith"
      {
        world: 1,
        index: 8,
        name: "Leap of Faith",
        ascii: [
          "############", "##G._...####", "##.####.####", "##.####.####",
          "##._.__.####", "##.#########", "##S.########", "############",
          "############",
        ],
        start_x: 2,
        start_y: 6,
        start_dir: North,
        par: 14,
        optimal: 11,
        hint: "Navigate gaps with careful jumps.",
        available_commands: [Move, TurnLeft, TurnRight, Jump],
      }
    // ========================================
    // WORLD 3: LOGIC (+ If conditions, color tiles)
    // ========================================
    (2, 0) =>
      // Level 3-1: "Color Step"
      {
        world: 2,
        index: 0,
        name: "Color Step",
        ascii: [
          "############", "############", "############", "###S.R.G####",
          "############", "############", "############", "############",
          "############",
        ],
        start_x: 3,
        start_y: 3,
        start_dir: East,
        par: 4,
        optimal: 3,
        hint: "Walk over the color tile to the goal.",
        available_commands: [
          Move, TurnLeft, TurnRight, Jump, If(PathAhead), If(WallAhead),
          If(AtGoal), If(OnColor(Red)),
        ],
      }
    (2, 1) =>
      // Level 3-2: "If Wall"
      {
        world: 2,
        index: 1,
        name: "If Wall",
        ascii: [
          "############", "############", "####G.######", "####..######",
          "####.#######", "##S...######", "############", "############",
          "############",
        ],
        start_x: 2,
        start_y: 5,
        start_dir: East,
        par: 8,
        optimal: 6,
        hint: "Use If:WallAhead to decide when to turn.",
        available_commands: [
          Move, TurnLeft, TurnRight, Jump, If(PathAhead), If(WallAhead),
          If(AtGoal), If(OnColor(Red)),
        ],
      }
    (2, 2) =>
      // Level 3-3: "Red or Blue"
      {
        world: 2,
        index: 2,
        name: "Red or Blue",
        ascii: [
          "############", "############", "###...G#####", "###.########",
          "###R..B#####", "###.########", "###S..######", "############",
          "############",
        ],
        start_x: 3,
        start_y: 6,
        start_dir: North,
        par: 8,
        optimal: 6,
        hint: "Use color conditions to navigate.",
        available_commands: [
          Move, TurnLeft, TurnRight, Jump, If(PathAhead), If(WallAhead),
          If(OnColor(Red)), If(OnColor(Blue)),
        ],
      }
    (2, 3) =>
      // Level 3-4: "Path Check"
      {
        world: 2,
        index: 3,
        name: "Path Check",
        ascii: [
          "############", "############", "##G..#######", "##...#######",
          "##.#.#######", "##S..#######", "############", "############",
          "############",
        ],
        start_x: 2,
        start_y: 5,
        start_dir: East,
        par: 10,
        optimal: 7,
        hint: "Check if the path ahead is clear.",
        available_commands: [
          Move, TurnLeft, TurnRight, Jump, If(PathAhead), If(WallAhead),
          If(AtGoal), If(OnColor(Red)),
        ],
      }
    (2, 4) =>
      // Level 3-5: "Goal Sense"
      {
        world: 2,
        index: 4,
        name: "Goal Sense",
        ascii: [
          "############", "############", "##G....G####", "##......####",
          "##..S...####", "##......####", "############", "############",
          "############",
        ],
        start_x: 4,
        start_y: 4,
        start_dir: North,
        par: 12,
        optimal: 8,
        hint: "Use If:AtGoal to stop at goal tiles.",
        available_commands: [
          Move, TurnLeft, TurnRight, Jump, If(PathAhead), If(WallAhead),
          If(AtGoal), If(OnColor(Red)),
        ],
      }
    (2, 5) =>
      // Level 3-6: "Color Maze"
      {
        world: 2,
        index: 5,
        name: "Color Maze",
        ascii: [
          "############", "############", "###R..B#####", "###.##.#####",
          "###B..R#####", "###.##.#####", "###S..G#####", "############",
          "############",
        ],
        start_x: 3,
        start_y: 6,
        start_dir: East,
        par: 14,
        optimal: 10,
        hint: "Colors tell you which way to turn!",
        available_commands: [
          Move, TurnLeft, TurnRight, Jump, If(PathAhead), If(WallAhead),
          If(OnColor(Red)), If(OnColor(Blue)),
        ],
      }
    (2, 6) =>
      // Level 3-7: "Branch Path"
      {
        world: 2,
        index: 6,
        name: "Branch Path",
        ascii: [
          "############", "############", "###G.R.G####", "###.#.#.####",
          "####.S.#####", "############", "############", "############",
          "############",
        ],
        start_x: 5,
        start_y: 4,
        start_dir: North,
        par: 12,
        optimal: 9,
        hint: "The red tile tells you to turn.",
        available_commands: [
          Move, TurnLeft, TurnRight, Jump, If(PathAhead), If(WallAhead),
          If(AtGoal), If(OnColor(Red)),
        ],
      }
    (2, 7) =>
      // Level 3-8: "Triple Color"
      {
        world: 2,
        index: 7,
        name: "Triple Color",
        ascii: [
          "############", "############", "##G..N..####", "##.##.######",
          "##R..B.G####", "##.########", "##S..#######", "############",
          "############",
        ],
        start_x: 2,
        start_y: 6,
        start_dir: North,
        par: 14,
        optimal: 10,
        hint: "Use all three colors as signals.",
        available_commands: [
          Move, TurnLeft, TurnRight, Jump, If(PathAhead), If(WallAhead),
          If(OnColor(Red)), If(OnColor(Blue)), If(OnColor(Green)),
        ],
      }
    (2, 8) =>
      // Level 3-9: "Logic Master"
      {
        world: 2,
        index: 8,
        name: "Logic Master",
        ascii: [
          "############", "##G...R.####", "##.##.#.####", "##.##...####",
          "##B##.#.####", "##..._.G####", "##S.########", "############",
          "############",
        ],
        start_x: 2,
        start_y: 6,
        start_dir: North,
        par: 16,
        optimal: 12,
        hint: "Combine conditions with jumps!",
        available_commands: [
          Move, TurnLeft, TurnRight, Jump, If(PathAhead), If(WallAhead),
          If(AtGoal), If(OnColor(Red)), If(OnColor(Blue)),
        ],
      }
    // ========================================
    // WORLD 4: MASTERY (+ Push, Loop)
    // ========================================
    (3, 0) =>
      // Level 4-1: "First Push"
      {
        world: 3,
        index: 0,
        name: "First Push",
        ascii: [
          "############", "############", "############", "###S.O.G####",
          "############", "############", "############", "############",
          "############",
        ],
        start_x: 3,
        start_y: 3,
        start_dir: East,
        par: 5,
        optimal: 4,
        hint: "Push the block out of the way!",
        available_commands: [
          Move, TurnLeft, TurnRight, Jump, Push, If(PathAhead), If(WallAhead),
          Loop(2), Loop(3),
        ],
      }
    (3, 1) =>
      // Level 4-2: "Fill the Gap"
      {
        world: 3,
        index: 1,
        name: "Fill the Gap",
        ascii: [
          "############", "############", "############", "##S.O_.G####",
          "############", "############", "############", "############",
          "############",
        ],
        start_x: 2,
        start_y: 3,
        start_dir: East,
        par: 6,
        optimal: 4,
        hint: "Push the block into the gap to fill it!",
        available_commands: [
          Move, TurnLeft, TurnRight, Jump, Push, If(PathAhead), If(WallAhead),
          Loop(2), Loop(3),
        ],
      }
    (3, 2) =>
      // Level 4-3: "Loop Walk"
      {
        world: 3,
        index: 2,
        name: "Loop Walk",
        ascii: [
          "############", "############", "############", "##S.....G###",
          "############", "############", "############", "############",
          "############",
        ],
        start_x: 2,
        start_y: 3,
        start_dir: East,
        par: 4,
        optimal: 2,
        hint: "Use Loop to repeat Move commands!",
        available_commands: [
          Move, TurnLeft, TurnRight, Jump, Push, If(PathAhead), If(WallAhead),
          Loop(2), Loop(3),
        ],
      }
    (3, 3) =>
      // Level 4-4: "Push and Turn"
      {
        world: 3,
        index: 3,
        name: "Push and Turn",
        ascii: [
          "############", "############", "####.G######", "####.O######",
          "##S...######", "############", "############", "############",
          "############",
        ],
        start_x: 2,
        start_y: 4,
        start_dir: East,
        par: 8,
        optimal: 6,
        hint: "Push the block north to reach the goal.",
        available_commands: [
          Move, TurnLeft, TurnRight, Jump, Push, If(PathAhead), If(WallAhead),
          Loop(2), Loop(3),
        ],
      }
    (3, 4) =>
      // Level 4-5: "Loop Turn"
      {
        world: 3,
        index: 4,
        name: "Loop Turn",
        ascii: [
          "############", "############", "##G.........##", "##.########.##",
          "##.########.##", "##..........##", "###########S##",
          "############", "############",
        ],
        start_x: 11,
        start_y: 6,
        start_dir: North,
        par: 12,
        optimal: 8,
        hint: "Use loops to move efficiently along walls.",
        available_commands: [
          Move, TurnLeft, TurnRight, Jump, Push, If(PathAhead), If(WallAhead),
          Loop(2), Loop(3), Loop(4), Loop(5),
        ],
      }
    (3, 5) =>
      // Level 4-6: "Bridge Builder"
      {
        world: 3,
        index: 5,
        name: "Bridge Builder",
        ascii: [
          "############", "############", "############", "##S.OO__G###",
          "############", "############", "############", "############",
          "############",
        ],
        start_x: 2,
        start_y: 3,
        start_dir: East,
        par: 8,
        optimal: 6,
        hint: "Push blocks into gaps to build a bridge!",
        available_commands: [
          Move, TurnLeft, TurnRight, Jump, Push, If(PathAhead), If(WallAhead),
          Loop(2), Loop(3),
        ],
      }
    (3, 6) =>
      // Level 4-7: "Double Push"
      {
        world: 3,
        index: 6,
        name: "Double Push",
        ascii: [
          "############", "############", "####G.######", "####_.######",
          "####O.######", "##S.O.######", "############", "############",
          "############",
        ],
        start_x: 2,
        start_y: 5,
        start_dir: East,
        par: 10,
        optimal: 7,
        hint: "Push blocks to fill gaps and reach the goal.",
        available_commands: [
          Move, TurnLeft, TurnRight, Jump, Push, If(PathAhead), If(WallAhead),
          Loop(2), Loop(3),
        ],
      }
    (3, 7) =>
      // Level 4-8: "Complex Loop"
      {
        world: 3,
        index: 7,
        name: "Complex Loop",
        ascii: [
          "############", "###G..######", "###.#.######", "###..#######",
          "###.#.######", "###..#######", "###S..######", "############",
          "############",
        ],
        start_x: 3,
        start_y: 6,
        start_dir: East,
        par: 14,
        optimal: 10,
        hint: "Loop a turn-move-turn-move pattern!",
        available_commands: [
          Move, TurnLeft, TurnRight, Jump, Push, If(PathAhead), If(WallAhead),
          Loop(2), Loop(3), Loop(4), Loop(5),
        ],
      }
    (3, 8) =>
      // Level 4-9: "Grand Finale"
      {
        world: 3,
        index: 8,
        name: "Grand Finale",
        ascii: [
          "############", "##G..R..####", "##.##.#.####", "##.##O..####",
          "##B##_#.####", "##..._.G####", "##S.########", "############",
          "############",
        ],
        start_x: 2,
        start_y: 6,
        start_dir: North,
        par: 18,
        optimal: 14,
        hint: "Use everything you've learned!",
        available_commands: [
          Move, TurnLeft, TurnRight, Jump, Push, If(PathAhead), If(WallAhead),
          If(OnColor(Red)), If(OnColor(Blue)), Loop(2), Loop(3),
        ],
      }
    _ =>
      // Fallback - simple level
      {
        world: 0,
        index: 0,
        name: "Empty",
        ascii: [
          "############", "############", "############", "#####SG#####",
          "############", "############", "############", "############",
          "############",
        ],
        start_x: 5,
        start_y: 3,
        start_dir: East,
        par: 2,
        optimal: 1,
        hint: "Just move forward!",
        available_commands: [Move, TurnLeft, TurnRight],
      }
  }
}

///|
pub fn parse_level(def : @types.LevelDef) -> @types.Level {
  let grid = @types.new_grid(@types.grid_width, @types.grid_height)
  let goals : Array[@types.Vec2i] = []
  let blocks : Array[@types.Vec2i] = []
  for y in 0..<@types.grid_height {
    if y < def.ascii.length() {
      let row = def.ascii[y]
      for x in 0..<@types.grid_width {
        if x < row.length() {
          let ch = row[x]
          match ch {
            '#' => @types.grid_set(grid, x, y, Wall)
            '.' => @types.grid_set(grid, x, y, Floor)
            '_' => @types.grid_set(grid, x, y, Gap)
            'G' => {
              @types.grid_set(grid, x, y, Goal)
              goals.push(@types.vec2i(x, y))
            }
            'R' => @types.grid_set(grid, x, y, ColorTile(Red))
            'B' => @types.grid_set(grid, x, y, ColorTile(Blue))
            'N' => @types.grid_set(grid, x, y, ColorTile(Green))
            'O' => {
              @types.grid_set(grid, x, y, Floor)
              blocks.push(@types.vec2i(x, y))
            }
            'S' => @types.grid_set(grid, x, y, Start)
            '>' | 'v' | '<' | '^' => @types.grid_set(grid, x, y, Start)
            _ => @types.grid_set(grid, x, y, Floor)
          }
        }
      }
    }
  }
  let goals_collected : Array[Bool] = []
  for _i in 0..<goals.length() {
    goals_collected.push(false)
  }
  let robot = @types.new_robot(def.start_x, def.start_y, def.start_dir)
  { grid, robot, goals, goals_collected, blocks }
}

///|
pub fn reload_level(def : @types.LevelDef) -> @types.Level {
  parse_level(def)
}

///|
pub fn get_world_name(world : Int) -> String {
  @types.world_name(world)
}

///|
pub fn get_level_name(world : Int, index : Int) -> String {
  let def = get_level_def(world, index)
  def.name
}

///|
pub fn total_levels() -> Int {
  @types.num_worlds * @types.levels_per_world
}
