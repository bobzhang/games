///|
pub(all) enum MetalKind {
  Iron
  Copper
  Tin
  Gold
  Carbon
  Zinc
} derive(Eq, Show)

///|
pub(all) enum Temperature {
  Low
  Medium
  High
} derive(Eq, Show)

///|
pub(all) enum Screen {
  Title
  LevelSelect
  Playing
  Blending
  LevelComplete
  LevelFailed
} derive(Eq, Show)

///|
pub(all) enum StarRating {
  Zero
  One
  Two
  Three
} derive(Eq, Show)
