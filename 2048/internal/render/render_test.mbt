///|
/// Helper: initializes a hidden raylib window, runs `f` which can draw frames
/// and export PNGs, then closes the window.
fn with_render_window(f : () -> Unit) -> Unit {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(@types.screen_w, @types.screen_h, "render_test")
  @raylib.set_target_fps(60)
  f()
  @raylib.close_window()
}

///|
/// Helper: renders one frame of `draw_frame(game)` into a PNG file.
/// Uses a RenderTexture so we don't need to present to screen.
fn render_to_png(game : @types.Game, path : String) -> Unit {
  let rt = @raylib.load_render_texture(@types.screen_w, @types.screen_h)
  @raylib.begin_texture_mode(rt)
  @raylib.clear_background(@types.bg_color)
  draw_frame(game)
  @raylib.end_texture_mode()
  let tex = @raylib.get_render_texture_texture(rt)
  let img = @raylib.load_image_from_texture(tex)
  // RenderTexture is Y-flipped in OpenGL, flip it back.
  @raylib.image_flip_vertical(img)
  ignore(@raylib.export_image(img, path))
  @raylib.unload_image(img)
  @raylib.unload_render_texture(rt)
}

///|
/// Builds a game in the Title state for testing.
fn make_title_game() -> @types.Game { Game() }

///|
/// Builds a game in Play state with a specific board layout for testing.
fn make_play_game() -> @types.Game {
  let game = @types.Game()
  game.state = Play
  game.score = 1234
  game.best_score = 5678
  game.can_undo = true
  // Place some tiles: 2, 4, 8, 16 on row 0; 32, 64 on row 1; 128, 256 on row 2; 2048 on row 3
  let values = [2, 4, 8, 16, 32, 64, 0, 0, 128, 256, 0, 0, 0, 0, 0, 2048]
  for i in 0..<@types.cell_count {
    game.tiles[i].value = values[i]
    game.tiles[i].scale = 1.0
    let r = i / @types.grid_size
    let c = i % @types.grid_size
    game.tiles[i].anim_x = @types.cell_screen_x(c)
    game.tiles[i].anim_y = @types.cell_screen_y(r)
    game.tiles[i].target_x = @types.cell_screen_x(c)
    game.tiles[i].target_y = @types.cell_screen_y(r)
  }
  game
}

///|
/// Builds a game in Won state for testing.
fn make_won_game() -> @types.Game {
  let game = make_play_game()
  game.state = Won
  game
}

///|
/// Builds a game in Over state for testing.
fn make_over_game() -> @types.Game {
  let game = @types.Game()
  game.state = Over
  game.score = 9876
  game.best_score = 9876
  // Fill board completely with alternating values so no moves remain.
  let values = [2, 4, 2, 4, 4, 2, 4, 2, 2, 4, 2, 4, 4, 2, 4, 2]
  for i in 0..<@types.cell_count {
    game.tiles[i].value = values[i]
    game.tiles[i].scale = 1.0
    let r = i / @types.grid_size
    let c = i % @types.grid_size
    game.tiles[i].anim_x = @types.cell_screen_x(c)
    game.tiles[i].anim_y = @types.cell_screen_y(r)
    game.tiles[i].target_x = @types.cell_screen_x(c)
    game.tiles[i].target_y = @types.cell_screen_y(r)
  }
  game
}

///|
test "render title screen to PNG" {
  with_render_window(fn() {
    let game = make_title_game()
    render_to_png(game, "test_title.png")
  })
}

///|
test "render play state to PNG" {
  with_render_window(fn() {
    let game = make_play_game()
    render_to_png(game, "test_play.png")
  })
}

///|
test "render won overlay to PNG" {
  with_render_window(fn() {
    let game = make_won_game()
    render_to_png(game, "test_won.png")
  })
}

///|
test "render game over overlay to PNG" {
  with_render_window(fn() {
    let game = make_over_game()
    render_to_png(game, "test_over.png")
  })
}
