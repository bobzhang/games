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
pub(all) struct HexCoord {
  q : Int32
  r : Int32
} derive(Eq, Debug)

///|
pub extend HexCoord with Eq::{not_equal, equal}

///|
pub extend HexCoord with Debug::{to_repr}

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
  radius : Int32
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
  mut count : Int32
}

///|
pub(all) struct Level {
  name : String
  tier : Tier
  grid_template : Array[
    (
      Int32,
      Int32,
      ComponentKind,
      HexDir,
      FilterColor?,
      CrystalFace?,
      BeamColor?,
    ),
  ]
  available : Array[AvailableComponent]
  par_count : Int32
}

///|
pub(all) struct LevelScore {
  mut stars : Int32
  mut solved : Bool
  mut components_used : Int32
}

///|
pub(all) struct Game {
  mut screen : Screen
  mut selected_tier : Tier
  mut selected_level : Int32
  grid : HexGrid
  mut beams : Array[BeamSegment]
  mut play_state : PlayState
  mut palette : Array[AvailableComponent]
  mut selected_palette : Int32
  mut current_level_index : Int32
  mut current_tier_index : Int32
  mut hover_q : Int32
  mut hover_r : Int32
  mut hover_valid : Bool
  mut scores : Array[LevelScore]
  mut frame_count : Int32
  mut par_count : Int32
  mut level_name : String
  mut show_help : Bool
}
