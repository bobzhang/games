///|
pub fn get_skirmish_map(index : Int) -> @types.LevelDef {
  match index {
    0 => skirmish_plains()
    1 => skirmish_forest()
    2 => skirmish_islands()
    3 => skirmish_fortress()
    _ => skirmish_plains()
  }
}

///|
pub fn skirmish_map_name(index : Int) -> String {
  match index {
    0 => "Open Plains"
    1 => "Dense Forest"
    2 => "Island Chain"
    3 => "Twin Fortress"
    _ => "Open Plains"
  }
}

///|
fn skirmish_plains() -> @types.LevelDef {
  {
    name: "Open Plains",
    width: 10,
    height: 8,
    terrain: [
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0,
    ],
    player_units: [],
    enemy_units: [],
    victory: EliminateAll,
    description: "Wide open plains with scattered hills.",
  }
}

///|
fn skirmish_forest() -> @types.LevelDef {
  {
    name: "Dense Forest",
    width: 10,
    height: 8,
    terrain: [
      0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 0, 0, 1, 0,
      0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0,
      0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1,
      0, 0, 1, 0, 0, 1, 0, 0,
    ],
    player_units: [],
    enemy_units: [],
    victory: EliminateAll,
    description: "Thick forest terrain favors infantry.",
  }
}

///|
fn skirmish_islands() -> @types.LevelDef {
  {
    name: "Island Chain",
    width: 10,
    height: 8,
    terrain: [
      3, 0, 0, 3, 3, 3, 0, 0, 3, 3, 0, 0, 0, 3, 3, 0, 0, 0, 3, 3, 0, 0, 0, 0,
      3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 3, 3, 0, 0, 0, 3, 3, 0, 0, 0, 3, 3,
      0, 0, 3, 3, 3, 0, 0, 3,
    ],
    player_units: [],
    enemy_units: [],
    victory: EliminateAll,
    description: "Navigate between islands. Movement is key.",
  }
}

///|
fn skirmish_fortress() -> @types.LevelDef {
  {
    name: "Twin Fortress",
    width: 10,
    height: 8,
    terrain: [
      2, 2, 1, 0, 0, 0, 0, 0, 0, 0, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 0, 0,
      0, 0, 0, 0, 0, 1, 2, 2,
    ],
    player_units: [],
    enemy_units: [],
    victory: EliminateAll,
    description: "Fortified positions on each side.",
  }
}

// Generate units for skirmish based on army size

///|
pub fn generate_skirmish_units(
  army_size : Int
) -> (Array[(@types.UnitKind, Int, Int)], Array[(@types.UnitKind, Int, Int)]) {
  let player : Array[(@types.UnitKind, Int, Int)] = []
  let enemy : Array[(@types.UnitKind, Int, Int)] = []
  for i = 0; i < army_size; i = i + 1 {
    let kind : @types.UnitKind = match i % 3 {
      0 => Infantry
      1 => Cavalry
      _ => Artillery
    }
    let prow = @types.mini(i, 7)
    let erow = @types.mini(i, 7)
    player.push((kind, 0, prow))
    enemy.push((kind, 9, erow))
  }
  (player, enemy)
}
