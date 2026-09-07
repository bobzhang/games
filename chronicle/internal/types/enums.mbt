///|
pub(all) enum Screen {
  Title
  TierSelect
  CaseSelect
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
pub(all) enum ClueKind {
  Before
  After
  Because
  During
  NotAdjacent
} derive(Eq, Debug)

///|
pub extend ClueKind with Eq::{not_equal, equal}

///|
pub extend ClueKind with Debug::{to_repr}

///|
pub impl Show for ClueKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend ClueKind with Show::{to_string, output}

///|
pub(all) enum PlayState {
  Arranging
  Linking
  Validated
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
  Reports
  Investigations
  ColdCases
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
