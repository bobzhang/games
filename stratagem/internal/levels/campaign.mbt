// 12 Campaign levels with progressive difficulty
// Terrain codes: 0=Plains, 1=Forest, 2=Hills, 3=Water

///|
pub fn get_campaign_level(index : Int) -> @types.LevelDef {
  match index {
    0 => level_01()
    1 => level_02()
    2 => level_03()
    3 => level_04()
    4 => level_05()
    5 => level_06()
    6 => level_07()
    7 => level_08()
    8 => level_09()
    9 => level_10()
    10 => level_11()
    11 => level_12()
    _ => level_01()
  }
}

///|
fn level_01() -> @types.LevelDef {
  // First Contact - learn basics with infantry
  {
    name: "First Contact",
    width: 10,
    height: 8,
    terrain: [
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0,
    ],
    player_units: [(Infantry, 1, 3), (Infantry, 1, 4), (Infantry, 2, 3)],
    enemy_units: [(Infantry, 8, 3), (Infantry, 8, 4)],
    victory: EliminateAll,
    description: "Your first engagement. Destroy all enemy infantry.",
  }
}

///|
fn level_02() -> @types.LevelDef {
  // Forest Ambush - learn forest terrain
  {
    name: "Forest Ambush",
    width: 10,
    height: 8,
    terrain: [
      0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1,
      1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0,
      0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0,
    ],
    player_units: [(Infantry, 0, 3), (Infantry, 0, 4), (Infantry, 1, 3)],
    enemy_units: [(Infantry, 7, 2), (Infantry, 7, 3), (Infantry, 8, 4)],
    victory: EliminateAll,
    description: "Use the forest for cover. Infantry excels here.",
  }
}

///|
fn level_03() -> @types.LevelDef {
  // Cavalry Charge - introduce cavalry
  {
    name: "Cavalry Charge",
    width: 10,
    height: 8,
    terrain: [
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0,
    ],
    player_units: [
      (Infantry, 1, 3),
      (Infantry, 1, 4),
      (Cavalry, 0, 1),
      (Cavalry, 0, 6),
    ],
    enemy_units: [(Infantry, 8, 3), (Infantry, 8, 4), (Infantry, 7, 3)],
    victory: EliminateAll,
    description: "Use cavalry to flank the enemy infantry.",
  }
}

///|
fn level_04() -> @types.LevelDef {
  // Artillery Hill - introduce artillery and hills
  {
    name: "Artillery Hill",
    width: 10,
    height: 8,
    terrain: [
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2,
      0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0,
      0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0,
    ],
    player_units: [(Infantry, 1, 3), (Infantry, 1, 4), (Artillery, 0, 3)],
    enemy_units: [(Infantry, 8, 3), (Infantry, 8, 4), (Cavalry, 9, 2)],
    victory: EliminateAll,
    description: "Seize the hill for artillery advantage.",
  }
}

///|
fn level_05() -> @types.LevelDef {
  // River Crossing
  {
    name: "River Crossing",
    width: 10,
    height: 8,
    terrain: [
      0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3,
      0, 0, 0, 0, 0,
    ],
    player_units: [
      (Infantry, 0, 3),
      (Cavalry, 0, 4),
      (Artillery, 1, 2),
      (Infantry, 1, 5),
    ],
    enemy_units: [(Infantry, 8, 3), (Infantry, 8, 4), (Artillery, 9, 3)],
    victory: EliminateAll,
    description: "Cross the river through the ford. Water is impassable!",
  }
}

///|
fn level_06() -> @types.LevelDef {
  // Fog of War
  {
    name: "Fog Assault",
    width: 10,
    height: 8,
    terrain: [
      0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0,
      0, 1, 0, 0, 0,
    ],
    player_units: [
      (Infantry, 0, 2),
      (Cavalry, 0, 5),
      (Infantry, 1, 3),
      (Artillery, 0, 3),
    ],
    enemy_units: [
      (Infantry, 8, 2),
      (Infantry, 8, 5),
      (Cavalry, 9, 3),
      (Artillery, 9, 4),
    ],
    victory: EliminateAll,
    description: "Use cavalry scouts to reveal enemy positions.",
  }
}

///|
fn level_07() -> @types.LevelDef {
  // Capture the Flag
  {
    name: "Capture the Flag",
    width: 10,
    height: 8,
    terrain: [
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2,
      2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0,
    ],
    player_units: [
      (Infantry, 0, 3),
      (Cavalry, 0, 1),
      (Cavalry, 0, 6),
      (Infantry, 1, 4),
      (Artillery, 1, 3),
    ],
    enemy_units: [
      (Infantry, 8, 3),
      (Infantry, 9, 3),
      (Infantry, 8, 4),
      (Cavalry, 9, 1),
    ],
    victory: CaptureFlag(9, 3),
    description: "Capture the enemy flag position at col 9, row 3!",
  }
}

