// Map and wave data

// Map layouts - returns array of strings (20 chars wide, 15 tall)
// Legend: '.' = grass, '#' = path, 'S' = start, 'E' = end, '~' = water, 'R' = rock

///|
/// Returns the tile layout strings for the map at `map_idx`.
pub fn get_map_data(map_idx : Int) -> Array[String] {
  if map_idx == 0 {
    // Map 1: Serpentine - Classic zigzag path
    [
      "....................", "S###................", "...#................", "...#####............",
      ".......#............", ".......####.........", "..........#.........", "..........####......",
      ".............#......", ".............####...", "................#...", "................####",
      "...................E", "....................", "....................",
    ]
  } else if map_idx == 1 {
    // Map 2: Spiral - Enemies spiral inward
    [
      "....................", "S################..", ".................#..", "..#############..#..",
      "..#...........#..#..", "..#..#######..#..#..", "..#..#.....#..#..#..", "..#..#..E..#..#..#..",
      "..#..#.....#..#..#..", "..#..#######..#..#..", "..#...........#..#..", "..#############..#..",
      ".................#..", "..################..", "....................",
    ]
  } else if map_idx == 2 {
    // Map 3: Crossroads - Path crosses itself
    [
      "........S...........", "........#...........", "........#...........", "........####........",
      "...........#........", "...........#........", "S####......####....", "....#.........#....",
      "....#.........#....", "....######....#....", ".........#....#....", ".........######....",
      ".................E..", "....................", "....................",
    ]
  } else if map_idx == 3 {
    // Map 4: Figure-8 - Enemies loop around twice
    [
      "....................", "..S###########......", "..#..........#......", "..#..........#......",
      "..#..........#......", "..#####..#####......", "......#..#..........", "......#..#..........",
      "..#####..#####......", "..#..........#......", "..#..........#......", "..#..........#......",
      "..############E.....", "....................", "....................",
    ]
  } else {
    // Map 5: Fortress - Open field with water hazards
    [
      "....................", ".S##...............", "...#..~~...........", "...####~~..........",
      "......#............", "......####.........", "..~~.....#..~~.....", "..~~.....#..~~.....",
      ".........####......", "............#......", "..........###......", "..........#........",
      "....~~....####E....", "....~~.............", "....................",
    ]
  }
}

// Map info for display

///|
/// Returns the metadata for the map at `map_idx` including name and difficulty.
pub fn get_map_info(map_idx : Int) -> @types.MapInfo {
  if map_idx == 0 {
    {
      name: "Serpentine",
      difficulty: 1,
      layout: get_map_data(0),
      description: "Classic zigzag path",
      starting_gold_bonus: 0,
    }
  } else if map_idx == 1 {
    {
      name: "Spiral",
      difficulty: 2,
      layout: get_map_data(1),
      description: "Enemies spiral inward",
      starting_gold_bonus: 50,
    }
  } else if map_idx == 2 {
    {
      name: "Crossroads",
      difficulty: 2,
      layout: get_map_data(2),
      description: "Paths cross each other",
      starting_gold_bonus: 25,
    }
  } else if map_idx == 3 {
    {
      name: "Figure-8",
      difficulty: 3,
      layout: get_map_data(3),
      description: "Looping double path",
      starting_gold_bonus: 75,
    }
  } else {
    {
      name: "Fortress",
      difficulty: 3,
      layout: get_map_data(4),
      description: "Open field with hazards",
      starting_gold_bonus: 100,
    }
  }
}

// Wave definitions - 30 waves

///|
/// Returns the enemy kind, count, HP multiplier, and speed multiplier for `wave`.
pub fn get_wave_def(wave : Int) -> (@types.EnemyKind, Int, Float, Float) {
  // Returns (enemy_kind, count, hp_mult, speed_mult)
  if wave == 0 {
    (Basic, 8, 1.0, 1.0)
  } else if wave == 1 {
    (Basic, 12, 1.0, 1.0)
  } else if wave == 2 {
    (Fast, 8, 1.0, 1.0)
  } else if wave == 3 {
    (Basic, 15, 1.3, 1.0)
  } else if wave == 4 {
    (Tank, 5, 1.0, 1.0)
  } else if wave == 5 {
    (Swarm, 20, 0.8, 1.2)
  } else if wave == 6 {
    (Fast, 15, 1.0, 1.2)
  } else if wave == 7 {
    (Flying, 6, 1.0, 1.0)
  } else if wave == 8 {
    (Healer, 4, 1.0, 0.9)
  } else if wave == 9 {
    (Boss, 1, 1.0, 0.7)
  } else if wave == 10 {
    (Basic, 25, 2.0, 1.1)
  } else if wave == 11 {
    (Shield, 6, 1.5, 0.9)
  } else if wave == 12 {
    (Camo, 8, 1.2, 1.3)
  } else if wave == 13 {
    (Splitter, 5, 1.5, 1.0)
  } else if wave == 14 {
    (Boss, 2, 1.5, 0.8)
  } else if wave == 15 {
    (Swarm, 35, 1.0, 1.3)
  } else if wave == 16 {
    (Tank, 12, 2.5, 1.0)
  } else if wave == 17 {
    (Flying, 15, 2.0, 1.2)
  } else if wave == 18 {
    (Healer, 8, 2.0, 1.0)
  } else if wave == 19 {
    (Boss, 3, 2.0, 0.8)
  } else if wave == 20 {
    (Fast, 30, 2.5, 1.5)
  } else if wave == 21 {
    (Shield, 10, 2.5, 1.0)
  } else if wave == 22 {
    (Splitter, 8, 2.5, 1.1)
  } else if wave == 23 {
    (Camo, 12, 2.0, 1.5)
  } else if wave == 24 {
    (Boss, 4, 2.5, 0.9)
  } else if wave == 25 {
    (Swarm, 50, 1.5, 1.5)
  } else if wave == 26 {
    (Tank, 20, 3.5, 1.0)
  } else if wave == 27 {
    (Flying, 20, 3.0, 1.3)
  } else if wave == 28 {
    (Healer, 12, 3.0, 1.1)
  } else {
    (Boss, 5, 3.5, 0.9)
  }
}

