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
        base_damage: 18,
        attack_speed: 0.35,
        range: 55.0,
        arc_angle: 120.0,
        knockback: 300.0,
        combo_count: 3,
        is_ranged: false,
        projectile_speed: 0.0,
        crit_bonus: 0.0,
      }
    Daggers =>
      {
        name: "Daggers",
        base_damage: 7,
        attack_speed: 0.14,
        range: 30.0,
        arc_angle: 70.0,
        knockback: 80.0,
        combo_count: 5,
        is_ranged: false,
        projectile_speed: 0.0,
        crit_bonus: 0.20,
      }
    Bow =>
      {
        name: "Bow",
        base_damage: 25,
        attack_speed: 0.65,
        range: 450.0,
        arc_angle: 0.0,
        knockback: 100.0,
        combo_count: 1,
        is_ranged: true,
        projectile_speed: 650.0,
        crit_bonus: 0.12,
      }
    Staff =>
      {
        name: "Staff",
        base_damage: 10,
        attack_speed: 0.45,
        range: 300.0,
        arc_angle: 0.0,
        knockback: 150.0,
        combo_count: 2,
        is_ranged: true,
        projectile_speed: 280.0,
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
