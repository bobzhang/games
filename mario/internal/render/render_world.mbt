// ── Color constants (used for entities without sprites) ─────────────

///|
let sky_blue : @raylib.Color = @raylib.Color::new(92, 148, 252, 255)

///|
let pipe_green : @raylib.Color = @raylib.Color::new(0, 168, 0, 255)

///|
let pipe_light : @raylib.Color = @raylib.Color::new(80, 220, 80, 255)

///|
let pipe_dark_col : @raylib.Color = @raylib.Color::new(0, 116, 0, 255)

///|
let mario_skin : @raylib.Color = @raylib.Color::new(252, 188, 116, 255)

///|
let mario_hair : @raylib.Color = @raylib.Color::new(100, 44, 0, 255)

///|
let hill_green : @raylib.Color = @raylib.Color::new(48, 180, 48, 255)

///|
let hill_dark : @raylib.Color = @raylib.Color::new(0, 140, 0, 255)

///|
let cloud_white : @raylib.Color = @raylib.Color::new(252, 252, 252, 255)

///|
let cloud_shadow : @raylib.Color = @raylib.Color::new(216, 228, 252, 255)

///|
let castle_gray : @raylib.Color = @raylib.Color::new(160, 160, 160, 255)

///|
let castle_dark : @raylib.Color = @raylib.Color::new(110, 110, 110, 255)

///|
let castle_top_c : @raylib.Color = @raylib.Color::new(180, 180, 180, 255)

///|
let flag_green : @raylib.Color = @raylib.Color::new(0, 200, 0, 255)

///|
let pole_gray : @raylib.Color = @raylib.Color::new(180, 180, 180, 255)

///|
let fireball_orange : @raylib.Color = @raylib.Color::new(252, 148, 0, 255)

///|
let fireball_yellow : @raylib.Color = @raylib.Color::new(252, 228, 88, 255)

///|
let underground_bg : @raylib.Color = @raylib.Color::new(0, 0, 0, 255)

///|
/// Draw the entire game world: background, tiles, entities, effects.
pub fn draw_game(game : @types.Game) -> Unit {
  let cam_x = game.camera_x.to_int()
  // Background
  let bg = if game.in_bonus_room || game.level_index == 1 || game.level_index == 3 {
    underground_bg
  } else {
    sky_blue
  }
  @raylib.clear_background(bg)
  // Star power zoom: slight zoom-in for visual punch
  let is_star = game.player.star_timer > 0.0
  if is_star {
    let star_zoom : Float = 1.03
    let sw = Float::from_int(@types.screen_w)
    let sh = Float::from_int(@types.screen_h)
    let cam = @raylib.Camera2D::new(
      @raylib.Vector2::new(sw / 2.0, sh / 2.0),
      @raylib.Vector2::new(sw / 2.0, sh / 2.0),
      0.0,
      star_zoom,
    )
    @raylib.begin_mode_2d(cam)
  }
  // Sky decorations (grassland levels only, not bonus rooms)
  if not(game.in_bonus_room) && game.level_index != 1 && game.level_index != 3 {
    draw_hills(game, cam_x)
    draw_clouds(game, cam_x)
  }
  // Tiles
  draw_tiles(game, cam_x)
  // Items (behind player)
  draw_items(game, cam_x)
  // Enemies
  draw_enemies(game, cam_x)
  // Fireballs
  draw_fireballs(game, cam_x)
  // Player
  draw_player(game, cam_x)
  // Particles
  draw_particles(game, cam_x)
  // Score popups
  draw_score_popups(game, cam_x)
  // Flagpole flag
  draw_flag(game, cam_x)
  // End star power zoom
  if is_star {
    @raylib.end_mode_2d()
  }
}

///|
fn draw_hills(game : @types.Game, cam_x : Int) -> Unit {
  let parallax_x = cam_x * 3 / 10
  let ground_y = 13 * @types.tile_size
  for i in 0..<8 {
    let hx = i * 320 + 60 - parallax_x
    let hw = 200 + i * 37 % 100
    let hh = 80 + i * 23 % 60
    if hx + hw > -100 && hx < @types.screen_w + 100 {
      @raylib.draw_ellipse(
        hx + hw / 2,
        ground_y,
        Float::from_int(hw / 2),
        Float::from_int(hh),
        hill_green,
      )
      @raylib.draw_ellipse(
        hx + hw / 2,
        ground_y + 4,
        Float::from_int(hw / 2 - 4),
        Float::from_int(hh / 2),
        hill_dark,
      )
    }
  }
  ignore(game)
}

///|
fn draw_clouds(game : @types.Game, cam_x : Int) -> Unit {
  for i in 0..<game.clouds.length() {
    let c = game.clouds[i]
    let sx = (c.x - Float::from_int(cam_x) * 0.3).to_int()
    let sy = c.y.to_int()
    let w = c.w.to_int()
    if sx + w > -50 && sx < @types.screen_w + 50 {
      let r = w / 3
      @raylib.draw_ellipse(
        sx + r,
        sy + r / 2,
        Float::from_int(r),
        Float::from_int(r * 2 / 3),
        cloud_shadow,
      )
      @raylib.draw_ellipse(
        sx + w / 2,
        sy,
        Float::from_int(r + r / 3),
        Float::from_int(r * 2 / 3 + 4),
        cloud_white,
      )
      @raylib.draw_ellipse(
        sx + w - r,
        sy + r / 4,
        Float::from_int(r - 2),
        Float::from_int(r * 2 / 3 - 2),
        cloud_white,
      )
      @raylib.draw_ellipse(
        sx + r,
        sy + r / 4,
        Float::from_int(r - 4),
        Float::from_int(r * 2 / 3 - 4),
        cloud_white,
      )
    }
  }
}

// ── Tiles ───────────────────────────────────────────────────────

///|
fn draw_tiles(game : @types.Game, cam_x : Int) -> Unit {
  let ts = @types.tile_size
  let start_tx = cam_x / ts
  let end_tx = (cam_x + @types.screen_w) / ts + 1
  for ty in 0..<game.map_height {
    for tx in start_tx..<=end_tx {
      let tile = @types.get_tile(game, tx, ty)
      if tile == Empty {
        continue
      }
      let sx = tx * ts - cam_x
      let mut sy = ty * ts
      for b in 0..<game.bumped_blocks.length() {
        let bb = game.bumped_blocks[b]
        if bb.active && bb.tile_x == tx && bb.tile_y == ty {
          sy = sy + bb.offset_y.to_int()
        }
      }
      match tile {
        Ground => draw_ground_tile(game, tx, ty, sx, sy)
        BrickBlock => draw_brick_tile(game, sx, sy)
        QuestionCoin | QuestionMushroom | QuestionStar | QuestionOneUp =>
          draw_question_tile(game, sx, sy)
        UsedBlock => draw_used_tile(sx, sy)
        PipeTopLeft => draw_pipe_top_left(sx, sy)
        PipeTopRight => draw_pipe_top_right(sx, sy)
        PipeBodyLeft => draw_pipe_body_left(sx, sy)
        PipeBodyRight => draw_pipe_body_right(sx, sy)
        PipeEntrance => draw_pipe_entrance_tile(sx, sy)
        Flagpole => draw_flagpole_tile(sx, sy)
        FlagTop => draw_flag_top_tile(sx, sy)
        CastleBlock => draw_castle_tile(sx, sy)
        CastleTop => draw_castle_top_tile(sx, sy)
        CastleDoor => draw_castle_door(sx, sy)
        CoinTile => draw_coin_tile(game, sx, sy)
        Checkpoint => draw_checkpoint_tile(game, sx, sy)
        HiddenCoin | HiddenOneUp | HiddenBonusCoin | HiddenBonusOneUp => ()
        _ => ()
      }
    }
  }
}

///|
fn draw_ground_tile(
  game : @types.Game,
  tx : Int,
  ty : Int,
  sx : Int,
  sy : Int,
) -> Unit {
  match tex_ground.val {
    Some(tex) => {
      // Ground sprite at src_offset=(0, 32), 16x16
      let above = @types.get_tile(game, tx, ty - 1)
      if not(@types.is_solid(above)) && above != Flagpole && above != FlagTop {
        // Grass-topped ground tile
        draw_sprite(tex, 0.0, 32.0, 16.0, 16.0, sx, sy, white)
      } else {
        // Underground dirt — use the top portion of ground sprite sheet
        draw_sprite(tex, 0.0, 0.0, 16.0, 16.0, sx, sy, white)
      }
    }
    None => draw_ground_tile_fallback(game, tx, ty, sx, sy)
  }
}