// Extended wave info for multi-group waves

///|
/// Returns the extended wave info with spawn groups and bonus gold for `wave`.
pub fn get_wave_info(wave : Int) -> @types.WaveInfo {
  if wave == 0 {
    {
      entries: [
        {
          enemy_kind: Basic,
          count: 8,
          hp_mult: 1.0,
          speed_mult: 1.0,
          spawn_delay: 0.8,
        },
      ],
      is_boss_wave: false,
      bonus_gold: 0,
      wave_message: "First wave incoming!",
    }
  } else if wave == 4 {
    {
      entries: [
        {
          enemy_kind: Tank,
          count: 5,
          hp_mult: 1.0,
          speed_mult: 1.0,
          spawn_delay: 1.2,
        },
      ],
      is_boss_wave: false,
      bonus_gold: 10,
      wave_message: "Heavy enemies approach!",
    }
  } else if wave == 5 {
    {
      entries: [
        {
          enemy_kind: Swarm,
          count: 20,
          hp_mult: 0.8,
          speed_mult: 1.2,
          spawn_delay: 0.3,
        },
      ],
      is_boss_wave: false,
      bonus_gold: 15,
      wave_message: "Swarm alert!",
    }
  } else if wave == 7 {
    {
      entries: [
        {
          enemy_kind: Flying,
          count: 6,
          hp_mult: 1.0,
          speed_mult: 1.0,
          spawn_delay: 1.0,
        },
      ],
      is_boss_wave: false,
      bonus_gold: 15,
      wave_message: "Flyers incoming!",
    }
  } else if wave == 8 {
    {
      entries: [
        {
          enemy_kind: Healer,
          count: 4,
          hp_mult: 1.0,
          speed_mult: 0.9,
          spawn_delay: 1.5,
        },
      ],
      is_boss_wave: false,
      bonus_gold: 20,
      wave_message: "Medics on the field!",
    }
  } else if wave == 9 {
    {
      entries: [
        {
          enemy_kind: Boss,
          count: 1,
          hp_mult: 1.0,
          speed_mult: 0.7,
          spawn_delay: 2.0,
        },
      ],
      is_boss_wave: true,
      bonus_gold: 50,
      wave_message: "BOSS WAVE!",
    }
  } else if wave == 11 {
    {
      entries: [
        {
          enemy_kind: Shield,
          count: 6,
          hp_mult: 1.5,
          speed_mult: 0.9,
          spawn_delay: 1.2,
        },
      ],
      is_boss_wave: false,
      bonus_gold: 20,
      wave_message: "Shielded enemies!",
    }
  } else if wave == 12 {
    {
      entries: [
        {
          enemy_kind: Camo,
          count: 8,
          hp_mult: 1.2,
          speed_mult: 1.3,
          spawn_delay: 0.8,
        },
      ],
      is_boss_wave: false,
      bonus_gold: 20,
      wave_message: "Stealth units detected!",
    }
  } else if wave == 13 {
    {
      entries: [
        {
          enemy_kind: Splitter,
          count: 5,
          hp_mult: 1.5,
          speed_mult: 1.0,
          spawn_delay: 1.5,
        },
      ],
      is_boss_wave: false,
      bonus_gold: 25,
      wave_message: "Splitter enemies!",
    }
  } else if wave == 14 {
    {
      entries: [
        {
          enemy_kind: Boss,
          count: 2,
          hp_mult: 1.5,
          speed_mult: 0.8,
          spawn_delay: 3.0,
        },
      ],
      is_boss_wave: true,
      bonus_gold: 75,
      wave_message: "Double BOSS!",
    }
  } else if wave == 19 {
    {
      entries: [
        {
          enemy_kind: Boss,
          count: 3,
          hp_mult: 2.0,
          speed_mult: 0.8,
          spawn_delay: 3.0,
        },
      ],
      is_boss_wave: true,
      bonus_gold: 100,
      wave_message: "Triple BOSS!",
    }
  } else if wave == 24 {
    {
      entries: [
        {
          enemy_kind: Boss,
          count: 4,
          hp_mult: 2.5,
          speed_mult: 0.9,
          spawn_delay: 2.5,
        },
      ],
      is_boss_wave: true,
      bonus_gold: 125,
      wave_message: "Quad BOSS!",
    }
  } else if wave == 29 {
    {
      entries: [
        {
          enemy_kind: Boss,
          count: 5,
          hp_mult: 3.5,
          speed_mult: 0.9,
          spawn_delay: 2.0,
        },
      ],
      is_boss_wave: true,
      bonus_gold: 200,
      wave_message: "FINAL BOSS WAVE!",
    }
  } else {
    let def = get_wave_def(wave)
    {
      entries: [
        {
          enemy_kind: def.0,
          count: def.1,
          hp_mult: def.2,
          speed_mult: def.3,
          spawn_delay: @types.spawn_interval,
        },
      ],
      is_boss_wave: false,
      bonus_gold: @types.wave_completion_bonus,
      wave_message: "Wave \{wave + 1}",
    }
  }
}

