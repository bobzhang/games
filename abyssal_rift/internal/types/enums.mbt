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
pub extend GameState with Eq::{not_equal, equal}

///|
pub(all) enum StarterKit {
  Vanguard
  Cutpurse
  Invoker
} derive(Eq, Debug)

///|
pub extend StarterKit with Eq::{not_equal, equal}

///|
pub extend StarterKit with Debug::{to_repr}

///|
pub impl Show for StarterKit with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend StarterKit with Show::{to_string, output}

///|
pub(all) enum PactKind {
  BloodPrice
  GlassStep
  MerchantsDebt
  CursedStrength
  VoidHeart
} derive(Eq, Debug)

///|
pub extend PactKind with Eq::{not_equal, equal}

///|
pub extend PactKind with Debug::{to_repr}

///|
pub impl Show for PactKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend PactKind with Show::{to_string, output}

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
pub extend MetaUpgrade with Eq::{not_equal, equal}

///|
pub extend MetaUpgrade with Debug::{to_repr}

///|
pub impl Show for MetaUpgrade with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend MetaUpgrade with Show::{to_string, output}

///|
pub(all) enum RoomState {
  Idle
  Sealed
  Cleared
} derive(Eq)

///|
pub extend RoomState with Eq::{not_equal, equal}

///|
pub(all) enum WeaponKind {
  Sword
  Daggers
  Bow
  Staff
} derive(Eq, Debug)

///|
pub extend WeaponKind with Eq::{not_equal, equal}

///|
pub extend WeaponKind with Debug::{to_repr}

///|
pub impl Show for WeaponKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend WeaponKind with Show::{to_string, output}

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
pub extend EnemyKind with Eq::{not_equal, equal}

///|
pub extend EnemyKind with Debug::{to_repr}

///|
pub impl Show for EnemyKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend EnemyKind with Show::{to_string, output}

///|
pub(all) enum ItemKind {
  HealthPotion
  WeaponPickup(WeaponKind)
  Gold(Int)
  PassiveItem(PassiveKind)
} derive(Debug)

///|
pub extend ItemKind with Debug::{to_repr}

///|
pub impl Show for ItemKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend ItemKind with Show::{to_string, output}

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
pub extend PassiveKind with Eq::{not_equal, equal}

///|
pub extend PassiveKind with Debug::{to_repr}

///|
pub impl Show for PassiveKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend PassiveKind with Show::{to_string, output}

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
pub extend RoomKind with Eq::{not_equal, equal}

///|
pub extend RoomKind with Debug::{to_repr}

///|
pub impl Show for RoomKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend RoomKind with Show::{to_string, output}

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
pub extend EncounterType with Eq::{not_equal, equal}

///|
pub extend EncounterType with Debug::{to_repr}

///|
pub impl Show for EncounterType with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend EncounterType with Show::{to_string, output}

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
pub extend ShrineKind with Eq::{not_equal, equal}

///|
pub extend ShrineKind with Debug::{to_repr}

///|
pub impl Show for ShrineKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend ShrineKind with Show::{to_string, output}

///|
pub(all) enum Direction {
  Up
  Down
  Left
  Right
} derive(Eq, Debug)

///|
pub extend Direction with Eq::{not_equal, equal}

///|
pub extend Direction with Debug::{to_repr}

///|
pub impl Show for Direction with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Direction with Show::{to_string, output}

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
pub extend GameEvent with Debug::{to_repr}

///|
pub impl Show for GameEvent with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend GameEvent with Show::{to_string, output}

///|
pub(all) enum AttackState {
  Idle
  Windup(Float)
  Active(Float)
  Recovery(Float)
} derive(Eq)

///|
pub extend AttackState with Eq::{not_equal, equal}

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
pub extend EnemyState with Eq::{not_equal, equal}

///|
pub(all) enum StatusEffect {
  Slow(Float)
  Poison(Float)
  Shield(Float)
  Haste(Float)
} derive(Debug)

///|
pub extend StatusEffect with Debug::{to_repr}

///|
pub impl Show for StatusEffect with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend StatusEffect with Show::{to_string, output}

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
pub extend EliteAffix with Eq::{not_equal, equal}

///|
pub extend EliteAffix with Debug::{to_repr}

///|
pub impl Show for EliteAffix with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend EliteAffix with Show::{to_string, output}

///|
pub(all) enum FloorPath {
  Hunter
  Pilgrim
  Rot
  Forge
  Gauntlet
} derive(Eq, Debug)

///|
pub extend FloorPath with Eq::{not_equal, equal}

///|
pub extend FloorPath with Debug::{to_repr}

///|
pub impl Show for FloorPath with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend FloorPath with Show::{to_string, output}

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
