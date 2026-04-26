///|
/// Draws all active road hazards with warning telegraphs.
fn @types.Game::draw_hazards(
  game : @types.Game,
  art : GameArt,
  cam_x : Float,
  cam_y : Float,
) -> Unit {
  for h in game.hazards {
    if !h.active {
      continue
    }
    let x = h.x + cam_x
    let y = h.y + cam_y
    match h.kind {
      OilSlick => {
        // Dark translucent slick with shimmer
        let pulse : Float = 0.5 +
          0.5 * @math.sinf(game.time_s * 3.0 + h.x * 0.01)
        draw_sprite_cell(
          art,
          8,
          x,
          y,
          h.w * 1.34,
          h.h * 2.2,
          @raylib.Color::new(255, 255, 255, 188 + (pulse * 38.0).to_int()),
        )
        // Rainbow shimmer line
        @raylib.draw_rectangle(
          (x - h.w * 0.4).to_int(),
          (y - 1.0).to_int(),
          (h.w * 0.8).to_int(),
          2,
          @raylib.Color::new(
            160 + (pulse * 60.0).to_int(),
            100 + (pulse * 80.0).to_int(),
            200 + (pulse * 40.0).to_int(),
            120,
          ),
        )
      }
      BarrierGate => {
        // Red/orange barrier with warning stripes
        let blink = (@math.sinf(game.time_s * 6.0) * 0.5 + 0.5 > 0.5 : Bool)
        let col = if blink {
          @raylib.Color::new(255, 80, 60, 210)
        } else {
          @raylib.Color::new(255, 140, 40, 180)
        }
        @raylib.draw_circle(
          x.to_int(),
          y.to_int(),
          @types.maxf(h.w, h.h) * 0.42,
          alpha_color(col, 54),
        )
        draw_sprite_cell(
          art,
          9,
          x,
          y,
          h.w * 1.9,
          @types.maxf(h.h * 2.5, 52.0),
          @raylib.Color::new(255, 255, 255, col.a.to_int()),
        )
        @raylib.draw_rectangle_lines(
          (x - h.w * 0.5).to_int(),
          (y - h.h * 0.5).to_int(),
          h.w.to_int(),
          h.h.to_int(),
          @raylib.Color::new(255, 200, 160, 220),
        )
      }
      BlastZone => {
        // Telegraph warning circle before explosion
        let warn_ratio = @types.clampf(
          h.timer / @types.blast_zone_fuse,
          0.0,
          1.0,
        )
        let pulse : Float = 0.5 +
          0.5 * @math.sinf(game.time_s * 8.0 + h.x * 0.02)
        // Warning circle
        if h.warn_t > 0.0 || h.timer > 0.5 {
          let warn_a = (warn_ratio * 180.0).to_int().clamp(min=40, max=180)
          draw_sprite_cell(
            art,
            10,
            x,
            y,
            h.w * 1.34,
            h.h * 1.34,
            @raylib.Color::new(255, 255, 255, warn_a + 54),
          )
          @raylib.draw_circle_lines(
            x.to_int(),
            y.to_int(),
            h.w * 0.5 + pulse * 4.0,
            @raylib.Color::new(255, 100, 60, warn_a),
          )
          // Inner fill getting more intense as timer runs out
          let fill_a = ((Float::from_int(1) - warn_ratio) * 120.0)
            .to_int()
            .clamp(min=0, max=120)
          @raylib.draw_circle(
            x.to_int(),
            y.to_int(),
            h.w * 0.35,
            @raylib.Color::new(255, 60, 40, fill_a),
          )
        }
        // Danger text
        if h.timer < 1.0 && h.timer > 0.0 {
          @draw.draw_text(
            "!",
            (x - 6.0).to_int(),
            (y - 12.0).to_int(),
            24,
            @raylib.Color::new(255, 180 + (pulse * 75.0).to_int(), 60, 240),
          )
        }
      }
    }
  }
}

///|
/// Draws the weapon upgrade indicator in the HUD area.
fn @types.Game::draw_weapon_hud(game : @types.Game) -> Unit {
  match game.weapon {
    None => ()
    Some(upgrade) => {
      let label = match upgrade {
        Spread => "SPREAD"
        Piercing => "PIERCE"
        Homing => "HOMING"
      }
      let col = match upgrade {
        Spread => @raylib.Color::new(120, 220, 255, 230)
        Piercing => @raylib.Color::new(255, 180, 100, 230)
        Homing => @raylib.Color::new(180, 255, 140, 230)
      }
      // Draw weapon indicator below boost/hack boxes
      @raylib.draw_rectangle(
        326,
        80,
        310,
        24,
        @raylib.Color::new(8, 18, 30, 200),
      )
      @raylib.draw_rectangle_lines(326, 80, 310, 24, col)
      let level_str = label + " Lv." + game.weapon_level.to_string()
      @draw.draw_text(level_str, 336, 84, 16, col)
      // Draw level pips
      for i in 0..<game.weapon_level.clamp(min=0, max=3) {
        @raylib.draw_circle(580 + i * 18, 92, 5.0, col)
      }
    }
  }
}

