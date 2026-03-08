// ── Color constants (private to render package) ─────────────

let sky_blue : @raylib.Color = @raylib.Color::new(92, 148, 252, 255)
let ground_brown : @raylib.Color = @raylib.Color::new(192, 96, 0, 255)
let ground_dark : @raylib.Color = @raylib.Color::new(148, 72, 0, 255)
let grass_green : @raylib.Color = @raylib.Color::new(0, 188, 0, 255)
let grass_light : @raylib.Color = @raylib.Color::new(80, 220, 80, 255)
let brick_col : @raylib.Color = @raylib.Color::new(200, 88, 24, 255)
let brick_dark : @raylib.Color = @raylib.Color::new(148, 64, 16, 255)
let brick_mortar : @raylib.Color = @raylib.Color::new(96, 44, 8, 255)
let question_yellow : @raylib.Color = @raylib.Color::new(248, 184, 0, 255)
let question_dark : @raylib.Color = @raylib.Color::new(200, 136, 0, 255)
let question_bright : @raylib.Color = @raylib.Color::new(252, 228, 120, 255)
let used_color : @raylib.Color = @raylib.Color::new(148, 108, 60, 255)
let used_dark : @raylib.Color = @raylib.Color::new(108, 76, 40, 255)
let pipe_green : @raylib.Color = @raylib.Color::new(0, 168, 0, 255)
let pipe_light : @raylib.Color = @raylib.Color::new(80, 220, 80, 255)
let pipe_dark_col : @raylib.Color = @raylib.Color::new(0, 116, 0, 255)
let mario_red : @raylib.Color = @raylib.Color::new(228, 0, 0, 255)
let mario_skin : @raylib.Color = @raylib.Color::new(252, 188, 116, 255)
let mario_hair : @raylib.Color = @raylib.Color::new(100, 44, 0, 255)
let mario_blue : @raylib.Color = @raylib.Color::new(32, 64, 200, 255)
let mario_fire_w : @raylib.Color = @raylib.Color::new(252, 252, 252, 255)
let mario_fire_r : @raylib.Color = @raylib.Color::new(228, 56, 0, 255)
let goomba_body : @raylib.Color = @raylib.Color::new(172, 80, 28, 255)
let goomba_dark : @raylib.Color = @raylib.Color::new(120, 52, 12, 255)
let koopa_green_c : @raylib.Color = @raylib.Color::new(0, 168, 68, 255)
let koopa_shell_c : @raylib.Color = @raylib.Color::new(0, 128, 48, 255)
let koopa_belly : @raylib.Color = @raylib.Color::new(252, 216, 108, 255)
let hill_green : @raylib.Color = @raylib.Color::new(48, 180, 48, 255)
let hill_dark : @raylib.Color = @raylib.Color::new(0, 140, 0, 255)
let cloud_white : @raylib.Color = @raylib.Color::new(252, 252, 252, 255)
let cloud_shadow : @raylib.Color = @raylib.Color::new(216, 228, 252, 255)
let castle_gray : @raylib.Color = @raylib.Color::new(160, 160, 160, 255)
let castle_dark : @raylib.Color = @raylib.Color::new(110, 110, 110, 255)
let castle_top_c : @raylib.Color = @raylib.Color::new(180, 180, 180, 255)
let flag_green : @raylib.Color = @raylib.Color::new(0, 200, 0, 255)
let pole_gray : @raylib.Color = @raylib.Color::new(180, 180, 180, 255)
let mushroom_red : @raylib.Color = @raylib.Color::new(228, 0, 0, 255)
let mushroom_white : @raylib.Color = @raylib.Color::new(252, 252, 252, 255)
let star_yellow : @raylib.Color = @raylib.Color::new(252, 228, 0, 255)
let star_body : @raylib.Color = @raylib.Color::new(200, 176, 0, 255)
let fireball_orange : @raylib.Color = @raylib.Color::new(252, 148, 0, 255)
let fireball_yellow : @raylib.Color = @raylib.Color::new(252, 228, 88, 255)
let underground_bg : @raylib.Color = @raylib.Color::new(0, 0, 0, 255)

