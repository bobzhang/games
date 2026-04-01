///|
/// Main draw dispatch
pub fn draw_frame(game : @types.Game) -> Unit {
  @raylib.begin_drawing()
  @raylib.clear_background(@types.color_bg)
  match game.screen {
    Title => draw_title(game)
    WorldSelect => draw_world_select(game)
    LevelSelect => draw_level_select(game)
    Playing => draw_playing(game)
    Planning => {
      draw_playing(game)
      draw_planning_overlay(game)
    }
    Results => draw_results(game)
    Paused => {
      draw_playing(game)
      draw_pause(game)
    }
  }
  @raylib.end_drawing()
}

///|
fn draw_playing(game : @types.Game) -> Unit {
  match game.maze {
    Some(maze) => {
      match game.maze_state {
        Some(maze_state) => {
          // Draw world
          draw_tiles(maze, maze_state)
          draw_wall_edges(maze)
          draw_door_animations(maze, maze_state)
          draw_grid_border(maze)
          draw_exit_glow(maze, game)
          draw_button_glow(maze, maze_state, game)
          draw_collectibles(maze, maze_state, game)
          draw_door_labels(maze, maze_state)
          draw_timed_door_indicators(maze, maze_state, game)
          draw_start_marker(maze, game)
          // Draw entities
          draw_ghosts(game, maze)
          draw_guards(maze_state, game)
          draw_player(game)
          // Draw FX
          draw_ghost_trails(game)
          draw_ghost_collision_preview(game)
          draw_ghost_button_feedback(game)
          draw_danger_border(game)
          draw_scanlines(game)
          draw_failed_overlay(game)
          draw_restart_flash(game)
          draw_loop_transition(game)
          // Draw HUD
          draw_hud(game)
          // Draw message
          draw_message(game, maze)
        }
        None => ()
      }
    }
    None => ()
  }
}