///|
fn draw_ground_tile_fallback(
  game : @types.Game,
  tx : Int,
  ty : Int,
  sx : Int,
  sy : Int,
) -> Unit {
  let ts = @types.tile_size
  let ground_brown = @raylib.Color::new(192, 96, 0, 255)
  let ground_dark = @raylib.Color::new(148, 72, 0, 255)
  let grass_green = @raylib.Color::new(0, 188, 0, 255)
  let grass_light = @raylib.Color::new(80, 220, 80, 255)
  let above = @types.get_tile(game, tx, ty - 1)
  if not(@types.is_solid(above)) && above != Flagpole && above != FlagTop {
    @raylib.draw_rectangle(sx, sy + 8, ts, ts - 8, ground_brown)
    @raylib.draw_rectangle(sx, sy, ts, 8, grass_green)
    @raylib.draw_rectangle(sx + 4, sy - 2, 3, 4, grass_light)
    @raylib.draw_rectangle(sx + 16, sy - 1, 2, 3, grass_light)
    @raylib.draw_rectangle(sx + 32, sy - 2, 3, 4, grass_light)
    @raylib.draw_rectangle(sx + 42, sy - 1, 2, 3, grass_light)
  } else {
    @raylib.draw_rectangle(sx, sy, ts, ts, ground_dark)
    @raylib.draw_rectangle(sx + 2, sy + 2, ts - 4, ts - 4, ground_brown)
    @raylib.draw_rectangle(sx + 8, sy + 12, 12, 8, ground_dark)
    @raylib.draw_rectangle(sx + 28, sy + 24, 10, 10, ground_dark)
  }
}

///|
fn draw_brick_tile(game : @types.Game, sx : Int, sy : Int) -> Unit {
  match tex_blocks.val {
    Some(tex) => {
      // Brick: src_offset=(0,0), 5 frames animated, 16x16
      let frame = game.frame_counter / 10 % 5
      draw_sprite_anim(tex, 0.0, 0.0, 16.0, 16.0, frame, sx, sy, white)
    }
    None => draw_brick_tile_fallback(sx, sy)
  }
}

///|
fn draw_brick_tile_fallback(sx : Int, sy : Int) -> Unit {
  let ts = @types.tile_size
  let brick_col = @raylib.Color::new(200, 88, 24, 255)
  let brick_dark = @raylib.Color::new(148, 64, 16, 255)
  let brick_mortar = @raylib.Color::new(96, 44, 8, 255)
  @raylib.draw_rectangle(sx, sy, ts, ts, brick_col)
  @raylib.draw_rectangle(sx, sy + ts / 2 - 1, ts, 2, brick_mortar)
  @raylib.draw_rectangle(sx + ts / 4 - 1, sy, 2, ts / 2, brick_mortar)
  @raylib.draw_rectangle(sx + ts * 3 / 4 - 1, sy, 2, ts / 2, brick_mortar)
  @raylib.draw_rectangle(sx + ts / 2 - 1, sy + ts / 2, 2, ts / 2, brick_mortar)
  @raylib.draw_rectangle(sx, sy + ts / 2, 2, ts / 2, brick_mortar)
  @raylib.draw_rectangle(sx, sy, ts, 2, brick_dark)
  @raylib.draw_rectangle(sx, sy, 2, ts, brick_dark)
}

///|
fn draw_question_tile(game : @types.Game, sx : Int, sy : Int) -> Unit {
  match tex_blocks.val {
    Some(tex) => {
      // QBlock: src_offset=(0,16), 4 frames animated, 16x16
      let frame = game.frame_counter / 15 % 4
      draw_sprite_anim(tex, 0.0, 16.0, 16.0, 16.0, frame, sx, sy, white)
    }
    None => draw_question_tile_fallback(game, sx, sy)
  }
}

///|
fn draw_question_tile_fallback(_game : @types.Game, sx : Int, sy : Int) -> Unit {
  let ts = @types.tile_size
  let question_yellow = @raylib.Color::new(248, 184, 0, 255)
  let question_dark = @raylib.Color::new(200, 136, 0, 255)
  let question_bright = @raylib.Color::new(252, 228, 120, 255)
  @raylib.draw_rectangle(sx, sy, ts, ts, question_yellow)
  @raylib.draw_rectangle(sx, sy, ts, 3, question_dark)
  @raylib.draw_rectangle(sx, sy, 3, ts, question_dark)
  @raylib.draw_rectangle(sx + ts - 3, sy, 3, ts, question_dark)
  @raylib.draw_rectangle(sx, sy + ts - 3, ts, 3, question_dark)
  let qx = sx + ts / 2 - 6
  let qy = sy + ts / 2 - 10
  @raylib.draw_rectangle(sx + 4, sy + 4, ts - 8, ts - 8, question_bright)
  @draw.draw_text("?", qx, qy, 24, question_dark)
}

///|
fn draw_used_tile(sx : Int, sy : Int) -> Unit {
  match tex_blocks.val {
    Some(tex) =>
      // QBlockUsed: src_offset=(0,32), 1 frame, 16x16
      draw_sprite(tex, 0.0, 32.0, 16.0, 16.0, sx, sy, white)
    None => draw_used_tile_fallback(sx, sy)
  }
}

///|
fn draw_used_tile_fallback(sx : Int, sy : Int) -> Unit {
  let ts = @types.tile_size
  let used_color = @raylib.Color::new(148, 108, 60, 255)
  let used_dark = @raylib.Color::new(108, 76, 40, 255)
  @raylib.draw_rectangle(sx, sy, ts, ts, used_color)
  @raylib.draw_rectangle(sx, sy, ts, 2, used_dark)
  @raylib.draw_rectangle(sx, sy, 2, ts, used_dark)
  @raylib.draw_rectangle(sx + ts - 2, sy, 2, ts, used_dark)
  @raylib.draw_rectangle(sx, sy + ts - 2, ts, 2, used_dark)
  @raylib.draw_rectangle(sx + 6, sy + 6, ts - 12, ts - 12, used_dark)
}

// ── Pipes (no sprite assets — keep rectangle drawing) ───────────

///|
fn draw_pipe_top_left(sx : Int, sy : Int) -> Unit {
  let ts = @types.tile_size
  @raylib.draw_rectangle(sx, sy, ts, ts, pipe_green)
  @raylib.draw_rectangle(sx, sy, 8, ts, pipe_light)
  @raylib.draw_rectangle(sx + ts - 4, sy, 4, ts, pipe_dark_col)
  @raylib.draw_rectangle(sx, sy, ts, 6, pipe_light)
  @raylib.draw_rectangle(sx - 4, sy, ts + 4, 12, pipe_green)
  @raylib.draw_rectangle(sx - 4, sy, 8, 12, pipe_light)
}

///|
fn draw_pipe_top_right(sx : Int, sy : Int) -> Unit {
  let ts = @types.tile_size
  @raylib.draw_rectangle(sx, sy, ts, ts, pipe_green)
  @raylib.draw_rectangle(sx, sy, 4, ts, pipe_light)
  @raylib.draw_rectangle(sx + ts - 8, sy, 8, ts, pipe_dark_col)
  @raylib.draw_rectangle(sx, sy, ts, 6, pipe_light)
  @raylib.draw_rectangle(sx, sy, ts + 4, 12, pipe_green)
  @raylib.draw_rectangle(sx + ts - 4, sy, 8, 12, pipe_dark_col)
}

///|
fn draw_pipe_body_left(sx : Int, sy : Int) -> Unit {
  let ts = @types.tile_size
  @raylib.draw_rectangle(sx, sy, ts, ts, pipe_green)
  @raylib.draw_rectangle(sx, sy, 8, ts, pipe_light)
  @raylib.draw_rectangle(sx + ts - 4, sy, 4, ts, pipe_dark_col)
}

///|
fn draw_pipe_body_right(sx : Int, sy : Int) -> Unit {
  let ts = @types.tile_size
  @raylib.draw_rectangle(sx, sy, ts, ts, pipe_green)
  @raylib.draw_rectangle(sx, sy, 4, ts, pipe_light)
  @raylib.draw_rectangle(sx + ts - 8, sy, 8, ts, pipe_dark_col)
}