///|
fn level_08() -> @types.LevelDef {
  // Fortified Position
  {
    name: "Fortified Position",
    width: 10,
    height: 8,
    terrain: [
      0, 0, 0, 0, 0, 1, 1, 2, 0, 0, 0, 0, 0, 0, 0, 1, 2, 2, 0, 0, 0, 0, 0, 0, 0,
      0, 1, 2, 2, 0, 0, 0, 0, 0, 0, 0, 1, 2, 2, 0, 0, 0, 0, 0, 0, 0, 1, 2, 2, 0,
      0, 0, 0, 0, 0, 0, 1, 2, 2, 0, 0, 0, 0, 0, 0, 1, 2, 2, 0, 0, 0, 0, 0, 0, 0,
      1, 1, 2, 0, 0,
    ],
    player_units: [
      (Infantry, 0, 2),
      (Infantry, 0, 3),
      (Infantry, 0, 4),
      (Cavalry, 0, 0),
      (Cavalry, 0, 7),
      (Artillery, 1, 3),
    ],
    enemy_units: [
      (Infantry, 8, 2),
      (Infantry, 8, 3),
      (Infantry, 8, 4),
      (Artillery, 9, 3),
      (Artillery, 9, 4),
    ],
    victory: EliminateAll,
    description: "Break through the fortified enemy position.",
  }
}

///|
fn level_09() -> @types.LevelDef {
  // Island Assault
  {
    name: "Island Assault",
    width: 10,
    height: 8,
    terrain: [
      3, 3, 0, 0, 3, 3, 3, 0, 0, 3, 3, 0, 0, 0, 3, 3, 0, 0, 0, 3, 0, 0, 0, 0, 3,
      3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 3, 3, 0, 0, 0, 0, 3, 0, 0, 0, 3, 3, 0, 0, 0, 3, 3, 3, 0, 0, 3,
      3, 3, 0, 0, 3,
    ],
    player_units: [
      (Infantry, 2, 2),
      (Infantry, 2, 3),
      (Cavalry, 3, 1),
      (Artillery, 2, 4),
      (Infantry, 3, 5),
    ],
    enemy_units: [
      (Infantry, 7, 2),
      (Infantry, 7, 3),
      (Cavalry, 7, 5),
      (Artillery, 8, 3),
      (Infantry, 7, 4),
    ],
    victory: EliminateAll,
    description: "Navigate the narrow land bridges to defeat the enemy.",
  }
}

///|
fn level_10() -> @types.LevelDef {
  // Mixed Arms
  {
    name: "Mixed Arms",
    width: 10,
    height: 8,
    terrain: [
      0, 1, 0, 0, 2, 0, 0, 1, 0, 0, 0, 0, 1, 0, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 2, 0, 0, 0, 1, 0, 0, 1, 0, 0, 2,
      0, 0, 1, 0, 0,
    ],
    player_units: [
      (Infantry, 0, 2),
      (Infantry, 0, 3),
      (Cavalry, 0, 0),
      (Cavalry, 0, 7),
      (Artillery, 1, 3),
      (Artillery, 1, 4),
    ],
    enemy_units: [
      (Infantry, 9, 2),
      (Infantry, 9, 3),
      (Cavalry, 9, 0),
      (Cavalry, 9, 7),
      (Artillery, 8, 3),
      (Artillery, 8, 4),
    ],
    victory: EliminateAll,
    description: "A full combined arms engagement. Use every unit type wisely.",
  }
}

///|
fn level_11() -> @types.LevelDef {
  // Last Stand
  {
    name: "Last Stand",
    width: 10,
    height: 8,
    terrain: [
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 2,
      1, 0, 0, 0, 0, 0, 0, 1, 2, 2, 1, 0, 0, 0, 0, 0, 0, 1, 2, 2, 1, 0, 0, 0, 0,
      0, 0, 1, 2, 2, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0,
    ],
    player_units: [
      (Infantry, 3, 3),
      (Infantry, 3, 4),
      (Artillery, 4, 3),
      (Artillery, 4, 4),
    ],
    enemy_units: [
      (Infantry, 0, 2),
      (Infantry, 0, 5),
      (Cavalry, 0, 0),
      (Cavalry, 0, 7),
      (Infantry, 9, 2),
      (Infantry, 9, 5),
      (Cavalry, 9, 0),
      (Cavalry, 9, 7),
    ],
    victory: EliminateAll,
    description: "Defend the hill against attacks from both sides!",
  }
}

///|
fn level_12() -> @types.LevelDef {
  // Final Battle
  {
    name: "Final Battle",
    width: 10,
    height: 8,
    terrain: [
      0, 1, 0, 0, 2, 3, 0, 0, 1, 0, 0, 0, 1, 0, 2, 3, 0, 1, 0, 0, 0, 0, 0, 0, 0,
      3, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0,
      0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 1, 0, 2, 3, 0, 1, 0, 0, 0, 1, 0, 0, 2,
      3, 0, 0, 1, 0,
    ],
    player_units: [
      (Infantry, 0, 2),
      (Infantry, 0, 3),
      (Infantry, 0, 4),
      (Infantry, 0, 5),
      (Cavalry, 0, 0),
      (Cavalry, 0, 7),
      (Artillery, 1, 3),
      (Artillery, 1, 4),
    ],
    enemy_units: [
      (Infantry, 9, 2),
      (Infantry, 9, 3),
      (Infantry, 9, 4),
      (Infantry, 9, 5),
      (Cavalry, 9, 0),
      (Cavalry, 9, 7),
      (Artillery, 8, 3),
      (Artillery, 8, 4),
      (Artillery, 7, 3),
    ],
    victory: CaptureFlag(9, 3),
    description: "The final battle. Capture the enemy HQ to win the war!",
  }
}
