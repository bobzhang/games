// missions.mbt - Mission template definitions.
// Each mission has unique terrain, enemy composition, objectives, and rewards.

///|
pub(all) struct MissionDef {
  id : Int
  name : String
  description : String
  objective : @types.Objective
  grid_template : Int             // terrain layout id
  enemy_types : Array[(@types.EnemyType, Int, Int)]  // (type, x, y)
  special_tiles : Array[(Int, Int, @types.TileKind)]  // (x, y, tile kind)
  hazard_tiles : Array[(Int, Int, @types.HazardKind)] // (x, y, hazard)
  turns_limit : Int
  reward_tier : Int               // 1=basic, 2=good, 3=great
}

///|
pub fn get_mission_def(id : Int) -> MissionDef {
  match id {
    0 => mission_first_contact()
    1 => mission_minefield()
    2 => mission_beam_gauntlet()
    3 => mission_swarm()
    4 => mission_boss_siege_engine()
    5 => mission_shield_wall()
    6 => mission_escort_run()
    7 => mission_capture()
    8 => mission_boss_hivemind()
    _ => mission_first_contact()
  }
}

///|
pub fn get_mission_count() -> Int {
  9
}

///|
/// Mission 0: "First Contact" - Survive 4 turns vs 3 Rammers (tutorial)
fn mission_first_contact() -> MissionDef {
  {
    id: 0,
    name: "First Contact",
    description: "Survive the initial assault. Learn the basics.",
    objective: Survive(4),
    grid_template: 0,
    enemy_types: [
      (Rammer, 6, 1),
      (Rammer, 6, 4),
      (Rammer, 7, 3),
    ],
    special_tiles: [],
    hazard_tiles: [],
    turns_limit: 6,
    reward_tier: 1,
  }
}

///|
/// Mission 1: "Minefield" - Assassinate MineLayer while avoiding mines
fn mission_minefield() -> MissionDef {
  {
    id: 1,
    name: "Minefield",
    description: "Eliminate the Mine Layer. Watch your step.",
    objective: Assassinate(0),
    grid_template: 1,
    enemy_types: [
      (MineLayer, 6, 3),
      (Rammer, 7, 1),
      (Rammer, 7, 5),
    ],
    special_tiles: [],
    hazard_tiles: [
      (3, 2, Mine),
      (4, 4, Mine),
      (5, 1, Mine),
      (5, 5, Mine),
    ],
    turns_limit: 8,
    reward_tier: 1,
  }
}

///|
/// Mission 2: "Beam Gauntlet" - Destroy 2 BeamTurrets in narrow corridor
fn mission_beam_gauntlet() -> MissionDef {
  {
    id: 2,
    name: "Beam Gauntlet",
    description: "Destroy the turrets guarding the corridor.",
    objective: Assassinate(0),
    grid_template: 2,
    enemy_types: [
      (BeamTurret, 6, 2),
      (BeamTurret, 6, 5),
      (Leaper, 7, 4),
    ],
    special_tiles: [
      (3, 0, Wall),
      (3, 1, Wall),
      (3, 6, Wall),
      (3, 7, Wall),
      (4, 0, Wall),
      (4, 7, Wall),
    ],
    hazard_tiles: [],
    turns_limit: 8,
    reward_tier: 2,
  }
}

///|
/// Mission 3: "Swarm" - Survive 5 turns vs Splitters (they multiply)
fn mission_swarm() -> MissionDef {
  {
    id: 3,
    name: "Swarm",
    description: "Splitters multiply when destroyed. Survive the tide.",
    objective: Survive(5),
    grid_template: 3,
    enemy_types: [
      (Splitter, 5, 2),
      (Splitter, 6, 4),
      (Splitter, 7, 1),
      (Splitter, 7, 6),
    ],
    special_tiles: [(4, 3, Chasm), (4, 4, Chasm)],
    hazard_tiles: [],
    turns_limit: 7,
    reward_tier: 2,
  }
}

