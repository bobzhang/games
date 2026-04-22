///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Debug)

///|
pub impl Show for Screen with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum PlayState {
  Placing
  Simulating
  Complete
  Failed
} derive(Eq, Debug)

///|
pub impl Show for PlayState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Tier {
  Tier1
  Tier2
  Tier3
} derive(Eq, Debug)

///|
pub impl Show for Tier with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum TileKind {
  Empty
  Spring
  Fountain
  Aqueduct
  Reservoir
  Dam
} derive(Eq, Debug)

///|
pub impl Show for TileKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Direction {
  North
  East
  South
  West
} derive(Eq, Debug)

///|
pub impl Show for Direction with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

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
