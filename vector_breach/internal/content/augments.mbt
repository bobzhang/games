// augments.mbt - Augment definitions and utility functions.
// Augments are permanent upgrades earned between missions that modify mech abilities.

///|
pub(all) struct AugmentDef {
  kind : @types.AugmentKind
  name : String
  description : String
  icon : String // single character icon for display
}

///|
pub fn get_augment_def(kind : @types.AugmentKind) -> AugmentDef {
  match kind {
    ExtendedBarrel =>
      {
        kind: ExtendedBarrel,
        name: "Extended Barrel",
        description: "+1 range on ranged attacks",
        icon: ">",
      }
    HeavyFrame =>
      {
        kind: HeavyFrame,
        name: "Heavy Frame",
        description: "+2 max HP, -1 move range",
        icon: "#",
      }
    OverchargedPush =>
      {
        kind: OverchargedPush,
        name: "Overcharged Push",
        description: "Push distance +1",
        icon: "^",
      }
    ShieldGenerator =>
      {
        kind: ShieldGenerator,
        name: "Shield Generator",
        description: "Start battles with 2 shield",
        icon: "O",
      }
    HeatSink =>
      {
        kind: HeatSink,
        name: "Heat Sink",
        description: "+1 max heat capacity",
        icon: "~",
      }
    ChainLightning =>
      {
        kind: ChainLightning,
        name: "Chain Lightning",
        description: "Attacks chain 1 dmg to adjacent enemy",
        icon: "Z",
      }
    VampireCore =>
      {
        kind: VampireCore,
        name: "Vampire Core",
        description: "Heal 1 HP on kill",
        icon: "V",
      }
    FortifiedGrid =>
      {
        kind: FortifiedGrid,
        name: "Fortified Grid",
        description: "Grid objectives take 1 less damage",
        icon: "G",
      }
    ReflexBoost =>
      {
        kind: ReflexBoost,
        name: "Reflex Boost",
        description: "First mech each turn gets +1 move range",
        icon: "+",
      }
    EmergencyRepair =>
      {
        kind: EmergencyRepair,
        name: "Emergency Repair",
        description: "Auto-heal 1 HP when below 25%",
        icon: "!",
      }
  }
}

///|
let all_augment_kinds : Array[@types.AugmentKind] = [
  ExtendedBarrel,
  HeavyFrame,
  OverchargedPush,
  ShieldGenerator,
  HeatSink,
  ChainLightning,
  VampireCore,
  FortifiedGrid,
  ReflexBoost,
  EmergencyRepair,
]

///|
/// Pick `count` random augments that the player does not already have.
pub fn pick_random_augments(
  seed : Ref[UInt],
  owned : Array[@types.AugmentKind],
  count : Int,
) -> Array[@types.AugmentKind] {
  // Build pool of unowned augments
  let pool : Array[@types.AugmentKind] = []
  for i = 0; i < all_augment_kinds.length(); i = i + 1 {
    let aug = all_augment_kinds[i]
    let mut already_owned = false
    for j = 0; j < owned.length(); j = j + 1 {
      if owned[j] == aug {
        already_owned = true
        break
      }
    }
    if !already_owned {
      pool.push(aug)
    }
  }
  if pool.length() == 0 {
    return []
  }
  // Fisher-Yates partial shuffle to pick `count` items
  let result : Array[@types.AugmentKind] = []
  let n = if count < pool.length() { count } else { pool.length() }
  for i = 0; i < n; i = i + 1 {
    let remaining = pool.length() - i
    let idx = i + @types.rand_range(seed, 0, remaining - 1)
    // Swap pool[i] and pool[idx]
    let tmp = pool[i]
    pool[i] = pool[idx]
    pool[idx] = tmp
    result.push(pool[i])
  }
  result
}

///|
/// Apply augment stat modifications to a mech's stats.
/// Called during battle setup to adjust base stats.
pub fn apply_augment_to_stats(
  kind : @types.AugmentKind,
  hp : Int,
  max_heat : Int,
  move_range : Int,
  ability_range : Int,
) -> (Int, Int, Int, Int) {
  // Returns (hp_delta, max_heat_delta, move_range_delta, ability_range_delta)
  match kind {
    ExtendedBarrel => (hp, max_heat, move_range, ability_range + 1)
    HeavyFrame => (hp + 2, max_heat, move_range - 1, ability_range)
    HeatSink => (hp, max_heat + 1, move_range, ability_range)
    _ => (hp, max_heat, move_range, ability_range)
  }
}

///|
/// Compute effective mech stats after all augments are applied.
pub fn get_augmented_mech_stats(
  class_ : @types.MechClass,
  augments : Array[@types.AugmentKind],
) -> MechStats {
  let base = get_mech_stats(class_)
  let mut hp = base.hp
  let mut max_heat = base.max_heat
  let mut move_range = base.move_range
  let mut ability_range = base.ability_range
  for i = 0; i < augments.length(); i = i + 1 {
    let result = apply_augment_to_stats(
      augments[i],
      hp,
      max_heat,
      move_range,
      ability_range,
    )
    hp = result.0
    max_heat = result.1
    move_range = result.2
    ability_range = result.3
  }
  // Clamp move range to at least 1
  if move_range < 1 {
    move_range = 1
  }
  {
    name: base.name,
    mech_class: base.mech_class,
    hp,
    max_heat,
    move_range,
    ability_name: base.ability_name,
    ability_range,
    ability_damage: base.ability_damage,
  }
}

///|
/// Get a human-readable name for an augment kind.
pub fn get_augment_name(kind : @types.AugmentKind) -> String {
  get_augment_def(kind).name
}
