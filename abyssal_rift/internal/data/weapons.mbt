///|
pub(all) struct WeaponStats {
  name : String
  base_damage : Int
  attack_speed : Float
  range : Float
  arc_angle : Float
  knockback : Float
  combo_count : Int
  is_ranged : Bool
  projectile_speed : Float
  crit_bonus : Float
}

///|
pub fn get_weapon_stats(kind : @types.WeaponKind) -> WeaponStats {
  match kind {
    Sword =>
      {
        name: "Sword",
        base_damage: 15,
        attack_speed: 0.35,
        range: 50.0,
        arc_angle: 90.0,
        knockback: 250.0,
        combo_count: 3,
        is_ranged: false,
        projectile_speed: 0.0,
        crit_bonus: 0.0,
      }
    Daggers =>
      {
        name: "Daggers",
        base_damage: 8,
        attack_speed: 0.18,
        range: 35.0,
        arc_angle: 60.0,
        knockback: 120.0,
        combo_count: 4,
        is_ranged: false,
        projectile_speed: 0.0,
        crit_bonus: 0.15,
      }
    Bow =>
      {
        name: "Bow",
        base_damage: 20,
        attack_speed: 0.5,
        range: 400.0,
        arc_angle: 0.0,
        knockback: 80.0,
        combo_count: 1,
        is_ranged: true,
        projectile_speed: 600.0,
        crit_bonus: 0.1,
      }
    Staff =>
      {
        name: "Staff",
        base_damage: 12,
        attack_speed: 0.6,
        range: 350.0,
        arc_angle: 0.0,
        knockback: 60.0,
        combo_count: 1,
        is_ranged: true,
        projectile_speed: 350.0,
        crit_bonus: 0.0,
      }
  }
}

///|
pub fn get_windup_time(kind : @types.WeaponKind, combo : Int) -> Float {
  match kind {
    Sword => if combo == 2 { 0.12 } else { 0.08 }
    Daggers => 0.04
    Bow => 0.3
    Staff => 0.2
  }
}

///|
pub fn get_active_time(kind : @types.WeaponKind) -> Float {
  match kind {
    Sword => 0.1
    Daggers => 0.06
    Bow => 0.05
    Staff => 0.08
  }
}

///|
pub fn get_recovery_time(kind : @types.WeaponKind, combo : Int) -> Float {
  match kind {
    Sword => if combo == 2 { 0.25 } else { 0.15 }
    Daggers => 0.08
    Bow => 0.15
    Staff => 0.3
  }
}
