///|
pub(all) struct BeamColor {
  r : Bool
  g : Bool
  b : Bool
} derive(Eq, Show)

///|
pub(all) struct Vec2i {
  x : Int
  y : Int
} derive(Eq, Show)

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
  width : Int
  height : Int
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
  mut count : Int
}

///|
pub(all) struct Level {
  name : String
  tier : Tier
  grid_template : Array[
    (Int, Int, ComponentKind, Direction, FilterColor?, BeamColor?),
  ]
  available : Array[AvailableComponent]
  par_count : Int
}

///|
pub(all) struct LevelScore {
  mut stars : Int
  mut solved : Bool
  mut components_used : Int
  mut beam_crossings : Int
}

///|
pub(all) struct Game {
  mut screen : Screen
  mut selected_tier : Tier
  mut selected_level : Int
  grid : Grid
  mut beams : Array[BeamSegment]
  mut play_state : PlayState
  mut palette : Array[AvailableComponent]
  mut selected_palette : Int
  mut current_level_index : Int
  mut current_tier_index : Int
  mut hover_x : Int
  mut hover_y : Int
  mut scores : Array[LevelScore]
  mut frame_count : Int
  mut par_count : Int
  mut level_name : String
  mut show_help : Bool
}
