///|
pub(all) enum Screen {
  Title
  TierSelect
  TabletSelect
  Playing
  Results
} derive(Eq, Show)

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
} derive(Eq, Show, Compare)

///|
pub(all) enum PlayState {
  Decoding
  Checking
  Solved
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Fragments
  Scrolls
  Monuments
} derive(Eq, Show)
