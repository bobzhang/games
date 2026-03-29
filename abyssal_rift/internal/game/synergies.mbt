///|
/// Evaluate all active synergies based on player passives and weapon.
/// Returns a SynergyBonuses struct describing which synergy effects are active.
pub fn get_synergy_bonuses(player : @types.Player) -> @types.SynergyBonuses {
  let bonuses = @types.SynergyBonuses::new()
  let passives = player.passives
  // Synergy: CritUp + Daggers = Bleed on crit (enemies take DOT for 2s)
  if passives.contains(CritUp) && player.weapon == Daggers {
    bonuses.bleed_on_crit = true
  }
  // Synergy: SpeedUp + DashCooldownDown = Phantom Dash (dash leaves damaging trail)
  if passives.contains(SpeedUp) && passives.contains(DashCooldownDown) {
    bonuses.dash_damages = true
    bonuses.dash_damage = 8
  }
  // Synergy: DamageUp + Sword = Cleave (melee hits all enemies in range, skip arc check)
  if passives.contains(DamageUp) && player.weapon == Sword {
    bonuses.cleave = true
  }
  // Synergy: MaxHpUp + DefenseUp = Fortify (30% less damage when above 70% HP)
  if passives.contains(MaxHpUp) && passives.contains(DefenseUp) {
    bonuses.fortify = true
  }
  // Synergy: AttackSpeedUp + Bow = Multishot (fire 3 arrows in a 15-degree spread)
  if passives.contains(AttackSpeedUp) && player.weapon == Bow {
    bonuses.multishot = true
    bonuses.multishot_count = 3
  }
  // Synergy: CritUp + DamageUp = Execute (3x damage to enemies below 25% HP)
  if passives.contains(CritUp) && passives.contains(DamageUp) {
    bonuses.execute = true
    bonuses.execute_threshold = 0.25
    bonuses.execute_mult = 3.0
  }
  // Synergy: PickupRange + MaxHpUp = Vampiric Aura (heal 1 HP per kill)
  if passives.contains(PickupRange) && passives.contains(MaxHpUp) {
    bonuses.vampiric = true
  }
  // Synergy: SpeedUp + AttackSpeedUp = Momentum (damage scales with movement speed)
  if passives.contains(SpeedUp) && passives.contains(AttackSpeedUp) {
    bonuses.momentum = true
  }
  // Synergy: Staff + DamageUp = Chain Lightning (projectiles bounce to nearby enemy)
  if passives.contains(DamageUp) && player.weapon == Staff {
    bonuses.chain_projectile = true
  }
  bonuses
}

///|
/// Return a list of human-readable synergy names that are currently active.
pub fn get_active_synergy_names(
  synergies : @types.SynergyBonuses
) -> Array[String] {
  let names : Array[String] = []
  if synergies.bleed_on_crit {
    names.push("Assassin's Bleed")
  }
  if synergies.dash_damages {
    names.push("Phantom Dash")
  }
  if synergies.cleave {
    names.push("Cleave")
  }
  if synergies.fortify {
    names.push("Fortify")
  }
  if synergies.multishot {
    names.push("Multishot")
  }
  if synergies.execute {
    names.push("Execute")
  }
  if synergies.vampiric {
    names.push("Vampiric Aura")
  }
  if synergies.momentum {
    names.push("Momentum")
  }
  if synergies.chain_projectile {
    names.push("Chain Lightning")
  }
  names
}
