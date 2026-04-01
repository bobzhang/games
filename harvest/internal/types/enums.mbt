///|
pub(all) enum Season {
  Spring
  Summer
  Fall
  Winter
} derive(Eq, Show)

///|
pub(all) enum CropKind {
  Wheat
  Corn
  Tomato
  Potato
  Carrot
  Pumpkin
  Clover
  Fallow
} derive(Eq, Show)

///|
pub(all) enum CropState {
  Empty
  Planted
  Growing
  Mature
  Harvested
  Withered
} derive(Eq, Show)

///|
pub(all) enum Screen {
  Title
  LevelSelect
  Planning
  Simulate
  Results
} derive(Eq, Show)

///|
pub(all) enum Nutrient {
  Nitrogen
  Phosphorus
  Potassium
} derive(Eq, Show)

///|
pub(all) enum Tier {
  Bronze
  Silver
  Gold
} derive(Eq, Show)