///|
/// Draws the oil slick effect overlay when the player is affected.
fn @types.Game::draw_oil_effect(game : @types.Game) -> Unit {
  if game.oil_t <= 0.0 {
    return
  }
  let alpha = (game.oil_t / @types.oil_slick_duration * 60.0)
    .to_int()
    .clamp(min=0, max=60)
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_w,
    @types.screen_h,
    @raylib.Color::new(40, 20, 60, alpha),
  )
  // "OIL" warning text
  if game.oil_t > 0.3 {
    let pulse = @math.sinf(game.time_s * 8.0)
    let text_a : Int = (Float::from_int(140) + pulse * 60.0)
      .to_int()
      .clamp(min=80, max=200)
    let tw = @draw.measure_text("OIL SLICK", 28)
    @draw.draw_text(
      "OIL SLICK",
      @types.screen_w / 2 - tw / 2,
      @types.screen_h / 2 + 80,
      28,
      @raylib.Color::new(200, 140, 255, text_a),
    )
  }
}

///|
/// Draws the stage transition flash effect.
fn @types.Game::draw_stage_transition(game : @types.Game) -> Unit {
  if game.stage_trans_t <= 0.0 {
    return
  }
  let t = game.stage_trans_t / @types.stage_trans_duration
  let alpha = (t * 180.0).to_int().clamp(min=0, max=180)
  // White flash that fades out
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_w,
    @types.screen_h,
    @raylib.Color::new(200, 240, 255, alpha),
  )
}

///|
/// Draws cooldown arc indicators around the boost and hack HUD boxes for better readability.
fn @types.Game::draw_cooldown_indicators(game : @types.Game) -> Unit {
  // Boost cooldown bar
  if game.boost_cd > 0.0 {
    let ratio = game.boost_cd / @types.boost_cd_time
    let bar_w = (Float::from_int(148) * ratio).to_int()
    @raylib.draw_rectangle(
      327,
      70,
      bar_w,
      3,
      @raylib.Color::new(236, 194, 136, 180),
    )
  } else {
    // Ready pulse
    let pulse = @math.sinf(game.time_s * 4.0) * 0.5 + 0.5
    let a : Int = (Float::from_int(100) + pulse * 80.0).to_int()
    @raylib.draw_rectangle(
      327,
      70,
      148,
      3,
      @raylib.Color::new(128, 248, 170, a),
    )
  }
  // Hack cooldown bar
  if game.hack_cd > 0.0 {
    let ratio = game.hack_cd / @types.hack_cd_time
    let bar_w = (Float::from_int(148) * ratio).to_int()
    @raylib.draw_rectangle(
      487,
      70,
      bar_w,
      3,
      @raylib.Color::new(236, 194, 136, 180),
    )
  } else {
    let pulse = @math.sinf(game.time_s * 4.0 + 1.0) * 0.5 + 0.5
    let a : Int = (Float::from_int(100) + pulse * 80.0).to_int()
    @raylib.draw_rectangle(
      487,
      70,
      148,
      3,
      @raylib.Color::new(128, 248, 170, a),
    )
  }
}

///|
/// Draws combo stinger effect when combo is high.
fn @types.Game::draw_combo_stinger(game : @types.Game) -> Unit {
  if game.combo < 8 || game.combo_t <= 0.0 {
    return
  }
  // Glowing edge lines for high combos
  let intensity = @types.clampf(
    Float::from_int(game.combo - 8) / 16.0,
    0.0,
    1.0,
  )
  let pulse = @math.sinf(game.time_s * 6.0) * 0.5 + 0.5
  let alpha = (intensity * 60.0 + pulse * 30.0 : Float)
    .to_int()
    .clamp(min=0, max=90)
  // Left edge glow
  @raylib.draw_rectangle(
    0,
    @types.ui_panel_h,
    4,
    @types.screen_h - @types.ui_panel_h,
    @raylib.Color::new(255, 220, 100, alpha),
  )
  // Right edge glow
  @raylib.draw_rectangle(
    @types.screen_w - 4,
    @types.ui_panel_h,
    4,
    @types.screen_h - @types.ui_panel_h,
    @raylib.Color::new(255, 220, 100, alpha),
  )
}
