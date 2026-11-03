///|
#derive(Eq, Debug)
pub(all) enum Screen {
  Title
  Campaign
  Skirmish
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
pub(all) enum UnitKind {
  Infantry
  Cavalry
  Artillery
}

///|
pub extend UnitKind with Eq::{not_equal, equal}

///|
pub extend UnitKind with Debug::{to_repr}

///|
pub impl Show for UnitKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend UnitKind with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum Terrain {
  Plains
  Forest
  Hills
  Water
}

///|
pub extend Terrain with Eq::{not_equal, equal}

///|
pub extend Terrain with Debug::{to_repr}

///|
pub impl Show for Terrain with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Terrain with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum Team {
  Player
  Enemy
}

///|
pub extend Team with Eq::{not_equal, equal}

///|
pub extend Team with Debug::{to_repr}

///|
pub impl Show for Team with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Team with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum Phase {
  Select
  Move
  Attack
  EnemyTurn
  Animating
}

///|
pub extend Phase with Eq::{not_equal, equal}

///|
pub extend Phase with Debug::{to_repr}

///|
pub impl Show for Phase with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Phase with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum Difficulty {
  Easy
  Normal
  Hard
}

///|
pub extend Difficulty with Eq::{not_equal, equal}

///|
pub extend Difficulty with Debug::{to_repr}

///|
pub impl Show for Difficulty with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Difficulty with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum FogState {
  Hidden
  Visible
  Explored
}

///|
pub extend FogState with Eq::{not_equal, equal}

///|
pub extend FogState with Debug::{to_repr}

///|
pub impl Show for FogState with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend FogState with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum VictoryCondition {
  EliminateAll
  CaptureFlag(Int32, Int32)
}

///|
pub extend VictoryCondition with Eq::{not_equal, equal}

///|
pub extend VictoryCondition with Debug::{to_repr}

///|
pub impl Show for VictoryCondition with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend VictoryCondition with Show::{to_string, output}

///|
#derive(Eq, Debug)
pub(all) enum GameResult {
  Victory
  Defeat
  Ongoing
}

///|
pub extend GameResult with Eq::{not_equal, equal}

///|
pub extend GameResult with Debug::{to_repr}

///|
pub impl Show for GameResult with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend GameResult with Show::{to_string, output}
