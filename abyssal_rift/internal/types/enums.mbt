///|
#derive(Eq)
pub(all) enum GameState {
  Title
  Playing
  Paused
  GameOver
  Victory
  MetaScreen
  StarterSelect
}

///|
pub extend GameState with Eq::{not_equal, equal}

///|
#derive(Eq, Debug)
pub(all) enum StarterKit {
  Vanguard
  Cutpurse
  Invoker
}

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
#derive(Eq, Debug)
pub(all) enum PactKind {
  BloodPrice
  GlassStep
  MerchantsDebt
  CursedStrength
  VoidHeart
}

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
#derive(Eq, Debug)
pub(all) enum MetaUpgrade {
  StartingHpUp
  StartingShieldUp
  StartingGold
  WeaponMastery
  DashMastery
  PotionEfficiency
}

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
#derive(Eq)
pub(all) enum RoomState {
  Idle
  Sealed
  Cleared
}

///|
pub extend RoomState with Eq::{not_equal, equal}

///|
#derive(Eq, Debug)
pub(all) enum WeaponKind {
  Sword
  Daggers
  Bow
  Staff
}

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
#derive(Eq, Debug)
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
}

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
#derive(Debug)
pub(all) enum ItemKind {
  HealthPotion
  WeaponPickup(WeaponKind)
  Gold(Int32)
  PassiveItem(PassiveKind)
}

///|
pub extend ItemKind with Debug::{to_repr}

///|
pub impl Show for ItemKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend ItemKind with Show::{to_string, output}

///|
#derive(Eq, Debug)
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
}

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
#derive(Eq, Debug)
pub(all) enum RoomKind {
  Start
  Combat
  Treasure
  Boss
  Corridor
  Shrine
  EliteVault
  Challenge
}

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
#derive(Eq, Debug)
pub(all) enum EncounterType {
  Standard
  Swarm
  SniperNest
  BossRush
  SurvivalWave
  PoisonNest
  Ambush
}

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
#derive(Eq, Debug)
pub(all) enum ShrineKind {
  BloodAltar
  HealingSpring
  GambleShrine
  CursedChest
  ReforgeAnvil
}

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
#derive(Eq, Debug)
pub(all) enum Direction {
  Up
  Down
  Left
  Right
}

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
#derive(Debug)
pub(all) enum GameEvent {
  Hit(Float, Float, Int32, Bool)
  Kill(EnemyKind, Float, Float)
  PlayerDamaged(Int32, Float, Float)
  Pickup(ItemKind, Float, Float)
  RoomCleared
  BossPhaseChange(Int32)
  DashUsed(Float, Float, Float, Float)
  WeaponSwing(Float, Float, Float)
  SynergyUnlocked(String)
}

///|
pub extend GameEvent with Debug::{to_repr}

///|
pub impl Show for GameEvent with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend GameEvent with Show::{to_string, output}

///|
#derive(Eq)
pub(all) enum AttackState {
  Idle
  Windup(Float)
  Active(Float)
  Recovery(Float)
}

///|
pub extend AttackState with Eq::{not_equal, equal}

///|
#derive(Eq)
pub(all) enum EnemyState {
  Idle
  Patrol
  Chase
  Attack(Float)
  Hurt(Float)
  Dead(Float)
}

///|
pub extend EnemyState with Eq::{not_equal, equal}

///|
#derive(Debug)
pub(all) enum StatusEffect {
  Slow(Float)
  Poison(Float)
  Shield(Float)
  Haste(Float)
}

///|
pub extend StatusEffect with Debug::{to_repr}

///|
pub impl Show for StatusEffect with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend StatusEffect with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum EliteAffix {
  None
  Fast
  Armored
  Splitting
  Vampiric
  Explosive
}

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
#derive(Eq, Debug)
pub(all) enum FloorPath {
  Hunter
  Pilgrim
  Rot
  Forge
  Gauntlet
}

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
