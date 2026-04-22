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
  Rising
  Won
  Lost
} derive(Eq, Debug)

///|
pub impl Show for PlayState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Tier {
  Shores
  Straits
  Archipelago
} derive(Eq, Debug)

///|
pub impl Show for Tier with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum TileKind {
  Land
  Water
  Settlement
  Sand
} derive(Eq, Debug)

///|
pub impl Show for TileKind with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
