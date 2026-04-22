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
pub impl Show for Screen with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

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
pub impl Show for TileKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Direction {
  North
  South
  East
  West
} derive(Eq, Debug)

///|
pub impl Show for Direction with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

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
pub impl Show for EnemyKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum BeatRating {
  Perfect
  Good
  Miss
} derive(Eq, Debug)

///|
pub impl Show for BeatRating with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum PlayerAction {
  Move(Direction)
  Attack(Direction)
  Special
  Wait
} derive(Debug)

///|
pub impl Show for PlayerAction with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

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
pub impl Show for EnemyIntent with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

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
pub impl Show for ItemKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

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
pub impl Show for ShopItemKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

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
pub impl Show for WeaponKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum AbilityKind {
  DoubleStep
  CounterAttack
  HealBeat
  ShadowDodge
  RhythmShield
} derive(Eq, Debug)

///|
pub impl Show for AbilityKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

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
pub impl Show for FloorTheme with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum ComboMilestone {
  Fever
  Frenzy
  PerfectStorm
  NoMilestone
} derive(Eq, Debug)

///|
pub impl Show for ComboMilestone with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum ScoreGrade {
  GradeS
  GradeA
  GradeB
  GradeC
} derive(Debug)

///|
pub impl Show for ScoreGrade with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Element {
  Fire
  Ice
  Lightning
  Dark
} derive(Eq, Debug)

///|
pub impl Show for Element with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

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
pub impl Show for SpellKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum CurseKind {
  DoubleTime
  GlassCannon
  BlindBeat
  Swarm
} derive(Eq, Debug)

///|
pub impl Show for CurseKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

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
pub impl Show for AchievementKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

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
pub impl Show for SoundEvent with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum BossPhase {
  Phase1
  Phase2
  Phase3
} derive(Eq, Debug)

///|
pub impl Show for BossPhase with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
