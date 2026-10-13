///|
pub(all) struct Cell {
  x : Int32
  y : Int32
} derive(Eq, Debug)

///|
pub extend Cell with Eq::{not_equal, equal}

///|
pub extend Cell with Debug::{to_repr}

///|
pub(all) struct Tile {
  kind : TileKind
  hazard : HazardKind
  occupied_by : Int32
}

///|
pub(all) struct CombatUnit {
  mut id : Int32
  mut active : Bool
  team : UnitTeam
  mut x : Int32
  mut y : Int32
  mut hp : Int32
  mut max_hp : Int32
  mut shield : Int32
  mut heat : Int32
  mut max_heat : Int32
  mut stunned : Bool
  mut moved_this_turn : Bool
  mut acted_this_turn : Bool
  mech_class : MechClass
  enemy_type : EnemyType
  mut intent : Intent
  mut statuses : Array[StatusEffect]
  mut upgrade_tier : Int32
  mut orbital_used : Bool
}

///|
pub(all) struct Grid {
  width : Int32
  height : Int32
  tiles : Array[Tile]
}

///|
pub fn Grid::new(w : Int32, h : Int32) -> Grid {
  let tiles = Array::make(w * h, { kind: Floor, hazard: None, occupied_by: -1, })
  { width: w, height: h, tiles, }
}

///|
pub fn Grid::get(self : Grid, x : Int32, y : Int32) -> Tile {
  self.tiles[y * self.width + x]
}

///|
pub fn Grid::set(self : Grid, x : Int32, y : Int32, tile : Tile) -> Unit {
  self.tiles[y * self.width + x] = tile
}

///|
pub fn Grid::in_bounds(self : Grid, x : Int32, y : Int32) -> Bool {
  x >= 0 && x < self.width && y >= 0 && y < self.height
}

///|
pub(all) struct AnimState {
  mut playing : Bool
  mut timer : Float
  mut kind : AnimKind
  mut source_x : Int32
  mut source_y : Int32
  mut target_x : Int32
  mut target_y : Int32
  mut unit_id : Int32
  mut alpha : Float
}

///|
pub(all) struct FloatingText {
  mut text : String
  mut x : Float
  mut y : Float
  mut timer : Float
  mut duration : Float
  mut color_r : Int32
  mut color_g : Int32
  mut color_b : Int32
  mut scale : Float
  mut glow : Bool
}

///|
pub(all) struct Particle {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut life : Float
  mut max_life : Float
  mut color_r : Int32
  mut color_g : Int32
  mut color_b : Int32
}

///|
pub(all) struct RingEffect {
  mut x : Float
  mut y : Float
  mut radius : Float
  mut max_radius : Float
  mut timer : Float
  mut duration : Float
  mut color_r : Int32
  mut color_g : Int32
  mut color_b : Int32
}

///|
pub(all) struct ScreenFX {
  mut shake_timer : Float
  mut shake_intensity : Float
  mut flash_timer : Float
  mut flash_r : Int32
  mut flash_g : Int32
  mut flash_b : Int32
  mut flash_alpha : Int32
  mut slowmo_timer : Float
  mut pulse_timer : Float
  mut hitstop_timer : Float
  mut tint_timer : Float
  mut tint_r : Int32
  mut tint_g : Int32
  mut tint_b : Int32
  mut tint_alpha : Int32
}

///|
pub(all) struct BattleState {
  grid : Grid
  units : Array[CombatUnit]
  mut turn : Int32
  mut phase : Screen
  objective : Objective
  mut objective_progress : Int32
  mut player_commands : Array[Command]
  mut selected_mech : Int32
  mut cursor_x : Int32
  mut cursor_y : Int32
  mut turn_log : Array[String]
  // Animation and effects
  mut anim_queue : Array[AnimState]
  mut anim_current : AnimState?
  mut floating_texts : Array[FloatingText]
  mut particles : Array[Particle]
  mut rings : Array[RingEffect]
  mut screen_fx : ScreenFX
  mut mission_id : Int32
  // Augment flags (copied from RunState at battle start for sim access)
  mut augments : Array[AugmentKind]
  // Combo scoring
  mut score : Int32
  mut combo_text : String
  mut combo_timer : Float
  mut damage_taken_this_turn : Bool
  // Undo system
  mut undo_stack : Array[BattleSnapshot]
  // Boss set-piece tracking
  mut boss_phase : Int32
  mut boss_narrative_text : String
  mut boss_narrative_timer : Float
  mut boss_walls_deployed : Array[(Int32, Int32)]
}

///|
pub(all) struct BattleSnapshot {
  unit_states : Array[UnitSnapshot]
  tile_states : Array[Tile]
  grid_width : Int32
  grid_height : Int32
  selected_mech : Int32
  cursor_x : Int32
  cursor_y : Int32
  commands : Array[Command]
}

///|
pub(all) struct UnitSnapshot {
  id : Int32
  active : Bool
  x : Int32
  y : Int32
  hp : Int32
  max_hp : Int32
  shield : Int32
  heat : Int32
  max_heat : Int32
  stunned : Bool
  moved_this_turn : Bool
  acted_this_turn : Bool
  statuses : Array[StatusEffect]
}

///|
pub(all) struct PreviewTile {
  x : Int32
  y : Int32
  effect : EffectKind
  affected_unit : Int32
} derive(Debug)

///|
pub extend PreviewTile with Debug::{to_repr}

///|
pub(all) struct CampaignNode {
  id : Int32
  kind : CampaignNodeKind
  x : Int32 // display x position (0-4 columns)
  y : Int32 // display y position (row in that column)
  connections : Array[Int32] // ids of nodes this connects to
  difficulty : Int32 // 1-3 stars
  reward_icon : String // "A"=augment, "G"=GP, "R"=repair, "?"=random
  theme : BranchTheme // path theme modifier
}

///|
pub(all) struct CampaignMap {
  nodes : Array[CampaignNode]
  mut selected_node : Int32
  mut completed_nodes : Array[Int32]
}

///|
pub(all) struct RunState {
  mut current_mission : Int32
  mut missions_completed : Int32
  mut squad : Array[Int32]
  mut augments : Array[AugmentKind]
  mut grid_power : Int32
  mut reputation : Int32
  mut campaign : CampaignMap?
  mut offered_augments : Array[AugmentKind]
  mut upgrade_tiers : Array[Int32] // [vanguard_tier, striker_tier, sentinel_tier]
  mut total_score : Int32
  mut mechs_lost : Int32
  mut best_combo : Int32
  mut total_turns : Int32
  mut mech_hp : Array[Int32] // persistent HP for [vanguard, striker, sentinel]
  mut event_choice : Int32 // 0=none, 1=pay, 2=fight for events
}

///|
pub(all) struct Game {
  mut screen : Screen
  mut battle : BattleState?
  mut run : RunState
  mut frame_count : Int32
  mut rng_state : UInt32
  mut anim_timer : Float
  mut message_text : String
  mut message_timer : Float
  mut hover_info : String
}

///|
pub fn Game::Game() -> Game {
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
      mech_hp: [0, 0, 0],
      event_choice: 0,
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
