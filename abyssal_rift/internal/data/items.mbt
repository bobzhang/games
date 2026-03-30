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
    AttackSpeedUp => { name: "Haste Gem", description: "+15% Attack Speed" }
    PickupRange => { name: "Magnet Amulet", description: "+50% Pickup Range" }
    LifeSteal => { name: "Blood Fang", description: "Heal 10% of damage dealt" }
    Thorns => { name: "Spike Shell", description: "Reflect 5 damage when hit" }
    Berserker => { name: "Rage Totem", description: "+30% DMG below 30% HP" }
    GlassCannon => { name: "Void Lens", description: "+50% DMG, -30 Max HP" }
    Vampiric => { name: "Soul Siphon", description: "Kills heal 5 HP" }
    ChainLightning =>
      { name: "Storm Orb", description: "20% chance to chain hit" }
  }
}
