///|
/// Draws a static pattern of dark pixel stars across the screen background.
fn draw_starfield() -> Unit {
  for i in 0..<70 {
    let x = (i * 97 + i * i * 7) % @types.screen_width
    let y = (i * 53 + i * i * 11) % @types.screen_height
    let c = if i % 3 == 0 { @raylib.darkgray } else { @raylib.gray }
    @raylib.draw_pixel(x, y, c)
  }
}

///|
/// Draws the player ship triangle and thrust flame, blinking during invulnerability.
fn @types.Game::draw_ship(game : @types.Game) -> Unit {
  if game.ship_invuln > 0.0 {
    let blink = @raylib.get_time().to_int() % 2
    if blink == 0 {
      return
    }
  }

  let dir_x = @math.cosf(game.ship_angle)
  let dir_y = @math.sinf(game.ship_angle)

  if game.thrusting {
    let back = @raylib.Vector2::new(
      game.ship_x - dir_x * 8.0,
      game.ship_y - dir_y * 8.0,
    )
    @raylib.draw_circle(back.x.to_int(), back.y.to_int(), 3.0, @raylib.orange)
  }

  match tex_ship_sprite.val {
    Some(texture) =>
      draw_art_fit(
        texture,
        game.ship_x,
        game.ship_y,
        46.0,
        34.0,
        game.ship_angle * 57.29577951308232,
        @raylib.white,
      )
    None => {
      let side_x = Float::from_double(
        @math.cos((game.ship_angle + @types.pi * 0.75).to_double()),
      )
      let side_y = Float::from_double(
        @math.sin((game.ship_angle + @types.pi * 0.75).to_double()),
      )
      let side2_x = Float::from_double(
        @math.cos((game.ship_angle - @types.pi * 0.75).to_double()),
      )
      let side2_y = Float::from_double(
        @math.sin((game.ship_angle - @types.pi * 0.75).to_double()),
      )

      let nose = @raylib.Vector2::new(
        game.ship_x + dir_x * 15.0,
        game.ship_y + dir_y * 15.0,
      )
      let left = @raylib.Vector2::new(
        game.ship_x + side_x * 10.0,
        game.ship_y + side_y * 10.0,
      )
      let right = @raylib.Vector2::new(
        game.ship_x + side2_x * 10.0,
        game.ship_y + side2_y * 10.0,
      )

      @raylib.draw_triangle_lines(nose, left, right, @raylib.raywhite)
    }
  }
}

///|
/// Draws all active rocks as overlapping circles, color-coded by size tier.
fn @types.Game::draw_rocks(game : @types.Game) -> Unit {
  for rock in game.rocks {
    if !rock.active {
      continue
    }
    let color = match rock.size {
      2 => @raylib.lightgray
      1 => @raylib.gray
      _ => @raylib.darkgray
    }
    match asteroid_art(rock.size) {
      Some(texture) =>
        draw_art_fit(
          texture,
          rock.x,
          rock.y,
          rock.radius * 2.45,
          rock.radius * 2.45,
          (rock.x + rock.y) * 0.018,
          @raylib.white,
        )
      None => {
        @raylib.draw_circle_lines(
          rock.x.to_int(),
          rock.y.to_int(),
          rock.radius,
          color,
        )
        @raylib.draw_circle_lines(
          (rock.x + 3.0).to_int(),
          (rock.y - 2.0).to_int(),
          rock.radius * 0.6,
          color,
        )
      }
    }
  }
}

///|
/// Draws all active bullets as generated plasma bolts when available, falling back to small yellow circles.
fn @types.Game::draw_bullets(game : @types.Game) -> Unit {
  for bullet in game.bullets {
    if !bullet.active {
      continue
    }
    match tex_projectile_sprite.val {
      Some(texture) =>
        draw_art_fit(
          texture,
          bullet.x,
          bullet.y,
          18.0,
          6.0,
          @math.atan2f(bullet.vy, bullet.vx) * 57.29577951308232,
          @raylib.white,
        )
      None =>
        @raylib.draw_circle(
          bullet.x.to_int(),
          bullet.y.to_int(),
          2.4,
          @raylib.yellow,
        )
    }
  }
}

///|
/// Draws the score, wave, lives counters, key hints, and game-over overlay.
fn @types.Game::draw_hud(game : @types.Game) -> Unit {
  @draw.draw_text("ASTEROID SALVAGE 2026", 18, 14, 30, @raylib.skyblue)
  @draw.draw_text("Score: \{game.score}", 18, 52, 24, @raylib.raywhite)
  @draw.draw_text("Wave: \{game.wave}", 18, 80, 22, @raylib.raywhite)
  @draw.draw_text("Lives: \{game.lives}", 18, 106, 22, @raylib.raywhite)

  @draw.draw_text("A/D or <-/-> rotate", 690, 20, 18, @raylib.gray)
  @draw.draw_text("W or UP thrust", 690, 42, 18, @raylib.gray)
  @draw.draw_text("SPACE fire", 690, 64, 18, @raylib.gray)
  @draw.draw_text("R restart", 690, 86, 18, @raylib.gray)

  if game.game_over {
    @raylib.draw_rectangle(250, 250, 460, 130, @raylib.fade(@raylib.black, 0.8))
    @draw.draw_text("MISSION FAILED", 320, 284, 42, @raylib.red)
    @draw.draw_text("Press R to restart", 360, 334, 28, @raylib.raywhite)
  }
}

///|
/// Draws the complete asteroid salvage frame, including HUD and entities.
pub fn draw_frame(game : @types.Game) -> Unit {
  @raylib.begin_drawing()
  if draw_backdrop_art() {
    @raylib.draw_rectangle(
      0,
      0,
      @types.screen_width,
      @types.screen_height,
      @raylib.Color::new(2, 5, 13, 58),
    )
  } else {
    @raylib.clear_background(@raylib.Color::new(7, 9, 18, 255))
  }
  draw_starfield()
  game.draw_rocks()
  game.draw_bullets()
  game.draw_ship()
  game.draw_hud()
  @fps.draw()
  @raylib.end_drawing()
}
