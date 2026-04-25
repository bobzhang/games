///|
/// Generated art resources used by the Mountain Bike Downhill renderer.
priv struct GameArt {
  downhill_trail_backdrop : @raylib.Texture
  rider_bike : @raylib.Texture
  checkpoint_gate : @raylib.Texture
  rock_hazard : @raylib.Texture
  pine_tree_hazard : @raylib.Texture
  wooden_crate : @raylib.Texture
  mud_puddle : @raylib.Texture
  repair_pickup : @raylib.Texture
  energy_pickup : @raylib.Texture
  coin_pickup : @raylib.Texture
}

///|
/// Loads one bilinear-filtered texture from the package resources directory.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "mountain_bike_downhill_2026/resources/\{file_name}",
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads the generated trail backdrop and gameplay sprites.
fn load_game_art() -> GameArt {
  {
    downhill_trail_backdrop: load_art_texture("downhill_trail_backdrop.png"),
    rider_bike: load_art_texture("rider_bike.png"),
    checkpoint_gate: load_art_texture("checkpoint_gate.png"),
    rock_hazard: load_art_texture("rock_hazard.png"),
    pine_tree_hazard: load_art_texture("pine_tree_hazard.png"),
    wooden_crate: load_art_texture("wooden_crate.png"),
    mud_puddle: load_art_texture("mud_puddle.png"),
    repair_pickup: load_art_texture("repair_pickup.png"),
    energy_pickup: load_art_texture("energy_pickup.png"),
    coin_pickup: load_art_texture("coin_pickup.png"),
  }
}

