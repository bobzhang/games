///|
pub(all) struct Cell {
  x : Int
  y : Int
} derive(Eq, Show)

///|
pub(all) struct Tile {
  kind : TileKind
  hazard : HazardKind
  occupied_by : Int
}

///|
pub(all) struct CombatUnit {
  mut id : Int
  mut active : Bool
  team : UnitTeam
  mut x : Int
  mut y : Int
  mut hp : Int
  mut max_hp : Int
  mut shield : Int
  mut heat : Int
  mut max_heat : Int
  mut stunned : Bool
  mut moved_this_turn : Bool
  mut acted_this_turn : Bool
  mech_class : MechClass
  enemy_type : EnemyType
  mut intent : Intent
  mut statuses : Array[StatusEffect]
  mut upgrade_tier : Int
  mut orbital_used : Bool
}

///|
pub(all) struct Grid {
  width : Int
  height : Int
  tiles : Array[Tile]
}

///|
pub fn Grid::new(w : Int, h : Int) -> Grid {
  let tiles = Array::make(
    w * h,
    { kind: Floor, hazard: None, occupied_by: -1 },
  )
  { width: w, height: h, tiles }
}

///|
pub fn Grid::get(self : Grid, x : Int, y : Int) -> Tile {
  self.tiles[y * self.width + x]
}

///|
pub fn Grid::set(self : Grid, x : Int, y : Int, tile : Tile) -> Unit {
  self.tiles[y * self.width + x] = tile
}

///|
pub fn Grid::in_bounds(self : Grid, x : Int, y : Int) -> Bool {
  x >= 0 && x < self.width && y >= 0 && y < self.height
}

///|
pub(all) struct AnimState {
  mut playing : Bool
  mut timer : Float
  mut kind : AnimKind
  mut source_x : Int
  mut source_y : Int
  mut target_x : Int
  mut target_y : Int
  mut unit_id : Int
  mut alpha : Float
}

///|
pub(all) struct FloatingText {
  mut text : String
  mut x : Float
  mut y : Float
  mut timer : Float
  mut duration : Float
  mut color_r : Int
  mut color_g : Int
  mut color_b : Int
}

///|
pub(all) struct Particle {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut life : Float
  mut max_life : Float
  mut color_r : Int
  mut color_g : Int
  mut color_b : Int
}

///|
pub(all) struct ScreenFX {
  mut shake_timer : Float
  mut shake_intensity : Float
  mut flash_timer : Float
  mut flash_r : Int
  mut flash_g : Int
  mut flash_b : Int
  mut flash_alpha : Int
  mut slowmo_timer : Float
  mut pulse_timer : Float
}

///|
pub(all) struct BattleState {
  grid : Grid
  units : Array[CombatUnit]
  mut turn : Int
  mut phase : Screen
  objective : Objective
  mut objective_progress : Int
  mut player_commands : Array[Command]
  mut selected_mech : Int
  mut cursor_x : Int
  mut cursor_y : Int
  mut turn_log : Array[String]
  // Animation and effects
  mut anim_queue : Array[AnimState]
  mut anim_current : AnimState?
  mut floating_texts : Array[FloatingText]
  mut particles : Array[Particle]
  mut screen_fx : ScreenFX
  mut mission_id : Int
  // Augment flags (copied from RunState at battle start for sim access)
  mut augments : Array[AugmentKind]
  // Combo scoring
  mut score : Int
  mut combo_text : String
  mut combo_timer : Float
  mut damage_taken_this_turn : Bool
  // Undo system
  mut undo_stack : Array[BattleSnapshot]
}

///|
pub(all) struct BattleSnapshot {
  unit_states : Array[UnitSnapshot]
  tile_states : Array[Tile]
  grid_width : Int
  grid_height : Int
  selected_mech : Int
  cursor_x : Int
  cursor_y : Int
  commands : Array[Command]
}

///|
pub(all) struct UnitSnapshot {
  id : Int
  active : Bool
  x : Int
  y : Int
  hp : Int
  max_hp : Int
  shield : Int
  heat : Int
  max_heat : Int
  stunned : Bool
  moved_this_turn : Bool
  acted_this_turn : Bool
  statuses : Array[StatusEffect]
}

///|
pub(all) struct PreviewTile {
  x : Int
  y : Int
  effect : EffectKind
  affected_unit : Int
} derive(Show)

///|
pub(all) struct CampaignNode {
  id : Int
  kind : CampaignNodeKind
  x : Int                        // display x position (0-4 columns)
  y : Int                        // display y position (row in that column)
  connections : Array[Int]       // ids of nodes this connects to
}

///|
pub(all) struct CampaignMap {
  nodes : Array[CampaignNode]
  mut selected_node : Int
  mut completed_nodes : Array[Int]
}

///|
pub(all) struct RunState {
  mut current_mission : Int
  mut missions_completed : Int
  mut squad : Array[Int]
  mut augments : Array[AugmentKind]
  mut grid_power : Int
  mut reputation : Int
  mut campaign : CampaignMap?
  mut offered_augments : Array[AugmentKind]
  mut upgrade_tiers : Array[Int]  // [vanguard_tier, striker_tier, sentinel_tier]
  mut total_score : Int
  mut mechs_lost : Int
  mut best_combo : Int
  mut total_turns : Int
}

///|
pub(all) struct Game {
  mut screen : Screen
  mut battle : BattleState?
  mut run : RunState
  mut frame_count : Int
  mut rng_state : UInt
  mut anim_timer : Float
  mut message_text : String
  mut message_timer : Float
  mut hover_info : String

  fn new() -> Game
}

///|
#deprecated
pub fn Game::new() -> Game {
  {
    screen: Title,
    battle: None,
    run: {
      current_mission: 0,
      missions_completed: 0,
      squad: [0, 1, 2],
      augments: [],
      grid_power: 3,
      reputation: 0,
      campaign: None,
      offered_augments: [],
      upgrade_tiers: [0, 0, 0],
      total_score: 0,
      mechs_lost: 0,
      best_combo: 0,
      total_turns: 0,
    },
    frame_count: 0,
    rng_state: 0xA3B7C1D5U,
    anim_timer: 0.0,
    message_text: "",
    message_timer: 0.0,
    hover_info: "",
  }
}

///|
pub fn has_augment(run : RunState, kind : AugmentKind) -> Bool {
  for i = 0; i < run.augments.length(); i = i + 1 {
    if run.augments[i] == kind {
      return true
    }
  }
  false
}
