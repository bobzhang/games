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
  CurseOffer
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
  ShopSpell(SpellKind)
  ShopManaPotion
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

///|
pub(all) enum Element {
  Fire
  Ice
  Lightning
  Dark
} derive(Eq, Show)

///|
pub(all) enum SpellKind {
  Fireball
  FrostNova
  ChainLightning
  ShadowStep
  Inferno
  Blizzard
  ThunderStrike
  VoidPulse
} derive(Eq, Show)

///|
pub(all) enum CurseKind {
  DoubleTime
  GlassCannon
  BlindBeat
  Swarm
} derive(Eq, Show)

///|
pub(all) enum AchievementKind {
  FirstBlood
  Perfect10
  BossSlayer
  ComboKing
  SpeedDemon
  Pacifist
} derive(Eq, Show)

///|
pub(all) enum SoundEvent {
  BeatTick
  BeatPerfect
  BeatGood
  BeatMiss
  PlayerAttack
  PlayerHit
  EnemyDeath
  ItemPickup
  SpellCast(Element)
  BossPhaseChange
  LevelComplete
  ComboMilestoneSound(ComboMilestone)
  ShopPurchase
  WeaponSwitch
  BossRoar
  CurseAccepted
} derive(Show)

///|
pub(all) enum BossPhase {
  Phase1
  Phase2
  Phase3
} derive(Eq, Show)
