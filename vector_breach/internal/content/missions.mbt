// missions.mbt - Mission template definitions.
// Each mission has unique terrain, enemy composition, objectives, and rewards.

///|
pub(all) struct MissionDef {
  id : Int
  name : String
  description : String
  briefing : String
  debrief : String
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
    briefing: "Commander, hostile mechs detected in Sector 7. Deploy your squad and hold the line. This is your first operation - proceed with caution. Use the terrain to your advantage and keep your mechs alive.",
    debrief: "First engagement survived. Your squad handled the pressure well. Hostile signatures are increasing across the sector - prepare for escalation.",
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
    briefing: "A Mine Layer has fortified sector perimeter with explosive ordnance. The grid is littered with mines. Push enemies into their own traps if you can - every mine they trigger is one less for your squad.",
    debrief: "Mine Layer neutralized. The sector is clear of explosive hazards. Scans show more complex threats ahead - the enemy is adapting to our tactics.",
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
    briefing: "Two Beam Turrets have locked down a critical corridor. Their firing lanes cover the entire approach. Use walls for cover and advance carefully. The Leaper flanking from behind adds urgency - do not let it close the gap.",
    debrief: "Corridor secured. Those turrets were well-positioned, but nothing your squad cannot handle. Intelligence reports heavier resistance in the next sector.",
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
    briefing: "Splitter units detected en masse. When destroyed, each one splits into smaller fragments. Push them into the chasms instead of fighting them head-on. Survival is the objective - do not get overwhelmed.",
    debrief: "The swarm has been weathered. Your squad held its ground against impossible numbers. Command is impressed - but the real test awaits.",
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
    briefing: "Intel reports a Siege Engine approaching the grid. It is heavily armored with phase-shifting capabilities. Target its weak points when it charges - that is your window. The fire zones on either side restrict your flanking options.",
    debrief: "The Siege Engine has been reduced to scrap. That was a hard-won victory, Commander. Your squad has proven it can handle the worst the enemy has to offer.",
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
    briefing: "An Artillery unit is shelling our forward positions, protected by Shield Drones. The drones regenerate shields each turn - you must break through the shield wall and eliminate the Artillery before it levels the sector.",
    debrief: "Artillery silenced. The shield wall tactic is a concern - expect the enemy to deploy similar formations going forward. Adaptability is our greatest weapon.",
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
    briefing: "We need to punch through enemy lines and reach the extraction point on the far side. Acid pools block the direct path and turret fire covers the approach. Move fast, push obstacles aside, and get at least one mech across.",
    debrief: "Extraction point reached. The corridor is now open for reinforcements. Your ability to adapt under fire continues to impress. One final push remains.",
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
    briefing: "Three control points must be captured simultaneously to unlock the Hivemind's command frequency. Spread your squad thin and hold the points. Enemy units will try to displace you - use push mechanics to maintain your positions.",
    debrief: "Control points secured. The Hivemind's signal has been triangulated. All that remains is the final assault. Prepare your squad for the hardest battle yet.",
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
    briefing: "The Hivemind has been located. It controls all remaining hostile units in the sector. It summons Splitters and absorbs their life force to regenerate. Destroy the minions away from it, then strike while it is vulnerable. End this conflict for good.",
    debrief: "The Hivemind is destroyed. All hostile units in the sector have gone dark. The war is over, Commander. Your squad has earned its place in history.",
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
