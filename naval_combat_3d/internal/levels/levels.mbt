// Battle definitions - 12 scenarios
// Returns (enemy_count, enemy_hp, enemy_speed, enemy_fire_rate, enemy_damage, detect_range, score_per_kill)

///|
/// Returns core battle tuning `(enemy_count, hp, speed, fire_rate, damage, detect_range, score_per_kill)`.
pub fn get_battle_def(
  battle : Int,
) -> (Int, Float, Float, Float, Float, Float, Int) {
  if battle == 0 {
    // Patrol Duty: Easy intro, 2 sloops
    (2, 40.0, 3.0, 3.0, 6.0, 35.0, 100)
  } else if battle == 1 {
    // Coastal Skirmish: 3 sloops
    (3, 45.0, 3.5, 2.8, 7.0, 38.0, 120)
  } else if battle == 2 {
    // Open Water: 4 mixed
    (4, 50.0, 3.5, 2.5, 8.0, 40.0, 150)
  } else if battle == 3 {
    // Island Ambush: enemies behind islands
    (4, 60.0, 4.0, 2.3, 9.0, 42.0, 180)
  } else if battle == 4 {
    // Channel Run: narrow passage, 5 enemies
    (5, 65.0, 4.0, 2.0, 10.0, 45.0, 200)
  } else if battle == 5 {
    // Fortress Assault: fortress island + escort
    (4, 70.0, 4.5, 1.8, 11.0, 45.0, 250)
  } else if battle == 6 {
    // Fleet Engagement: 6 brigantines
    (6, 80.0, 4.0, 2.0, 12.0, 45.0, 280)
  } else if battle == 7 {
    // Escort Mission: protect convoy
    (5, 70.0, 4.5, 1.8, 11.0, 48.0, 300)
  } else if battle == 8 {
    // Night Raid: heavy hitters
    (5, 90.0, 3.5, 1.8, 14.0, 40.0, 350)
  } else if battle == 9 {
    // Blockade Run: survive and break through
    (7, 80.0, 4.5, 1.5, 12.0, 48.0, 300)
  } else if battle == 10 {
    // Grand Battle: 8 ships mixed
    (8, 100.0, 4.5, 1.5, 13.0, 50.0, 380)
  } else {
    // Final Stand: 8 heavy warships
    (8, 130.0, 5.0, 1.2, 16.0, 55.0, 500)
  }
}

// Get battle name

///|
/// Returns the display name for a battle scenario index.
pub fn get_battle_name(battle : Int) -> String {
  if battle == 0 {
    "Patrol Duty"
  } else if battle == 1 {
    "Coastal Skirmish"
  } else if battle == 2 {
    "Open Water"
  } else if battle == 3 {
    "Island Ambush"
  } else if battle == 4 {
    "Channel Run"
  } else if battle == 5 {
    "Fortress Assault"
  } else if battle == 6 {
    "Fleet Engagement"
  } else if battle == 7 {
    "Escort Mission"
  } else if battle == 8 {
    "Night Raid"
  } else if battle == 9 {
    "Blockade Run"
  } else if battle == 10 {
    "Grand Battle"
  } else {
    "Final Stand"
  }
}

// Get battle description

// Get battle difficulty (1-5 stars)

///|
/// Returns a difficulty rating from 1 to 5 for the battle scenario.
pub fn get_battle_difficulty(battle : Int) -> Int {
  if battle <= 1 {
    1
  } else if battle <= 3 {
    2
  } else if battle <= 5 {
    3
  } else if battle <= 8 {
    4
  } else {
    5
  }
}

// Get battle objective type

///|
/// Returns the objective type id used by battle win/fail logic.
pub fn get_battle_objective_type(battle : Int) -> Int {
  if battle == 5 {
    // Fortress assault: destroy fortress + ships
    @types.objective_destroy_all
  } else if battle == 7 {
    @types.objective_escort_convoy
  } else if battle == 9 {
    @types.objective_blockade_run
  } else {
    @types.objective_destroy_all
  }
}

// Get battle objective description

///|
/// Returns the player-facing objective text for a battle.
pub fn get_battle_objective_desc(battle : Int) -> String {
  let obj_type = get_battle_objective_type(battle)
  if obj_type == @types.objective_destroy_all {
    "Destroy all enemy ships"
  } else if obj_type == @types.objective_escort_convoy {
    "Protect the convoy ships"
  } else if obj_type == @types.objective_blockade_run {
    "Reach the far side of the map"
  } else {
    "Complete the objective"
  }
}

// Get enemy ship classes per battle
// Returns array of ship class IDs

