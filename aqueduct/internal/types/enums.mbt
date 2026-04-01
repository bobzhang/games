///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Show)

///|
pub(all) enum PlayState {
  Placing
  Simulating
  Complete
  Failed
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Tier1
  Tier2
  Tier3
} derive(Eq, Show)

///|
pub(all) enum TileKind {
  Empty
  Spring
  Fountain
  Aqueduct
  Reservoir
  Dam
} derive(Eq, Show)

///|
pub(all) enum Direction {
  North
  East
  South
  West
} derive(Eq, Show)

///|
pub fn Direction::opposite(self : Direction) -> Direction {
  match self {
    North => South
    South => North
    East => West
    West => East
  }
}

///|
pub fn Direction::dx(self : Direction) -> Int {
  match self {
    East => 1
    West => -1
    _ => 0
  }
}

///|
pub fn Direction::dy(self : Direction) -> Int {
  match self {
    South => 1
    North => -1
    _ => 0
  }
}

///|
pub let all_directions : Array[Direction] = [North, East, South, West]
