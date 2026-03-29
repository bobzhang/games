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
  }
}
