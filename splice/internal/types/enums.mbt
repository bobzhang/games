///|
pub(all) enum Screen {
  Title
  TierSelect
  LevelSelect
  Playing
  Results
} derive(Eq, Show)

///|
pub(all) enum Base {
  A
  T
  G
  C
} derive(Eq, Show)

///|
pub(all) enum Trait {
  Start
  Stop
  Strength
  Speed
  Shield
  Stealth
  Heal
  Poison
  Armor
  Vision
  Neutral
} derive(Eq, Show)

///|
pub(all) enum OpKind {
  Cut
  Insert
  Duplicate
  Invert
  Delete
} derive(Eq, Show)

///|
pub(all) enum PlayState {
  Editing
  Verified
  Failed
} derive(Eq, Show)

///|
pub(all) enum Tier {
  LabBasics
  GeneEditing
  Mastery
} derive(Eq, Show)
