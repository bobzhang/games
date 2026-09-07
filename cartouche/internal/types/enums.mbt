///|
pub(all) enum Screen {
  Title
  TierSelect
  TabletSelect
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
pub(all) enum Symbol {
  Circle
  Triangle
  Square
  Diamond
  Star
  Cross
  Arrow
  Wave
  Spiral
  Dot
  Crescent
  Lightning
  Eye
  Hand
  Sun
  MoonSym
  Mountain
  River
  Tree
  Flame
} derive(Eq, Debug, Compare)

///|
pub extend Symbol with Eq::{not_equal, equal}

///|
pub extend Symbol with Debug::{to_repr}

///|
pub extend Symbol with Compare::{op_lt, op_le, op_ge, compare, op_gt}

///|
pub impl Show for Symbol with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Symbol with Show::{to_string, output}

///|
pub(all) enum PlayState {
  Decoding
  Checking
  Solved
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
  Fragments
  Scrolls
  Monuments
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
