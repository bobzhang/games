///|
#derive(Eq, Debug)
pub(all) enum Screen {
  Title
  Playing
  Paused
  SectorMap
  Shop
  GameOver
  RunSummary
  WeaponSelect
  BossIntro
  Victory
}

///|
pub extend Screen with Eq::{not_equal, equal}

///|
pub extend Screen with Debug::{to_repr}

///|
pub impl Show for Screen with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Screen with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum WeaponKind {
  Laser
  Shotgun
  Missile
  Railgun
  Flak
  Beam
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
pub(all) enum ModKind {
  Piercing
  Homing
  Split
  Chain
  Explosive
  Freezing
  Bouncing
  Overcharge
}

///|
pub extend ModKind with Eq::{not_equal, equal}

///|
pub extend ModKind with Debug::{to_repr}

///|
pub impl Show for ModKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend ModKind with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum UtilityMod {
  ShieldDrain
  Vampire
  HeatSink
  Accelerator
}

///|
pub extend UtilityMod with Eq::{not_equal, equal}

///|
pub extend UtilityMod with Debug::{to_repr}

///|
pub impl Show for UtilityMod with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend UtilityMod with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum EnemyKind {
  Drone
  Fighter
  Kiter
  Swarm
  Turret
  Carrier
  Bomber
  ShieldBearer
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
#derive(Eq, Debug)
pub(all) enum BossKind {
  Leviathan
  Hive
  Dreadnought
}

///|
pub extend BossKind with Eq::{not_equal, equal}

///|
pub extend BossKind with Debug::{to_repr}

///|
pub impl Show for BossKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend BossKind with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum SectorKind {
  Asteroids
  Nebula
  Station
  BossArena
  EliteZone
  EmptySpace
}

///|
pub extend SectorKind with Eq::{not_equal, equal}

///|
pub extend SectorKind with Debug::{to_repr}

///|
pub impl Show for SectorKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend SectorKind with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum HazardKind {
  AsteroidField
  RadiationZone
  GravityWell
  MineField
}

///|
pub extend HazardKind with Eq::{not_equal, equal}

///|
pub extend HazardKind with Debug::{to_repr}

///|
pub impl Show for HazardKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend HazardKind with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum PickupKind {
  HealthPack
  ShieldRecharge
  WeaponMod(ModKind)
  UtilityPickup(UtilityMod)
  Credits(Int32)
  HeatVent
  WeaponDrop(WeaponKind)
}

///|
pub extend PickupKind with Eq::{not_equal, equal}

///|
pub extend PickupKind with Debug::{to_repr}

///|
pub impl Show for PickupKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend PickupKind with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum SoundEvent {
  PlayerShoot
  PlayerHit
  PlayerDash
  PlayerDeath
  EnemyHit
  EnemyDeath
  BossPhase
  Pickup
  ShopBuy
  MenuSelect
  Explosion
  ShieldBreak
  OverheatWarn
  SectorEnter
}

///|
pub extend SoundEvent with Eq::{not_equal, equal}

///|
pub extend SoundEvent with Debug::{to_repr}

///|
pub impl Show for SoundEvent with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend SoundEvent with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum MetaUnlock {
  UnlockWeapon(WeaponKind)
  UnlockMod(ModKind)
  UnlockUtility(UtilityMod)
  UnlockShip(Int32)
}

///|
pub extend MetaUnlock with Eq::{not_equal, equal}

///|
pub extend MetaUnlock with Debug::{to_repr}

///|
pub impl Show for MetaUnlock with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend MetaUnlock with Show::{to_string, output}

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
