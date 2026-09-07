///|
pub(all) enum MetalKind {
  Iron
  Copper
  Tin
  Gold
  Carbon
  Zinc
} derive(Eq, Debug)

///|
pub extend MetalKind with Eq::{not_equal, equal}

///|
pub extend MetalKind with Debug::{to_repr}

///|
pub impl Show for MetalKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend MetalKind with Show::{to_string, output}

///|
pub(all) enum Temperature {
  Low
  Medium
  High
} derive(Eq, Debug)

///|
pub extend Temperature with Eq::{not_equal, equal}

///|
pub extend Temperature with Debug::{to_repr}

///|
pub impl Show for Temperature with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Temperature with Show::{to_string, output}

///|
pub(all) enum Screen {
  Title
  LevelSelect
  Playing
  Blending
  LevelComplete
  LevelFailed
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
