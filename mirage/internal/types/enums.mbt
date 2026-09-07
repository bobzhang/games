///|
pub(all) enum Tile {
  Empty
  Floor
  Wall
  Gap
  Exit
  Switch(Int)
  Platform
  Gem
} derive(Eq, Debug)

///|
pub extend Tile with Eq::{not_equal, equal}

///|
pub extend Tile with Debug::{to_repr}

///|
pub impl Show for Tile with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Tile with Show::{to_string, output}

///|
pub(all) enum Screen {
  Title
  Playing
  LevelSelect
  LevelComplete
  GameComplete
  Paused
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
pub(all) enum Layer {
  Foreground
  Background
} derive(Eq, Debug)

///|
pub extend Layer with Eq::{not_equal, equal}

///|
pub extend Layer with Debug::{to_repr}

///|
pub impl Show for Layer with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Layer with Show::{to_string, output}

///|
pub(all) enum Direction {
  Up
  Down
  Left
  Right
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
pub(all) enum Tier {
  Reflection
  Overlap
  Illusion
} derive(Eq, Debug)

///|
pub extend Tier with Eq::{not_equal, equal}

///|
pub extend Tier with Debug::{to_repr}

///|
pub impl Show for Tier with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Tier with Show::{to_string, output}

///|
pub(all) enum MergeState {
  Split
  Merged
} derive(Eq, Debug)

///|
pub extend MergeState with Eq::{not_equal, equal}

///|
pub extend MergeState with Debug::{to_repr}

///|
pub impl Show for MergeState with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend MergeState with Show::{to_string, output}

///|
pub(all) enum AnimKind {
  LayerSwap
  Merge
  PlayerMove
  SwitchToggle
  LevelClear
  GemCollect
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
