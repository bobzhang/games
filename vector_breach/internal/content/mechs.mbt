///|
pub(all) struct MechStats {
  name : String
  mech_class : @types.MechClass
  hp : Int
  max_heat : Int
  move_range : Int
  ability_name : String
  ability_range : Int
  ability_damage : Int
}

///|
pub fn get_mech_stats(class_ : @types.MechClass) -> MechStats {
  match class_ {
    Vanguard =>
      {
        name: "Vanguard",
        mech_class: Vanguard,
        hp: 7,
        max_heat: 3,
        move_range: 3,
        ability_name: "Ram Charge",
        ability_range: 3,
        ability_damage: 1,
      }
    Striker =>
      {
        name: "Striker",
        mech_class: Striker,
        hp: 4,
        max_heat: 3,
        move_range: 4,
        ability_name: "Blade Dash",
        ability_range: 2,
        ability_damage: 3,
      }
    Sentinel =>
      {
        name: "Sentinel",
        mech_class: Sentinel,
        hp: 5,
        max_heat: 3,
        move_range: 2,
        ability_name: "Pulse Cannon",
        ability_range: 5,
        ability_damage: 2,
      }
  }
}

///|
pub fn get_enemy_hp(etype : @types.EnemyType) -> Int {
  match etype {
    Rammer => 3
    Artillery => 2
    BeamTurret => 4
    Leaper => 2
    MineLayer => 2
    ShieldDrone => 1
    Splitter => 2
    Boss => 8
  }
}

///|
pub fn get_enemy_name(etype : @types.EnemyType) -> String {
  match etype {
    Rammer => "Rammer"
    Artillery => "Artillery"
    BeamTurret => "Beam Turret"
    Leaper => "Leaper"
    MineLayer => "Mine Layer"
    ShieldDrone => "Shield Drone"
    Splitter => "Splitter"
    Boss => "Boss"
  }
}
