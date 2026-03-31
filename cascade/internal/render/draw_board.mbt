///|
fn draw_board(game : @types.Game) -> Unit {
  // Draw socket grid
  draw_grid()
  // Draw dominoes
  let display_tick = if game.replay_mode {
    game.replay_tick
  } else {
    game.current_tick
  }
  for i in 0..<game.dominoes.length() {
    draw_domino(game.dominoes[i], display_tick)
  }
  // Draw hover preview in edit mode
  if game.play_state == Editing && game.show_hover {
    draw_hover_preview(game)
  }
}

///|
fn draw_grid() -> Unit {
  for gy in 0..<@types.grid_rows {
    for gx in 0..<@types.grid_cols {
      let sx = @types.socket_to_screen_x(gx)
      let sy = @types.socket_to_screen_y(gy)
      @raylib.draw_circle(sx, sy, 3.0, @types.color_grid_dot)
    }
  }
}

///|
fn draw_domino(d : @types.Domino, display_tick : Int) -> Unit {
  let sx = Float::from_int(@types.socket_to_screen_x(d.pos.x))
  let sy = Float::from_int(@types.socket_to_screen_y(d.pos.y))
  let angle = @types.orientation_angle(d.orientation)
  // Determine color based on kind and state
  let base_color = if d.is_starter {
    @types.color_starter
  } else {
    @types.kind_color(d.kind)
  }
  let color = match d.state {
    Standing => base_color
    Toppling => {
      if d.topple_tick <= display_tick {
        @types.color_toppling
      } else {
        base_color
      }
    }
    Fallen => @types.color_fallen
  }
  // Calculate tilt for animation
  let tilt : Float = match d.state {
    Standing => 0.0
    Toppling => {
      if d.topple_tick <= display_tick {
        let t = @types.clampf(d.anim_progress, 0.0, 1.0)
        t * 80.0
      } else {
        0.0
      }
    }
    Fallen => 80.0
  }
  let final_angle = angle + tilt
  // Draw target glow
  if d.is_target {
    let glow_alpha = if d.state == Fallen { 60 } else { 120 }
    let glow_color = @raylib.Color::new(40, 220, 80, glow_alpha)
    @raylib.draw_circle_v(
      @raylib.Vector2::new(sx, sy),
      20.0,
      glow_color,
    )
  }
  // Draw starter highlight
  if d.is_starter {
    let pulse_v = Float::from_int(display_tick % 60)
    let pulse : Float = @types.absf(pulse_v / 30.0 - 1.0)
    let pa : Float = 40.0 + pulse * 60.0
    let starter_glow = @raylib.Color::new(255, 180, 0, pa.to_int())
    @raylib.draw_circle_v(
      @raylib.Vector2::new(sx, sy),
      22.0,
      starter_glow,
    )
  }
  // Draw domino body as rotated rectangle
  let hw = @types.domino_width / 2.0
  let hh = @types.domino_height / 2.0
  let rec = @raylib.Rectangle::new(
    sx - hw, sy - hh, @types.domino_width, @types.domino_height,
  )
  @raylib.draw_rectangle_pro(
    rec,
    @raylib.Vector2::new(hw, hh),
    final_angle,
    color,
  )
  // Draw direction indicator for standing dominoes
  if d.state == Standing {
    let dx = Float::from_int(@types.orientation_dx(d.orientation))
    let dy = Float::from_int(@types.orientation_dy(d.orientation))
    let arrow_len : Float = 12.0
    let ax = sx + dx * arrow_len
    let ay = sy + dy * arrow_len
    @raylib.draw_circle_v(
      @raylib.Vector2::new(ax, ay),
      3.0,
      @raylib.Color::new(0, 0, 0, 192),
    )
  }
  // Draw kind indicator
  match d.kind {
    Heavy =>
      @raylib.draw_circle_v(
        @raylib.Vector2::new(sx, sy),
        4.0,
        @raylib.Color::new(0, 0, 0, 128),
      )
    Splitter =>
      @raylib.draw_line(
        sx.to_int() - 4,
        sy.to_int(),
        sx.to_int() + 4,
        sy.to_int(),
        @raylib.Color::new(0, 0, 0, 192),
      )
    Delay =>
      @raylib.draw_circle_lines(
        sx.to_int(),
        sy.to_int(),
        5.0,
        @raylib.Color::new(0, 0, 0, 192),
      )
    _ => ()
  }
}

///|
fn draw_hover_preview(game : @types.Game) -> Unit {
  let gx = game.hover_pos.x
  let gy = game.hover_pos.y
  if !@types.in_grid(gx, gy) {
    return
  }
  let sx = Float::from_int(@types.socket_to_screen_x(gx))
  let sy = Float::from_int(@types.socket_to_screen_y(gy))
  // Check if socket is occupied
  let occupied = @types.find_domino_at(game.dominoes, game.hover_pos) >= 0
  if occupied {
    @raylib.draw_circle_v(
      @raylib.Vector2::new(sx, sy),
      16.0,
      @raylib.Color::new(255, 48, 48, 64),
    )
    return
  }
  // Ghost preview of domino to be placed
  let base_color = @types.kind_color(game.selected_kind)
  let ghost_color = @raylib.Color::new(
    base_color.r.to_int(),
    base_color.g.to_int(),
    base_color.b.to_int(),
    96,
  )
  let angle = @types.orientation_angle(game.hover_orientation)
  let hw = @types.domino_width / 2.0
  let hh = @types.domino_height / 2.0
  let rec = @raylib.Rectangle::new(
    sx - hw, sy - hh, @types.domino_width, @types.domino_height,
  )
  @raylib.draw_rectangle_pro(
    rec,
    @raylib.Vector2::new(hw, hh),
    angle,
    ghost_color,
  )
  // Socket highlight
  @raylib.draw_circle_v(
    @raylib.Vector2::new(sx, sy),
    16.0,
    @types.color_socket_hover,
  )
}
