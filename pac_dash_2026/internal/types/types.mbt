///|
/// Ghost actor state, including movement direction and scatter home.
pub(all) struct Ghost {
  mut x : Int32
  mut y : Int32
  mut dir_x : Int32
  mut dir_y : Int32
  start_x : Int32
  start_y : Int32
  scatter_x : Int32
  scatter_y : Int32
  color : @raylib.Color
}

///|
/// Creates a ghost at spawn with its scatter target and color.
pub fn Ghost::Ghost(
  x : Int32,
  y : Int32,
  scatter_x : Int32,
  scatter_y : Int32,
  color : @raylib.Color,
) -> Ghost {
  {
    x,
    y,
    dir_x: 1,
    dir_y: 0,
    start_x: x,
    start_y: y,
    scatter_x,
    scatter_y,
    color,
  }
}

///|
/// Complete runtime state for one Pac Dash session.
pub(all) struct Game {
  walls : Array[Int32]
  pellets : Array[Int32]
  mut player_x : Int32
  mut player_y : Int32
  mut dir_x : Int32
  mut dir_y : Int32
  mut want_x : Int32
  mut want_y : Int32
  ghosts : Array[Ghost]
  mut score : Int32
  mut lives : Int32
  mut pellets_left : Int32
  mut frightened_timer : Float
  mut phase_timer : Float
  mut chase_mode : Bool
  mut step_timer_player : Float
  mut step_timer_ghost : Float
  mut game_over : Bool
  mut win : Bool
}

///|
/// Allocates a fresh game state with empty maze layers and default counters.
pub fn Game::Game() -> Game {
  {
    walls: Array::make(maze_cols * maze_rows, 0),
    pellets: Array::make(maze_cols * maze_rows, 0),
    player_x: maze_cols / 2,
    player_y: maze_rows - 4,
    dir_x: 0,
    dir_y: 0,
    want_x: 0,
    want_y: 0,
    ghosts: [],
    score: 0,
    lives: 3,
    pellets_left: 0,
    frightened_timer: 0.0,
    phase_timer: 0.0,
    chase_mode: true,
    step_timer_player: 0.0,
    step_timer_ghost: 0.0,
    game_over: false,
    win: false,
  }
}
