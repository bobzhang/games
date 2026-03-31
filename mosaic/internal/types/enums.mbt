///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Show)

///|
pub(all) enum TileColor {
  Red
  Blue
  Green
  Gold
  Purple
  White
} derive(Eq, Show)

///|
pub(all) enum TileShape {
  Square
  Triangle
  Arrow
  Diamond
  Circle
  Cross
} derive(Eq, Show)

///|
pub(all) enum Orientation {
  N
  E
  S
  W
} derive(Eq, Show)

///|
pub(all) enum SymmetryKind {
  MirrorH
  MirrorV
  MirrorD
  Rotate2
  Rotate4
  Glide
} derive(Eq, Show)

///|
pub(all) enum PlayState {
  Placing
  GuessSymmetry
  Complete
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Repair
  Restore
  Master
} derive(Eq, Show)
