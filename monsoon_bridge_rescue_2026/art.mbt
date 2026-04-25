///|
/// Generated art resources used by the Monsoon Bridge Rescue renderer.
priv struct GameArt {
  monsoon_river_backdrop : @raylib.Texture
  rescue_boat : @raylib.Texture
  survivor_raft : @raylib.Texture
  flood_debris : @raylib.Texture
  supply_crate : @raylib.Texture
  bridge_span : @raylib.Texture
  supply_dock : @raylib.Texture
  evac_camp : @raylib.Texture
}

///|
/// Loads one bilinear-filtered texture from the package resources directory.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "monsoon_bridge_rescue_2026/resources/\{file_name}",
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads the generated storm river backdrop and gameplay sprites.
fn load_game_art() -> GameArt {
  {
    monsoon_river_backdrop: load_art_texture("monsoon_river_backdrop.png"),
    rescue_boat: load_art_texture("rescue_boat.png"),
    survivor_raft: load_art_texture("survivor_raft.png"),
    flood_debris: load_art_texture("flood_debris.png"),
    supply_crate: load_art_texture("supply_crate.png"),
    bridge_span: load_art_texture("bridge_span.png"),
    supply_dock: load_art_texture("supply_dock.png"),
    evac_camp: load_art_texture("evac_camp.png"),
  }
}