// (draw_pipe_entrance_tile, draw_coin_tile, draw_checkpoint_tile defined below)

// ── Flagpole / Castle (no sprite assets — keep rectangles) ──────

///|
fn draw_flagpole_tile(sx : Int, sy : Int) -> Unit {
  let ts = @types.tile_size
  @raylib.draw_rectangle(sx + ts / 2 - 3, sy, 6, ts, pole_gray)
  @raylib.draw_rectangle(
    sx + ts / 2 - 1,
    sy,
    2,
    ts,
    @raylib.Color::new(220, 220, 220, 255),
  )
}

///|
fn draw_flag_top_tile(sx : Int, sy : Int) -> Unit {
  let ts = @types.tile_size
  @raylib.draw_rectangle(sx + ts / 2 - 3, sy, 6, ts, pole_gray)
  @raylib.draw_circle(
    sx + ts / 2,
    sy + 6,
    8,
    @raylib.Color::new(220, 200, 0, 255),
  )
}

///|
fn draw_flag(game : @types.Game, cam_x : Int) -> Unit {
  if game.state != LevelClear && game.state != Playing && game.state != BonusRoom {
    return
  }
  let ts = @types.tile_size
  let start_tx = cam_x / ts
  let end_tx = (cam_x + @types.screen_w) / ts + 1
  for tx in start_tx..<=end_tx {
    for ty in 0..<game.map_height {
      if @types.get_tile(game, tx, ty) == FlagTop {
        let pole_sx = tx * ts - cam_x + ts / 2
        let flag_sy = if game.state == LevelClear {
          game.flag_y.to_int()
        } else {
          ty * ts + 16
        }
        @raylib.draw_rectangle(pole_sx + 3, flag_sy, 28, 20, flag_green)
        @raylib.draw_rectangle(
          pole_sx + 3,
          flag_sy,
          28,
          3,
          @raylib.Color::new(0, 160, 0, 255),
        )
        return
      }
    }
  }
}

///|
fn draw_castle_tile(sx : Int, sy : Int) -> Unit {
  let ts = @types.tile_size
  @raylib.draw_rectangle(sx, sy, ts, ts, castle_gray)
  @raylib.draw_rectangle(sx, sy + ts / 2 - 1, ts, 2, castle_dark)
  @raylib.draw_rectangle(sx + ts / 2 - 1, sy, 2, ts / 2, castle_dark)
  @raylib.draw_rectangle(sx + ts / 4 - 1, sy + ts / 2, 2, ts / 2, castle_dark)
  @raylib.draw_rectangle(
    sx + ts * 3 / 4 - 1,
    sy + ts / 2,
    2,
    ts / 2,
    castle_dark,
  )
}

///|
fn draw_castle_top_tile(sx : Int, sy : Int) -> Unit {
  let ts = @types.tile_size
  @raylib.draw_rectangle(sx, sy + ts / 2, ts, ts / 2, castle_gray)
  @raylib.draw_rectangle(sx + 2, sy + ts / 4, ts / 2 - 4, ts / 2, castle_top_c)
  @raylib.draw_rectangle(
    sx + ts / 2 + 2,
    sy + ts / 4,
    ts / 2 - 4,
    ts / 2,
    castle_top_c,
  )
}

///|
fn draw_castle_door(sx : Int, sy : Int) -> Unit {
  let ts = @types.tile_size
  @raylib.draw_rectangle(sx, sy, ts, ts, castle_gray)
  @raylib.draw_rectangle(
    sx + 8,
    sy + 8,
    ts - 16,
    ts - 8,
    @raylib.Color::new(40, 20, 0, 255),
  )
  @raylib.draw_rectangle(sx + 8, sy + 6, ts - 16, 8, castle_dark)
}

// ── Player ──────────────────────────────────────────────────────

///|
fn draw_player(game : @types.Game, cam_x : Int) -> Unit {
  let p = game.player
  // Invulnerability blink
  if p.invuln_timer > 0.0 {
    let blink = (p.invuln_timer * 10.0).to_int() % 2
    if blink == 0 {
      return
    }
  }
  // Growth animation blink
  if p.grow_timer > 0.0 {
    let blink = (p.grow_timer * 12.0).to_int() % 3
    if blink == 0 {
      return
    }
  }
  if p.shrink_timer > 0.0 {
    let blink = (p.shrink_timer * 12.0).to_int() % 3
    if blink == 0 {
      return
    }
  }
  let sx = (p.x - Float::from_int(cam_x)).to_int()
  let sy = p.y.to_int()
  // Star power tint
  let is_star = p.star_timer > 0.0
  let tint = if is_star {
    @types.star_color(game.frame_counter / 3 % 5)
  } else {
    white
  }
  if p.dead {
    draw_mario_dead(sx, sy, p.height().to_int())
    return
  }
  if p.power == Small {
    draw_mario_small_sprite(
      sx,
      sy,
      p.facing_right,
      p.anim_frame,
      p.on_ground,
      p.vy < -50.0,
      tint,
    )
  } else {
    // Big or Fire Mario (including ducking state)
    draw_mario_big_sprite(
      sx,
      sy,
      p.facing_right,
      p.anim_frame,
      p.on_ground,
      p.vy < -50.0,
      p.ducking,
      tint,
    )
  }
}

///|
fn draw_mario_small_sprite(
  sx : Int,
  sy : Int,
  facing_right : Bool,
  frame : Int,
  on_ground : Bool,
  jumping : Bool,
  tint : @raylib.Color,
) -> Unit {
  match tex_mario_small.val {
    Some(tex) => {
      // Small Mario sprite: 16x16 source, 48x48 at 3x scale
      // Position: bottom-center at (sx, sy)
      let dx = sx - 24
      let dy = sy - 48
      // Select sprite based on state and direction
      // Reference sprite sheet layout (src_offset = x, y):
      //   Standing Left:  (0, 0)   Standing Right:  (0, 32)
      //   Running Left:   (16, 0)  Running Right:   (16, 32)  — 3 frames
      //   Jumping Left:   (16, 16) Jumping Right:   (16, 48)  — 2 frames
      //   Crouching:      (0, 64)
      let y_off : Float = if facing_right { 32.0 } else { 0.0 }
      if jumping && not(on_ground) {
        // Jumping sprite
        draw_sprite(tex, 16.0, 16.0 + y_off, 16.0, 16.0, dx, dy, tint)
      } else if on_ground && (frame == 1 || frame == 2) {
        // Running sprite (animated)
        let run_frame = frame - 1
        draw_sprite_anim(tex, 16.0, y_off, 16.0, 16.0, run_frame, dx, dy, tint)
      } else {
        // Standing sprite
        draw_sprite(tex, 0.0, y_off, 16.0, 16.0, dx, dy, tint)
      }
    }
    None =>
      draw_mario_small_fallback(
        sx,
        sy,
        if facing_right {
          1
        } else {
          -1
        },
        frame,
        on_ground,
        jumping,
        tint,
      )
  }
}

