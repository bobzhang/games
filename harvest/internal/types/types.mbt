///|
pub(all) struct Soil {
  mut nitrogen : Int
  mut phosphorus : Int
  mut potassium : Int
} derive(Debug)

///|
pub extend Soil with Debug::{to_repr}

///|
pub(all) struct Plot {
  mut crop : CropKind
  mut state : CropState
  mut growth_turns : Int
  mut soil : Soil
  mut season_planted : Season
} derive(Debug)

///|
pub extend Plot with Debug::{to_repr}

///|
pub(all) struct CropInfo {
  name : String
  plant_season : Season?
  growth_time : Int
  harvest_season : Season
  value : Int
  n_cost : Int
  p_cost : Int
  k_cost : Int
} derive(Debug)

///|
pub extend CropInfo with Debug::{to_repr}

///|
pub(all) struct LevelGoal {
  target_value : Int
  bronze_threshold : Int
  silver_threshold : Int
  gold_threshold : Int
  hint : String
  locked_plots : Array[(Int, Int)]
  initial_soil : Array[Array[(Int, Int, Int)]]
} derive(Debug)

///|
pub extend LevelGoal with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut value_earned : Int
  mut target_value : Int
  mut tier : Tier?
} derive(Debug)

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct SeasonPlan {
  mut crops : Array[Array[CropKind]]
} derive(Debug)

///|
pub extend SeasonPlan with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut level_index : Int
  mut grid : Array[Array[Plot]]
  mut season : Season
  mut season_index : Int
  mut plans : Array[SeasonPlan]
  mut planning_season : Int
  mut selected_crop : CropKind
  mut hover_col : Int
  mut hover_row : Int
  mut hover_valid : Bool
  mut total_value : Int
  mut season_value : Int
  mut level_scores : Array[LevelScore?]
  mut message : String
  mut message_timer : Float
  mut frame_count : Int
  mut menu_selection : Int
  mut sim_timer : Float
  mut sim_season : Int
  mut sim_step : Int
  mut fade_timer : Float
  mut scroll_offset : Int
  mut anim_timer : Float
  mut harvest_flash : Array[Array[Float]]
  mut growth_anim : Array[Array[Float]]
} derive(Debug)

///|
pub extend Game with Debug::{to_repr}