///|
/// Releases generated textures before the Raylib window is closed.
fn unload_game_art(art : GameArt) -> Unit {
  @raylib.unload_texture(art.monsoon_river_backdrop)
  @raylib.unload_texture(art.rescue_boat)
  @raylib.unload_texture(art.survivor_raft)
  @raylib.unload_texture(art.flood_debris)
  @raylib.unload_texture(art.supply_crate)
  @raylib.unload_texture(art.bridge_span)
  @raylib.unload_texture(art.supply_dock)
  @raylib.unload_texture(art.evac_camp)
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
/// Draws the generated river backdrop with a storm-darkening overlay.
fn draw_monsoon_backdrop(
  art : GameArt,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  storm : Float,
) -> Unit {
  draw_texture_cover(
    art.monsoon_river_backdrop,
    Float::from_int(x),
    Float::from_int(y),
    Float::from_int(w),
    Float::from_int(h),
    @raylib.white,
  )
  @raylib.draw_rectangle(
    x,
    y,
    w,
    h,
    @raylib.Color::new(4, 12, 24, (28.0F + storm * 54.0F).to_int()),
  )
}

///|
/// Draws a generated bridge span with a compact integrity readout.
fn draw_bridge_span_art(
  art : GameArt,
  span : BridgeSpan,
  scene_t : Float,
  index : Int,
) -> Unit {
  let cx : Float = span.x + span.w * 0.5
  let cy : Float = span.y + span.h * 0.5
  let p : Float = clampf(span.integrity / 100.0, 0.0, 1.0)
  let pulse : Float = @math.sinf(scene_t * 4.6 + Float::from_int(index) * 0.7) *
    0.5 +
    0.5

  @raylib.draw_rectangle(
    (cx - span.w * 0.74).to_int(),
    (cy - span.h * 0.62).to_int(),
    (span.w * 1.48).to_int(),
    (span.h * 1.24).to_int(),
    @raylib.Color::new(0, 0, 0, 90),
  )
  draw_texture_centered(
    art.bridge_span,
    cx,
    cy,
    span.w * 1.48,
    span.h * 1.42,
    @raylib.white,
  )

  let bar_w : Int = (span.w * 1.04).to_int()
  let bar_x : Int = (cx - Float::from_int(bar_w) * 0.5).to_int()
  let bar_y : Int = (span.y + span.h + 8.0).to_int()
  let red : Int = 224 - (p * 102.0).to_int()
  let green : Int = 48 + (p * 174.0).to_int()
  @raylib.draw_rectangle(
    bar_x,
    bar_y,
    bar_w,
    7,
    @raylib.Color::new(8, 12, 18, 202),
  )
  @raylib.draw_rectangle(
    bar_x + 1,
    bar_y + 1,
    (Float::from_int(bar_w - 2) * p).to_int(),
    5,
    @raylib.Color::new(red, green, 60, 232),
  )

  if span.integrity < 44.0 {
    let ax : Float = span.x + span.w * 0.5
    let ay : Float = span.y - 14.0
    let rr : Float = 9.0 + pulse * 5.0
    @raylib.draw_circle_v(
      @raylib.Vector2::new(ax, ay),
      rr,
      @raylib.Color::new(255, 68, 46, 128),
    )
    @draw.draw_text(
      "!",
      (ax - 4.0).to_int(),
      (ay - 10.0).to_int(),
      18,
      @raylib.white,
    )
  }
}

///|
/// Draws a generated survivor raft with its gameplay passenger count.
fn draw_raft_art(art : GameArt, raft : RaftGroup, scene_t : Float) -> Unit {
  let panic_col : Int = 80 + (clampf(raft.panic, 0.0, 1.0) * 132.0).to_int()
  @raylib.draw_circle_v(
    @raylib.Vector2::new(raft.x, raft.y),
    28.0,
    @raylib.Color::new(255, panic_col, 74, 36),
  )
  draw_texture_centered(
    art.survivor_raft,
    raft.x,
    raft.y,
    52.0,
    52.0,
    @raylib.white,
  )

  let blink : Float = @math.sinf(scene_t * 7.0 + raft.flare_t) * 0.5 + 0.5
  @raylib.draw_circle_v(
    @raylib.Vector2::new(raft.x, raft.y - 24.0),
    5.0 + blink * 4.0,
    @raylib.Color::new(255, 110, 72, 186),
  )
  @raylib.draw_circle_v(
    @raylib.Vector2::new(raft.x, raft.y),
    10.0,
    @raylib.Color::new(18, 24, 34, 150),
  )
  @draw.draw_text(
    "\{raft.survivors}",
    (raft.x - 8.0).to_int(),
    (raft.y - 8.0).to_int(),
    18,
    @raylib.white,
  )
}

///|
/// Draws a generated debris obstacle scaled to its collision hardness.
fn draw_debris_art(art : GameArt, debris : Debris) -> Unit {
  let w : Float = debris.size * 3.45
  let h : Float = debris.size * 1.55
  @raylib.draw_rectangle(
    (debris.x - w * 0.48).to_int(),
    (debris.y + h * 0.28).to_int(),
    (w * 0.96).to_int(),
    5,
    @raylib.Color::new(0, 0, 0, 94),
  )
  draw_texture_centered_rotated(
    art.flood_debris,
    debris.x,
    debris.y,
    w,
    h,
    debris.spin * 12.0,
    @raylib.white,
  )
}

///|
/// Draws a generated floating supply crate with kind-specific glow.
fn draw_supply_art(
  art : GameArt,
  supply : SupplyCrate,
  scene_t : Float,
) -> Unit {
  let blink : Float = @math.sinf(scene_t * 6.2 + supply.blink) * 0.5 + 0.5
  let glow = if supply.kind == 0 {
    @raylib.Color::new(104, 222, 132, 54 + (blink * 52.0).to_int())
  } else {
    @raylib.Color::new(112, 190, 248, 54 + (blink * 52.0).to_int())
  }
  @raylib.draw_circle_v(@raylib.Vector2::new(supply.x, supply.y), 24.0, glow)
  draw_texture_centered(
    art.supply_crate,
    supply.x,
    supply.y,
    38.0,
    38.0,
    @raylib.white,
  )
  @raylib.draw_circle_v(
    @raylib.Vector2::new(supply.x + 12.0, supply.y - 12.0),
    8.0,
    @raylib.Color::new(236, 248, 255, 224),
  )
  @draw.draw_text(
    if supply.kind == 0 {
      "K"
    } else {
      "F"
    },
    (supply.x + 7.0).to_int(),
    (supply.y - 20.0).to_int(),
    15,
    @raylib.Color::new(20, 28, 40, 255),
  )
}

///|
/// Draws the generated rescue boat sprite with boost glow.
fn draw_rescue_boat_art(
  art : GameArt,
  boat : RescueBoat,
  scene_t : Float,
) -> Unit {
  let bob : Float = @math.sinf(scene_t * 7.2) * 1.4
  let x : Float = boat.x
  let y : Float = boat.y + bob
  let c : Float = @math.cosf(boat.heading)
  let s : Float = @math.sinf(boat.heading)
  let heat_alpha : Int = clampf(boat.boost_heat * 170.0, 0.0, 180.0).to_int()
  if heat_alpha > 0 {
    @raylib.draw_circle_v(
      @raylib.Vector2::new(x - c * 31.0, y - s * 31.0),
      10.0 + boat.boost_heat * 6.0,
      @raylib.Color::new(255, 146, 62, heat_alpha),
    )
  }
  @raylib.draw_rectangle(
    (x - 30.0).to_int(),
    (y + 16.0).to_int(),
    60,
    6,
    @raylib.Color::new(0, 0, 0, 88),
  )
  draw_texture_centered_rotated(
    art.rescue_boat,
    x,
    y,
    74.0,
    50.0,
    boat.heading * 57.29577951308232,
    @raylib.white,
  )
}

///|
/// Draws the generated supply dock and evacuation camp sprites with gameplay labels.
fn draw_world_panel_art(
  art : GameArt,
  dock : SupplyDock,
  camp : EvacCamp,
  scene_t : Float,
) -> Unit {
  let pulse : Float = @math.sinf(scene_t * 3.6) * 0.5 + 0.5
  @raylib.draw_circle_v(
    @raylib.Vector2::new(
      dock.x + Float::from_int(dock.w) * 0.5,
      dock.y + Float::from_int(dock.h) * 0.5,
    ),
    38.0 + pulse * 8.0,
    @raylib.Color::new(154, 244, 212, 64),
  )
  draw_texture_centered(
    art.supply_dock,
    dock.x + Float::from_int(dock.w) * 0.5,
    dock.y + Float::from_int(dock.h) * 0.54,
    Float::from_int(dock.w) * 1.08,
    Float::from_int(dock.h) * 1.08,
    @raylib.white,
  )
  @raylib.draw_rectangle_lines(
    dock.x.to_int(),
    dock.y.to_int(),
    dock.w,
    dock.h,
    @raylib.Color::new(154, 238, 190, 220),
  )
  @draw.draw_text(
    "SUPPLY DOCK",
    dock.x.to_int() + 14,
    dock.y.to_int() + 12,
    20,
    @raylib.Color::new(220, 248, 234, 250),
  )

  @raylib.draw_circle_v(
    @raylib.Vector2::new(
      camp.x + Float::from_int(camp.w) * 0.5,
      camp.y + Float::from_int(camp.h) * 0.5,
    ),
    38.0 + pulse * 8.0,
    @raylib.Color::new(244, 236, 154, 64),
  )
  draw_texture_centered(
    art.evac_camp,
    camp.x + Float::from_int(camp.w) * 0.5,
    camp.y + Float::from_int(camp.h) * 0.54,
    Float::from_int(camp.w) * 1.08,
    Float::from_int(camp.h) * 1.08,
    @raylib.white,
  )
  @raylib.draw_rectangle_lines(
    camp.x.to_int(),
    camp.y.to_int(),
    camp.w,
    camp.h,
    @raylib.Color::new(240, 242, 148, 220),
  )
  @draw.draw_text(
    "EVAC CAMP",
    camp.x.to_int() + 16,
    camp.y.to_int() + 12,
    20,
    @raylib.Color::new(250, 250, 208, 250),
  )
}
