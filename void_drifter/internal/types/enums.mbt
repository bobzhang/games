///|
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
} derive(Eq, Debug)

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
pub(all) enum WeaponKind {
  Laser
  Shotgun
  Missile
  Railgun
  Flak
  Beam
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
pub(all) enum ModKind {
  Piercing
  Homing
  Split
  Chain
  Explosive
  Freezing
  Bouncing
  Overcharge
} derive(Eq, Debug)

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
pub(all) enum UtilityMod {
  ShieldDrain
  Vampire
  HeatSink
  Accelerator
} derive(Eq, Debug)

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
pub(all) enum EnemyKind {
  Drone
  Fighter
  Kiter
  Swarm
  Turret
  Carrier
  Bomber
  ShieldBearer
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
pub(all) enum BossKind {
  Leviathan
  Hive
  Dreadnought
} derive(Eq, Debug)

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
pub(all) enum SectorKind {
  Asteroids
  Nebula
  Station
  BossArena
  EliteZone
  EmptySpace
} derive(Eq, Debug)

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
pub(all) enum HazardKind {
  AsteroidField
  RadiationZone
  GravityWell
  MineField
} derive(Eq, Debug)

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
pub(all) enum PickupKind {
  HealthPack
  ShieldRecharge
  WeaponMod(ModKind)
  UtilityPickup(UtilityMod)
  Credits(Int)
  HeatVent
  WeaponDrop(WeaponKind)
} derive(Eq, Debug)

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
} derive(Eq, Debug)

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
pub(all) enum MetaUnlock {
  UnlockWeapon(WeaponKind)
  UnlockMod(ModKind)
  UnlockUtility(UtilityMod)
  UnlockShip(Int)
} derive(Eq, Debug)

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
