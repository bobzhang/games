///|
pub(all) enum Screen {
  Title
  Campaign
  Skirmish
  Playing
  Results
} derive(Eq, Show)

///|
pub(all) enum UnitKind {
  Infantry
  Cavalry
  Artillery
} derive(Eq, Show)

///|
pub(all) enum Terrain {
  Plains
  Forest
  Hills
  Water
} derive(Eq, Show)

///|
pub(all) enum Team {
  Player
  Enemy
} derive(Eq, Show)

///|
pub(all) enum Phase {
  Select
  Move
  Attack
  EnemyTurn
  Animating
} derive(Eq, Show)

///|
pub(all) enum Difficulty {
  Easy
  Normal
  Hard
} derive(Eq, Show)

///|
pub(all) enum FogState {
  Hidden
  Visible
  Explored
} derive(Eq, Show)

///|
pub(all) enum VictoryCondition {
  EliminateAll
  CaptureFlag(Int, Int)
} derive(Eq, Show)

///|
pub(all) enum GameResult {
  Victory
  Defeat
  Ongoing
} derive(Eq, Show)