///|
/// Releases generated textures before the Raylib window is closed.
fn unload_game_art(art : GameArt) -> Unit {
  @raylib.unload_texture(art.downhill_trail_backdrop)
  @raylib.unload_texture(art.rider_bike)
  @raylib.unload_texture(art.checkpoint_gate)
  @raylib.unload_texture(art.rock_hazard)
  @raylib.unload_texture(art.pine_tree_hazard)
  @raylib.unload_texture(art.wooden_crate)
  @raylib.unload_texture(art.mud_puddle)
  @raylib.unload_texture(art.repair_pickup)
  @raylib.unload_texture(art.energy_pickup)
  @raylib.unload_texture(art.coin_pickup)
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
/// Draws the generated mountain trail backdrop with subtle speed lines.
fn draw_downhill_backdrop(art : GameArt, cam_y : Float, state : Int) -> Unit {
  draw_texture_cover(
    art.downhill_trail_backdrop,
    0.0,
    0.0,
    Float::from_int(sw),
    Float::from_int(sh),
    @raylib.white,
  )

  let overlay_alpha = if state == 2 { 18 } else if state == 3 { 64 } else { 28 }
  @raylib.draw_rectangle(
    0,
    0,
    sw,
    sh,
    @raylib.Color::new(4, 10, 16, overlay_alpha),
  )

  let drift : Int = (cam_y * 0.52).to_int() % 54
  for idx in 0..<20 {
    let sy : Int = idx * 54 - drift
    let lane_w : Int = 480 + idx % 4 * 34
    @raylib.draw_rectangle(
      sw / 2 - lane_w / 2,
      sy,
      lane_w,
      3,
      @raylib.Color::new(238, 218, 176, 34),
    )
  }

  for i in 0..<7 {
    let shade_x = 250 + i * 128 + (cam_y * 0.16).to_int() % 128
    @raylib.draw_rectangle(
      shade_x,
      98,
      2,
      sh - 98,
      @raylib.Color::new(16, 34, 42, 42),
    )
  }
}

///|
/// Draws a generated checkpoint gate with state-colored gameplay feedback.
fn draw_checkpoint_art(
  checkpoint : Checkpoint,
  art : GameArt,
  csy : Float,
) -> Unit {
  let gate_w : Float = checkpoint.width + 108.0
  let gate_h : Float = 106.0
  @raylib.draw_ellipse(
    checkpoint.x.to_int(),
    (csy + 38.0).to_int(),
    gate_w * 0.46,
    13.0,
    @raylib.Color::new(0, 0, 0, 78),
  )
  draw_texture_centered(
    art.checkpoint_gate,
    checkpoint.x,
    csy - 4.0,
    gate_w,
    gate_h,
    @raylib.white,
  )

  let left_x : Float = checkpoint.x - checkpoint.width * 0.5
  let right_x : Float = checkpoint.x + checkpoint.width * 0.5
  let mut state_col = @raylib.Color::new(86, 188, 246, 82)
  if checkpoint.state == 1 {
    state_col = @raylib.Color::new(90, 238, 146, 100)
  } else if checkpoint.state == 2 {
    state_col = @raylib.Color::new(238, 86, 106, 112)
  }

  @raylib.draw_rectangle(
    (left_x + 10.0).to_int(),
    (csy - 17.0).to_int(),
    (checkpoint.width - 20.0).to_int(),
    20,
    state_col,
  )
  @raylib.draw_rectangle_lines(
    (left_x - 6.0).to_int(),
    (csy - 44.0).to_int(),
    (right_x - left_x + 12.0).to_int(),
    88,
    @raylib.Color::new(244, 250, 255, 62),
  )
}

///|
/// Draws one generated hazard sprite scaled to its gameplay collision size.
fn draw_hazard_art(hazard : Hazard, art : GameArt, hsy : Float) -> Unit {
  let mut texture = art.rock_hazard
  let mut w : Float = hazard.size * 2.75
  let mut h : Float = hazard.size * 2.75
  let mut y_offset : Float = 0.0

  if hazard.kind == 1 {
    texture = art.pine_tree_hazard
    w = hazard.size * 3.4
    h = hazard.size * 3.8
    y_offset = -hazard.size * 0.36
  } else if hazard.kind == 2 {
    texture = art.wooden_crate
    w = hazard.size * 2.85
    h = hazard.size * 2.85
  } else if hazard.kind == 3 {
    texture = art.mud_puddle
    w = hazard.size * 3.55
    h = hazard.size * 2.15
    y_offset = hazard.size * 0.12
  }

  @raylib.draw_ellipse(
    hazard.x.to_int(),
    (hsy + h * 0.25).to_int(),
    w * 0.38,
    8.0,
    @raylib.Color::new(0, 0, 0, 70),
  )
  draw_texture_centered(texture, hazard.x, hsy + y_offset, w, h, @raylib.white)
}

///|
/// Draws a generated pickup sprite with an animated collection halo.
fn draw_pickup_art(
  pickup : Pickup,
  art : GameArt,
  psy : Float,
  blink : Int,
) -> Unit {
  let mut texture = art.repair_pickup
  let mut glow_col = @raylib.Color::new(242, 112, 126, 76)
  let mut size : Float = 42.0
  if pickup.kind == 1 {
    texture = art.energy_pickup
    glow_col = @raylib.Color::new(130, 244, 120, 82)
    size = 48.0
  } else if pickup.kind == 2 {
    texture = art.coin_pickup
    glow_col = @raylib.Color::new(252, 212, 84, 82)
    size = 40.0
  }

  @raylib.draw_circle_v(@raylib.Vector2::new(pickup.x, psy), 22.0, glow_col)
  draw_texture_centered(
    texture,
    pickup.x,
    psy - 1.0,
    size,
    size,
    @raylib.Color::new(255, 255, 255, blink),
  )
  @raylib.draw_circle_lines(
    pickup.x.to_int(),
    psy.to_int(),
    18.0,
    @raylib.Color::new(246, 250, 255, blink),
  )
}

///|
/// Draws the generated rider sprite plus existing jump and boost feedback.
fn draw_rider_art(
  rider : Rider,
  art : GameArt,
  rider_sy : Float,
  jump_offset : Float,
) -> Unit {
  @raylib.draw_ellipse(
    rider.x.to_int(),
    (rider_sy + 42.0).to_int(),
    36.0,
    15.0,
    @raylib.Color::new(0, 0, 0, 86),
  )

  if rider.boost_t > 0.0 {
    @raylib.draw_rectangle(
      (rider.x - 33.0).to_int(),
      (rider_sy + 38.0 - jump_offset).to_int(),
      8,
      26,
      @raylib.Color::new(84, 210, 252, 198),
    )
    @raylib.draw_rectangle(
      (rider.x + 25.0).to_int(),
      (rider_sy + 38.0 - jump_offset).to_int(),
      8,
      26,
      @raylib.Color::new(84, 210, 252, 198),
    )
  }

  let rotation : Float = clampf(rider.vx * 0.036, -14.0, 14.0)
  let tint = if rider.flash_t > 0.0 {
    @raylib.Color::new(255, 244, 226, 255)
  } else {
    @raylib.white
  }
  draw_texture_centered_rotated(
    art.rider_bike,
    rider.x,
    rider_sy + 1.0 - jump_offset,
    82.0,
    124.0,
    rotation,
    tint,
  )

  if rider.air_t > 0.0 {
    @raylib.draw_circle_lines(
      rider.x.to_int(),
      (rider_sy - jump_offset).to_int(),
      31.0,
      @raylib.Color::new(132, 224, 252, 220),
    )
  }
}
