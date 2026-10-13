///|
pub(all) struct Soil {
  mut nitrogen : Int32
  mut phosphorus : Int32
  mut potassium : Int32
} derive(Debug)

///|
pub extend Soil with Debug::{to_repr}

///|
pub(all) struct Plot {
  mut crop : CropKind
  mut state : CropState
  mut growth_turns : Int32
  mut soil : Soil
  mut season_planted : Season
} derive(Debug)

///|
pub extend Plot with Debug::{to_repr}

///|
pub(all) struct CropInfo {
  name : String
  plant_season : Season?
  growth_time : Int32
  harvest_season : Season
  value : Int32
  n_cost : Int32
  p_cost : Int32
  k_cost : Int32
} derive(Debug)

///|
pub extend CropInfo with Debug::{to_repr}

///|
pub(all) struct LevelGoal {
  target_value : Int32
  bronze_threshold : Int32
  silver_threshold : Int32
  gold_threshold : Int32
  hint : String
  locked_plots : Array[(Int32, Int32)]
  initial_soil : Array[Array[(Int32, Int32, Int32)]]
} derive(Debug)

///|
pub extend LevelGoal with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut value_earned : Int32
  mut target_value : Int32
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
  mut level_index : Int32
  mut grid : Array[Array[Plot]]
  mut season : Season
  mut season_index : Int32
  mut plans : Array[SeasonPlan]
  mut planning_season : Int32
  mut selected_crop : CropKind
  mut hover_col : Int32
  mut hover_row : Int32
  mut hover_valid : Bool
  mut total_value : Int32
  mut season_value : Int32
  mut level_scores : Array[LevelScore?]
  mut message : String
  mut message_timer : Float
  mut frame_count : Int32
  mut menu_selection : Int32
  mut sim_timer : Float
  mut sim_season : Int32
  mut sim_step : Int32
  mut fade_timer : Float
  mut scroll_offset : Int32
  mut anim_timer : Float
  mut harvest_flash : Array[Array[Float]]
  mut growth_anim : Array[Array[Float]]
} derive(Debug)

///|
pub extend Game with Debug::{to_repr}
