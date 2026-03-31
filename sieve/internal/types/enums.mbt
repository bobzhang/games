///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Show)

///|
pub(all) enum ConstraintKind {
  RowSum
  ColProduct
  Adjacent
  NoPrimePair
  Divisible
  Unique
} derive(Eq, Show)

///|
pub(all) enum PlayState {
  Editing
  Checking
  Solved
  Failed
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Primes
  Factors
  Theorem
} derive(Eq, Show)
