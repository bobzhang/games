///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
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
pub(all) enum DominoKind {
  Normal
  Heavy
  Splitter
  Delay
} derive(Eq, Debug)

///|
pub extend DominoKind with Eq::{not_equal, equal}

///|
pub extend DominoKind with Debug::{to_repr}

///|
pub impl Show for DominoKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend DominoKind with Show::{to_string, output}

///|
pub(all) enum Orientation {
  N
  NE
  E
  SE
  S
  SW
  W
  NW
} derive(Eq, Debug)

///|
pub extend Orientation with Eq::{not_equal, equal}

///|
pub extend Orientation with Debug::{to_repr}

///|
pub impl Show for Orientation with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Orientation with Show::{to_string, output}

///|
pub(all) enum DominoState {
  Standing
  Toppling
  Fallen
} derive(Eq, Debug)

///|
pub extend DominoState with Eq::{not_equal, equal}

///|
pub extend DominoState with Debug::{to_repr}

///|
pub impl Show for DominoState with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend DominoState with Show::{to_string, output}

///|
pub(all) enum PlayState {
  Editing
  Running
  Stepping
  Complete
  Failed
} derive(Eq, Debug)

///|
pub extend PlayState with Eq::{not_equal, equal}

///|
pub extend PlayState with Debug::{to_repr}

///|
pub impl Show for PlayState with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend PlayState with Show::{to_string, output}

///|
pub(all) enum Tier {
  Chains
  Splits
  Timing
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