///|
/// Returns enemy ship class ids to spawn for the battle.
pub fn get_enemy_classes(battle : Int) -> Array[@types.ShipClass] {
  if battle == 0 {
    [Sloop, Sloop]
  } else if battle == 1 {
    [Sloop, Sloop, Sloop]
  } else if battle == 2 {
    [
      Sloop, Sloop, Brigantine, Brigantine,
    ]
  } else if battle == 3 {
    [
      Brigantine, Brigantine, Sloop, Sloop,
    ]
  } else if battle == 4 {
    [
      Brigantine, Brigantine, Brigantine,
      Sloop, Sloop,
    ]
  } else if battle == 5 {
    [
      Brigantine, Brigantine, Frigate, Sloop,
    ]
  } else if battle == 6 {
    [
      Brigantine, Brigantine, Brigantine,
      Brigantine, Brigantine, Brigantine,
    ]
  } else if battle == 7 {
    [
      Sloop, Sloop, Brigantine, Brigantine,
      Frigate,
    ]
  } else if battle == 8 {
    [
      Frigate, Frigate, Galleon, Brigantine,
      Brigantine,
    ]
  } else if battle == 9 {
    [
      Brigantine, Brigantine, Frigate, Frigate,
      Frigate, Galleon, Galleon,
    ]
  } else if battle == 10 {
    [
      Frigate, Frigate, Frigate, Galleon,
      Galleon, Brigantine, Brigantine, ManOfWar,
    ]
  } else {
    [
      Galleon, Galleon, Galleon, Frigate,
      Frigate, ManOfWar, ManOfWar, ManOfWar,
    ]
  }
}

// Get AI personalities per battle

///|
/// Returns AI personality ids for each spawned enemy ship.
pub fn get_enemy_personalities(battle : Int) -> Array[@types.AiPersonality] {
  if battle == 0 {
    [Defensive, Defensive]
  } else if battle == 1 {
    [
      Aggressive, Defensive, Flanker,
    ]
  } else if battle == 2 {
    [
      Aggressive, Flanker, Defensive,
      Aggressive,
    ]
  } else if battle == 3 {
    [
      Flanker, Flanker, Aggressive,
      Retreater,
    ]
  } else if battle == 4 {
    [
      Aggressive, Aggressive, Defensive,
      Flanker, Flanker,
    ]
  } else if battle == 5 {
    [
      Defensive, Defensive, Aggressive,
      Flanker,
    ]
  } else if battle == 6 {
    [
      Aggressive, Aggressive, Flanker,
      Flanker, Defensive, Berserker,
    ]
  } else if battle == 7 {
    [
      Berserker, Berserker, Aggressive,
      Aggressive, Flanker,
    ]
  } else if battle == 8 {
    [
      Aggressive, Aggressive, Berserker,
      Flanker, Defensive,
    ]
  } else if battle == 9 {
    [
      Defensive, Defensive, Aggressive,
      Aggressive, Flanker, Flanker,
      Defensive,
    ]
  } else if battle == 10 {
    [
      Aggressive, Berserker, Flanker,
      Defensive, Aggressive, Flanker,
      Aggressive, Berserker,
    ]
  } else {
    [
      Berserker, Berserker, Aggressive,
      Aggressive, Flanker, Berserker,
      Berserker, Aggressive,
    ]
  }
}

// Which battle index has a fortress island

// Get fortress island index for a battle (-1 if none)

///|
/// Returns the fortress island index for the battle, or `-1` when absent.
pub fn get_fortress_island(battle : Int) -> Int {
  if battle == 5 {
    0
  } else if battle == 9 {
    2
  } else if battle == 11 {
    0
  } else {
    -1
  }
}

// Get fleet ship count for battle (allied ships)

// Get fleet ship classes

///|
/// Returns allied fleet ship class ids for this battle.
pub fn get_fleet_classes(battle : Int) -> Array[@types.ShipClass] {
  if battle <= 4 {
    []
  } else if battle == 5 {
    [Sloop]
  } else if battle == 6 {
    [Brigantine]
  } else if battle == 7 {
    [Brigantine]
  } else if battle == 8 {
    [Sloop, Sloop]
  } else if battle == 9 {
    [Brigantine, Sloop]
  } else if battle == 10 {
    [Frigate, Brigantine, Sloop]
  } else {
    [Frigate, Brigantine, Brigantine]
  }
}

// Get convoy ship count

///|
/// Returns the number of convoy ships to escort in this battle.
pub fn get_convoy_count(battle : Int) -> Int {
  if battle == 7 {
    3
  } else {
    0
  }
}

// Get starting wind conditions per battle

