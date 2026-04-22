///|
pub(all) enum Screen {
  Title
  MapSelect
  MechSelect
  Campaign
  MissionBriefing
  Battle
  EnemyTurn
  Reward
  UpgradeScreen
  MissionDebrief
  RunSummary
  GameOver
  Victory
} derive(Eq, Debug)

///|
pub impl Show for Screen with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Command {
  Move(Int, Int)
  Attack(Int, Int, Int)
  Overclock(Int)
  Wait
  Push(Int, Int, Int)
} derive(Debug)

///|
pub impl Show for Command with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Effect {
  Damage(Int)
  Push(Int, Int)
  Pull(Int, Int)
  Shield(Int)
  Heal(Int)
  Stun
  Spawn(Int, Int, Int)
  DestroyTile(Int, Int)
  ApplyHazard(Int, Int, Int)
} derive(Debug)

///|
pub impl Show for Effect with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Intent {
  March(Int, Int)
  FireLine(Int, Int, Int)
  Leap(Int, Int)
  AreaBlast(Int, Int, Int)
  Summon(Int, Int, Int)
  Charge(Int, Int)
  MinePlace(Int, Int)
} derive(Debug)

///|
pub impl Show for Intent with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Objective {
  DefendGrid(Int)
  Survive(Int)
  Assassinate(Int)
  CapturePoints(Int)
  Escort(Int, Int)
} derive(Eq, Debug)

///|
pub impl Show for Objective with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum TileKind {
  Floor
  Wall
  Chasm
  Water
  Lava
  Ice
  ControlPoint
  SpawnPoint
} derive(Eq, Debug)

///|
pub impl Show for TileKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum UnitTeam {
  Player
  Enemy
} derive(Eq, Debug)

///|
pub impl Show for UnitTeam with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum MechClass {
  Vanguard
  Striker
  Sentinel
} derive(Eq, Debug)

///|
pub impl Show for MechClass with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum EnemyType {
  Rammer
  Artillery
  BeamTurret
  Leaper
  MineLayer
  ShieldDrone
  Splitter
  Boss
} derive(Eq, Debug)

///|
pub impl Show for EnemyType with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum HazardKind {
  None
  Fire
  Acid
  Mine
  Smoke
} derive(Eq, Debug)

///|
pub impl Show for HazardKind with output(self, logger) {
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
pub(all) enum EffectKind {
  DamagePreview
  PushPreview
  PullPreview
  MovePreview
  HazardPreview
  KillPreview
  CollisionPreview
} derive(Eq, Debug)

///|
pub impl Show for EffectKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum AugmentKind {
  ExtendedBarrel // +1 range on ranged attacks
  HeavyFrame // +2 max HP, -1 move range
  OverchargedPush // push distance +1
  ShieldGenerator // start each battle with 2 shield
  HeatSink // +1 max heat capacity
  ChainLightning // attacks chain to adjacent enemy for 1 damage
  VampireCore // heal 1 HP on kill
  FortifiedGrid // grid objectives take 1 less damage
  ReflexBoost // first mech each turn gets +1 move range
  EmergencyRepair // auto-heal 1 HP when below 25%
} derive(Eq, Debug)

///|
pub impl Show for AugmentKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum CampaignNodeKind {
  Mission(Int) // mission def index
  Boss(Int) // boss mission def index
  Rest // heal opportunity
  Shop // buy augments
  Event // random risk/reward event
  Elite(Int) // harder mission with guaranteed rare augment
} derive(Eq, Debug)

///|
pub impl Show for CampaignNodeKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum EventKind {
  Scavenger // pay 2 GP for random augment, or fight for free augment
  Ambush // surprise battle with extra enemies but double reward
  Intel // see next 2 missions' enemies + objectives
} derive(Eq, Debug)

///|
pub impl Show for EventKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum BranchTheme {
  ScorchedEarth // more lava/fire tiles, fire-themed rewards
  IceProtocol // more ice tiles, mobility-themed rewards
  VoidZone // more chasms, push-themed rewards
  Neutral // no special theme
} derive(Eq, Debug)

///|
pub impl Show for BranchTheme with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum RewardChoice {
  PickAugment(Int) // index into offered augments
  RepairAll
  GainGridPower
} derive(Eq, Debug)

///|
pub impl Show for RewardChoice with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum AnimKind {
  AnimNone
  AnimMove
  AnimAttack
  AnimPush
  AnimDeath
  AnimIntentReveal
} derive(Eq, Debug)

///|
pub impl Show for AnimKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum StatusEffect {
  OnFire(Int) // turns remaining
  Immobilized(Int) // turns remaining
} derive(Eq, Debug)

///|
pub impl Show for StatusEffect with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
