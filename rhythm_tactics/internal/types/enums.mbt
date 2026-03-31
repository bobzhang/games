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
  AbilityChoice
  RunSummary
} derive(Eq, Show)

///|
pub(all) enum TileKind {
  Floor
  Wall
  Pit
  Spike
  Ice
  Exit
  Lava
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
  ShopWeapon(WeaponKind)
} derive(Show)

///|
pub(all) enum WeaponKind {
  Sword
  Spear
  Whip
  Hammer
  Bow
  Staff
} derive(Eq, Show)

///|
pub(all) enum AbilityKind {
  DoubleStep
  CounterAttack
  HealBeat
  ShadowDodge
  RhythmShield
} derive(Eq, Show)

///|
pub(all) enum FloorTheme {
  Meadow
  Cave
  BossArena
  IceDungeon
  Volcano
  FinalArena
} derive(Eq, Show)

///|
pub(all) enum ComboMilestone {
  Fever
  Frenzy
  PerfectStorm
  NoMilestone
} derive(Eq, Show)

///|
pub(all) enum ScoreGrade {
  GradeS
  GradeA
  GradeB
  GradeC
} derive(Show)