///|
/// Returns starting wind `(direction, speed, shift_interval_seconds)` for the battle.
pub fn get_wind_conditions(battle : Int) -> (Float, Float, Float) {
  // Returns (direction, speed, shift_interval)
  if battle == 0 {
    (0.5, @types.wind_speed_moderate, 20.0)
  } else if battle == 1 {
    (1.2, @types.wind_speed_moderate, 18.0)
  } else if battle == 2 {
    (2.0, @types.wind_speed_strong, 15.0)
  } else if battle == 3 {
    (0.8, @types.wind_speed_light, 25.0)
  } else if battle == 4 {
    (@types.pi * 0.5, @types.wind_speed_strong, 12.0)
  } else if battle == 5 {
    (1.5, @types.wind_speed_moderate, 18.0)
  } else if battle == 6 {
    (2.5, @types.wind_speed_strong, 10.0)
  } else if battle == 7 {
    (0.0, @types.wind_speed_moderate, 20.0)
  } else if battle == 8 {
    (@types.pi, @types.wind_speed_light, 30.0)
  } else if battle == 9 {
    (@types.pi * 0.75, @types.wind_speed_gale, 8.0)
  } else if battle == 10 {
    (1.0, @types.wind_speed_strong, 12.0)
  } else {
    (@types.pi * 0.5, @types.wind_speed_gale, 6.0)
  }
}

// Island layout per battle
// Returns array of (x, z, radius, height, block_count)

///|
/// Returns island layout tuples `(x, z, radius, height, block_count)` for the battle map.
pub fn get_island_layout(
  battle : Int,
) -> Array[(Float, Float, Float, Float, Int)] {
  if battle == 0 {
    [(30.0, 30.0, 6.0, 4.0, 4), (-25.0, -20.0, 5.0, 3.0, 3)]
  } else if battle == 1 {
    [
      (0.0, 35.0, 7.0, 5.0, 5),
      (-30.0, -10.0, 5.0, 3.0, 3),
      (25.0, -25.0, 4.0, 2.5, 2),
    ]
  } else if battle == 2 {
    [
      (20.0, 20.0, 6.0, 4.0, 4),
      (-20.0, 25.0, 5.0, 3.5, 3),
      (0.0, -30.0, 8.0, 5.0, 5),
      (-35.0, -15.0, 4.0, 2.0, 2),
    ]
  } else if battle == 3 {
    [
      (15.0, 30.0, 7.0, 5.0, 5),
      (-25.0, 20.0, 6.0, 4.0, 4),
      (30.0, -20.0, 5.0, 3.0, 3),
      (-15.0, -30.0, 6.0, 4.0, 4),
      (0.0, 0.0, 4.0, 2.0, 2),
    ]
  } else if battle == 4 {
    // Channel: two long island barriers
    [
      (25.0, 25.0, 8.0, 5.0, 6),
      (-30.0, 15.0, 6.0, 4.0, 4),
      (10.0, -35.0, 7.0, 4.5, 5),
      (-20.0, -25.0, 5.0, 3.0, 3),
      (30.0, -10.0, 6.0, 4.0, 4),
      (-25.0, 30.0, 5.0, 3.5, 3),
    ]
  } else if battle == 5 {
    // Fortress in center
    [
      (0.0, 0.0, 10.0, 7.0, 6),
      (30.0, 30.0, 6.0, 4.0, 4),
      (-30.0, 30.0, 5.0, 3.0, 3),
      (25.0, -20.0, 4.0, 2.5, 2),
      (-25.0, -25.0, 5.0, 3.5, 3),
    ]
  } else if battle == 6 {
    [
      (0.0, 30.0, 9.0, 6.0, 6),
      (30.0, 0.0, 7.0, 4.5, 5),
      (-30.0, 0.0, 7.0, 4.5, 5),
      (0.0, -30.0, 9.0, 6.0, 6),
      (20.0, 20.0, 4.0, 2.5, 2),
      (-20.0, -20.0, 4.0, 2.5, 2),
    ]
  } else if battle == 7 {
    // Escort: islands along convoy route
    [
      (20.0, -30.0, 6.0, 4.0, 4),
      (-20.0, -10.0, 5.0, 3.0, 3),
      (25.0, 10.0, 7.0, 5.0, 5),
      (-30.0, 30.0, 6.0, 4.0, 4),
      (15.0, 40.0, 5.0, 3.0, 3),
    ]
  } else if battle == 8 {
    [
      (20.0, 30.0, 6.0, 4.0, 4),
      (-20.0, 30.0, 6.0, 4.0, 4),
      (35.0, 0.0, 5.0, 3.0, 3),
      (-35.0, 0.0, 5.0, 3.0, 3),
      (20.0, -30.0, 6.0, 4.0, 4),
      (-20.0, -30.0, 6.0, 4.0, 4),
      (0.0, 0.0, 5.0, 3.0, 3),
    ]
  } else if battle == 9 {
    // Blockade: barrier of islands
    [
      (-40.0, 20.0, 8.0, 5.0, 5),
      (-15.0, 25.0, 6.0, 4.0, 4),
      (15.0, 20.0, 7.0, 5.0, 5),
      (40.0, 25.0, 6.0, 4.0, 4),
      (0.0, -30.0, 5.0, 3.0, 3),
      (-30.0, -15.0, 4.0, 2.5, 2),
      (30.0, -10.0, 5.0, 3.0, 3),
    ]
  } else if battle == 10 {
    [
      (25.0, 25.0, 7.0, 5.0, 5),
      (-25.0, 25.0, 7.0, 5.0, 5),
      (25.0, -25.0, 7.0, 5.0, 5),
      (-25.0, -25.0, 7.0, 5.0, 5),
      (0.0, 35.0, 5.0, 3.0, 3),
      (0.0, -35.0, 5.0, 3.0, 3),
      (35.0, 0.0, 5.0, 3.0, 3),
      (-35.0, 0.0, 5.0, 3.0, 3),
    ]
  } else {
    // Final: fortress islands
    [
      (0.0, 40.0, 10.0, 8.0, 7),
      (30.0, 30.0, 6.0, 4.0, 4),
      (-30.0, 30.0, 6.0, 4.0, 4),
      (40.0, 0.0, 7.0, 5.0, 5),
      (-40.0, 0.0, 7.0, 5.0, 5),
      (25.0, -25.0, 5.0, 3.0, 3),
      (-25.0, -25.0, 5.0, 3.0, 3),
      (0.0, -40.0, 8.0, 6.0, 5),
    ]
  }
}

