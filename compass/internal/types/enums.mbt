///|
pub(all) enum Tile {
  Ocean
  Land
  Lighthouse
  Reef
  Landmark
  Current(Direction)
} derive(Show, Eq, ToJson)

///|
pub(all) enum Direction {
  North
  South
  East
  West
} derive(Show, Eq, ToJson)

///|
pub(all) enum GamePhase {
  Menu
  Playing
  LevelComplete
  GameOver
  LevelSelect
} derive(Show, Eq, ToJson)

///|
pub(all) enum StarRating {
  None
  One
  Two
  Three
} derive(Show, Eq, ToJson)