///|
/// Mission 4: "Boss: Siege Engine" - Defeat boss with phase transitions
fn mission_boss_siege_engine() -> MissionDef {
  {
    id: 4,
    name: "Siege Engine",
    description: "A massive war machine. It charges and slams.",
    objective: Assassinate(0),
    grid_template: 4,
    enemy_types: [
      (Boss, 6, 3),
      (Rammer, 7, 1),
      (Artillery, 7, 6),
    ],
    special_tiles: [(3, 3, Wall), (3, 4, Wall)],
    hazard_tiles: [(5, 2, Fire), (5, 5, Fire)],
    turns_limit: 10,
    reward_tier: 3,
  }
}

///|
/// Mission 5: "Shield Wall" - Kill ShieldDrone protecting Artillery
fn mission_shield_wall() -> MissionDef {
  {
    id: 5,
    name: "Shield Wall",
    description: "Shield Drones protect the Artillery. Break through.",
    objective: Assassinate(0),
    grid_template: 5,
    enemy_types: [
      (Artillery, 7, 3),
      (ShieldDrone, 6, 2),
      (ShieldDrone, 6, 4),
      (Rammer, 5, 6),
    ],
    special_tiles: [],
    hazard_tiles: [],
    turns_limit: 8,
    reward_tier: 2,
  }
}

///|
/// Mission 6: "Escort Run" - Move a mech across the grid
fn mission_escort_run() -> MissionDef {
  {
    id: 6,
    name: "Escort Run",
    description: "Get one mech to the far side of the grid.",
    objective: Escort(0, 7),
    grid_template: 6,
    enemy_types: [
      (Rammer, 4, 2),
      (Rammer, 4, 5),
      (BeamTurret, 6, 3),
      (Leaper, 7, 1),
    ],
    special_tiles: [(3, 0, Wall), (3, 7, Wall)],
    hazard_tiles: [(5, 3, Acid), (5, 4, Acid)],
    turns_limit: 8,
    reward_tier: 2,
  }
}

///|
/// Mission 7: "Capture" - Hold 3 control points for 3 turns
fn mission_capture() -> MissionDef {
  {
    id: 7,
    name: "Capture",
    description: "Hold 3 control points simultaneously.",
    objective: CapturePoints(3),
    grid_template: 7,
    enemy_types: [
      (Rammer, 6, 1),
      (Rammer, 6, 6),
      (Leaper, 7, 3),
      (ShieldDrone, 5, 4),
    ],
    special_tiles: [
      (3, 1, ControlPoint),
      (4, 4, ControlPoint),
      (5, 6, ControlPoint),
    ],
    hazard_tiles: [],
    turns_limit: 10,
    reward_tier: 2,
  }
}

///|
/// Mission 8: "Boss: Hivemind" - Defeat boss that summons minions
fn mission_boss_hivemind() -> MissionDef {
  {
    id: 8,
    name: "Hivemind",
    description: "The Hivemind summons minions and absorbs their HP.",
    objective: Assassinate(0),
    grid_template: 8,
    enemy_types: [
      (Boss, 6, 3),
      (Splitter, 7, 1),
      (Splitter, 7, 5),
      (ShieldDrone, 5, 3),
    ],
    special_tiles: [(3, 2, Lava), (3, 5, Lava)],
    hazard_tiles: [(3, 2, Fire), (3, 5, Fire)],
    turns_limit: 12,
    reward_tier: 3,
  }
}

///|
/// Get the boss HP for a specific boss mission.
pub fn get_boss_hp(mission_id : Int) -> Int {
  match mission_id {
    4 => 12   // Siege Engine - tanky
    8 => 10   // Hivemind - moderate but regenerates
    _ => 8    // Default boss HP
  }
}

///|
/// Check if a mission is a boss mission.
pub fn is_boss_mission(mission_id : Int) -> Bool {
  mission_id == 4 || mission_id == 8
}