///|
fn draw_mario_small_fallback(
  sx : Int,
  sy : Int,
  flip : Int,
  frame : Int,
  on_ground : Bool,
  jumping : Bool,
  _tint : @raylib.Color,
) -> Unit {
  let mario_red = @raylib.Color::new(228, 0, 0, 255)
  let mario_blue = @raylib.Color::new(32, 64, 200, 255)
  let bx = sx - 16
  let by = sy - 44
  @raylib.draw_rectangle(bx + 4, by, 24, 10, mario_red)
  @raylib.draw_rectangle(
    bx + (if flip > 0 { 2 } else { 16 }),
    by + 2,
    14,
    8,
    mario_red,
  )
  @raylib.draw_rectangle(bx + 6, by + 10, 20, 12, mario_skin)
  let eye_x = if flip > 0 { bx + 18 } else { bx + 10 }
  @raylib.draw_rectangle(eye_x, by + 12, 4, 4, @raylib.Color::new(0, 0, 0, 255))
  @raylib.draw_rectangle(
    bx + (if flip > 0 { 12 } else { 8 }),
    by + 18,
    12,
    3,
    mario_hair,
  )
  @raylib.draw_rectangle(bx + 4, by + 22, 24, 12, mario_blue)
  if jumping {
    @raylib.draw_rectangle(bx, by + 18, 6, 8, mario_skin)
    @raylib.draw_rectangle(bx + 26, by + 18, 6, 8, mario_skin)
  } else {
    match frame {
      0 => {
        @raylib.draw_rectangle(bx, by + 24, 6, 8, mario_skin)
        @raylib.draw_rectangle(bx + 26, by + 24, 6, 8, mario_skin)
      }
      1 => {
        @raylib.draw_rectangle(bx - 2, by + 22, 6, 8, mario_skin)
        @raylib.draw_rectangle(bx + 28, by + 26, 6, 8, mario_skin)
      }
      _ => {
        @raylib.draw_rectangle(bx + 28, by + 22, 6, 8, mario_skin)
        @raylib.draw_rectangle(bx - 2, by + 26, 6, 8, mario_skin)
      }
    }
  }
  if on_ground && not(jumping) {
    match frame {
      0 => {
        @raylib.draw_rectangle(bx + 6, by + 34, 8, 10, mario_blue)
        @raylib.draw_rectangle(bx + 18, by + 34, 8, 10, mario_blue)
      }
      1 => {
        @raylib.draw_rectangle(bx + 2, by + 34, 8, 10, mario_blue)
        @raylib.draw_rectangle(bx + 22, by + 32, 8, 10, mario_blue)
      }
      _ => {
        @raylib.draw_rectangle(bx + 22, by + 34, 8, 10, mario_blue)
        @raylib.draw_rectangle(bx + 2, by + 32, 8, 10, mario_blue)
      }
    }
  } else {
    @raylib.draw_rectangle(bx + 8, by + 34, 16, 10, mario_blue)
  }
}

///|
fn draw_mario_big_sprite(
  sx : Int,
  sy : Int,
  facing_right : Bool,
  frame : Int,
  on_ground : Bool,
  jumping : Bool,
  ducking : Bool,
  tint : @raylib.Color,
) -> Unit {
  match tex_mario_large.val {
    Some(tex) => {
      // Large Mario sprite: 16x27 source, 48x81 at 3x scale
      // Position: bottom-center at (sx, sy)
      let dx = sx - 24
      let dy = sy - 81
      // Reference sprite sheet layout (src_offset = x, y):
      //   Standing Left:  (16, 5)   Standing Right:  (16, 69)
      //   Running Left:   (0, 37)   Running Right:   (0, 101)  — 4 frames
      //   Jumping Left:   (48, 6)   Jumping Right:   (48, 70)
      //   Crouching:      (32, 5)   (same for both directions)
      if ducking {
        draw_sprite(tex, 32.0, 5.0, 16.0, 27.0, dx, dy, tint)
      } else if jumping && not(on_ground) {
        let src_y : Float = if facing_right { 70.0 } else { 6.0 }
        draw_sprite(tex, 48.0, src_y, 16.0, 27.0, dx, dy, tint)
      } else if on_ground && (frame == 1 || frame == 2) {
        // Running sprite (animated)
        let src_y : Float = if facing_right { 101.0 } else { 37.0 }
        let run_frame = frame - 1
        draw_sprite_anim(tex, 0.0, src_y, 16.0, 27.0, run_frame, dx, dy, tint)
      } else {
        // Standing sprite
        let src_y : Float = if facing_right { 69.0 } else { 5.0 }
        draw_sprite(tex, 16.0, src_y, 16.0, 27.0, dx, dy, tint)
      }
    }
    None =>
      draw_mario_big_fallback(
        sx,
        sy,
        if facing_right {
          1
        } else {
          -1
        },
        frame,
        on_ground,
        jumping,
        tint,
      )
  }
}

///|
fn draw_mario_big_fallback(
  sx : Int,
  sy : Int,
  flip : Int,
  frame : Int,
  on_ground : Bool,
  jumping : Bool,
  _tint : @raylib.Color,
) -> Unit {
  let mario_red = @raylib.Color::new(228, 0, 0, 255)
  let mario_blue = @raylib.Color::new(32, 64, 200, 255)
  let bx = sx - 16
  let by = sy - 76
  @raylib.draw_rectangle(bx + 2, by, 28, 14, mario_red)
  @raylib.draw_rectangle(
    bx + (if flip > 0 { 0 } else { 14 }),
    by + 4,
    18,
    10,
    mario_red,
  )
  @raylib.draw_rectangle(bx + 4, by + 14, 24, 16, mario_skin)
  let eye_x = if flip > 0 { bx + 18 } else { bx + 8 }
  @raylib.draw_rectangle(eye_x, by + 18, 5, 5, @raylib.Color::new(0, 0, 0, 255))
  @raylib.draw_rectangle(
    bx + (if flip > 0 { 12 } else { 6 }),
    by + 26,
    14,
    4,
    mario_hair,
  )
  @raylib.draw_rectangle(bx + 2, by + 30, 28, 14, mario_red)
  @raylib.draw_rectangle(bx + 4, by + 30, 24, 4, mario_blue)
  @raylib.draw_rectangle(bx + 2, by + 40, 28, 16, mario_blue)
  @raylib.draw_rectangle(
    bx + 12,
    by + 42,
    8,
    4,
    @raylib.Color::new(252, 200, 32, 255),
  )
  if jumping {
    @raylib.draw_rectangle(bx - 4, by + 26, 8, 12, mario_skin)
    @raylib.draw_rectangle(bx + 28, by + 26, 8, 12, mario_skin)
  } else {
    match frame {
      0 => {
        @raylib.draw_rectangle(bx - 4, by + 34, 8, 12, mario_skin)
        @raylib.draw_rectangle(bx + 28, by + 34, 8, 12, mario_skin)
      }
      1 => {
        @raylib.draw_rectangle(bx - 6, by + 30, 8, 12, mario_skin)
        @raylib.draw_rectangle(bx + 30, by + 38, 8, 12, mario_skin)
      }
      _ => {
        @raylib.draw_rectangle(bx + 30, by + 30, 8, 12, mario_skin)
        @raylib.draw_rectangle(bx - 6, by + 38, 8, 12, mario_skin)
      }
    }
  }
  if on_ground && not(jumping) {
    match frame {
      0 => {
        @raylib.draw_rectangle(bx + 4, by + 56, 10, 14, mario_blue)
        @raylib.draw_rectangle(bx + 18, by + 56, 10, 14, mario_blue)
        @raylib.draw_rectangle(bx + 2, by + 68, 12, 8, mario_hair)
        @raylib.draw_rectangle(bx + 18, by + 68, 12, 8, mario_hair)
      }
      1 => {
        @raylib.draw_rectangle(bx, by + 56, 10, 12, mario_blue)
        @raylib.draw_rectangle(bx + 22, by + 54, 10, 14, mario_blue)
        @raylib.draw_rectangle(bx - 2, by + 66, 12, 10, mario_hair)
        @raylib.draw_rectangle(bx + 22, by + 66, 12, 10, mario_hair)
      }
      _ => {
        @raylib.draw_rectangle(bx + 22, by + 56, 10, 12, mario_blue)
        @raylib.draw_rectangle(bx, by + 54, 10, 14, mario_blue)
        @raylib.draw_rectangle(bx + 22, by + 66, 12, 10, mario_hair)
        @raylib.draw_rectangle(bx - 2, by + 66, 12, 10, mario_hair)
      }
    }
  } else {
    @raylib.draw_rectangle(bx + 4, by + 56, 10, 14, mario_blue)
    @raylib.draw_rectangle(bx + 18, by + 56, 10, 14, mario_blue)
    @raylib.draw_rectangle(bx + 2, by + 68, 12, 8, mario_hair)
    @raylib.draw_rectangle(bx + 18, by + 68, 12, 8, mario_hair)
  }
}

///|
fn draw_mario_dead(sx : Int, sy : Int, h : Int) -> Unit {
  let mario_red = @raylib.Color::new(228, 0, 0, 255)
  let mario_blue = @raylib.Color::new(32, 64, 200, 255)
  let bx = sx - 16
  let by = sy - h
  @raylib.draw_rectangle(bx + 4, by, 24, 10, mario_red)
  @raylib.draw_rectangle(bx + 6, by + 10, 20, 12, mario_skin)
  @draw.draw_text("x", bx + 12, by + 11, 12, @raylib.Color::new(0, 0, 0, 255))
  @draw.draw_text("x", bx + 20, by + 11, 12, @raylib.Color::new(0, 0, 0, 255))
  @raylib.draw_rectangle(bx + 4, by + 22, 24, 12, mario_blue)
  @raylib.draw_rectangle(bx - 2, by + 16, 6, 10, mario_skin)
  @raylib.draw_rectangle(bx + 28, by + 16, 6, 10, mario_skin)
}

