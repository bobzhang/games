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
pub(all) enum TileKind {
  Floor
  Wall
  Pit
  Spike
  Ice
  Exit
  Lava
} derive(Eq, Debug)

///|
pub extend TileKind with Eq::{not_equal, equal}

///|
pub extend TileKind with Debug::{to_repr}

///|
pub impl Show for TileKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend TileKind with Show::{to_string, output}

///|
pub(all) enum Direction {
  North
  South
  East
  West
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
pub(all) enum BeatRating {
  Perfect
  Good
  Miss
} derive(Eq, Debug)

///|
pub extend BeatRating with Eq::{not_equal, equal}

///|
pub extend BeatRating with Debug::{to_repr}

///|
pub impl Show for BeatRating with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend BeatRating with Show::{to_string, output}

///|
pub(all) enum PlayerAction {
  Move(Direction)
  Attack(Direction)
  Special
  Wait
} derive(Debug)

///|
pub extend PlayerAction with Debug::{to_repr}

///|
pub impl Show for PlayerAction with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend PlayerAction with Show::{to_string, output}

///|
pub(all) enum EnemyIntent {
  Move(Direction)
  Attack(Direction, Int)
  Charge(Direction, Int)
  Summon(EnemyKind, Int, Int)
  BreathFire(Direction, Int)
  AoeFreeze(Int)
  Wait
} derive(Debug)

///|
pub extend EnemyIntent with Debug::{to_repr}

///|
pub impl Show for EnemyIntent with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend EnemyIntent with Show::{to_string, output}

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
pub(all) enum ShopItemKind {
  ShopHealthPotion
  ShopShield
  ShopWeaponUpgrade
  ShopSpecialCharge
  ShopBeatWindow
  ShopWeapon(WeaponKind)
  ShopSpell(SpellKind)
  ShopManaPotion
} derive(Debug)

///|
pub extend ShopItemKind with Debug::{to_repr}

///|
pub impl Show for ShopItemKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend ShopItemKind with Show::{to_string, output}

///|
pub(all) enum WeaponKind {
  Sword
  Spear
  Whip
  Hammer
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
pub(all) enum AbilityKind {
  DoubleStep
  CounterAttack
  HealBeat
  ShadowDodge
  RhythmShield
} derive(Eq, Debug)

///|
pub extend AbilityKind with Eq::{not_equal, equal}

///|
pub extend AbilityKind with Debug::{to_repr}

///|
pub impl Show for AbilityKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend AbilityKind with Show::{to_string, output}

///|
pub(all) enum FloorTheme {
  Meadow
  Cave
  BossArena
  IceDungeon
  Volcano
  FinalArena
} derive(Eq, Debug)

///|
pub extend FloorTheme with Eq::{not_equal, equal}

///|
pub extend FloorTheme with Debug::{to_repr}

///|
pub impl Show for FloorTheme with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend FloorTheme with Show::{to_string, output}

///|
pub(all) enum ComboMilestone {
  Fever
  Frenzy
  PerfectStorm
  NoMilestone
} derive(Eq, Debug)

///|
pub extend ComboMilestone with Eq::{not_equal, equal}

///|
pub extend ComboMilestone with Debug::{to_repr}

///|
pub impl Show for ComboMilestone with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend ComboMilestone with Show::{to_string, output}

///|
pub(all) enum ScoreGrade {
  GradeS
  GradeA
  GradeB
  GradeC
} derive(Debug)

///|
pub extend ScoreGrade with Debug::{to_repr}

///|
pub impl Show for ScoreGrade with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend ScoreGrade with Show::{to_string, output}

///|
pub(all) enum Element {
  Fire
  Ice
  Lightning
  Dark
} derive(Eq, Debug)

///|
pub extend Element with Eq::{not_equal, equal}

///|
pub extend Element with Debug::{to_repr}

///|
pub impl Show for Element with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Element with Show::{to_string, output}

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
} derive(Eq, Debug)

///|
pub extend SpellKind with Eq::{not_equal, equal}

///|
pub extend SpellKind with Debug::{to_repr}

///|
pub impl Show for SpellKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend SpellKind with Show::{to_string, output}

///|
pub(all) enum CurseKind {
  DoubleTime
  GlassCannon
  BlindBeat
  Swarm
} derive(Eq, Debug)

///|
pub extend CurseKind with Eq::{not_equal, equal}

///|
pub extend CurseKind with Debug::{to_repr}

///|
pub impl Show for CurseKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend CurseKind with Show::{to_string, output}

///|
pub(all) enum AchievementKind {
  FirstBlood
  Perfect10
  BossSlayer
  ComboKing
  SpeedDemon
  Pacifist
} derive(Eq, Debug)

///|
pub extend AchievementKind with Eq::{not_equal, equal}

///|
pub extend AchievementKind with Debug::{to_repr}

///|
pub impl Show for AchievementKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend AchievementKind with Show::{to_string, output}

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
} derive(Debug)

///|
pub extend SoundEvent with Debug::{to_repr}

///|
pub impl Show for SoundEvent with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend SoundEvent with Show::{to_string, output}

///|
pub(all) enum BossPhase {
  Phase1
  Phase2
  Phase3
} derive(Eq, Debug)

///|
pub extend BossPhase with Eq::{not_equal, equal}

///|
pub extend BossPhase with Debug::{to_repr}

///|
pub impl Show for BossPhase with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend BossPhase with Show::{to_string, output}
