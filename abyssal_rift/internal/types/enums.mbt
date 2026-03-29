///|
pub(all) enum GameState {
  Title
  Playing
  Paused
  GameOver
  Victory
} derive(Eq)

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
} derive(Eq, Show)

///|
pub(all) enum EnemyKind {
  Slime
  SlimeSmall
  Skeleton
  Archer
  Bat
  Spider
  Golem
} derive(Eq, Show)

///|
pub(all) enum ItemKind {
  HealthPotion
  WeaponPickup(WeaponKind)
  Gold(Int)
  PassiveItem(PassiveKind)
} derive(Show)

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
} derive(Eq, Show)

///|
pub(all) enum RoomKind {
  Start
  Combat
  Treasure
  Boss
  Corridor
} derive(Eq, Show)

///|
pub(all) enum Direction {
  Up
  Down
  Left
  Right
} derive(Eq, Show)

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
} derive(Show)

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
