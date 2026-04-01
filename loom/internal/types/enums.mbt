///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Show)

///|
pub(all) enum PlayState {
  Weaving
  Complete
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Apprentice
  Journeyman
  Master
} derive(Eq, Show)

///|
pub(all) enum WeaveType {
  Plain
  Twill
  Satin
  Herringbone
  Diamond
  Custom
} derive(Eq, Show)

///|
pub(all) enum CellState {
  WarpOver
  WeftOver
} derive(Eq, Show)
