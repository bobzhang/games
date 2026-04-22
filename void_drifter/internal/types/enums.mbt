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
pub impl Show for Screen with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

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
pub impl Show for WeaponKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

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
pub impl Show for ModKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum UtilityMod {
  ShieldDrain
  Vampire
  HeatSink
  Accelerator
} derive(Eq, Debug)

///|
pub impl Show for UtilityMod with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

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
pub impl Show for EnemyKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum BossKind {
  Leviathan
  Hive
  Dreadnought
} derive(Eq, Debug)

///|
pub impl Show for BossKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

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
pub impl Show for SectorKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum HazardKind {
  AsteroidField
  RadiationZone
  GravityWell
  MineField
} derive(Eq, Debug)

///|
pub impl Show for HazardKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

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
pub impl Show for PickupKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

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
pub impl Show for SoundEvent with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum MetaUnlock {
  UnlockWeapon(WeaponKind)
  UnlockMod(ModKind)
  UnlockUtility(UtilityMod)
  UnlockShip(Int)
} derive(Eq, Debug)

///|
pub impl Show for MetaUnlock with output(self, logger) {
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
