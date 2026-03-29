///|
pub(all) struct PassiveStats {
  name : String
  description : String
}

///|
pub fn get_passive_stats(kind : @types.PassiveKind) -> PassiveStats {
  match kind {
    MaxHpUp => { name: "Vitality Crystal", description: "+20 Max HP" }
    DamageUp => { name: "Power Shard", description: "+15% Damage" }
    SpeedUp => { name: "Swift Boots", description: "+12% Speed" }
    CritUp => { name: "Lucky Charm", description: "+8% Crit Chance" }
    DashCooldownDown =>
      { name: "Shadow Cloak", description: "-25% Dash Cooldown" }
    DefenseUp => { name: "Iron Ring", description: "+3 Defense" }
    AttackSpeedUp =>
      { name: "Haste Gem", description: "+15% Attack Speed" }
    PickupRange => { name: "Magnet Amulet", description: "+50% Pickup Range" }
    LifeSteal => { name: "Blood Fang", description: "Heal 10% of damage dealt" }
    Thorns => { name: "Spike Shell", description: "Reflect 5 damage when hit" }
    Berserker => { name: "Rage Totem", description: "+30% DMG below 30% HP" }
    GlassCannon => { name: "Void Lens", description: "+50% DMG, -30 Max HP" }
    Vampiric => { name: "Soul Siphon", description: "Kills heal 5 HP" }
    ChainLightning => { name: "Storm Orb", description: "20% chance to chain hit" }
  }
}

///|
pub fn get_active_synergies(p : @types.Player) -> Array[String] {
  let synergies : Array[String] = []
  // Crit + Daggers = "Assassin's Bleed" (bleed DOT on crit)
  if p.passives.contains(CritUp) && p.weapon == Daggers {
    synergies.push("Assassin's Bleed")
  }
  // LifeSteal + Berserker = "Blood Rage" (lifesteal doubles below 30%)
  if p.passives.contains(LifeSteal) && p.passives.contains(Berserker) {
    synergies.push("Blood Rage")
  }
  // SpeedUp + DashCooldownDown = "Phantom Dash" (dash damages enemies)
  if p.passives.contains(SpeedUp) && p.passives.contains(DashCooldownDown) {
    synergies.push("Phantom Dash")
  }
  // DefenseUp + Thorns = "Iron Maiden" (thorns doubled)
  if p.passives.contains(DefenseUp) && p.passives.contains(Thorns) {
    synergies.push("Iron Maiden")
  }
  // DamageUp + GlassCannon = "Destroyer" (even more damage)
  if p.passives.contains(DamageUp) && p.passives.contains(GlassCannon) {
    synergies.push("Destroyer")
  }
  // DamageUp + Sword = "Cleave" (hit all enemies in range)
  if p.passives.contains(DamageUp) && p.weapon == Sword {
    synergies.push("Cleave")
  }
  // MaxHpUp + DefenseUp = "Fortify" (30% less damage when above 70% HP)
  if p.passives.contains(MaxHpUp) && p.passives.contains(DefenseUp) {
    synergies.push("Fortify")
  }
  // AttackSpeedUp + Bow = "Multishot" (3 arrows in a spread)
  if p.passives.contains(AttackSpeedUp) && p.weapon == Bow {
    synergies.push("Multishot")
  }
  // CritUp + DamageUp = "Execute" (3x damage to low-HP enemies)
  if p.passives.contains(CritUp) && p.passives.contains(DamageUp) {
    synergies.push("Execute")
  }
  // PickupRange + MaxHpUp = "Vampiric Aura" (heal 1 HP per kill)
  if p.passives.contains(PickupRange) && p.passives.contains(MaxHpUp) {
    synergies.push("Vampiric Aura")
  }
  // SpeedUp + AttackSpeedUp = "Momentum" (damage scales with speed)
  if p.passives.contains(SpeedUp) && p.passives.contains(AttackSpeedUp) {
    synergies.push("Momentum")
  }
  // DamageUp + Staff = "Chain Lightning" (projectiles bounce to nearby enemy)
  if p.passives.contains(DamageUp) && p.weapon == Staff {
    synergies.push("Chain Lightning")
  }
  synergies
}
