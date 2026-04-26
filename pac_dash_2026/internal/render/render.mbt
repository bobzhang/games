///|
/// Draws the maze background, wall tiles, normal pellets, and power pellets.
fn @types.Game::draw_maze(game : @types.Game, art : GameArt) -> Unit {
  @raylib.draw_rectangle(
    @types.maze_x - 4,
    @types.maze_y - 4,
    @types.maze_cols * @types.tile_size + 8,
    @types.maze_rows * @types.tile_size + 8,
    @raylib.Color::new(12, 12, 34, 255),
  )
  draw_texture_cover(
    art.maze_panel,
    Float::from_int(@types.maze_x - 4),
    Float::from_int(@types.maze_y - 4),
    Float::from_int(@types.maze_cols * @types.tile_size + 8),
    Float::from_int(@types.maze_rows * @types.tile_size + 8),
    @raylib.Color::new(90, 150, 255, 68),
  )

  for y in 0..<@types.maze_rows {
    for x in 0..<@types.maze_cols {
      let i = @types.map_index(x, y)
      let px = @types.maze_x + x * @types.tile_size
      let py = @types.maze_y + y * @types.tile_size
      if game.walls[i] != 0 {
        @raylib.draw_rectangle(
          px,
          py,
          @types.tile_size,
          @types.tile_size,
          @raylib.Color::new(24, 60, 185, 255),
        )
        draw_texture_cover(
          art.maze_panel,
          Float::from_int(px),
          Float::from_int(py),
          Float::from_int(@types.tile_size),
          Float::from_int(@types.tile_size),
          @raylib.Color::new(90, 170, 255, 132),
        )
      } else {
        @raylib.draw_rectangle(
          px,
          py,
          @types.tile_size,
          @types.tile_size,
          @raylib.Color::new(8, 8, 18, 255),
        )
        match game.pellets[i] {
          1 =>
            draw_sprite_cell(
              art,
              9,
              Float::from_int(@types.tile_center_x(x)),
              Float::from_int(@types.tile_center_y(y)),
              10.0,
              10.0,
              @raylib.white,
            )
          2 =>
            draw_sprite_cell(
              art,
              10,
              Float::from_int(@types.tile_center_x(x)),
              Float::from_int(@types.tile_center_y(y)),
              22.0,
              22.0,
              @raylib.white,
            )
          _ => ()
        }
      }
    }
  }
}

///|
/// Draws the player character as a yellow circle at its current tile position.
fn @types.Game::draw_player(game : @types.Game, art : GameArt) -> Unit {
  let cx = @types.tile_center_x(game.player_x)
  let cy = @types.tile_center_y(game.player_y)
  let sprite = if game.dir_x < 0 {
    1
  } else if game.dir_y < 0 {
    2
  } else if game.dir_y > 0 {
    3
  } else {
    0
  }
  draw_sprite_cell(
    art,
    sprite,
    Float::from_int(cx),
    Float::from_int(cy),
    27.0,
    27.0,
    @raylib.white,
  )
}

///|
/// Draws all ghosts in their team color, or blue when frightened mode is active.
fn @types.Game::draw_ghosts(game : @types.Game, art : GameArt) -> Unit {
  let mut ghost_index = 0
  for ghost in game.ghosts {
    let cx = @types.tile_center_x(ghost.x)
    let cy = @types.tile_center_y(ghost.y)
    let sprite = if game.frightened_timer > 0.0 {
      8
    } else {
      4 + ghost_index
    }
    draw_sprite_cell(
      art,
      sprite,
      Float::from_int(cx),
      Float::from_int(cy),
      28.0,
      30.0,
      @raylib.white,
    )
    ghost_index = ghost_index + 1
  }
}

///|
/// Draws the HUD panel showing score, lives, pellet count, ghost mode, and controls.
fn @types.Game::draw_hud(game : @types.Game, art : GameArt) -> Unit {
  draw_texture_cover(
    art.hud_panel,
    Float::from_int(@types.hud_x - 16),
    16.0,
    Float::from_int(@types.screen_width - @types.hud_x - 8),
    Float::from_int(@types.screen_height - 32),
    @raylib.Color::new(255, 255, 255, 218),
  )
  @raylib.draw_rectangle(
    @types.hud_x - 8,
    26,
    @types.screen_width - @types.hud_x - 26,
    @types.screen_height - 60,
    @raylib.Color::new(4, 8, 18, 112),
  )

  @draw.draw_text("PAC DASH 2026", @types.hud_x, 30, 30, @raylib.raywhite)
  draw_sprite_cell(art, 11, 724.0, 46.0, 34.0, 34.0, @raylib.white)
  @draw.draw_text("Score", @types.hud_x, 90, 24, @raylib.lightgray)
  @draw.draw_text("\{game.score}", @types.hud_x, 118, 32, @raylib.yellow)
  @draw.draw_text("Lives", @types.hud_x, 170, 24, @raylib.lightgray)
  @draw.draw_text("\{game.lives}", @types.hud_x, 198, 30, @raylib.orange)
  for i in 0..<game.lives {
    draw_sprite_cell(
      art,
      0,
      Float::from_int(@types.hud_x + i * 26),
      230.0,
      22.0,
      22.0,
      @raylib.white,
    )
  }
  @draw.draw_text("Pellets", @types.hud_x, 246, 24, @raylib.lightgray)
  @draw.draw_text(
    "\{game.pellets_left}",
    @types.hud_x,
    274,
    30,
    @raylib.raywhite,
  )

  let mode = if game.frightened_timer > 0.0 {
    "Frightened"
  } else if game.chase_mode {
    "Chase"
  } else {
    "Scatter"
  }
  @draw.draw_text("Mode", @types.hud_x, 322, 24, @raylib.lightgray)
  @draw.draw_text(mode, @types.hud_x, 350, 28, @raylib.skyblue)

  @draw.draw_text("Controls", @types.hud_x, 416, 24, @raylib.lightgray)
  @draw.draw_text("WASD / Arrows", @types.hud_x, 445, 20, @raylib.gray)
  @draw.draw_text("R: Restart", @types.hud_x, 468, 20, @raylib.gray)

  if game.game_over {
    let msg = if game.win { "YOU WIN" } else { "GAME OVER" }
    let color = if game.win { @raylib.lime } else { @raylib.red }
    @draw.draw_text(msg, @types.hud_x, 520, 34, color)
  }
}

///|
/// Draws maze, actors, and HUD for the current Pac Dash frame.
pub fn draw_frame(game : @types.Game, art : GameArt) -> Unit {
  @raylib.begin_drawing()
  @raylib.clear_background(@raylib.Color::new(5, 5, 10, 255))
  draw_texture_cover(
    art.maze_panel,
    0.0,
    0.0,
    Float::from_int(@types.screen_width),
    Float::from_int(@types.screen_height),
    @raylib.Color::new(24, 74, 170, 42),
  )
  game.draw_maze(art)
  game.draw_player(art)
  game.draw_ghosts(art)
  game.draw_hud(art)
  @fps.draw()
  @raylib.end_drawing()
}
