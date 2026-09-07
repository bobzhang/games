///|
pub(all) enum Season {
  Spring
  Summer
  Fall
  Winter
} derive(Eq, Debug)

///|
pub extend Season with Eq::{not_equal, equal}

///|
pub extend Season with Debug::{to_repr}

///|
pub impl Show for Season with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Season with Show::{to_string, output}

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
} derive(Eq, Debug)

///|
pub extend CropKind with Eq::{not_equal, equal}

///|
pub extend CropKind with Debug::{to_repr}

///|
pub impl Show for CropKind with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend CropKind with Show::{to_string, output}

///|
pub(all) enum CropState {
  Empty
  Planted
  Growing
  Mature
  Harvested
  Withered
} derive(Eq, Debug)

///|
pub extend CropState with Eq::{not_equal, equal}

///|
pub extend CropState with Debug::{to_repr}

///|
pub impl Show for CropState with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend CropState with Show::{to_string, output}

///|
pub(all) enum Screen {
  Title
  LevelSelect
  Planning
  Simulate
  Results
} derive(Eq, Debug)

///|
pub extend Screen with Eq::{not_equal, equal}

///|
pub extend Screen with Debug::{to_repr}

///|
pub impl Show for Screen with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Screen with Show::{to_string, output}

///|
pub(all) enum Nutrient {
  Nitrogen
  Phosphorus
  Potassium
} derive(Eq, Debug)

///|
pub extend Nutrient with Eq::{not_equal, equal}

///|
pub extend Nutrient with Debug::{to_repr}

///|
pub impl Show for Nutrient with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Nutrient with Show::{to_string, output}

///|
pub(all) enum Tier {
  Bronze
  Silver
  Gold
} derive(Eq, Debug)

///|
pub extend Tier with Eq::{not_equal, equal}

///|
pub extend Tier with Debug::{to_repr}

///|
pub impl Show for Tier with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend Tier with Show::{to_string, output}