// ── Enemies ─────────────────────────────────────────────────────

///|
fn draw_enemies(game : @types.Game, cam_x : Int) -> Unit {
  for i in 0..<game.enemies.length() {
    let e = game.enemies[i]
    if not(e.active) {
      continue
    }
    let sx = (e.x - Float::from_int(cam_x)).to_int()
    let sy = e.y.to_int()
    if sx < -60 || sx > @types.screen_w + 60 {
      continue
    }
    match e.kind {
      Goomba => draw_goomba(e, sx, sy)
      KoopaTroopa => draw_koopa(e, sx, sy)
      KoopaShell => draw_shell(e, sx, sy)
      PiranhaPlant => draw_piranha_plant(e, sx, sy)
      BuzzyBeetle => draw_buzzy_beetle(e, sx, sy)
      Firebar => draw_firebar(e, sx, sy)
      BowserLite => draw_bowser_lite(game, e, sx, sy)
    }
  }
  // Bowser fire breath projectiles
  draw_bowser_fireballs(game, cam_x)
}

///|
fn draw_goomba(e : @types.Enemy, sx : Int, sy : Int) -> Unit {
  match tex_enemies.val {
    Some(tex) => {
      if e.squished && e.dead {
        // Squished goomba: GoombaSquish at (0, 144), 16x16
        draw_sprite(tex, 0.0, 144.0, 16.0, 16.0, sx - 24, sy - 24, white)
        return
      }
      if e.dead {
        // Flipped goomba — draw upside down using negative height
        let src = @raylib.Rectangle::new(0.0, 128.0, 16.0, -16.0)
        let dst = @raylib.Rectangle::new(
          Float::from_int(sx - 24),
          Float::from_int(sy - 48),
          48.0,
          48.0,
        )
        @raylib.draw_texture_pro(
          tex,
          src,
          dst,
          @raylib.Vector2::new(0.0, 0.0),
          0.0,
          white,
        )
        return
      }
      // Walking goomba: src_offset=(0, 128), 2 frames, 16x16
      let dx = sx - 24
      let dy = sy - 48
      draw_sprite_anim(
        tex,
        0.0,
        128.0,
        16.0,
        16.0,
        e.anim_frame % 2,
        dx,
        dy,
        white,
      )
    }
    None => draw_goomba_fallback(e, sx, sy)
  }
}

///|
fn draw_goomba_fallback(e : @types.Enemy, sx : Int, sy : Int) -> Unit {
  let goomba_body = @raylib.Color::new(172, 80, 28, 255)
  let goomba_dark = @raylib.Color::new(120, 52, 12, 255)
  if e.squished && e.dead {
    @raylib.draw_rectangle(sx - 20, sy - 8, 40, 8, goomba_dark)
    return
  }
  if e.dead {
    let by = sy - 40
    @raylib.draw_rectangle(sx - 18, by, 36, 28, goomba_body)
    @raylib.draw_rectangle(sx - 16, by + 28, 14, 12, goomba_dark)
    @raylib.draw_rectangle(sx + 2, by + 28, 14, 12, goomba_dark)
    return
  }
  let by = sy - 40
  @raylib.draw_rectangle(sx - 18, by + 8, 36, 20, goomba_body)
  @raylib.draw_rectangle(sx - 14, by + 2, 28, 8, goomba_body)
  @raylib.draw_rectangle(sx - 18, by + 20, 36, 8, goomba_dark)
  @raylib.draw_rectangle(
    sx - 10,
    by + 10,
    7,
    8,
    @raylib.Color::new(252, 252, 252, 255),
  )
  @raylib.draw_rectangle(
    sx + 3,
    by + 10,
    7,
    8,
    @raylib.Color::new(252, 252, 252, 255),
  )
  let pupil_off = if e.anim_frame == 0 { 0 } else { 2 }
  @raylib.draw_rectangle(
    sx - 8 + pupil_off,
    by + 12,
    4,
    5,
    @raylib.Color::new(0, 0, 0, 255),
  )
  @raylib.draw_rectangle(
    sx + 5 + pupil_off,
    by + 12,
    4,
    5,
    @raylib.Color::new(0, 0, 0, 255),
  )
  @raylib.draw_rectangle(
    sx - 10,
    by + 8,
    8,
    2,
    @raylib.Color::new(0, 0, 0, 255),
  )
  @raylib.draw_rectangle(sx + 3, by + 8, 8, 2, @raylib.Color::new(0, 0, 0, 255))
  if e.anim_frame == 0 {
    @raylib.draw_rectangle(sx - 16, by + 28, 12, 12, goomba_dark)
    @raylib.draw_rectangle(sx + 4, by + 28, 12, 12, goomba_dark)
  } else {
    @raylib.draw_rectangle(sx - 20, by + 30, 12, 10, goomba_dark)
    @raylib.draw_rectangle(sx + 8, by + 30, 12, 10, goomba_dark)
  }
}

///|
fn draw_koopa(e : @types.Enemy, sx : Int, sy : Int) -> Unit {
  match tex_enemies.val {
    Some(tex) => {
      if e.dead {
        // Flipped koopa — draw shell upside down
        let src = @raylib.Rectangle::new(0.0, 96.0, 16.0, -16.0)
        let dst = @raylib.Rectangle::new(
          Float::from_int(sx - 24),
          Float::from_int(sy - 48),
          48.0,
          48.0,
        )
        @raylib.draw_texture_pro(
          tex,
          src,
          dst,
          @raylib.Vector2::new(0.0, 0.0),
          0.0,
          white,
        )
        return
      }
      // Green Koopa: 16x27 sprites
      // Left: src_offset=(0, 69), Right: src_offset=(32, 69), 2 frames
      let facing_left = e.vx < 0.0
      let src_x : Float = if facing_left { 0.0 } else { 32.0 }
      let dx = sx - 24
      let dy = sy - 81
      draw_sprite_anim(
        tex,
        src_x,
        69.0,
        16.0,
        27.0,
        e.anim_frame % 2,
        dx,
        dy,
        white,
      )
    }
    None => draw_koopa_fallback(e, sx, sy)
  }
}

///|
fn draw_koopa_fallback(e : @types.Enemy, sx : Int, sy : Int) -> Unit {
  let koopa_green_c = @raylib.Color::new(0, 168, 68, 255)
  let koopa_shell_c = @raylib.Color::new(0, 128, 48, 255)
  let koopa_belly = @raylib.Color::new(252, 216, 108, 255)
  if e.dead {
    let by = sy - 52
    @raylib.draw_rectangle(sx - 16, by, 32, 32, koopa_shell_c)
    return
  }
  let by = sy - 52
  @raylib.draw_rectangle(sx - 16, by + 8, 32, 24, koopa_green_c)
  @raylib.draw_rectangle(sx - 14, by + 6, 28, 4, koopa_shell_c)
  @raylib.draw_rectangle(sx - 4, by + 10, 8, 18, koopa_shell_c)
  @raylib.draw_rectangle(sx - 10, by + 26, 20, 10, koopa_belly)
  @raylib.draw_rectangle(
    sx + (if e.vx < 0.0 { -18 } else { 10 }),
    by + 2,
    14,
    16,
    koopa_green_c,
  )
  let head_x = if e.vx < 0.0 { sx - 16 } else { sx + 12 }
  @raylib.draw_rectangle(
    head_x,
    by + 6,
    6,
    6,
    @raylib.Color::new(252, 252, 252, 255),
  )
  @raylib.draw_rectangle(
    head_x + (if e.vx < 0.0 { 0 } else { 3 }),
    by + 8,
    3,
    4,
    @raylib.Color::new(0, 0, 0, 255),
  )
  if e.anim_frame == 0 {
    @raylib.draw_rectangle(sx - 12, by + 36, 10, 16, koopa_belly)
    @raylib.draw_rectangle(sx + 2, by + 36, 10, 16, koopa_belly)
  } else {
    @raylib.draw_rectangle(sx - 16, by + 38, 10, 14, koopa_belly)
    @raylib.draw_rectangle(sx + 6, by + 38, 10, 14, koopa_belly)
  }
}

