///|
#derive(Eq, Debug)
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
}

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
#derive(Eq, Debug)
pub(all) enum PlayState {
  Weaving
  Complete
}

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
#derive(Eq, Debug)
pub(all) enum Tier {
  Apprentice
  Journeyman
  Master
}

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
#derive(Eq, Debug)
pub(all) enum WeaveType {
  Plain
  Twill
  Satin
  Herringbone
  Diamond
  Custom
}

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
#derive(Eq, Debug)
pub(all) enum CellState {
  WarpOver
  WeftOver
}

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
