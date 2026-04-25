///|
/// Generated art resources used by the Chrono Rail Shooter renderer.
priv struct GameArt {
  chrono_rail_backdrop : @raylib.Texture
  player_interceptor : @raylib.Texture
  enemy_scout : @raylib.Texture
  enemy_raider : @raylib.Texture
  enemy_heavy : @raylib.Texture
  chrono_warden_boss : @raylib.Texture
  repair_pickup : @raylib.Texture
  energy_cell_pickup : @raylib.Texture
  chrono_shard_pickup : @raylib.Texture
}

///|
/// Loads one bilinear-filtered texture from the package resources directory.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "chrono_rail_shooter_2026/resources/\{file_name}",
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads the generated timeline rail backdrop and gameplay sprites.
fn load_game_art() -> GameArt {
  {
    chrono_rail_backdrop: load_art_texture("chrono_rail_backdrop.png"),
    player_interceptor: load_art_texture("player_interceptor.png"),
    enemy_scout: load_art_texture("enemy_scout.png"),
    enemy_raider: load_art_texture("enemy_raider.png"),
    enemy_heavy: load_art_texture("enemy_heavy.png"),
    chrono_warden_boss: load_art_texture("chrono_warden_boss.png"),
    repair_pickup: load_art_texture("repair_pickup.png"),
    energy_cell_pickup: load_art_texture("energy_cell_pickup.png"),
    chrono_shard_pickup: load_art_texture("chrono_shard_pickup.png"),
  }
}

///|
/// Releases generated textures before the Raylib window is closed.
fn unload_game_art(art : GameArt) -> Unit {
  @raylib.unload_texture(art.chrono_rail_backdrop)
  @raylib.unload_texture(art.player_interceptor)
  @raylib.unload_texture(art.enemy_scout)
  @raylib.unload_texture(art.enemy_raider)
  @raylib.unload_texture(art.enemy_heavy)
  @raylib.unload_texture(art.chrono_warden_boss)
  @raylib.unload_texture(art.repair_pickup)
  @raylib.unload_texture(art.energy_cell_pickup)
  @raylib.unload_texture(art.chrono_shard_pickup)
}

///|
/// Draws a texture centered on the destination point with optional rotation.
fn draw_texture_centered_rotated(
  texture : @raylib.Texture,
  cx : Float,
  cy : Float,
  w : Float,
  h : Float,
  rotation : Float,
  tint : @raylib.Color,
) -> Unit {
  @raylib.draw_texture_pro(
    texture,
    @raylib.Rectangle::new(
      0.0,
      0.0,
      Float::from_int(texture.width()),
      Float::from_int(texture.height()),
    ),
    @raylib.Rectangle::new(cx, cy, w, h),
    @raylib.Vector2::new(w * 0.5, h * 0.5),
    rotation,
    tint,
  )
}

///|
/// Draws a texture centered on the destination point.
fn draw_texture_centered(
  texture : @raylib.Texture,
  cx : Float,
  cy : Float,
  w : Float,
  h : Float,
  tint : @raylib.Color,
) -> Unit {
  draw_texture_centered_rotated(texture, cx, cy, w, h, 0.0, tint)
}

///|
/// Draws a texture cover-cropped into the destination rectangle.
fn draw_texture_cover(
  texture : @raylib.Texture,
  x : Float,
  y : Float,
  w : Float,
  h : Float,
  tint : @raylib.Color,
) -> Unit {
  let source_w : Float = Float::from_int(texture.width())
  let source_h : Float = Float::from_int(texture.height())
  let source_ratio : Float = source_w / source_h
  let dest_ratio : Float = w / h

  let mut src_x : Float = 0.0
  let mut src_y : Float = 0.0
  let mut src_w : Float = source_w
  let mut src_h : Float = source_h

  if source_ratio > dest_ratio {
    src_w = source_h * dest_ratio
    src_x = (source_w - src_w) * 0.5
  } else if source_ratio < dest_ratio {
    src_h = source_w / dest_ratio
    src_y = (source_h - src_h) * 0.5
  }

  @raylib.draw_texture_pro(
    texture,
    @raylib.Rectangle::new(src_x, src_y, src_w, src_h),
    @raylib.Rectangle::new(x, y, w, h),
    @raylib.Vector2::new(0.0, 0.0),
    0.0,
    tint,
  )
}

///|
/// Draws the generated timeline rail background with live rail bounds.
fn draw_chrono_backdrop(art : GameArt, storm_t : Float, state : Int) -> Unit {
  draw_texture_cover(
    art.chrono_rail_backdrop,
    0.0,
    0.0,
    Float::from_int(sw),
    Float::from_int(sh),
    @raylib.white,
  )

  let shade_alpha = if state == 3 { 80 } else if state == 2 { 30 } else { 44 }
  @raylib.draw_rectangle(
    0,
    0,
    sw,
    sh,
    @raylib.Color::new(2, 6, 16, shade_alpha),
  )
  @raylib.draw_rectangle(
    0,
    0,
    rail_l.to_int(),
    sh,
    @raylib.Color::new(4, 8, 18, 156),
  )
  @raylib.draw_rectangle(
    rail_r.to_int(),
    0,
    sw - rail_r.to_int(),
    sh,
    @raylib.Color::new(4, 8, 18, 156),
  )

  @raylib.draw_line(
    rail_l.to_int(),
    0,
    rail_l.to_int(),
    sh,
    @raylib.Color::new(80, 184, 248, 220),
  )
  @raylib.draw_line(
    rail_r.to_int(),
    0,
    rail_r.to_int(),
    sh,
    @raylib.Color::new(80, 184, 248, 220),
  )

  let mut sweep : Float = storm_t * 92.0
  while sweep > 70.0 {
    sweep = sweep - 70.0
  }
  for i in 0..<12 {
    let y = (Float::from_int(i) * 70.0 + sweep).to_int() - 70
    @raylib.draw_rectangle(
      rail_l.to_int() + 18,
      y,
      (rail_r - rail_l - 36.0).to_int(),
      2,
      @raylib.Color::new(116, 220, 255, 46),
    )
  }
}

