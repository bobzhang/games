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
pub(all) enum RockKind {
  Sandstone
  Limestone
  Shale
  Granite
  Basalt
  Coal
  Chalk
  Slate
} derive(Eq, Debug)

///|
pub extend RockKind with Eq::{not_equal, equal}

///|
pub extend RockKind with Debug::{to_repr}

///|
pub impl Show for RockKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend RockKind with Show::{to_string, output}

///|
pub(all) enum ClueKind {
  FossilAge
  Superposition
  Dating
  Intrusion
  Unconformity
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
  Checking
  Solved
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
  Surface
  Bedrock
  DeepCore
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