///|
fn draw_shell(e : @types.Enemy, sx : Int, sy : Int) -> Unit {
  match tex_enemies.val {
    Some(tex) => {
      // Green Koopa Shell: src_offset=(0, 96), 4 frames, 16x16
      let dx = sx - 24
      let dy = sy - 48
      let frame = if e.shell_moving {
        (e.anim_timer * 20.0).to_int() % 4
      } else {
        0
      }
      draw_sprite_anim(tex, 0.0, 96.0, 16.0, 16.0, frame, dx, dy, white)
    }
    None => draw_shell_fallback(e, sx, sy)
  }
}

///|
fn draw_shell_fallback(e : @types.Enemy, sx : Int, sy : Int) -> Unit {
  let koopa_green_c = @raylib.Color::new(0, 168, 68, 255)
  let koopa_shell_c = @raylib.Color::new(0, 128, 48, 255)
  let koopa_belly = @raylib.Color::new(252, 216, 108, 255)
  let by = sy - 36
  @raylib.draw_rectangle(sx - 18, by, 36, 28, koopa_green_c)
  @raylib.draw_rectangle(sx - 16, by + 2, 32, 4, koopa_shell_c)
  @raylib.draw_rectangle(sx - 4, by + 4, 8, 20, koopa_shell_c)
  @raylib.draw_rectangle(sx - 14, by + 22, 28, 8, koopa_belly)
  if e.shell_moving {
    let spin = (e.anim_timer * 20.0).to_int() % 3
    let mark_x = sx - 12 + spin * 10
    @raylib.draw_rectangle(mark_x, by + 8, 4, 12, koopa_shell_c)
  }
}

// ── Items ───────────────────────────────────────────────────────

///|
fn draw_items(game : @types.Game, cam_x : Int) -> Unit {
  for i in 0..<game.items.length() {
    let it = game.items[i]
    if not(it.active) {
      continue
    }
    let sx = (it.x - Float::from_int(cam_x)).to_int()
    let sy = it.y.to_int()
    if sx < -50 || sx > @types.screen_w + 50 {
      continue
    }
    match it.kind {
      Mushroom => draw_mushroom_sprite(game, sx, sy)
      FireFlower => draw_fire_flower(game, sx, sy)
      Star => draw_star(game, sx, sy)
      OneUp => draw_oneup(sx, sy)
      CoinPopup => ()
    }
  }
}

///|
fn draw_mushroom_sprite(game : @types.Game, sx : Int, sy : Int) -> Unit {
  match tex_items.val {
    Some(tex) => {
      // Mushroom: src_offset=(0, 0), 1 frame, 16x16
      let dx = sx - 24
      let dy = sy - 48
      draw_sprite(tex, 0.0, 0.0, 16.0, 16.0, dx, dy, white)
    }
    None => draw_mushroom_fallback(sx, sy)
  }
  ignore(game)
}

///|
fn draw_mushroom_fallback(sx : Int, sy : Int) -> Unit {
  let mushroom_red = @raylib.Color::new(228, 0, 0, 255)
  let mushroom_white = @raylib.Color::new(252, 252, 252, 255)
  @raylib.draw_rectangle(sx - 18, sy - 36, 36, 18, mushroom_red)
  @raylib.draw_rectangle(sx - 8, sy - 38, 16, 6, mushroom_red)
  @raylib.draw_circle(sx - 6, sy - 28, 5, mushroom_white)
  @raylib.draw_circle(sx + 8, sy - 28, 5, mushroom_white)
  @raylib.draw_circle(sx, sy - 34, 4, mushroom_white)
  @raylib.draw_rectangle(sx - 10, sy - 18, 20, 18, mario_skin)
  @raylib.draw_rectangle(
    sx - 6,
    sy - 14,
    4,
    4,
    @raylib.Color::new(0, 0, 0, 255),
  )
  @raylib.draw_rectangle(
    sx + 4,
    sy - 14,
    4,
    4,
    @raylib.Color::new(0, 0, 0, 255),
  )
}

///|
fn draw_fire_flower(game : @types.Game, sx : Int, sy : Int) -> Unit {
  let phase = game.frame_counter / 8 % 2
  let col1 = if phase == 0 {
    @raylib.Color::new(252, 148, 0, 255)
  } else {
    @raylib.Color::new(252, 228, 0, 255)
  }
  let col2 = if phase == 0 {
    @raylib.Color::new(228, 0, 0, 255)
  } else {
    @raylib.Color::new(252, 148, 0, 255)
  }
  @raylib.draw_circle(sx, sy - 32, 8, col2)
  @raylib.draw_circle(sx - 8, sy - 24, 6, col1)
  @raylib.draw_circle(sx + 8, sy - 24, 6, col1)
  @raylib.draw_circle(sx, sy - 20, 6, col1)
  @raylib.draw_circle(sx, sy - 26, 5, @raylib.Color::new(252, 252, 252, 255))
  @raylib.draw_rectangle(
    sx - 3,
    sy - 18,
    6,
    18,
    @raylib.Color::new(0, 168, 0, 255),
  )
}

///|
fn draw_star(game : @types.Game, sx : Int, sy : Int) -> Unit {
  let col = @types.star_color(game.frame_counter / 4 % 5)
  let star_yellow = @raylib.Color::new(252, 228, 0, 255)
  let star_body = @raylib.Color::new(200, 176, 0, 255)
  @raylib.draw_rectangle(sx - 14, sy - 30, 28, 20, col)
  @raylib.draw_rectangle(sx - 8, sy - 36, 16, 8, star_yellow)
  @raylib.draw_rectangle(sx - 8, sy - 10, 16, 10, star_body)
  @raylib.draw_rectangle(
    sx - 6,
    sy - 24,
    4,
    4,
    @raylib.Color::new(0, 0, 0, 255),
  )
  @raylib.draw_rectangle(
    sx + 4,
    sy - 24,
    4,
    4,
    @raylib.Color::new(0, 0, 0, 255),
  )
}

///|
fn draw_oneup(sx : Int, sy : Int) -> Unit {
  let mushroom_white = @raylib.Color::new(252, 252, 252, 255)
  @raylib.draw_rectangle(
    sx - 18,
    sy - 36,
    36,
    18,
    @raylib.Color::new(0, 168, 0, 255),
  )
  @raylib.draw_rectangle(
    sx - 8,
    sy - 38,
    16,
    6,
    @raylib.Color::new(0, 168, 0, 255),
  )
  @raylib.draw_circle(sx - 6, sy - 28, 5, mushroom_white)
  @raylib.draw_circle(sx + 8, sy - 28, 5, mushroom_white)
  @raylib.draw_rectangle(sx - 10, sy - 18, 20, 18, mario_skin)
  @raylib.draw_rectangle(
    sx - 6,
    sy - 14,
    4,
    4,
    @raylib.Color::new(0, 0, 0, 255),
  )
  @raylib.draw_rectangle(
    sx + 4,
    sy - 14,
    4,
    4,
    @raylib.Color::new(0, 0, 0, 255),
  )
}

// ── Fireballs ───────────────────────────────────────────────────

///|
fn draw_fireballs(game : @types.Game, cam_x : Int) -> Unit {
  for i in 0..<game.fireballs.length() {
    let fb = game.fireballs[i]
    if not(fb.active) {
      continue
    }
    let sx = (fb.x - Float::from_int(cam_x)).to_int()
    let sy = fb.y.to_int()
    if sx < -20 || sx > @types.screen_w + 20 {
      continue
    }
    let phase = game.frame_counter % 4
    @raylib.draw_circle(sx, sy, 7, fireball_orange)
    @raylib.draw_circle(
      sx + (if phase < 2 { 3 } else { -3 }),
      sy + (if phase % 2 == 0 { 3 } else { -3 }),
      4,
      fireball_yellow,
    )
  }
}

// ── Particles ───────────────────────────────────────────────────

