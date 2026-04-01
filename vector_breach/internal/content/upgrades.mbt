// upgrades.mbt - Mech upgrade paths using Grid Power.
// Each mech class has 3 tiers of upgrades.

///|
pub(all) struct UpgradeDef {
  name : String
  description : String
  cost : Int
  tier : Int
  mech_class : @types.MechClass
}

///|
/// Get upgrade definition for a mech class at a specific tier (1-3).
pub fn get_upgrade_def(class_ : @types.MechClass, tier : Int) -> UpgradeDef {
  match class_ {
    Vanguard =>
      match tier {
        1 =>
          {
            name: "Reinforced Plating",
            description: "+1 HP, +1 push range",
            cost: 2,
            tier: 1,
            mech_class: Vanguard,
          }
        2 =>
          {
            name: "Fortress Mode",
            description: "Skip move to gain 3 shield",
            cost: 4,
            tier: 2,
            mech_class: Vanguard,
          }
        _ =>
          {
            name: "Gravity Well",
            description: "Pull ALL adjacent enemies 1 tile",
            cost: 6,
            tier: 3,
            mech_class: Vanguard,
          }
      }
    Striker =>
      match tier {
        1 =>
          {
            name: "Combat Edge",
            description: "+1 move range, +1 damage",
            cost: 2,
            tier: 1,
            mech_class: Striker,
          }
        2 =>
          {
            name: "Phase Dash",
            description: "Dash through enemies",
            cost: 4,
            tier: 2,
            mech_class: Striker,
          }
        _ =>
          {
            name: "Execute",
            description: "2x damage to targets below 25% HP",
            cost: 6,
            tier: 3,
            mech_class: Striker,
          }
      }
    Sentinel =>
      match tier {
        1 =>
          {
            name: "Extended Optics",
            description: "+1 range, +1 artillery radius",
            cost: 2,
            tier: 1,
            mech_class: Sentinel,
          }
        2 =>
          {
            name: "Overwatch",
            description: "Auto-attack first enemy in range",
            cost: 4,
            tier: 2,
            mech_class: Sentinel,
          }
        _ =>
          {
            name: "Orbital Strike",
            description: "Once/mission: 5 dmg in 5x5 area",
            cost: 6,
            tier: 3,
            mech_class: Sentinel,
          }
      }
  }
}

///|
/// Get the cost of the next upgrade for a mech class given current tier.
pub fn get_next_upgrade_cost(current_tier : Int) -> Int {
  match current_tier {
    0 => 2
    1 => 4
    2 => 6
    _ => 0 // Already maxed
  }
}

///|
/// Get the mech class index (0=Vanguard, 1=Striker, 2=Sentinel).
pub fn mech_class_index(class_ : @types.MechClass) -> Int {
  match class_ {
    Vanguard => 0
    Striker => 1
    Sentinel => 2
  }
}

///|
/// Try to purchase an upgrade for a mech class. Returns true on success.
pub fn try_purchase_upgrade(
  run : @types.RunState,
  class_ : @types.MechClass,
) -> Bool {
  let idx = mech_class_index(class_)
  let current_tier = run.upgrade_tiers[idx]
  if current_tier >= 3 {
    return false // Already maxed
  }
  let cost = get_next_upgrade_cost(current_tier)
  if run.grid_power < cost {
    return false // Not enough GP
  }
  run.grid_power -= cost
  run.upgrade_tiers[idx] = current_tier + 1
  true
}

///|
/// Get the current upgrade tier for a mech class.
pub fn get_upgrade_tier(
  run : @types.RunState,
  class_ : @types.MechClass,
) -> Int {
  let idx = mech_class_index(class_)
  run.upgrade_tiers[idx]
}

///|
/// Apply tier 1 stat bonuses to mech stats.
pub fn apply_upgrade_stats(
  class_ : @types.MechClass,
  tier : Int,
  hp : Int,
  move_range : Int,
  ability_range : Int,
  ability_damage : Int,
) -> (Int, Int, Int, Int) {
  match class_ {
    Vanguard =>
      if tier >= 1 {
        (hp + 1, move_range, ability_range, ability_damage)
      } else {
        (hp, move_range, ability_range, ability_damage)
      }
    Striker =>
      if tier >= 1 {
        (hp, move_range + 1, ability_range, ability_damage + 1)
      } else {
        (hp, move_range, ability_range, ability_damage)
      }
    Sentinel =>
      if tier >= 1 {
        (hp, move_range, ability_range + 1, ability_damage)
      } else {
        (hp, move_range, ability_range, ability_damage)
      }
  }
}
