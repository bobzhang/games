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
pub(all) enum Command {
  Move(Int, Int)
  Attack(Int, Int, Int)
  Overclock(Int)
  Wait
  Push(Int, Int, Int)
} derive(Debug)

///|
pub extend Command with Debug::{to_repr}

///|
pub impl Show for Command with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Command with Show::{to_string, output}

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
pub extend Effect with Debug::{to_repr}

///|
pub impl Show for Effect with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Effect with Show::{to_string, output}

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
pub extend Intent with Debug::{to_repr}

///|
pub impl Show for Intent with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Intent with Show::{to_string, output}

///|
pub(all) enum Objective {
  DefendGrid(Int)
  Survive(Int)
  Assassinate(Int)
  CapturePoints(Int)
  Escort(Int, Int)
} derive(Eq, Debug)

///|
pub extend Objective with Eq::{not_equal, equal}

///|
pub extend Objective with Debug::{to_repr}

///|
pub impl Show for Objective with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Objective with Show::{to_string, output}

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
pub(all) enum UnitTeam {
  Player
  Enemy
} derive(Eq, Debug)

///|
pub extend UnitTeam with Eq::{not_equal, equal}

///|
pub extend UnitTeam with Debug::{to_repr}

///|
pub impl Show for UnitTeam with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend UnitTeam with Show::{to_string, output}

///|
pub(all) enum MechClass {
  Vanguard
  Striker
  Sentinel
} derive(Eq, Debug)

///|
pub extend MechClass with Eq::{not_equal, equal}

///|
pub extend MechClass with Debug::{to_repr}

///|
pub impl Show for MechClass with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend MechClass with Show::{to_string, output}

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
pub extend EnemyType with Eq::{not_equal, equal}

///|
pub extend EnemyType with Debug::{to_repr}

///|
pub impl Show for EnemyType with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend EnemyType with Show::{to_string, output}

///|
pub(all) enum HazardKind {
  None
  Fire
  Acid
  Mine
  Smoke
} derive(Eq, Debug)

///|
pub extend HazardKind with Eq::{not_equal, equal}

///|
pub extend HazardKind with Debug::{to_repr}

///|
pub impl Show for HazardKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend HazardKind with Show::{to_string, output}

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
pub extend EffectKind with Eq::{not_equal, equal}

///|
pub extend EffectKind with Debug::{to_repr}

///|
pub impl Show for EffectKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend EffectKind with Show::{to_string, output}

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
pub extend AugmentKind with Eq::{not_equal, equal}

///|
pub extend AugmentKind with Debug::{to_repr}

///|
pub impl Show for AugmentKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend AugmentKind with Show::{to_string, output}

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
pub extend CampaignNodeKind with Eq::{not_equal, equal}

///|
pub extend CampaignNodeKind with Debug::{to_repr}

///|
pub impl Show for CampaignNodeKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend CampaignNodeKind with Show::{to_string, output}

///|
pub(all) enum EventKind {
  Scavenger // pay 2 GP for random augment, or fight for free augment
  Ambush // surprise battle with extra enemies but double reward
  Intel // see next 2 missions' enemies + objectives
} derive(Eq, Debug)

///|
pub extend EventKind with Eq::{not_equal, equal}

///|
pub extend EventKind with Debug::{to_repr}

///|
pub impl Show for EventKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend EventKind with Show::{to_string, output}

///|
pub(all) enum BranchTheme {
  ScorchedEarth // more lava/fire tiles, fire-themed rewards
  IceProtocol // more ice tiles, mobility-themed rewards
  VoidZone // more chasms, push-themed rewards
  Neutral // no special theme
} derive(Eq, Debug)

///|
pub extend BranchTheme with Eq::{not_equal, equal}

///|
pub extend BranchTheme with Debug::{to_repr}

///|
pub impl Show for BranchTheme with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend BranchTheme with Show::{to_string, output}

///|
pub(all) enum RewardChoice {
  PickAugment(Int) // index into offered augments
  RepairAll
  GainGridPower
} derive(Eq, Debug)

///|
pub extend RewardChoice with Eq::{not_equal, equal}

///|
pub extend RewardChoice with Debug::{to_repr}

///|
pub impl Show for RewardChoice with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend RewardChoice with Show::{to_string, output}

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
pub extend AnimKind with Eq::{not_equal, equal}

///|
pub extend AnimKind with Debug::{to_repr}

///|
pub impl Show for AnimKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend AnimKind with Show::{to_string, output}

///|
pub(all) enum StatusEffect {
  OnFire(Int) // turns remaining
  Immobilized(Int) // turns remaining
} derive(Eq, Debug)

///|
pub extend StatusEffect with Eq::{not_equal, equal}

///|
pub extend StatusEffect with Debug::{to_repr}

///|
pub impl Show for StatusEffect with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend StatusEffect with Show::{to_string, output}
