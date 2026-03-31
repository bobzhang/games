///|
pub(all) enum Screen {
  Title
  Build
  Test
  Results
  LevelSelect
  Sandbox
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
