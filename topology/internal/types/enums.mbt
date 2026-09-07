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
pub(all) enum OpKind {
  Shift
  Rotate
  Flip
  Grow
  Shrink
} derive(Eq, Debug)

///|
pub extend OpKind with Eq::{not_equal, equal}

///|
pub extend OpKind with Debug::{to_repr}

///|
pub impl Show for OpKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend OpKind with Show::{to_string, output}

///|
pub(all) enum Direction {
  N
  E
  S
  W
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
pub(all) enum FlipAxis {
  Horizontal
  Vertical
} derive(Eq, Debug)

///|
pub extend FlipAxis with Eq::{not_equal, equal}

///|
pub extend FlipAxis with Debug::{to_repr}

///|
pub impl Show for FlipAxis with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend FlipAxis with Show::{to_string, output}

///|
pub(all) enum PlayState {
  Idle
  SelectingDirection
  SelectingFlipAxis
  SelectingGrowCell
  SelectingShrinkCell
  AnimatingOp
  Won
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
  Morph
  Sculpt
  Transform
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
pub(all) enum StarRating {
  Zero
  One
  Two
  Three
} derive(Eq, Debug)

///|
pub extend StarRating with Eq::{not_equal, equal}

///|
pub extend StarRating with Debug::{to_repr}

///|
pub impl Show for StarRating with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend StarRating with Show::{to_string, output}
