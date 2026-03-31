///|
pub(all) enum Screen {
  Title
  Playing
  BeatFail
  LevelComplete
  GameOver
  FloorSelect
  Shop
  FloorTransition
  BossIntro
} derive(Eq, Show)

///|
pub(all) enum TileKind {
  Floor
  Wall
  Pit
  Spike
  Ice
  Exit
} derive(Eq, Show)

///|
pub(all) enum Direction {
  North
  South
  East
  West
} derive(Eq, Show)

///|
pub(all) enum EnemyKind {
  Slime
  Skeleton
  Bat
  Dragon
  Mimic
  Golem
  Wraith
  Boss
  BeatDragon
  RhythmLich
} derive(Eq, Show)

///|
pub(all) enum BeatRating {
  Perfect
  Good
  Miss
} derive(Eq, Show)

///|
pub(all) enum PlayerAction {
  Move(Direction)
  Attack(Direction)
  Special
  Wait
} derive(Show)

///|
pub(all) enum EnemyIntent {
  Move(Direction)
  Attack(Direction, Int)
  Charge(Direction, Int)
  Summon(EnemyKind, Int, Int)
  BreathFire(Direction, Int)
  AoeFreeze(Int)
  Wait
} derive(Show)

///|
pub(all) enum ItemKind {
  Gold(Int)
  HealthPotion
  ShieldOrb
  SpeedBoost
  WeaponUpgrade
  BeatFreeze
  SpecialCharge
  Bomb
} derive(Show)

///|
pub(all) enum ShopItemKind {
  ShopHealthPotion
  ShopShield
  ShopWeaponUpgrade
  ShopSpecialCharge
  ShopBeatWindow
} derive(Show)

///|
pub(all) enum ScoreGrade {
  GradeS
  GradeA
  GradeB
  GradeC
} derive(Show)
