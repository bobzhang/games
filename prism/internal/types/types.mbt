///|
pub(all) struct BeamColor {
  r : Bool
  g : Bool
  b : Bool
} derive(Eq, Show)

///|
pub(all) struct HexCoord {
  q : Int
  r : Int
} derive(Eq, Show)

///|
pub(all) struct HexCell {
  mut component : ComponentKind?
  mut direction : HexDir
  mut filter_color : FilterColor?
  mut crystal_face : CrystalFace?
  mut target_color : BeamColor?
  mut locked : Bool
  mut received_color : BeamColor?
}

///|
pub(all) struct HexGrid {
  radius : Int
  cells : Map[String, HexCell]
}

///|
pub(all) struct BeamSegment {
  start : HexCoord
  end_ : HexCoord
  color : BeamColor
  direction : HexDir
}

///|
pub(all) struct AvailableComponent {
  kind : ComponentKind
  mut filter_color : FilterColor?
  mut crystal_face : CrystalFace?
  mut count : Int
}

///|
pub(all) struct Level {
  name : String
  tier : Tier
  grid_template : Array[
    (Int, Int, ComponentKind, HexDir, FilterColor?, CrystalFace?, BeamColor?),
  ]
  available : Array[AvailableComponent]
  par_count : Int
}

///|
pub(all) struct LevelScore {
  mut stars : Int
  mut solved : Bool
  mut components_used : Int
}

///|
pub(all) struct Game {
  mut screen : Screen
  mut selected_tier : Tier
  mut selected_level : Int
  grid : HexGrid
  mut beams : Array[BeamSegment]
  mut play_state : PlayState
  mut palette : Array[AvailableComponent]
  mut selected_palette : Int
  mut current_level_index : Int
  mut current_tier_index : Int
  mut hover_q : Int
  mut hover_r : Int
  mut hover_valid : Bool
  mut scores : Array[LevelScore]
  mut frame_count : Int
  mut par_count : Int
  mut level_name : String
  mut show_help : Bool
}