///|
/// Draw the entire game world: background, tiles, entities, effects.
pub fn draw_game(game : @types.Game) -> Unit {
  let cam_x = game.camera_x.to_int()
  // Background
  let bg = if game.level_index == 1 || game.level_index == 3 {
    underground_bg
  } else {
    sky_blue
  }
  @raylib.clear_background(bg)
  // Sky decorations (grassland levels only)
  if game.level_index != 1 && game.level_index != 3 {
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
}

///|
fn draw_hills(game : @types.Game, cam_x : Int) -> Unit {
  // Parallax hills at 30% scroll rate
  let parallax_x = cam_x * 3 / 10
  let ground_y = 13 * @types.tile_size
  // Draw a few big hills
  for i in 0..<8 {
    let hx = i * 320 + 60 - parallax_x
    let hw = 200 + (i * 37) % 100
    let hh = 80 + (i * 23) % 60
    if hx + hw > -100 && hx < @types.screen_w + 100 {
      // Hill body
      @raylib.draw_ellipse(hx + hw / 2, ground_y, Float::from_int(hw / 2), Float::from_int(hh), hill_green)
      // Darker bottom half
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
      // Main cloud body (3 circles)
      let r = w / 3
      @raylib.draw_ellipse(sx + r, sy + r / 2, Float::from_int(r), Float::from_int(r * 2 / 3), cloud_shadow)
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
      @raylib.draw_ellipse(sx + r, sy + r / 4, Float::from_int(r - 4), Float::from_int(r * 2 / 3 - 4), cloud_white)
    }
  }
}

///|
fn draw_tiles(game : @types.Game, cam_x : Int) -> Unit {
  let ts = @types.tile_size
  let start_tx = cam_x / ts
  let end_tx = (cam_x + @types.screen_w) / ts + 1
  for ty in 0..<game.map_height {
    for tx in start_tx..=end_tx {
      let tile = @types.get_tile(game, tx, ty)
      if tile == Empty {
        continue
      }
      let sx = tx * ts - cam_x
      let mut sy = ty * ts
      // Check for bump animation offset
      for b in 0..<game.bumped_blocks.length() {
        let bb = game.bumped_blocks[b]
        if bb.active && bb.tile_x == tx && bb.tile_y == ty {
          sy = sy + bb.offset_y.to_int()
        }
      }
      match tile {
        Ground => draw_ground_tile(game, tx, ty, sx, sy)
        BrickBlock => draw_brick_tile(sx, sy)
        QuestionCoin | QuestionMushroom | QuestionStar | QuestionOneUp =>
          draw_question_tile(game, sx, sy)
        UsedBlock => draw_used_tile(sx, sy)
        PipeTopLeft => draw_pipe_top_left(sx, sy)
        PipeTopRight => draw_pipe_top_right(sx, sy)
        PipeBodyLeft => draw_pipe_body_left(sx, sy)
        PipeBodyRight => draw_pipe_body_right(sx, sy)
        Flagpole => draw_flagpole_tile(sx, sy)
        FlagTop => draw_flag_top_tile(sx, sy)
        CastleBlock => draw_castle_tile(sx, sy)
        CastleTop => draw_castle_top_tile(sx, sy)
        CastleDoor => draw_castle_door(sx, sy)
        HiddenCoin | HiddenOneUp => () // Invisible until bumped
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
  sy : Int
) -> Unit {
  let ts = @types.tile_size
  // Check if top of ground (tile above is not solid)
  let above = @types.get_tile(game, tx, ty - 1)
  if not(@types.is_solid(above)) && above != Flagpole && above != FlagTop {
    // Grass-topped ground
    @raylib.draw_rectangle(sx, sy + 8, ts, ts - 8, ground_brown)
    @raylib.draw_rectangle(sx, sy, ts, 8, grass_green)
    // Grass tufts
    @raylib.draw_rectangle(sx + 4, sy - 2, 3, 4, grass_light)
    @raylib.draw_rectangle(sx + 16, sy - 1, 2, 3, grass_light)
    @raylib.draw_rectangle(sx + 32, sy - 2, 3, 4, grass_light)
    @raylib.draw_rectangle(sx + 42, sy - 1, 2, 3, grass_light)
  } else {
    // Underground dirt
    @raylib.draw_rectangle(sx, sy, ts, ts, ground_dark)
    @raylib.draw_rectangle(sx + 2, sy + 2, ts - 4, ts - 4, ground_brown)
    // Rock texture
    @raylib.draw_rectangle(sx + 8, sy + 12, 12, 8, ground_dark)
    @raylib.draw_rectangle(sx + 28, sy + 24, 10, 10, ground_dark)
  }
}

///|
fn draw_brick_tile(sx : Int, sy : Int) -> Unit {
  let ts = @types.tile_size
  // Brick body
  @raylib.draw_rectangle(sx, sy, ts, ts, brick_col)
  // Mortar lines (horizontal)
  @raylib.draw_rectangle(sx, sy + ts / 2 - 1, ts, 2, brick_mortar)
  // Mortar lines (vertical, offset per row)
  @raylib.draw_rectangle(sx + ts / 4 - 1, sy, 2, ts / 2, brick_mortar)
  @raylib.draw_rectangle(sx + ts * 3 / 4 - 1, sy, 2, ts / 2, brick_mortar)
  @raylib.draw_rectangle(sx + ts / 2 - 1, sy + ts / 2, 2, ts / 2, brick_mortar)
  @raylib.draw_rectangle(sx, sy + ts / 2, 2, ts / 2, brick_mortar)
  // Highlight
  @raylib.draw_rectangle(sx, sy, ts, 2, brick_dark)
  @raylib.draw_rectangle(sx, sy, 2, ts, brick_dark)
}

///|
fn draw_question_tile(game : @types.Game, sx : Int, sy : Int) -> Unit {
  let ts = @types.tile_size
  // Shimmering animation
  let phase = Float::from_int(game.frame_counter) * 0.08
  let shimmer = @math.cosf(phase) * 0.15 + 0.85
  let _ = shimmer
  // Body
  @raylib.draw_rectangle(sx, sy, ts, ts, question_yellow)
  // Border
  @raylib.draw_rectangle(sx, sy, ts, 3, question_dark)
  @raylib.draw_rectangle(sx, sy, 3, ts, question_dark)
  @raylib.draw_rectangle(sx + ts - 3, sy, 3, ts, question_dark)
  @raylib.draw_rectangle(sx, sy + ts - 3, ts, 3, question_dark)
  // "?" symbol
  let qx = sx + ts / 2 - 6
  let qy = sy + ts / 2 - 10
  // Bright inner highlight
  @raylib.draw_rectangle(sx + 4, sy + 4, ts - 8, ts - 8, question_bright)
  @draw.draw_text("?", qx, qy, 24, question_dark)
}

///|
fn draw_used_tile(sx : Int, sy : Int) -> Unit {
  let ts = @types.tile_size
  @raylib.draw_rectangle(sx, sy, ts, ts, used_color)
  @raylib.draw_rectangle(sx, sy, ts, 2, used_dark)
  @raylib.draw_rectangle(sx, sy, 2, ts, used_dark)
  @raylib.draw_rectangle(sx + ts - 2, sy, 2, ts, used_dark)
  @raylib.draw_rectangle(sx, sy + ts - 2, ts, 2, used_dark)
  @raylib.draw_rectangle(sx + 6, sy + 6, ts - 12, ts - 12, used_dark)
}

///|
fn draw_pipe_top_left(sx : Int, sy : Int) -> Unit {
  let ts = @types.tile_size
  @raylib.draw_rectangle(sx, sy, ts, ts, pipe_green)
  @raylib.draw_rectangle(sx, sy, 8, ts, pipe_light)
  @raylib.draw_rectangle(sx + ts - 4, sy, 4, ts, pipe_dark_col)
  @raylib.draw_rectangle(sx, sy, ts, 6, pipe_light)
  // Lip
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
  // Lip
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

///|
fn draw_flagpole_tile(sx : Int, sy : Int) -> Unit {
  let ts = @types.tile_size
  // Pole shaft
  @raylib.draw_rectangle(sx + ts / 2 - 3, sy, 6, ts, pole_gray)
  @raylib.draw_rectangle(sx + ts / 2 - 1, sy, 2, ts, @raylib.Color::new(
    220, 220, 220, 255,
  ))
}

///|
fn draw_flag_top_tile(sx : Int, sy : Int) -> Unit {
  let ts = @types.tile_size
  // Pole
  @raylib.draw_rectangle(sx + ts / 2 - 3, sy, 6, ts, pole_gray)
  // Ball on top
  @raylib.draw_circle(sx + ts / 2, sy + 6, 8, @raylib.Color::new(
    220, 200, 0, 255,
  ))
}

///|
fn draw_flag(game : @types.Game, cam_x : Int) -> Unit {
  if game.state != LevelClear && game.state != Playing {
    return
  }
  // Find the flagpole column
  let ts = @types.tile_size
  let start_tx = cam_x / ts
  let end_tx = (cam_x + @types.screen_w) / ts + 1
  for tx in start_tx..=end_tx {
    for ty in 0..<game.map_height {
      if @types.get_tile(game, tx, ty) == FlagTop {
        let pole_sx = tx * ts - cam_x + ts / 2
        let flag_sy = if game.state == LevelClear {
          game.flag_y.to_int()
        } else {
          ty * ts + 16
        }
        // Draw flag triangle
        @raylib.draw_rectangle(pole_sx + 3, flag_sy, 28, 20, flag_green)
        @raylib.draw_rectangle(pole_sx + 3, flag_sy, 28, 3, @raylib.Color::new(
          0, 160, 0, 255,
        ))
        return
      }
    }
  }
}

///|
fn draw_castle_tile(sx : Int, sy : Int) -> Unit {
  let ts = @types.tile_size
  @raylib.draw_rectangle(sx, sy, ts, ts, castle_gray)
  // Brick pattern
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
  // Battlement
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
  // Dark door opening
  @raylib.draw_rectangle(sx + 8, sy + 8, ts - 16, ts - 8, @raylib.Color::new(
    40, 20, 0, 255,
  ))
  // Arch top
  @raylib.draw_rectangle(sx + 8, sy + 6, ts - 16, 8, castle_dark)
}

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
  let h = p.height()
  // Star power rainbow tint
  let is_star = p.star_timer > 0.0
  let hat_color = if is_star {
    @types.star_color((game.frame_counter / 3) % 5)
  } else if p.power == Fire {
    mario_fire_w
  } else {
    mario_red
  }
  let overall_color = if is_star {
    @types.star_color((game.frame_counter / 3 + 2) % 5)
  } else if p.power == Fire {
    mario_fire_r
  } else {
    mario_blue
  }
  let flip = if p.facing_right { 1 } else { -1 }
  if p.dead {
    // Dead Mario pose — hands up
    draw_mario_dead(sx, sy, h.to_int())
    return
  }
  if p.power == Small || p.ducking {
    draw_mario_small(
      sx,
      sy,
      flip,
      p.anim_frame,
      p.on_ground,
      p.vy < -50.0,
      p.skid_timer > 0.0,
      hat_color,
      overall_color,
    )
  } else {
    draw_mario_big(
      sx,
      sy,
      flip,
      p.anim_frame,
      p.on_ground,
      p.vy < -50.0,
      p.skid_timer > 0.0,
      hat_color,
      overall_color,
    )
  }
  ignore(h)
}

///|
fn draw_mario_small(
  sx : Int,
  sy : Int,
  flip : Int,
  frame : Int,
  on_ground : Bool,
  jumping : Bool,
  skidding : Bool,
  hat_col : @raylib.Color,
  overall_col : @raylib.Color
) -> Unit {
  // Small Mario: 32x44, position is bottom-center
  let bx = sx - 16
  let by = sy - 44
  // Hat
  @raylib.draw_rectangle(bx + 4, by, 24, 10, hat_col)
  @raylib.draw_rectangle(
    bx + (if flip > 0 { 2 } else { 16 }),
    by + 2,
    14,
    8,
    hat_col,
  )
  // Face
  @raylib.draw_rectangle(bx + 6, by + 10, 20, 12, mario_skin)
  // Eyes
  let eye_x = if flip > 0 { bx + 18 } else { bx + 10 }
  @raylib.draw_rectangle(eye_x, by + 12, 4, 4, @raylib.Color::new(0, 0, 0, 255))
  // Mustache
  @raylib.draw_rectangle(
    bx + (if flip > 0 { 12 } else { 8 }),
    by + 18,
    12,
    3,
    mario_hair,
  )
  // Body / overalls
  @raylib.draw_rectangle(bx + 4, by + 22, 24, 12, overall_col)
  // Arms (change with animation frame)
  if jumping {
    // Arms up
    @raylib.draw_rectangle(bx, by + 18, 6, 8, mario_skin)
    @raylib.draw_rectangle(bx + 26, by + 18, 6, 8, mario_skin)
  } else if skidding {
    // Arms forward
    @raylib.draw_rectangle(
      bx + (if flip > 0 { 26 } else { -6 }),
      by + 22,
      8,
      6,
      mario_skin,
    )
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
  // Legs
  if on_ground && not(jumping) {
    match frame {
      0 => {
        @raylib.draw_rectangle(bx + 6, by + 34, 8, 10, overall_col)
        @raylib.draw_rectangle(bx + 18, by + 34, 8, 10, overall_col)
      }
      1 => {
        @raylib.draw_rectangle(bx + 2, by + 34, 8, 10, overall_col)
        @raylib.draw_rectangle(bx + 22, by + 32, 8, 10, overall_col)
      }
      _ => {
        @raylib.draw_rectangle(bx + 22, by + 34, 8, 10, overall_col)
        @raylib.draw_rectangle(bx + 2, by + 32, 8, 10, overall_col)
      }
    }
  } else {
    // Jumping pose — legs together
    @raylib.draw_rectangle(bx + 8, by + 34, 16, 10, overall_col)
  }
}

///|
fn draw_mario_big(
  sx : Int,
  sy : Int,
  flip : Int,
  frame : Int,
  on_ground : Bool,
  jumping : Bool,
  skidding : Bool,
  hat_col : @raylib.Color,
  overall_col : @raylib.Color
) -> Unit {
  // Big Mario: 32x76, position is bottom-center
  let bx = sx - 16
  let by = sy - 76
  // Hat
  @raylib.draw_rectangle(bx + 2, by, 28, 14, hat_col)
  @raylib.draw_rectangle(
    bx + (if flip > 0 { 0 } else { 14 }),
    by + 4,
    18,
    10,
    hat_col,
  )
  // Face
  @raylib.draw_rectangle(bx + 4, by + 14, 24, 16, mario_skin)
  // Eyes
  let eye_x = if flip > 0 { bx + 18 } else { bx + 8 }
  @raylib.draw_rectangle(eye_x, by + 18, 5, 5, @raylib.Color::new(0, 0, 0, 255))
  // Mustache / mouth area
  @raylib.draw_rectangle(
    bx + (if flip > 0 { 12 } else { 6 }),
    by + 26,
    14,
    4,
    mario_hair,
  )
  // Shirt / torso
  @raylib.draw_rectangle(bx + 2, by + 30, 28, 14, hat_col)
  // Overall straps
  @raylib.draw_rectangle(bx + 4, by + 30, 24, 4, overall_col)
  // Overalls
  @raylib.draw_rectangle(bx + 2, by + 40, 28, 16, overall_col)
  // Belt/buttons
  @raylib.draw_rectangle(
    bx + 12,
    by + 42,
    8,
    4,
    @raylib.Color::new(252, 200, 32, 255),
  )
  // Arms
  if jumping {
    @raylib.draw_rectangle(bx - 4, by + 26, 8, 12, mario_skin)
    @raylib.draw_rectangle(bx + 28, by + 26, 8, 12, mario_skin)
  } else if skidding {
    @raylib.draw_rectangle(
      bx + (if flip > 0 { 28 } else { -8 }),
      by + 32,
      10,
      10,
      mario_skin,
    )
    @raylib.draw_rectangle(
      bx + (if flip > 0 { -4 } else { 26 }),
      by + 38,
      8,
      10,
      mario_skin,
    )
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
  // Legs
  if on_ground && not(jumping) {
    match frame {
      0 => {
        @raylib.draw_rectangle(bx + 4, by + 56, 10, 14, overall_col)
        @raylib.draw_rectangle(bx + 18, by + 56, 10, 14, overall_col)
        // Shoes
        @raylib.draw_rectangle(bx + 2, by + 68, 12, 8, mario_hair)
        @raylib.draw_rectangle(bx + 18, by + 68, 12, 8, mario_hair)
      }
      1 => {
        @raylib.draw_rectangle(bx, by + 56, 10, 12, overall_col)
        @raylib.draw_rectangle(bx + 22, by + 54, 10, 14, overall_col)
        @raylib.draw_rectangle(bx - 2, by + 66, 12, 10, mario_hair)
        @raylib.draw_rectangle(bx + 22, by + 66, 12, 10, mario_hair)
      }
      _ => {
        @raylib.draw_rectangle(bx + 22, by + 56, 10, 12, overall_col)
        @raylib.draw_rectangle(bx, by + 54, 10, 14, overall_col)
        @raylib.draw_rectangle(bx + 22, by + 66, 12, 10, mario_hair)
        @raylib.draw_rectangle(bx - 2, by + 66, 12, 10, mario_hair)
      }
    }
  } else {
    // Jump pose
    @raylib.draw_rectangle(bx + 4, by + 56, 10, 14, overall_col)
    @raylib.draw_rectangle(bx + 18, by + 56, 10, 14, overall_col)
    @raylib.draw_rectangle(bx + 2, by + 68, 12, 8, mario_hair)
    @raylib.draw_rectangle(bx + 18, by + 68, 12, 8, mario_hair)
  }
}

///|
fn draw_mario_dead(sx : Int, sy : Int, h : Int) -> Unit {
  let bx = sx - 16
  let by = sy - h
  // Simplified dead pose
  @raylib.draw_rectangle(bx + 4, by, 24, 10, mario_red)
  @raylib.draw_rectangle(bx + 6, by + 10, 20, 12, mario_skin)
  // X eyes
  @draw.draw_text("x", bx + 12, by + 11, 12, @raylib.Color::new(0, 0, 0, 255))
  @draw.draw_text("x", bx + 20, by + 11, 12, @raylib.Color::new(0, 0, 0, 255))
  @raylib.draw_rectangle(bx + 4, by + 22, 24, 12, mario_blue)
  // Arms up
  @raylib.draw_rectangle(bx - 2, by + 16, 6, 10, mario_skin)
  @raylib.draw_rectangle(bx + 28, by + 16, 6, 10, mario_skin)
}

///|
fn draw_enemies(game : @types.Game, cam_x : Int) -> Unit {
  for i in 0..<game.enemies.length() {
    let e = game.enemies[i]
    if not(e.active) {
      continue
    }
    let sx = (e.x - Float::from_int(cam_x)).to_int()
    let sy = e.y.to_int()
    // Skip if off-screen
    if sx < -60 || sx > @types.screen_w + 60 {
      continue
    }
    match e.kind {
      Goomba => draw_goomba(e, sx, sy)
      KoopaTroopa => draw_koopa(e, sx, sy)
      KoopaShell => draw_shell(e, sx, sy)
    }
  }
}

///|
fn draw_goomba(e : @types.Enemy, sx : Int, sy : Int) -> Unit {
  if e.squished && e.dead {
    // Flat squished goomba
    @raylib.draw_rectangle(sx - 20, sy - 8, 40, 8, goomba_dark)
    return
  }
  if e.dead {
    // Flipped upside down
    let by = sy - 40
    @raylib.draw_rectangle(sx - 18, by, 36, 28, goomba_body)
    @raylib.draw_rectangle(sx - 16, by + 28, 14, 12, goomba_dark)
    @raylib.draw_rectangle(sx + 2, by + 28, 14, 12, goomba_dark)
    return
  }
  let by = sy - 40
  // Body (rounded shape)
  @raylib.draw_rectangle(sx - 18, by + 8, 36, 20, goomba_body)
  @raylib.draw_rectangle(sx - 14, by + 2, 28, 8, goomba_body)
  // Dark bottom
  @raylib.draw_rectangle(sx - 18, by + 20, 36, 8, goomba_dark)
  // Eyes (angry)
  @raylib.draw_rectangle(sx - 10, by + 10, 7, 8, @raylib.Color::new(
    252, 252, 252, 255,
  ))
  @raylib.draw_rectangle(sx + 3, by + 10, 7, 8, @raylib.Color::new(
    252, 252, 252, 255,
  ))
  // Pupils (shift based on frame for animation)
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
  // Angry eyebrows
  @raylib.draw_rectangle(sx - 10, by + 8, 8, 2, @raylib.Color::new(0, 0, 0, 255))
  @raylib.draw_rectangle(sx + 3, by + 8, 8, 2, @raylib.Color::new(0, 0, 0, 255))
  // Feet (animated walking)
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
  if e.dead {
    // Flipped
    let by = sy - 52
    @raylib.draw_rectangle(sx - 16, by, 32, 32, koopa_shell_c)
    return
  }
  let by = sy - 52
  // Shell
  @raylib.draw_rectangle(sx - 16, by + 8, 32, 24, koopa_green_c)
  @raylib.draw_rectangle(sx - 14, by + 6, 28, 4, koopa_shell_c)
  // Shell pattern
  @raylib.draw_rectangle(sx - 4, by + 10, 8, 18, koopa_shell_c)
  // Belly
  @raylib.draw_rectangle(sx - 10, by + 26, 20, 10, koopa_belly)
  // Head
  @raylib.draw_rectangle(
    sx + (if e.vx < 0.0 { -18 } else { 10 }),
    by + 2,
    14,
    16,
    koopa_green_c,
  )
  // Eye
  let head_x = if e.vx < 0.0 { sx - 16 } else { sx + 12 }
  @raylib.draw_rectangle(head_x, by + 6, 6, 6, @raylib.Color::new(
    252, 252, 252, 255,
  ))
  @raylib.draw_rectangle(
    head_x + (if e.vx < 0.0 { 0 } else { 3 }),
    by + 8,
    3,
    4,
    @raylib.Color::new(0, 0, 0, 255),
  )
  // Feet
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
  let by = sy - 36
  @raylib.draw_rectangle(sx - 18, by, 36, 28, koopa_green_c)
  @raylib.draw_rectangle(sx - 16, by + 2, 32, 4, koopa_shell_c)
  @raylib.draw_rectangle(sx - 4, by + 4, 8, 20, koopa_shell_c)
  @raylib.draw_rectangle(sx - 14, by + 22, 28, 8, koopa_belly)
  // Spinning effect when moving
  if e.shell_moving {
    let spin = (e.anim_timer * 20.0).to_int() % 3
    let mark_x = sx - 12 + spin * 10
    @raylib.draw_rectangle(mark_x, by + 8, 4, 12, koopa_shell_c)
  }
}

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
      Mushroom => {
        // Red cap mushroom
        @raylib.draw_rectangle(sx - 18, sy - 36, 36, 18, mushroom_red)
        @raylib.draw_rectangle(sx - 8, sy - 38, 16, 6, mushroom_red)
        // White spots
        @raylib.draw_circle(sx - 6, sy - 28, 5, mushroom_white)
        @raylib.draw_circle(sx + 8, sy - 28, 5, mushroom_white)
        @raylib.draw_circle(sx, sy - 34, 4, mushroom_white)
        // Stem
        @raylib.draw_rectangle(sx - 10, sy - 18, 20, 18, mario_skin)
        // Eyes
        @raylib.draw_rectangle(sx - 6, sy - 14, 4, 4, @raylib.Color::new(
          0, 0, 0, 255,
        ))
        @raylib.draw_rectangle(sx + 4, sy - 14, 4, 4, @raylib.Color::new(
          0, 0, 0, 255,
        ))
      }
      FireFlower => {
        // Animated fire flower
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
        // Petals
        @raylib.draw_circle(sx, sy - 32, 8, col2)
        @raylib.draw_circle(sx - 8, sy - 24, 6, col1)
        @raylib.draw_circle(sx + 8, sy - 24, 6, col1)
        @raylib.draw_circle(sx, sy - 20, 6, col1)
        // Center
        @raylib.draw_circle(sx, sy - 26, 5, @raylib.Color::new(
          252, 252, 252, 255,
        ))
        // Stem
        @raylib.draw_rectangle(sx - 3, sy - 18, 6, 18, @raylib.Color::new(
          0, 168, 0, 255,
        ))
      }
      Star => {
        // Bouncing star
        let col = @types.star_color((game.frame_counter / 4) % 5)
        @raylib.draw_rectangle(sx - 14, sy - 30, 28, 20, col)
        @raylib.draw_rectangle(sx - 8, sy - 36, 16, 8, star_yellow)
        @raylib.draw_rectangle(sx - 8, sy - 10, 16, 10, star_body)
        // Eyes
        @raylib.draw_rectangle(sx - 6, sy - 24, 4, 4, @raylib.Color::new(
          0, 0, 0, 255,
        ))
        @raylib.draw_rectangle(sx + 4, sy - 24, 4, 4, @raylib.Color::new(
          0, 0, 0, 255,
        ))
      }
      OneUp => {
        // Green 1-UP mushroom
        @raylib.draw_rectangle(sx - 18, sy - 36, 36, 18, @raylib.Color::new(
          0, 168, 0, 255,
        ))
        @raylib.draw_rectangle(sx - 8, sy - 38, 16, 6, @raylib.Color::new(
          0, 168, 0, 255,
        ))
        @raylib.draw_circle(sx - 6, sy - 28, 5, mushroom_white)
        @raylib.draw_circle(sx + 8, sy - 28, 5, mushroom_white)
        @raylib.draw_rectangle(sx - 10, sy - 18, 20, 18, mario_skin)
        @raylib.draw_rectangle(sx - 6, sy - 14, 4, 4, @raylib.Color::new(
          0, 0, 0, 255,
        ))
        @raylib.draw_rectangle(sx + 4, sy - 14, 4, 4, @raylib.Color::new(
          0, 0, 0, 255,
        ))
      }
      CoinPopup => ()
    }
  }
}

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
    // Spinning fireball
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
