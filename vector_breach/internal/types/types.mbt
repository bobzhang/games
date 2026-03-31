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
}

///|
pub(all) struct PreviewTile {
  x : Int
  y : Int
  effect : EffectKind
  affected_unit : Int
} derive(Show)

///|
pub(all) struct RunState {
  mut current_mission : Int
  mut missions_completed : Int
  mut squad : Array[Int]
  mut augments : Array[Int]
  mut grid_power : Int
  mut reputation : Int
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
    },
    frame_count: 0,
    rng_state: 0xA3B7C1D5U,
    anim_timer: 0.0,
    message_text: "",
    message_timer: 0.0,
    hover_info: "",
  }
}
