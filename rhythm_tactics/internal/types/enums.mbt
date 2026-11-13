///|
#derive(Eq, Debug)
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
pub(all) enum TileKind {
  Floor
  Wall
  Pit
  Spike
  Ice
  Exit
  Lava
}

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
#derive(Eq, Debug)
pub(all) enum Direction {
  North
  South
  East
  West
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
#derive(Eq, Debug)
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
pub(all) enum BeatRating {
  Perfect
  Good
  Miss
}

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
#derive(Debug)
pub(all) enum PlayerAction {
  Move(Direction)
  Attack(Direction)
  Special
  Wait
}

///|
pub extend PlayerAction with Debug::{to_repr}

///|
pub impl Show for PlayerAction with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend PlayerAction with Show::{to_string, output}

///|
#derive(Debug)
pub(all) enum EnemyIntent {
  Move(Direction)
  Attack(Direction, Int32)
  Charge(Direction, Int32)
  Summon(EnemyKind, Int32, Int32)
  BreathFire(Direction, Int32)
  AoeFreeze(Int32)
  Wait
}

///|
pub extend EnemyIntent with Debug::{to_repr}

///|
pub impl Show for EnemyIntent with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend EnemyIntent with Show::{to_string, output}

///|
#derive(Debug)
pub(all) enum ItemKind {
  Gold(Int32)
  HealthPotion
  ShieldOrb
  SpeedBoost
  WeaponUpgrade
  BeatFreeze
  SpecialCharge
  Bomb
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
#derive(Debug)
pub(all) enum ShopItemKind {
  ShopHealthPotion
  ShopShield
  ShopWeaponUpgrade
  ShopSpecialCharge
  ShopBeatWindow
  ShopWeapon(WeaponKind)
  ShopSpell(SpellKind)
  ShopManaPotion
}

///|
pub extend ShopItemKind with Debug::{to_repr}

///|
pub impl Show for ShopItemKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend ShopItemKind with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum WeaponKind {
  Sword
  Spear
  Whip
  Hammer
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
pub(all) enum AbilityKind {
  DoubleStep
  CounterAttack
  HealBeat
  ShadowDodge
  RhythmShield
}

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
#derive(Eq, Debug)
pub(all) enum FloorTheme {
  Meadow
  Cave
  BossArena
  IceDungeon
  Volcano
  FinalArena
}

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
#derive(Eq, Debug)
pub(all) enum ComboMilestone {
  Fever
  Frenzy
  PerfectStorm
  NoMilestone
}

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
#derive(Debug)
pub(all) enum ScoreGrade {
  GradeS
  GradeA
  GradeB
  GradeC
}

///|
pub extend ScoreGrade with Debug::{to_repr}

///|
pub impl Show for ScoreGrade with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend ScoreGrade with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum Element {
  Fire
  Ice
  Lightning
  Dark
}

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
#derive(Eq, Debug)
pub(all) enum SpellKind {
  Fireball
  FrostNova
  ChainLightning
  ShadowStep
  Inferno
  Blizzard
  ThunderStrike
  VoidPulse
}

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
#derive(Eq, Debug)
pub(all) enum CurseKind {
  DoubleTime
  GlassCannon
  BlindBeat
  Swarm
}

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
#derive(Eq, Debug)
pub(all) enum AchievementKind {
  FirstBlood
  Perfect10
  BossSlayer
  ComboKing
  SpeedDemon
  Pacifist
}

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
#derive(Debug)
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
}

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
pub(all) enum BossPhase {
  Phase1
  Phase2
  Phase3
}

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