// Island types per battle (parallel to layout)

///|
/// Returns island type ids aligned with `get_island_layout` ordering.
pub fn get_island_types(battle : Int) -> Array[@types.IslandKind] {
  if battle == 0 {
    [Medium, Small]
  } else if battle == 1 {
    [Medium, Small, Small]
  } else if battle == 2 {
    [
      Medium, Small, Large, Small,
    ]
  } else if battle == 3 {
    [
      Medium, Medium, Small, Medium,
      Small,
    ]
  } else if battle == 4 {
    [
      Large, Medium, Medium, Small,
      Medium, Small,
    ]
  } else if battle == 5 {
    [
      Fortress, Medium, Small, Small,
      Small,
    ]
  } else if battle == 6 {
    [
      Large, Medium, Medium, Large,
      Small, Small,
    ]
  } else if battle == 7 {
    [
      Medium, Small, Medium, Medium,
      Small,
    ]
  } else if battle == 8 {
    [
      Medium, Medium, Small, Small,
      Medium, Medium, Small,
    ]
  } else if battle == 9 {
    [
      Large, Medium, Fortress, Medium,
      Small, Small, Small,
    ]
  } else if battle == 10 {
    [
      Medium, Medium, Medium, Medium,
      Small, Small, Small, Small,
    ]
  } else {
    [
      Fortress, Medium, Medium, Medium,
      Medium, Small, Small, Large,
    ]
  }
}

// Enemy starting positions relative to center, returns (angle, distance)

///|
/// Returns spawn polar coordinates `(angle_radians, distance_units)` for an enemy index.
pub fn get_enemy_spawn_angle(idx : Int, total : Int) -> (Float, Float) {
  let base_angle : Float = 6.28318 *
    Float::from_int(idx) /
    Float::from_int(total)
  let dist : Float = 45.0
  (base_angle, dist)
}

// Get flagship index for a battle (-1 if no flagship)

///|
/// Returns the flagship enemy index for the battle, or `-1` if none.
pub fn get_flagship_index(battle : Int) -> Int {
  if battle >= 6 {
    0
  } else {
    -1
  }
}

// Get reward score multiplier for battle

///|
/// Returns reward multiplier applied to battle completion rewards.
pub fn get_battle_reward_mult(battle : Int) -> Int {
  if battle <= 2 {
    1
  } else if battle <= 5 {
    2
  } else if battle <= 8 {
    3
  } else {
    4
  }
}

// Cannon type per enemy class for a given battle

///|
/// Returns cannon type id equipped by an enemy ship class for the battle context.
pub fn get_enemy_cannon_type(ship_class : @types.ShipClass, battle : Int) -> @types.Cannon {
  match ship_class {
    Sloop => Light
    Brigantine => if battle >= 6 { Medium } else { Light }
    Frigate => Medium
    Galleon => if battle >= 10 { Heavy } else { Medium }
    ManOfWar => Heavy
  }
}
