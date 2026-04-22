///|
pub(all) enum Screen {
  Title
  Campaign
  Skirmish
  Playing
  Results
} derive(Eq, Debug)

///|
pub impl Show for Screen with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum UnitKind {
  Infantry
  Cavalry
  Artillery
} derive(Eq, Debug)

///|
pub impl Show for UnitKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Terrain {
  Plains
  Forest
  Hills
  Water
} derive(Eq, Debug)

///|
pub impl Show for Terrain with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Team {
  Player
  Enemy
} derive(Eq, Debug)

///|
pub impl Show for Team with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Phase {
  Select
  Move
  Attack
  EnemyTurn
  Animating
} derive(Eq, Debug)

///|
pub impl Show for Phase with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Difficulty {
  Easy
  Normal
  Hard
} derive(Eq, Debug)

///|
pub impl Show for Difficulty with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum FogState {
  Hidden
  Visible
  Explored
} derive(Eq, Debug)

///|
pub impl Show for FogState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum VictoryCondition {
  EliminateAll
  CaptureFlag(Int, Int)
} derive(Eq, Debug)

///|
pub impl Show for VictoryCondition with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum GameResult {
  Victory
  Defeat
  Ongoing
} derive(Eq, Debug)

///|
pub impl Show for GameResult with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
