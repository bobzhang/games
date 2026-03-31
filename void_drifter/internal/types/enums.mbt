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
} derive(Eq, Show)

///|
pub(all) enum WeaponKind {
  Laser
  Shotgun
  Missile
  Railgun
  Flak
  Beam
} derive(Eq, Show)

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
} derive(Eq, Show)

///|
pub(all) enum UtilityMod {
  ShieldDrain
  Vampire
  HeatSink
  Accelerator
} derive(Eq, Show)

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
} derive(Eq, Show)

///|
pub(all) enum BossKind {
  Leviathan
  Hive
  Dreadnought
} derive(Eq, Show)

///|
pub(all) enum SectorKind {
  Asteroids
  Nebula
  Station
  BossArena
  EliteZone
  EmptySpace
} derive(Eq, Show)

///|
pub(all) enum HazardKind {
  AsteroidField
  RadiationZone
  GravityWell
  MineField
} derive(Eq, Show)

///|
pub(all) enum PickupKind {
  HealthPack
  ShieldRecharge
  WeaponMod(ModKind)
  UtilityPickup(UtilityMod)
  Credits(Int)
  HeatVent
  WeaponDrop(WeaponKind)
} derive(Eq, Show)

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
} derive(Eq, Show)

///|
pub(all) enum MetaUnlock {
  UnlockWeapon(WeaponKind)
  UnlockMod(ModKind)
  UnlockUtility(UtilityMod)
  UnlockShip(Int)
} derive(Eq, Show)

///|
pub(all) enum Direction {
  Up
  Down
  Left
  Right
} derive(Eq, Show)
