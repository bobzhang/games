///|
pub(all) struct BeamColor {
  r : Bool
  g : Bool
  b : Bool
} derive(Eq, Debug)

///|
pub extend BeamColor with Eq::{not_equal, equal}

///|
pub extend BeamColor with Debug::{to_repr}

///|
pub(all) struct Vec2i {
  x : Int32
  y : Int32
} derive(Eq, Debug)

///|
pub extend Vec2i with Eq::{not_equal, equal}

///|
pub extend Vec2i with Debug::{to_repr}

///|
pub(all) struct GridCell {
  mut component : ComponentKind?
  mut direction : Direction
  mut filter_color : FilterColor?
  mut target_color : BeamColor?
  mut locked : Bool
  mut received_color : BeamColor?
}

///|
pub(all) struct Grid {
  width : Int32
  height : Int32
  cells : Array[GridCell]
}

///|
pub(all) struct BeamSegment {
  start : Vec2i
  end_ : Vec2i
  color : BeamColor
  direction : Direction
}

///|
pub(all) struct AvailableComponent {
  kind : ComponentKind
  mut filter_color : FilterColor?
  mut count : Int32
}

///|
pub(all) struct Level {
  name : String
  tier : Tier
  grid_template : Array[
    (Int32, Int32, ComponentKind, Direction, FilterColor?, BeamColor?),
  ]
  available : Array[AvailableComponent]
  par_count : Int32
}

///|
pub(all) struct LevelScore {
  mut stars : Int32
  mut solved : Bool
  mut components_used : Int32
  mut beam_crossings : Int32
}

///|
pub(all) struct Game {
  mut screen : Screen
  mut selected_tier : Tier
  mut selected_level : Int32
  grid : Grid
  mut beams : Array[BeamSegment]
  mut play_state : PlayState
  mut palette : Array[AvailableComponent]
  mut selected_palette : Int32
  mut current_level_index : Int32
  mut current_tier_index : Int32
  mut hover_x : Int32
  mut hover_y : Int32
  mut scores : Array[LevelScore]
  mut frame_count : Int32
  mut par_count : Int32
  mut level_name : String
  mut show_help : Bool
}