///|
/// Returns the base hit points for an enemy of the given `kind`.
pub fn enemy_base_hp(kind : Int) -> Float {
  if kind == 0 {
    30.0
  } else if kind == 1 {
    20.0
  } else if kind == 2 {
    80.0
  } else if kind == 3 {
    25.0
  } else if kind == 4 {
    300.0
  } else if kind == 5 {
    40.0
  } else if kind == 6 {
    12.0
  } else if kind == 7 {
    60.0
  } else if kind == 8 {
    22.0
  } else if kind == 9 {
    50.0
  } else {
    30.0
  }
}

///|
/// Returns the base movement speed for an enemy of the given `kind`.
pub fn enemy_base_speed(kind : Int) -> Float {
  if kind == 0 {
    2.5
  } else if kind == 1 {
    4.0
  } else if kind == 2 {
    1.5
  } else if kind == 3 {
    3.0
  } else if kind == 4 {
    1.2
  } else if kind == 5 {
    2.0
  } else if kind == 6 {
    3.5
  } else if kind == 7 {
    1.8
  } else if kind == 8 {
    3.2
  } else if kind == 9 {
    2.2
  } else {
    2.5
  }
}

///|
/// Returns the gold reward for killing an enemy of the given `kind`.
pub fn enemy_gold_value(kind : Int) -> Int {
  if kind == 0 {
    10
  } else if kind == 1 {
    12
  } else if kind == 2 {
    25
  } else if kind == 3 {
    15
  } else if kind == 4 {
    100
  } else if kind == 5 {
    20
  } else if kind == 6 {
    5
  } else if kind == 7 {
    30
  } else if kind == 8 {
    18
  } else if kind == 9 {
    22
  } else {
    10
  }
}

// Enemy score value (may differ from gold)

///|
/// Returns the score points awarded for killing an enemy of the given `kind`.
pub fn enemy_score_value(kind : Int) -> Int {
  if kind == 0 {
    10
  } else if kind == 1 {
    15
  } else if kind == 2 {
    30
  } else if kind == 3 {
    20
  } else if kind == 4 {
    200
  } else if kind == 5 {
    25
  } else if kind == 6 {
    5
  } else if kind == 7 {
    35
  } else if kind == 8 {
    25
  } else if kind == 9 {
    30
  } else {
    10
  }
}

// Check if enemy type is flying

///|
/// Returns whether the enemy `kind` is an airborne flying type.
pub fn enemy_is_flying(kind : Int) -> Bool {
  kind == 3
}

// Check if enemy type is a boss

///|
/// Returns whether the enemy `kind` is a boss type.
pub fn enemy_is_boss(kind : Int) -> Bool {
  kind == 4
}

// Check if enemy type is camo

///|
/// Returns whether the enemy `kind` is a camouflaged stealth type.
pub fn enemy_is_camo(kind : Int) -> Bool {
  kind == 8
}

// Check if enemy type spawns children on death

///|
/// Returns whether the enemy `kind` splits into children on death.
pub fn enemy_spawns_children(kind : Int) -> Bool {
  kind == 9
}

// Check if enemy type heals others

// Check if enemy type has shield

///|
/// Returns whether the enemy `kind` has a regenerating energy shield.
pub fn enemy_has_shield(kind : Int) -> Bool {
  kind == 7
}

// Get shield HP for shield enemies

///|
/// Returns the initial shield HP for an enemy of `kind` scaled by `hp_mult`.
pub fn enemy_shield_hp(kind : Int, hp_mult : Float) -> Float {
  if kind == 7 {
    let base_hp = enemy_base_hp(kind) * hp_mult
    base_hp * @types.shield_max_pct
  } else {
    0.0
  }
}
