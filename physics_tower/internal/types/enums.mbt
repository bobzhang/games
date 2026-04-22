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
pub impl Show for Screen with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum PieceKind {
  Beam
  Block
  Triangle
  Arch
  Cable
} derive(Eq, Debug)

///|
pub impl Show for PieceKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum TestKind {
  Wind
  Earthquake
  Impact
} derive(Eq, Debug)

///|
pub impl Show for TestKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Material {
  Wood
  Stone
  Steel
} derive(Eq, Debug)

///|
pub impl Show for Material with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum JointKind {
  Fixed
  Hinge
  Spring
} derive(Eq, Debug)

///|
pub impl Show for JointKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum BlueprintKind {
  Column
  ArchWay
  Truss
  Foundation
  Custom(Int)
} derive(Eq, Debug)

///|
pub impl Show for BlueprintKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum ChallengeMode {
  TimeAttack
  BudgetMode
  Survival
  Precision
} derive(Eq, Debug)

///|
pub impl Show for ChallengeMode with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum UpgradeKind {
  Reinforce(Material)
  Lightweight(Material)
  FlexJoints
  DeepFoundation
} derive(Eq, Debug)

///|
pub impl Show for UpgradeKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum WorldTheme {
  StoneFortress
  DesertRuins
  ArcticPeaks
} derive(Eq, Debug)

///|
pub impl Show for WorldTheme with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum ComboKind {
  FlexCombo // Wood+Steel adjacent
  MonolithCombo // Stone+Stone adjacent
  ReinforcedCombo // Steel+Steel adjacent
  LightweightCombo // Wood+Wood adjacent
} derive(Eq, Debug)

///|
pub impl Show for ComboKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

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
pub impl Show for SoundEvent with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum ReplayAction {
  Place(PieceKind, Material, Float, Float, Float) // kind, material, x, y, angle
  Rotate(Int) // body_id
  BlueprintPlace(BlueprintKind, Float, Float) // kind, x, y
} derive(Eq, Debug)

///|
pub impl Show for ReplayAction with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