///|
/// Draws a rail panel with hazard or boost styling.
fn draw_panel_art(panel : Panel) -> Unit {
  let x = (panel.x - panel.w * 0.5).to_int()
  let y = (panel.y - panel.h * 0.5).to_int()
  let w = panel.w.to_int()
  let h = panel.h.to_int()

  let col = if panel.hazard {
    @raylib.Color::new(172, 54, 70, 218)
  } else if panel.boost {
    @raylib.Color::new(48, 184, 220, 218)
  } else {
    @raylib.Color::new(28, 42, 68, 190)
  }
  @raylib.draw_rectangle(x, y, w, h, @raylib.Color::new(0, 0, 0, 78))
  @raylib.draw_rectangle(x + 2, y + 2, w - 4, h - 4, col)
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(190, 224, 250, 128),
  )

  if panel.hazard {
    for k in 0..<4 {
      let lx0 = x + 8 + k * ((w - 16) / 4)
      @raylib.draw_line(
        lx0,
        y + 4,
        lx0 + 10,
        y + h - 4,
        @raylib.Color::new(255, 184, 108, 238),
      )
    }
  } else if panel.boost {
    @raylib.draw_line(
      x + 10,
      y + h / 2,
      x + w - 10,
      y + h / 2,
      @raylib.Color::new(206, 250, 255, 230),
    )
  }
}

///|
/// Draws a generated pickup sprite with a small collection halo.
fn draw_pickup_art(pickup : Pickup, art : GameArt) -> Unit {
  let mut texture = art.repair_pickup
  let mut size : Float = 34.0
  let mut glow_col = @raylib.Color::new(110, 236, 182, 76)
  if pickup.kind == 1 {
    texture = art.energy_cell_pickup
    size = 38.0
    glow_col = @raylib.Color::new(102, 190, 252, 84)
  } else if pickup.kind == 2 {
    texture = art.chrono_shard_pickup
    size = 42.0
    glow_col = @raylib.Color::new(250, 198, 88, 86)
  }

  let pulse : Float = @math.sinf(pickup.t * 7.0) * 0.5 + 0.5
  @raylib.draw_circle_v(
    @raylib.Vector2::new(pickup.x, pickup.y),
    15.0 + pulse * 4.0,
    glow_col,
  )
  draw_texture_centered(texture, pickup.x, pickup.y, size, size, @raylib.white)
}

///|
/// Draws a generated enemy sprite for the enemy kind.
fn draw_enemy_art(enemy : Enemy, art : GameArt) -> Unit {
  let mut texture = art.enemy_scout
  let mut w : Float = 46.0
  let mut h : Float = 46.0
  if enemy.kind == 1 {
    texture = art.enemy_raider
    w = 58.0
    h = 78.0
  } else if enemy.kind == 2 {
    texture = art.enemy_heavy
    w = 78.0
    h = 86.0
  }

  @raylib.draw_circle_v(
    @raylib.Vector2::new(enemy.x, enemy.y),
    enemy_radius(enemy.kind) + 10.0,
    @raylib.Color::new(248, 76, 116, 48),
  )
  draw_texture_centered(texture, enemy.x, enemy.y, w, h, @raylib.white)
}

///|
/// Draws the generated Chrono Warden boss sprite.
fn draw_boss_art(boss : Boss, art : GameArt) -> Unit {
  @raylib.draw_circle_v(
    @raylib.Vector2::new(boss.x, boss.y),
    92.0,
    @raylib.Color::new(212, 80, 246, 42),
  )
  draw_texture_centered(
    art.chrono_warden_boss,
    boss.x,
    boss.y + 4.0,
    196.0,
    156.0,
    @raylib.white,
  )
}

///|
/// Draws the generated player ship and shield/dash feedback.
fn draw_player_art(player : Player, art : GameArt) -> Unit {
  if player.dash_t > 0.0 {
    @raylib.draw_circle_v(
      @raylib.Vector2::new(player.x, player.y + 18.0),
      38.0,
      @raylib.Color::new(96, 222, 252, 72),
    )
  }

  let tint = if player.inv_t > 0.0 {
    @raylib.Color::new(255, 255, 255, 224)
  } else {
    @raylib.white
  }
  draw_texture_centered(
    art.player_interceptor,
    player.x,
    player.y,
    68.0,
    68.0,
    tint,
  )

  if player.shield_on {
    @raylib.draw_circle_lines(
      player.x.to_int(),
      player.y.to_int(),
      28.0,
      @raylib.Color::new(130, 214, 246, 230),
    )
  }
}
