///|
pub(all) enum GameState {
  Title
  Playing
  Paused
  GameOver
  Victory
  MetaScreen
  StarterSelect
} derive(Eq)

///|
pub(all) enum StarterKit {
  Vanguard
  Cutpurse
  Invoker
} derive(Eq, Debug)

///|
pub impl Show for StarterKit with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum PactKind {
  BloodPrice
  GlassStep
  MerchantsDebt
  CursedStrength
  VoidHeart
} derive(Eq, Debug)

///|
pub impl Show for PactKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum MetaUpgrade {
  StartingHpUp
  StartingShieldUp
  StartingGold
  WeaponMastery
  DashMastery
  PotionEfficiency
} derive(Eq, Debug)

///|
pub impl Show for MetaUpgrade with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum RoomState {
  Idle
  Sealed
  Cleared
} derive(Eq)

///|
pub(all) enum WeaponKind {
  Sword
  Daggers
  Bow
  Staff
} derive(Eq, Debug)

///|
pub impl Show for WeaponKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum EnemyKind {
  Slime
  SlimeSmall
  Skeleton
  Archer
  Bat
  Spider
  Golem
  BroodMother
  LichKing
} derive(Eq, Debug)

///|
pub impl Show for EnemyKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum ItemKind {
  HealthPotion
  WeaponPickup(WeaponKind)
  Gold(Int)
  PassiveItem(PassiveKind)
} derive(Debug)

///|
pub impl Show for ItemKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum PassiveKind {
  MaxHpUp
  DamageUp
  SpeedUp
  CritUp
  DashCooldownDown
  DefenseUp
  AttackSpeedUp
  PickupRange
  LifeSteal
  Thorns
  Berserker
  GlassCannon
  Vampiric
  ChainLightning
} derive(Eq, Debug)

///|
pub impl Show for PassiveKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum RoomKind {
  Start
  Combat
  Treasure
  Boss
  Corridor
  Shrine
  EliteVault
  Challenge
} derive(Eq, Debug)

///|
pub impl Show for RoomKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum EncounterType {
  Standard
  Swarm
  SniperNest
  BossRush
  SurvivalWave
  PoisonNest
  Ambush
} derive(Eq, Debug)

///|
pub impl Show for EncounterType with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub fn encounter_name(encounter : EncounterType) -> String {
  match encounter {
    Standard => "COMBAT!"
    Swarm => "SWARM!"
    SniperNest => "SNIPER NEST!"
    BossRush => "ELITE RUSH!"
    SurvivalWave => "SURVIVAL WAVE!"
    PoisonNest => "POISON NEST!"
    Ambush => "AMBUSH!"
  }
}

///|
pub(all) enum ShrineKind {
  BloodAltar
  HealingSpring
  GambleShrine
  CursedChest
  ReforgeAnvil
} derive(Eq, Debug)

///|
pub impl Show for ShrineKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Direction {
  Up
  Down
  Left
  Right
} derive(Eq, Debug)

///|
pub impl Show for Direction with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum GameEvent {
  Hit(Float, Float, Int, Bool)
  Kill(EnemyKind, Float, Float)
  PlayerDamaged(Int, Float, Float)
  Pickup(ItemKind, Float, Float)
  RoomCleared
  BossPhaseChange(Int)
  DashUsed(Float, Float, Float, Float)
  WeaponSwing(Float, Float, Float)
  SynergyUnlocked(String)
} derive(Debug)

///|
pub impl Show for GameEvent with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum AttackState {
  Idle
  Windup(Float)
  Active(Float)
  Recovery(Float)
} derive(Eq)

///|
pub(all) enum EnemyState {
  Idle
  Patrol
  Chase
  Attack(Float)
  Hurt(Float)
  Dead(Float)
} derive(Eq)

///|
pub(all) enum StatusEffect {
  Slow(Float)
  Poison(Float)
  Shield(Float)
  Haste(Float)
} derive(Debug)

///|
pub impl Show for StatusEffect with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum EliteAffix {
  None
  Fast
  Armored
  Splitting
  Vampiric
  Explosive
} derive(Eq, Debug)

///|
pub impl Show for EliteAffix with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum FloorPath {
  Hunter
  Pilgrim
  Rot
  Forge
  Gauntlet
} derive(Eq, Debug)

///|
pub impl Show for FloorPath with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub fn path_name(path : FloorPath) -> String {
  match path {
    Hunter => "HUNTER"
    Pilgrim => "PILGRIM"
    Rot => "ROT"
    Forge => "FORGE"
    Gauntlet => "GAUNTLET"
  }
}
