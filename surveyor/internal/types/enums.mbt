///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Show)

///|
pub(all) enum TileKind {
  Empty
  House(Int) // color_id
  Road
  Water
} derive(Eq, Show)

///|
pub(all) enum PlayState {
  Drawing
  Checking
  Complete
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Plots
  Districts
  Zoning
} derive(Eq, Show)

///|
pub(all) enum Orientation {
  Horizontal // fence on top/bottom edge of cell
  Vertical // fence on left/right edge of cell
} derive(Eq, Show)

///|
pub(all) enum ConstraintResult {
  Satisfied
  Violated
  Unchecked
} derive(Eq, Show)