///|
fn draw_particles(game : @types.Game, cam_x : Int) -> Unit {
  for i in 0..<game.particles.length() {
    let p = game.particles[i]
    if not(p.active) {
      continue
    }
    let sx = (p.x - Float::from_int(cam_x)).to_int()
    let sy = p.y.to_int()
    let alpha = (p.life / p.max_life * 255.0).to_int().clamp(min=0, max=255)
    let color = @raylib.Color::new(
      p.color.r.to_int(),
      p.color.g.to_int(),
      p.color.b.to_int(),
      alpha,
    )
    let sz = p.size.to_int()
    @raylib.draw_rectangle(sx - sz / 2, sy - sz / 2, sz, sz, color)
  }
}

///|
fn draw_score_popups(game : @types.Game, cam_x : Int) -> Unit {
  for i in 0..<game.score_popups.length() {
    let s = game.score_popups[i]
    if not(s.active) {
      continue
    }
    let sx = (s.x - Float::from_int(cam_x)).to_int()
    let sy = s.y.to_int()
    let alpha = (s.life * 255.0).to_int().clamp(min=0, max=255)
    let color = @raylib.Color::new(255, 255, 255, alpha)
    @draw.draw_text(s.text, sx - 12, sy, 16, color)
  }
}

// ── Coin tile ──────────────────────────────────────────────────

///|
/// Draw a spinning coin tile (animated rotation effect).
fn draw_coin_tile(game : @types.Game, sx : Int, sy : Int) -> Unit {
  let ts = @types.tile_size
  let coin_gold = @raylib.Color::new(252, 200, 32, 255)
  let coin_light = @raylib.Color::new(252, 228, 120, 255)
  let coin_dark = @raylib.Color::new(200, 148, 0, 255)
  let phase = game.frame_counter / 6 % 8
  let widths = [12, 10, 6, 2, 6, 10, 12, 12]
  let w = widths[phase]
  let cx = sx + ts / 2
  let cy = sy + ts / 2
  @raylib.draw_rectangle(cx - w / 2, cy - 10, w, 20, coin_gold)
  if w > 4 {
    @raylib.draw_rectangle(cx - w / 2 + 2, cy - 8, w / 3, 16, coin_light)
  }
  @raylib.draw_rectangle(cx - w / 2, cy - 10, w, 2, coin_dark)
  @raylib.draw_rectangle(cx - w / 2, cy + 8, w, 2, coin_dark)
  if game.frame_counter / 15 % 3 == 0 {
    let spark_x = cx + 6
    let spark_y = cy - 12
    @raylib.draw_rectangle(spark_x - 1, spark_y - 3, 2, 6, coin_light)
    @raylib.draw_rectangle(spark_x - 3, spark_y - 1, 6, 2, coin_light)
  }
}

// ── Pipe entrance tile ────────────────────────────────────────

///|
fn draw_pipe_entrance_tile(sx : Int, sy : Int) -> Unit {
  let ts = @types.tile_size
  @raylib.draw_rectangle(sx, sy, ts, ts, pipe_green)
  @raylib.draw_rectangle(sx, sy, 8, ts, pipe_light)
  @raylib.draw_rectangle(sx + ts - 4, sy, 4, ts, pipe_dark_col)
  @raylib.draw_rectangle(sx, sy, ts, 6, pipe_light)
  @raylib.draw_rectangle(sx - 4, sy, ts + 4, 12, pipe_green)
  @raylib.draw_rectangle(sx - 4, sy, 8, 12, pipe_light)
  let arrow_col = @raylib.Color::new(252, 252, 0, 220)
  let mid_x = sx + ts / 2
  let mid_y = sy + ts / 2 + 4
  @raylib.draw_rectangle(mid_x - 2, mid_y - 8, 4, 12, arrow_col)
  @raylib.draw_rectangle(mid_x - 6, mid_y, 12, 4, arrow_col)
  @raylib.draw_rectangle(mid_x - 4, mid_y + 4, 8, 2, arrow_col)
  @raylib.draw_rectangle(mid_x - 2, mid_y + 6, 4, 2, arrow_col)
}

// ── Checkpoint tile ───────────────────────────────────────────

///|
fn draw_checkpoint_tile(game : @types.Game, sx : Int, sy : Int) -> Unit {
  let ts = @types.tile_size
  let pole_x = sx + ts / 2 - 2
  @raylib.draw_rectangle(
    pole_x,
    sy,
    4,
    ts,
    @raylib.Color::new(180, 180, 180, 255),
  )
  let flag_col = if game.checkpoint_active {
    @raylib.Color::new(0, 200, 0, 255)
  } else {
    @raylib.Color::new(200, 200, 0, 255)
  }
  @raylib.draw_rectangle(pole_x + 4, sy + 4, 18, 14, flag_col)
  @raylib.draw_rectangle(
    pole_x + 4,
    sy + 4,
    18,
    2,
    @raylib.Color::new(160, 160, 0, 255),
  )
  @raylib.draw_rectangle(
    pole_x - 4,
    sy + ts - 6,
    12,
    6,
    @raylib.Color::new(140, 140, 140, 255),
  )
}

// ── Fade overlay for bonus room transitions ────────────────────

///|
/// Draw a screen fade overlay for pipe transitions.
pub fn draw_fade_overlay(game : @types.Game) -> Unit {
  if game.bonus_fade_timer > 0.0 {
    let alpha = (game.bonus_fade_timer * 2.0 * 255.0).to_int().clamp(
      min=0,
      max=255,
    )
    @raylib.draw_rectangle(
      0,
      0,
      @types.screen_w,
      @types.screen_h,
      @raylib.Color::new(0, 0, 0, alpha),
    )
  }
}

// ── New enemy rendering ────────────────────────────────────────

///|
/// Draw a PiranhaPlant popping out of a pipe.
fn draw_piranha_plant(e : @types.Enemy, sx : Int, sy : Int) -> Unit {
  if e.dead {
    return
  }
  if not(e.extended) {
    // Retracted — hidden inside pipe, draw nothing
    return
  }
  // Green body
  let plant_green = @raylib.Color::new(0, 180, 0, 255)
  let plant_dark = @raylib.Color::new(0, 120, 0, 255)
  let plant_red = @raylib.Color::new(220, 40, 40, 255)
  let bx = sx - 18
  let by = sy - 48
  // Stem
  @raylib.draw_rectangle(bx + 10, by + 20, 16, 28, plant_green)
  @raylib.draw_rectangle(bx + 12, by + 20, 12, 28, plant_dark)
  // Head (bulb with mouth)
  @raylib.draw_rectangle(bx, by, 36, 22, plant_green)
  @raylib.draw_rectangle(bx + 2, by + 2, 32, 18, plant_dark)
  // Mouth (triangular teeth — red inside)
  @raylib.draw_rectangle(bx + 4, by + 8, 28, 8, plant_red)
  // White teeth as small rectangles
  let teeth_white = @raylib.Color::new(252, 252, 252, 255)
  @raylib.draw_rectangle(bx + 6, by + 8, 4, 4, teeth_white)
  @raylib.draw_rectangle(bx + 14, by + 8, 4, 4, teeth_white)
  @raylib.draw_rectangle(bx + 22, by + 8, 4, 4, teeth_white)
  @raylib.draw_rectangle(bx + 8, by + 12, 4, 4, teeth_white)
  @raylib.draw_rectangle(bx + 18, by + 12, 4, 4, teeth_white)
  @raylib.draw_rectangle(bx + 26, by + 12, 4, 4, teeth_white)
  // Spots on head
  @raylib.draw_circle(bx + 8, by + 4, 3, plant_green)
  @raylib.draw_circle(bx + 28, by + 4, 3, plant_green)
}

