///|
/// High-level phase of a 2048 run.
pub(all) enum GameState {
  Title
  Play
  Won
  Over
} derive(Eq)

///|
/// Mutable tile data used for value storage and render animation.
pub(all) struct Tile {
  mut value : Int
  mut anim_x : Float
  mut anim_y : Float
  mut target_x : Float
  mut target_y : Float
  mut scale : Float
  mut is_new : Bool
  mut is_merged : Bool
  fn new () -> Tile
}

///|
/// Creates an empty tile with neutral animation state.
pub fn Tile::new() -> Tile {
  {
    value: 0,
    anim_x: 0.0,
    anim_y: 0.0,
    target_x: 0.0,
    target_y: 0.0,
    scale: 1.0,
    is_new: false,
    is_merged: false,
  }
}

///|
/// Entire runtime state for one 2048 session.
pub(all) struct Game {
  tiles : Array[Tile]
  prev_values : Array[Int]
  mut state : GameState
  mut score : Int
  mut best_score : Int
  mut prev_score : Int
  mut can_undo : Bool
  mut animating : Bool
  mut msg : String
  mut msg_t : Float
  mut keep_playing : Bool
  fn new() -> Game
}

///|
/// Allocates a fresh game state with cleared board and score counters.
pub fn Game::new() -> Game {
  let g : Game = {
    tiles: Array::makei(cell_count, (_i) => { Tile() }),
    prev_values: Array::make(cell_count, 0),
    state: Title,
    score: 0,
    best_score: 0,
    prev_score: 0,
    can_undo: false,
    animating: false,
    msg: "",
    msg_t: 0.0,
    keep_playing: false,
  }
  g
}
