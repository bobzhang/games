///|
pub(all) enum Screen {
  Title
  TierSelect
  TabletSelect
  Playing
  Results
} derive(Eq, Debug)

///|
pub impl Show for Screen with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Symbol {
  Circle
  Triangle
  Square
  Diamond
  Star
  Cross
  Arrow
  Wave
  Spiral
  Dot
  Crescent
  Lightning
  Eye
  Hand
  Sun
  MoonSym
  Mountain
  River
  Tree
  Flame
} derive(Eq, Debug, Compare)

///|
pub impl Show for Symbol with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum PlayState {
  Decoding
  Checking
  Solved
} derive(Eq, Debug)

///|
pub impl Show for PlayState with output(self, logger) {
  Debug::to_repr(self).output(logger)
}

///|
pub(all) enum Tier {
  Fragments
  Scrolls
  Monuments
} derive(Eq, Debug)

///|
pub impl Show for Tier with output(self, logger) {
  Debug::to_repr(self).output(logger)
}