///|
/// Draw a BuzzyBeetle (Goomba-like with wings).
fn draw_buzzy_beetle(e : @types.Enemy, sx : Int, sy : Int) -> Unit {
  let beetle_body = @raylib.Color::new(40, 80, 180, 255)
  let beetle_dark = @raylib.Color::new(20, 50, 120, 255)
  let wing_white = @raylib.Color::new(240, 240, 255, 255)
  if e.squished && e.dead {
    @raylib.draw_rectangle(sx - 20, sy - 8, 40, 8, beetle_dark)
    return
  }
  if e.dead {
    let by = sy - 40
    @raylib.draw_rectangle(sx - 18, by, 36, 28, beetle_body)
    return
  }
  let by = sy - 40
  // Body (like Goomba but blue)
  @raylib.draw_rectangle(sx - 18, by + 8, 36, 20, beetle_body)
  @raylib.draw_rectangle(sx - 14, by + 2, 28, 8, beetle_body)
  @raylib.draw_rectangle(sx - 18, by + 20, 36, 8, beetle_dark)
  // Eyes
  @raylib.draw_rectangle(
    sx - 10,
    by + 10,
    7,
    8,
    @raylib.Color::new(252, 252, 252, 255),
  )
  @raylib.draw_rectangle(
    sx + 3,
    by + 10,
    7,
    8,
    @raylib.Color::new(252, 252, 252, 255),
  )
  let pupil_off = if e.anim_frame == 0 { 0 } else { 2 }
  @raylib.draw_rectangle(
    sx - 8 + pupil_off,
    by + 12,
    4,
    5,
    @raylib.Color::new(0, 0, 0, 255),
  )
  @raylib.draw_rectangle(
    sx + 5 + pupil_off,
    by + 12,
    4,
    5,
    @raylib.Color::new(0, 0, 0, 255),
  )
  // Feet
  if e.anim_frame == 0 {
    @raylib.draw_rectangle(sx - 16, by + 28, 12, 12, beetle_dark)
    @raylib.draw_rectangle(sx + 4, by + 28, 12, 12, beetle_dark)
  } else {
    @raylib.draw_rectangle(sx - 20, by + 30, 12, 10, beetle_dark)
    @raylib.draw_rectangle(sx + 8, by + 30, 12, 10, beetle_dark)
  }
  // Wings (small triangles on sides)
  let wing_bob = if e.anim_frame == 0 { -4 } else { 2 }
  // Left wing
  @raylib.draw_rectangle(sx - 26, by + wing_bob, 12, 8, wing_white)
  @raylib.draw_rectangle(sx - 24, by + wing_bob - 2, 8, 4, wing_white)
  // Right wing
  @raylib.draw_rectangle(sx + 14, by + wing_bob, 12, 8, wing_white)
  @raylib.draw_rectangle(sx + 16, by + wing_bob - 2, 8, 4, wing_white)
}

///|
/// Draw a Firebar (rotating fire chain around a center block).
fn draw_firebar(e : @types.Enemy, sx : Int, sy : Int) -> Unit {
  // Center block (gray)
  let center_gray = @raylib.Color::new(140, 140, 140, 255)
  @raylib.draw_rectangle(sx - 8, sy - 24, 16, 16, center_gray)
  // Fire segments rotating
  let angle = e.firebar_angle.to_double()
  let segments = e.firebar_segments
  let spacing = @types.firebar_segment_spacing.to_double()
  let seg_r = @types.firebar_segment_radius
  for seg in 1..=segments {
    let dist = spacing * seg.to_double()
    let seg_x = sx.to_double() + @math.cos(angle) * dist
    let seg_y = (sy - 16).to_double() + @math.sin(angle) * dist
    let seg_sx = seg_x.to_int()
    let seg_sy = seg_y.to_int()
    // Outer orange, inner yellow
    let seg_ri = seg_r.to_int()
    @raylib.draw_circle(seg_sx, seg_sy, seg_r, fireball_orange)
    @raylib.draw_circle(
      seg_sx,
      seg_sy,
      Float::from_int(seg_ri - 3),
      fireball_yellow,
    )
  }
}

///|
/// Draw BowserLite (large boss enemy).
fn draw_bowser_lite(
  game : @types.Game,
  e : @types.Enemy,
  sx : Int,
  sy : Int,
) -> Unit {
  if e.dead {
    // Death animation — falls off screen
    let alpha = 255 - (e.dead_timer * 200.0).to_int().clamp(min=0, max=255)
    let color = @raylib.Color::new(0, 140, 0, alpha)
    @raylib.draw_rectangle(sx - 32, sy - 72, 64, 72, color)
    return
  }
  // Large green body
  let bowser_green = @raylib.Color::new(0, 140, 0, 255)
  let bowser_dark = @raylib.Color::new(0, 100, 0, 255)
  let bowser_belly = @raylib.Color::new(220, 180, 80, 255)
  let horn_color = @raylib.Color::new(240, 200, 40, 255)
  let bx = sx - 32
  let by = sy - 72
  // Body
  @raylib.draw_rectangle(bx + 4, by + 16, 56, 40, bowser_green)
  @raylib.draw_rectangle(bx + 8, by + 12, 48, 8, bowser_green)
  // Belly
  @raylib.draw_rectangle(bx + 12, by + 30, 32, 22, bowser_belly)
  // Shell (dark back ridge)
  @raylib.draw_rectangle(bx + 16, by + 14, 28, 16, bowser_dark)
  // Spikes on shell
  let spike_y = by + 10
  @raylib.draw_rectangle(bx + 20, spike_y, 6, 8, bowser_dark)
  @raylib.draw_rectangle(bx + 30, spike_y - 2, 6, 10, bowser_dark)
  @raylib.draw_rectangle(bx + 40, spike_y, 6, 8, bowser_dark)
  // Head
  let head_x = if e.vx >= 0.0 { bx + 44 } else { bx - 12 }
  @raylib.draw_rectangle(head_x, by + 4, 24, 24, bowser_green)
  // Horns
  @raylib.draw_rectangle(head_x + 2, by - 4, 6, 10, horn_color)
  @raylib.draw_rectangle(head_x + 16, by - 4, 6, 10, horn_color)
  // Eyes
  let eye_x = if e.vx >= 0.0 { head_x + 12 } else { head_x + 4 }
  @raylib.draw_rectangle(
    eye_x,
    by + 10,
    6,
    6,
    @raylib.Color::new(252, 252, 252, 255),
  )
  @raylib.draw_rectangle(
    eye_x + 2,
    by + 12,
    3,
    4,
    @raylib.Color::new(200, 0, 0, 255),
  )
  // Mouth / fire breath animation
  if e.fire_cooldown < 0.5 && e.fire_cooldown > 0.0 {
    // Breathing fire animation
    let fire_x = if e.vx >= 0.0 { head_x + 24 } else { head_x - 16 }
    let fire_phase = game.frame_counter % 4
    @raylib.draw_rectangle(fire_x, by + 14, 16, 8, fireball_orange)
    @raylib.draw_rectangle(
      fire_x + (if fire_phase < 2 { 4 } else { -2 }),
      by + 16,
      8,
      4,
      fireball_yellow,
    )
  }
  // Legs
  @raylib.draw_rectangle(bx + 8, by + 56, 14, 16, bowser_green)
  @raylib.draw_rectangle(bx + 36, by + 56, 14, 16, bowser_green)
  @raylib.draw_rectangle(bx + 6, by + 68, 16, 6, bowser_dark)
  @raylib.draw_rectangle(bx + 34, by + 68, 16, 6, bowser_dark)
  // HP bar above head
  let hp_max = @types.bowser_hp
  let hp_cur = e.boss_hp
  let bar_w = 48
  let bar_h = 6
  let bar_x = sx - bar_w / 2
  let bar_y = by - 12
  @raylib.draw_rectangle(bar_x, bar_y, bar_w, bar_h, @raylib.Color::new(
    80, 0, 0, 255,
  ))
  let fill_w = bar_w * hp_cur / hp_max
  @raylib.draw_rectangle(bar_x, bar_y, fill_w, bar_h, @raylib.Color::new(
    0, 220, 0, 255,
  ))
}

///|
/// Draw Bowser fire breath projectiles.
fn draw_bowser_fireballs(game : @types.Game, cam_x : Int) -> Unit {
  for i in 0..<game.bowser_fireballs.length() {
    let bf = game.bowser_fireballs[i]
    if not(bf.active) {
      continue
    }
    let sx = (bf.x - Float::from_int(cam_x)).to_int()
    let sy = bf.y.to_int()
    if sx < -30 || sx > @types.screen_w + 30 {
      continue
    }
    let phase = game.frame_counter % 4
    // Fire breath: elongated flame
    @raylib.draw_rectangle(sx - 12, sy - 6, 24, 12, fireball_orange)
    @raylib.draw_rectangle(
      sx - 8 + (if phase < 2 { 2 } else { -2 }),
      sy - 4,
      16,
      8,
      fireball_yellow,
    )
    @raylib.draw_circle(
      sx + (if bf.vx > 0.0 { 10 } else { -10 }),
      sy,
      6,
      fireball_orange,
    )
  }
}
