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
} derive(Eq, Show)

///|
pub(all) enum PieceKind {
  Beam
  Block
  Triangle
  Arch
  Cable
} derive(Eq, Show)

///|
pub(all) enum TestKind {
  Wind
  Earthquake
  Impact
} derive(Eq, Show)

///|
pub(all) enum Material {
  Wood
  Stone
  Steel
} derive(Eq, Show)

///|
pub(all) enum JointKind {
  Fixed
  Hinge
  Spring
} derive(Eq, Show)

///|
pub(all) enum BlueprintKind {
  Column
  ArchWay
  Truss
  Foundation
  Custom(Int)
} derive(Eq, Show)

///|
pub(all) enum ChallengeMode {
  TimeAttack
  BudgetMode
  Survival
  Precision
} derive(Eq, Show)

///|
pub(all) enum UpgradeKind {
  Reinforce(Material)
  Lightweight(Material)
  FlexJoints
  DeepFoundation
} derive(Eq, Show)

///|
pub(all) enum WorldTheme {
  StoneFortress
  DesertRuins
  ArcticPeaks
} derive(Eq, Show)

///|
pub(all) enum ComboKind {
  FlexCombo // Wood+Steel adjacent
  MonolithCombo // Stone+Stone adjacent
  ReinforcedCombo // Steel+Steel adjacent
  LightweightCombo // Wood+Wood adjacent
} derive(Eq, Show)

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
} derive(Eq, Show)

///|
pub(all) enum ReplayAction {
  Place(PieceKind, Material, Float, Float, Float) // kind, material, x, y, angle
  Rotate(Int) // body_id
  BlueprintPlace(BlueprintKind, Float, Float) // kind, x, y
} derive(Eq, Show)
