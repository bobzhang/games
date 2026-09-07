///|
pub(all) enum Screen {
  Title
  Build
  Test
  Results
  LevelSelect
  Sandbox
  Upgrades
  ChallengeSelect
  Challenge
  ChallengeResults
  StatsScreen
  ReplayPlayback
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
pub(all) enum PieceKind {
  Beam
  Block
  Triangle
  Arch
  Cable
} derive(Eq, Debug)

///|
pub extend PieceKind with Eq::{not_equal, equal}

///|
pub extend PieceKind with Debug::{to_repr}

///|
pub impl Show for PieceKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend PieceKind with Show::{to_string, output}

///|
pub(all) enum TestKind {
  Wind
  Earthquake
  Impact
} derive(Eq, Debug)

///|
pub extend TestKind with Eq::{not_equal, equal}

///|
pub extend TestKind with Debug::{to_repr}

///|
pub impl Show for TestKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend TestKind with Show::{to_string, output}

///|
pub(all) enum Material {
  Wood
  Stone
  Steel
} derive(Eq, Debug)

///|
pub extend Material with Eq::{not_equal, equal}

///|
pub extend Material with Debug::{to_repr}

///|
pub impl Show for Material with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Material with Show::{to_string, output}

///|
pub(all) enum JointKind {
  Fixed
  Hinge
  Spring
} derive(Eq, Debug)

///|
pub extend JointKind with Eq::{not_equal, equal}

///|
pub extend JointKind with Debug::{to_repr}

///|
pub impl Show for JointKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend JointKind with Show::{to_string, output}

///|
pub(all) enum BlueprintKind {
  Column
  ArchWay
  Truss
  Foundation
  Custom(Int)
} derive(Eq, Debug)

///|
pub extend BlueprintKind with Eq::{not_equal, equal}

///|
pub extend BlueprintKind with Debug::{to_repr}

///|
pub impl Show for BlueprintKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend BlueprintKind with Show::{to_string, output}

///|
pub(all) enum ChallengeMode {
  TimeAttack
  BudgetMode
  Survival
  Precision
} derive(Eq, Debug)

///|
pub extend ChallengeMode with Eq::{not_equal, equal}

///|
pub extend ChallengeMode with Debug::{to_repr}

///|
pub impl Show for ChallengeMode with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend ChallengeMode with Show::{to_string, output}

///|
pub(all) enum UpgradeKind {
  Reinforce(Material)
  Lightweight(Material)
  FlexJoints
  DeepFoundation
} derive(Eq, Debug)

///|
pub extend UpgradeKind with Eq::{not_equal, equal}

///|
pub extend UpgradeKind with Debug::{to_repr}

///|
pub impl Show for UpgradeKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend UpgradeKind with Show::{to_string, output}

///|
pub(all) enum WorldTheme {
  StoneFortress
  DesertRuins
  ArcticPeaks
} derive(Eq, Debug)

///|
pub extend WorldTheme with Eq::{not_equal, equal}

///|
pub extend WorldTheme with Debug::{to_repr}

///|
pub impl Show for WorldTheme with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend WorldTheme with Show::{to_string, output}

///|
pub(all) enum ComboKind {
  FlexCombo // Wood+Steel adjacent
  MonolithCombo // Stone+Stone adjacent
  ReinforcedCombo // Steel+Steel adjacent
  LightweightCombo // Wood+Wood adjacent
} derive(Eq, Debug)

///|
pub extend ComboKind with Eq::{not_equal, equal}

///|
pub extend ComboKind with Debug::{to_repr}

///|
pub impl Show for ComboKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend ComboKind with Show::{to_string, output}

///|
pub(all) enum SoundEvent {
  PlacePiece
  RotatePiece
  StartTest
  BodyBreak
  JointBreak
  TestPass
  TestFail
  LevelComplete
  WindStart
  EarthquakeStart
  ImpactHit
  ButtonClick
  StarEarned
} derive(Eq, Debug)

///|
pub extend SoundEvent with Eq::{not_equal, equal}

///|
pub extend SoundEvent with Debug::{to_repr}

///|
pub impl Show for SoundEvent with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend SoundEvent with Show::{to_string, output}

///|
pub(all) enum ReplayAction {
  Place(PieceKind, Material, Float, Float, Float) // kind, material, x, y, angle
  Rotate(Int) // body_id
  BlueprintPlace(BlueprintKind, Float, Float) // kind, x, y
} derive(Eq, Debug)

///|
pub extend ReplayAction with Eq::{not_equal, equal}

///|
pub extend ReplayAction with Debug::{to_repr}

///|
pub impl Show for ReplayAction with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend ReplayAction with Show::{to_string, output}
