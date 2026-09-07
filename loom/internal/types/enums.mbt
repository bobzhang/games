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
pub(all) enum PlayState {
  Weaving
  Complete
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
  Apprentice
  Journeyman
  Master
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
pub(all) enum WeaveType {
  Plain
  Twill
  Satin
  Herringbone
  Diamond
  Custom
} derive(Eq, Debug)

///|
pub extend WeaveType with Eq::{not_equal, equal}

///|
pub extend WeaveType with Debug::{to_repr}

///|
pub impl Show for WeaveType with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend WeaveType with Show::{to_string, output}

///|
pub(all) enum CellState {
  WarpOver
  WeftOver
} derive(Eq, Debug)

///|
pub extend CellState with Eq::{not_equal, equal}

///|
pub extend CellState with Debug::{to_repr}

///|
pub impl Show for CellState with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend CellState with Show::{to_string, output}
