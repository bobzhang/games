// 3D world rendering

///|
/// Draws the complete 3D world including track, karts, items, particles, and visual effects.
pub fn draw_world(game : @types.Game) -> Unit {
  draw_sky_gradient(game)
  let camera = game.build_camera()
  @raylib.begin_mode_3d(camera)
  game.draw_skybox_elements()
  game.draw_ground()
  game.draw_track()
  game.draw_surface_indicators()
  game.draw_boost_pad_glow()
  game.draw_powerups()
  game.draw_powerup_halos()
  game.draw_kart_blob_shadows()
  game.draw_skid_marks()
  game.draw_karts()
  game.draw_kart_details()
  game.draw_drift_smoke()
  game.draw_hit_sparkle_effect_3d()
  game.draw_projectiles()
  game.draw_particles_3d()
  game.draw_start_finish_line()
  game.draw_trackside_objects()
  game.draw_themed_decorations()
  @raylib.end_mode_3d()
  draw_effects(game)
}

///|
fn @types.Game::build_camera(game : @types.Game) -> @raylib.Camera3D {
  @raylib.Camera3D::new(
    @raylib.Vector3::new(game.camera_x, game.camera_y, game.camera_z),
    @raylib.Vector3::new(
      game.camera_look_x,
      game.camera_look_y,
      game.camera_look_z,
    ),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    game.camera_fov,
    @raylib.CameraPerspective,
  )
}

///|
fn @types.Game::draw_ground(game : @types.Game) -> Unit {
  let gc = @levels.get_track_ground_color(game.current_cup, game.current_race)
  // Draw a large ground plane
  @raylib.draw_plane(
    @raylib.Vector3::new(15.0, -0.05, 20.0),
    @raylib.Vector2::new(200.0, 200.0),
    @raylib.Color::new(gc.0, gc.1, gc.2, 255),
  )
  // Subtle grid lines on the ground for depth cues
  let grid_step : Float = 10.0
  let grid_half : Int = 10
  let grid_r = (gc.0 - 15).clamp(min=0, max=255)
  let grid_g = (gc.1 - 15).clamp(min=0, max=255)
  let grid_b = (gc.2 - 15).clamp(min=0, max=255)
  let grid_color = @raylib.Color::new(grid_r, grid_g, grid_b, 60)
  let center_x : Float = 15.0
  let center_z : Float = 20.0
  for gi = -grid_half; gi <= grid_half; gi = gi + 1 {
    let offset = Float::from_int(gi) * grid_step
    let half_extent : Float = Float::from_int(grid_half) * grid_step
    // Lines along X axis
    @raylib.draw_line_3d(
      @raylib.Vector3::new(center_x - half_extent, -0.04, center_z + offset),
      @raylib.Vector3::new(center_x + half_extent, -0.04, center_z + offset),
      grid_color,
    )
    // Lines along Z axis
    @raylib.draw_line_3d(
      @raylib.Vector3::new(center_x + offset, -0.04, center_z - half_extent),
      @raylib.Vector3::new(center_x + offset, -0.04, center_z + half_extent),
      grid_color,
    )
  }
}

///|
fn @types.Game::draw_track(game : @types.Game) -> Unit {
  let wc = game.waypoint_count
  if wc < 2 {
    return
  }
  let rc = @levels.get_track_road_color(game.current_cup, game.current_race)
  let road_color = @raylib.Color::new(rc.0, rc.1, rc.2, 255)
  // Shoulder color: darker than road
  let sh_r = (rc.0 - 30).clamp(min=0, max=255)
  let sh_g = (rc.1 - 30).clamp(min=0, max=255)
  let sh_b = (rc.2 - 30).clamp(min=0, max=255)
  let shoulder_color = @raylib.Color::new(sh_r, sh_g, sh_b, 255)
  let curb_white = @raylib.Color::new(240, 240, 240, 255)
  let curb_red = @raylib.Color::new(200, 40, 40, 255)
  let dash_color = @raylib.Color::new(230, 230, 230, 220)
  let shoulder_extra : Float = 1.2
  let curb_width_f : Float = 0.35
  // Per-segment: compute perpendiculars at each waypoint (average of adjacent segments)
  let perp_x : Array[Float] = Array::make(wc, 0.0)
  let perp_z : Array[Float] = Array::make(wc, 0.0)
  for i in 0..<wc {
    let prev = (i + wc - 1) % wc
    let next = (i + 1) % wc
    let wp_prev = game.waypoints[prev]
    let wp_cur = game.waypoints[i]
    let wp_next = game.waypoints[next]
    // Direction from prev->cur
    let d1x = wp_cur.x - wp_prev.x
    let d1z = wp_cur.z - wp_prev.z
    let len1 = @types.distance2d(0.0, 0.0, d1x, d1z)
    // Direction from cur->next
    let d2x = wp_next.x - wp_cur.x
    let d2z = wp_next.z - wp_cur.z
    let len2 = @types.distance2d(0.0, 0.0, d2x, d2z)
    let mut avg_dx : Float = 0.0
    let mut avg_dz : Float = 0.0
    if len1 > 0.01 && len2 > 0.01 {
      avg_dx = d1x / len1 + d2x / len2
      avg_dz = d1z / len1 + d2z / len2
    } else if len2 > 0.01 {
      avg_dx = d2x / len2
      avg_dz = d2z / len2
    } else if len1 > 0.01 {
      avg_dx = d1x / len1
      avg_dz = d1z / len1
    } else {
      avg_dx = 0.0
      avg_dz = 1.0
    }
    let avg_len = @types.distance2d(0.0, 0.0, avg_dx, avg_dz)
    if avg_len > 0.01 {
      avg_dx = avg_dx / avg_len
      avg_dz = avg_dz / avg_len
    }
    // Perpendicular (right-hand side of forward direction)
    perp_x[i] = -avg_dz
    perp_z[i] = avg_dx
  }
  // Draw each road segment as an oriented quad strip
  for i in 0..<wc {
    let next = (i + 1) % wc
    let wp0 = game.waypoints[i]
    let wp1 = game.waypoints[next]
    let seg = game.segments[i]
    let seg_dist = @types.distance2d(wp0.x, wp0.z, wp1.x, wp1.z)
    if seg_dist < 0.01 {
      continue
    }
    let half_w : Float = @types.road_half * seg.width_mult
    let shoulder_w : Float = half_w + shoulder_extra
    let curb_inner : Float = half_w - curb_width_f * 0.1
    let curb_outer : Float = half_w + curb_width_f
    // Subdivide the segment for smoothness
    let sub_count_f = (seg_dist / 2.5).to_int() + 1
    let sub_count = if sub_count_f < 2 { 2 } else { sub_count_f }
    for s in 0..<sub_count {
      let t0 = Float::from_int(s) / Float::from_int(sub_count)
      let t1 = Float::from_int(s + 1) / Float::from_int(sub_count)
      // Interpolate positions
      let x0 = @types.lerpf(wp0.x, wp1.x, t0)
      let y0 = @types.lerpf(wp0.y, wp1.y, t0)
      let z0 = @types.lerpf(wp0.z, wp1.z, t0)
      let x1 = @types.lerpf(wp0.x, wp1.x, t1)
      let y1 = @types.lerpf(wp0.y, wp1.y, t1)
      let z1 = @types.lerpf(wp0.z, wp1.z, t1)
      // Interpolate perpendiculars and renormalize to avoid pinching on sharp bends
      let mut px0 = @types.lerpf(perp_x[i], perp_x[next], t0)
      let mut pz0 = @types.lerpf(perp_z[i], perp_z[next], t0)
      let len0 = (px0 * px0 + pz0 * pz0).sqrt()
      if len0 > 0.001 {
        px0 = px0 / len0
        pz0 = pz0 / len0
      }
      let mut px1 = @types.lerpf(perp_x[i], perp_x[next], t1)
      let mut pz1 = @types.lerpf(perp_z[i], perp_z[next], t1)
      let len1 = (px1 * px1 + pz1 * pz1).sqrt()
      if len1 > 0.001 {
        px1 = px1 / len1
        pz1 = pz1 / len1
      }
      let road_y0 = y0 + 0.01
      let road_y1 = y1 + 0.01
      // Shoulder quads (wider, darker)
      let s0_lx = x0 - px0 * shoulder_w
      let s0_lz = z0 - pz0 * shoulder_w
      let s0_rx = x0 + px0 * shoulder_w
      let s0_rz = z0 + pz0 * shoulder_w
      let s1_lx = x1 - px1 * shoulder_w
      let s1_lz = z1 - pz1 * shoulder_w
      let s1_rx = x1 + px1 * shoulder_w
      let s1_rz = z1 + pz1 * shoulder_w
      let sh_y0 = road_y0 - 0.01
      let sh_y1 = road_y1 - 0.01
      @raylib.draw_triangle_3d(
        @raylib.Vector3::new(s0_lx, sh_y0, s0_lz),
        @raylib.Vector3::new(s0_rx, sh_y0, s0_rz),
        @raylib.Vector3::new(s1_rx, sh_y1, s1_rz),
        shoulder_color,
      )
      @raylib.draw_triangle_3d(
        @raylib.Vector3::new(s0_lx, sh_y0, s0_lz),
        @raylib.Vector3::new(s1_rx, sh_y1, s1_rz),
        @raylib.Vector3::new(s1_lx, sh_y1, s1_lz),
        shoulder_color,
      )
      // Main road surface quad
      let r0_lx = x0 - px0 * half_w
      let r0_lz = z0 - pz0 * half_w
      let r0_rx = x0 + px0 * half_w
      let r0_rz = z0 + pz0 * half_w
      let r1_lx = x1 - px1 * half_w
      let r1_lz = z1 - pz1 * half_w
      let r1_rx = x1 + px1 * half_w
      let r1_rz = z1 + pz1 * half_w
      @raylib.draw_triangle_3d(
        @raylib.Vector3::new(r0_lx, road_y0, r0_lz),
        @raylib.Vector3::new(r0_rx, road_y0, r0_rz),
        @raylib.Vector3::new(r1_rx, road_y1, r1_rz),
        road_color,
      )
      @raylib.draw_triangle_3d(
        @raylib.Vector3::new(r0_lx, road_y0, r0_lz),
        @raylib.Vector3::new(r1_rx, road_y1, r1_rz),
        @raylib.Vector3::new(r1_lx, road_y1, r1_lz),
        road_color,
      )
      // Curb strips (alternating red/white) on each edge
      let curb_idx = i * sub_count + s
      let curb_color = if curb_idx % 2 == 0 { curb_red } else { curb_white }
      // Left curb
      let cl0_ix = x0 - px0 * curb_inner
      let cl0_iz = z0 - pz0 * curb_inner
      let cl0_ox = x0 - px0 * curb_outer
      let cl0_oz = z0 - pz0 * curb_outer
      let cl1_ix = x1 - px1 * curb_inner
      let cl1_iz = z1 - pz1 * curb_inner
      let cl1_ox = x1 - px1 * curb_outer
      let cl1_oz = z1 - pz1 * curb_outer
      let curb_y0 = road_y0 + 0.02
      let curb_y1 = road_y1 + 0.02
      @raylib.draw_triangle_3d(
        @raylib.Vector3::new(cl0_ix, curb_y0, cl0_iz),
        @raylib.Vector3::new(cl0_ox, curb_y0, cl0_oz),
        @raylib.Vector3::new(cl1_ox, curb_y1, cl1_oz),
        curb_color,
      )
      @raylib.draw_triangle_3d(
        @raylib.Vector3::new(cl0_ix, curb_y0, cl0_iz),
        @raylib.Vector3::new(cl1_ox, curb_y1, cl1_oz),
        @raylib.Vector3::new(cl1_ix, curb_y1, cl1_iz),
        curb_color,
      )
      // Right curb
      let cr0_ix = x0 + px0 * curb_inner
      let cr0_iz = z0 + pz0 * curb_inner
      let cr0_ox = x0 + px0 * curb_outer
      let cr0_oz = z0 + pz0 * curb_outer
      let cr1_ix = x1 + px1 * curb_inner
      let cr1_iz = z1 + pz1 * curb_inner
      let cr1_ox = x1 + px1 * curb_outer
      let cr1_oz = z1 + pz1 * curb_outer
      @raylib.draw_triangle_3d(
        @raylib.Vector3::new(cr0_ix, curb_y0, cr0_iz),
        @raylib.Vector3::new(cr0_ox, curb_y0, cr0_oz),
        @raylib.Vector3::new(cr1_ox, curb_y1, cr1_oz),
        curb_color,
      )
      @raylib.draw_triangle_3d(
        @raylib.Vector3::new(cr0_ix, curb_y0, cr0_iz),
        @raylib.Vector3::new(cr1_ox, curb_y1, cr1_oz),
        @raylib.Vector3::new(cr1_ix, curb_y1, cr1_iz),
        curb_color,
      )
      // Center lane dashes (every other sub-segment)
      if curb_idx % 3 == 0 {
        let dash_half : Float = 0.12
        let dash_y0 = road_y0 + 0.02
        let dash_y1 = road_y1 + 0.02
        @raylib.draw_triangle_3d(
          @raylib.Vector3::new(x0 - px0 * dash_half, dash_y0, z0 - pz0 * dash_half),
          @raylib.Vector3::new(x0 + px0 * dash_half, dash_y0, z0 + pz0 * dash_half),
          @raylib.Vector3::new(x1 + px1 * dash_half, dash_y1, z1 + pz1 * dash_half),
          dash_color,
        )
        @raylib.draw_triangle_3d(
          @raylib.Vector3::new(x0 - px0 * dash_half, dash_y0, z0 - pz0 * dash_half),
          @raylib.Vector3::new(x1 + px1 * dash_half, dash_y1, z1 + pz1 * dash_half),
          @raylib.Vector3::new(x1 - px1 * dash_half, dash_y1, z1 - pz1 * dash_half),
          dash_color,
        )
      }
    }
  }
}

///|
fn @types.Game::draw_start_finish_line(game : @types.Game) -> Unit {
  let wc = game.waypoint_count
  if wc < 2 {
    return
  }
  let wp0 = game.waypoints[0]
  let wp1 = game.waypoints[1]
  let dx = wp1.x - wp0.x
  let dz = wp1.z - wp0.z
  let dist = @types.distance2d(wp0.x, wp0.z, wp1.x, wp1.z)
  if dist < 0.01 {
    return
  }
  // Perpendicular (across road)
  let px = -dz / dist
  let pz = dx / dist
  // Forward direction (along road)
  let fx = dx / dist
  let fz = dz / dist
  let seg = game.segments[0]
  let half_w : Float = @types.road_half * seg.width_mult
  // Draw a proper checkerboard grid at start/finish
  let checks_across = 8
  let checks_along = 3
  let check_w : Float = half_w * 2.0 / Float::from_int(checks_across)
  let check_l : Float = 0.7
  let line_y = wp0.y + 0.05
  let white = @raylib.Color::new(255, 255, 255, 255)
  let black = @raylib.Color::new(25, 25, 25, 255)
  for row in 0..<checks_along {
    for col in 0..<checks_across {
      let color = if (row + col) % 2 == 0 { white } else { black }
      let col_f = Float::from_int(col) - Float::from_int(checks_across) / 2.0
      let row_f = Float::from_int(row) - Float::from_int(checks_along) / 2.0
      // Center of this check square
      let cx = wp0.x + px * (col_f + 0.5) * check_w + fx * (row_f + 0.5) * check_l
      let cz = wp0.z + pz * (col_f + 0.5) * check_w + fz * (row_f + 0.5) * check_l
      // Quad corners
      let hw = check_w * 0.5
      let hl = check_l * 0.5
      let v0x = cx - px * hw - fx * hl
      let v0z = cz - pz * hw - fz * hl
      let v1x = cx + px * hw - fx * hl
      let v1z = cz + pz * hw - fz * hl
      let v2x = cx + px * hw + fx * hl
      let v2z = cz + pz * hw + fz * hl
      let v3x = cx - px * hw + fx * hl
      let v3z = cz - pz * hw + fz * hl
      @raylib.draw_triangle_3d(
        @raylib.Vector3::new(v0x, line_y, v0z),
        @raylib.Vector3::new(v1x, line_y, v1z),
        @raylib.Vector3::new(v2x, line_y, v2z),
        color,
      )
      @raylib.draw_triangle_3d(
        @raylib.Vector3::new(v0x, line_y, v0z),
        @raylib.Vector3::new(v2x, line_y, v2z),
        @raylib.Vector3::new(v3x, line_y, v3z),
        color,
      )
    }
  }
  // Finish arch poles
  @raylib.draw_cube(
    @raylib.Vector3::new(
      wp0.x + px * (half_w + 0.8),
      wp0.y + 2.0,
      wp0.z + pz * (half_w + 0.8),
    ),
    0.3,
    4.0,
    0.3,
    @raylib.Color::new(200, 200, 200, 255),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(
      wp0.x - px * (half_w + 0.8),
      wp0.y + 2.0,
      wp0.z - pz * (half_w + 0.8),
    ),
    0.3,
    4.0,
    0.3,
    @raylib.Color::new(200, 200, 200, 255),
  )
  // Top bar (checkered banner)
  let bar_y = wp0.y + 4.0
  let bar_hw = half_w + 0.8
  for bc in 0..<12 {
    let bt = Float::from_int(bc) / 12.0 * 2.0 - 1.0
    let bx = wp0.x + px * bt * bar_hw
    let bz = wp0.z + pz * bt * bar_hw
    let bc_color = if bc % 2 == 0 { white } else { @raylib.Color::new(220, 40, 40, 255) }
    @raylib.draw_cube(
      @raylib.Vector3::new(bx, bar_y, bz),
      0.2,
      0.35,
      0.35,
      bc_color,
    )
  }
}

///|
fn @types.Game::draw_trackside_objects(game : @types.Game) -> Unit {
  let wc = game.waypoint_count
  if wc < 3 {
    return
  }
  // Place trees/rocks along the track edges
  for i in 0..<wc {
    let wp = game.waypoints[i]
    let next = game.waypoints[(i + 1) % wc]
    let dx = next.x - wp.x
    let dz = next.z - wp.z
    let dist = @types.distance2d(wp.x, wp.z, next.x, next.z)
    if dist < 0.01 {
      continue
    }
    let px = -dz / dist
    let pz = dx / dist
    // Trees on the right side
    let tree_dist = @types.road_half + 4.0 + Float::from_int(i % 3) * 2.0
    let tx = wp.x + px * tree_dist
    let tz = wp.z + pz * tree_dist
    // Tree trunk
    @raylib.draw_cube(
      @raylib.Vector3::new(tx, wp.y + 1.0, tz),
      0.3,
      2.0,
      0.3,
      @raylib.Color::new(100, 70, 40, 255),
    )
    // Tree canopy
    @raylib.draw_sphere(
      @raylib.Vector3::new(tx, wp.y + 2.5, tz),
      1.0,
      @raylib.Color::new(40, 120 + i % 40, 30, 255),
    )
    // Rocks on the left side (every other waypoint)
    if i % 2 == 0 {
      let rock_dist = @types.road_half + 3.0 + Float::from_int(i % 5)
      let rx = wp.x - px * rock_dist
      let rz = wp.z - pz * rock_dist
      @raylib.draw_cube(
        @raylib.Vector3::new(rx, wp.y + 0.3, rz),
        0.8,
        0.6,
        0.8,
        @raylib.Color::new(110, 105, 95, 255),
      )
    }
  }
}

///|
fn @types.Game::draw_karts(game : @types.Game) -> Unit {
  let time_f = Float::from_int(game.frame_counter) * 0.016
  for i in 0..<@types.max_karts {
    let kart = game.karts[i]
    if !kart.active {
      continue
    }
    let colors = @types.kart_colors
    let ci = i.clamp(min=0, max=colors.length() - 1)
    let kc = colors[ci]
    let aci = i.clamp(min=0, max=@types.kart_accent_colors.length() - 1)
    let ac = @types.kart_accent_colors[aci]
    let body_color = @raylib.Color::new(kc.0, kc.1, kc.2, 255)
    let accent_color = @raylib.Color::new(ac.0, ac.1, ac.2, 255)
    let kw = @types.kart_width
    let kh = @types.kart_height
    let kl = @types.kart_length
    // Spin visual rotation
    let visual_angle : Float = if kart.spin_timer > 0.0 {
      kart.angle + kart.spin_timer * 10.0
    } else {
      kart.angle
    }
    let sin_a = @math.sinf(visual_angle)
    let cos_a = @math.cosf(visual_angle)
    // Visual lean on turns
    let lean_amount = -kart.steer * 0.15
    let lean_y_offset : Float = lean_amount.abs() * 0.03
    // Suspension bounce based on speed
    let speed_ratio = @types.clampf(kart.speed / 28.0, 0.0, 1.0)
    let bounce : Float = @math.sinf(time_f * 8.0) * speed_ratio * 0.05
    let landing_bounce : Float = if kart.bounce_timer > 0.0 {
      @math.sinf(kart.bounce_timer * 25.0) * kart.bounce_timer * 0.4
    } else {
      0.0
    }
    let total_bounce = bounce + landing_bounce
    let base_y = kart.y + total_bounce + lean_y_offset
    let draw_y = base_y + kh * 0.35
    // Lean offset: shift kart center laterally to simulate roll
    let lean_lateral = lean_amount * 0.08
    let lean_ox = cos_a * lean_lateral
    let lean_oz = -sin_a * lean_lateral
    let cx = kart.x + lean_ox
    let cz = kart.z + lean_oz
    // --- Chassis (low, wide, flat) ---
    @raylib.draw_cube(
      @raylib.Vector3::new(cx, draw_y - kh * 0.1, cz),
      kw * 1.05,
      kh * 0.35,
      kl * 0.85,
      body_color,
    )
    // --- Front nose (tapered, forward) ---
    let nose_dist : Float = kl * 0.52
    let nose_x = cx + sin_a * nose_dist
    let nose_z = cz + cos_a * nose_dist
    @raylib.draw_cube(
      @raylib.Vector3::new(nose_x, draw_y - kh * 0.12, nose_z),
      kw * 0.55,
      kh * 0.25,
      kl * 0.35,
      body_color,
    )
    // Nose tip (white headlight area)
    let tip_dist : Float = kl * 0.72
    let tip_x = cx + sin_a * tip_dist
    let tip_z = cz + cos_a * tip_dist
    @raylib.draw_cube(
      @raylib.Vector3::new(tip_x, draw_y - kh * 0.15, tip_z),
      kw * 0.35,
      kh * 0.18,
      0.15,
      @raylib.Color::new(240, 240, 240, 220),
    )
    // --- Cockpit (raised section in middle) ---
    let cockpit_x = cx - sin_a * kl * 0.05
    let cockpit_z = cz - cos_a * kl * 0.05
    @raylib.draw_cube(
      @raylib.Vector3::new(cockpit_x, draw_y + kh * 0.25, cockpit_z),
      kw * 0.52,
      kh * 0.45,
      kl * 0.35,
      @raylib.Color::new(
        (kc.0 * 2 / 3).clamp(min=0, max=255),
        (kc.1 * 2 / 3).clamp(min=0, max=255),
        (kc.2 * 2 / 3).clamp(min=0, max=255),
        255,
      ),
    )
    // Windshield (translucent blue-tinted)
    let ws_dist : Float = kl * 0.12
    let ws_x = cockpit_x + sin_a * ws_dist
    let ws_z = cockpit_z + cos_a * ws_dist
    @raylib.draw_cube(
      @raylib.Vector3::new(ws_x, draw_y + kh * 0.35, ws_z),
      kw * 0.44,
      kh * 0.28,
      0.06,
      @raylib.Color::new(130, 180, 220, 160),
    )
    // --- Side pods (accent colored) ---
    let pod_fwd : Float = kl * 0.05
    let pod_side : Float = kw * 0.55
    let pod_lx = cx + sin_a * pod_fwd + cos_a * pod_side
    let pod_lz = cz + cos_a * pod_fwd - sin_a * pod_side
    @raylib.draw_cube(
      @raylib.Vector3::new(pod_lx, draw_y - kh * 0.05, pod_lz),
      kw * 0.18,
      kh * 0.25,
      kl * 0.5,
      accent_color,
    )
    let pod_rx = cx + sin_a * pod_fwd - cos_a * pod_side
    let pod_rz = cz + cos_a * pod_fwd + sin_a * pod_side
    @raylib.draw_cube(
      @raylib.Vector3::new(pod_rx, draw_y - kh * 0.05, pod_rz),
      kw * 0.18,
      kh * 0.25,
      kl * 0.5,
      accent_color,
    )
    // --- Rear engine block ---
    let rear_dist : Float = kl * 0.35
    let rear_x = cx - sin_a * rear_dist
    let rear_z = cz - cos_a * rear_dist
    @raylib.draw_cube(
      @raylib.Vector3::new(rear_x, draw_y + kh * 0.05, rear_z),
      kw * 0.7,
      kh * 0.35,
      kl * 0.25,
      @raylib.Color::new(
        (kc.0 * 3 / 4).clamp(min=0, max=255),
        (kc.1 * 3 / 4).clamp(min=0, max=255),
        (kc.2 * 3 / 4).clamp(min=0, max=255),
        255,
      ),
    )
    // --- Spoiler (thin flat rectangle raised behind) ---
    let sp_dist : Float = kl * 0.5
    let sp_x = cx - sin_a * sp_dist
    let sp_z = cz - cos_a * sp_dist
    let sp_y = draw_y + kh * 0.55
    @raylib.draw_cube(
      @raylib.Vector3::new(sp_x, sp_y, sp_z),
      kw * 0.85,
      0.04,
      0.12,
      accent_color,
    )
    // Spoiler supports
    let sup_off : Float = kw * 0.32
    let sup_lx = sp_x + cos_a * sup_off
    let sup_lz = sp_z - sin_a * sup_off
    @raylib.draw_cube(
      @raylib.Vector3::new(sup_lx, draw_y + kh * 0.28, sup_lz),
      0.04,
      kh * 0.45,
      0.04,
      accent_color,
    )
    let sup_rx = sp_x - cos_a * sup_off
    let sup_rz = sp_z + sin_a * sup_off
    @raylib.draw_cube(
      @raylib.Vector3::new(sup_rx, draw_y + kh * 0.28, sup_rz),
      0.04,
      kh * 0.45,
      0.04,
      accent_color,
    )
    // --- Exhaust pipes (two at rear) ---
    let ex_back : Float = kl * 0.58
    let ex_side : Float = kw * 0.22
    let ex_ly = draw_y - kh * 0.05
    let exl_x = cx - sin_a * ex_back + cos_a * ex_side
    let exl_z = cz - cos_a * ex_back - sin_a * ex_side
    @raylib.draw_cube(
      @raylib.Vector3::new(exl_x, ex_ly, exl_z),
      0.08,
      0.08,
      0.18,
      @raylib.Color::new(70, 70, 75, 255),
    )
    let exr_x = cx - sin_a * ex_back - cos_a * ex_side
    let exr_z = cz - cos_a * ex_back + sin_a * ex_side
    @raylib.draw_cube(
      @raylib.Vector3::new(exr_x, ex_ly, exr_z),
      0.08,
      0.08,
      0.18,
      @raylib.Color::new(70, 70, 75, 255),
    )
    // --- Wheels with steering visual ---
    let wheel_color = @raylib.Color::new(25, 25, 28, 255)
    let hub_color = @raylib.Color::new(ac.0, ac.1, ac.2, 200)
    let wx_off = kw * 0.62
    let wz_front = kl * 0.38
    let wz_rear = kl * 0.32
    let wheel_h : Float = 0.22
    let wheel_w : Float = 0.16
    let wheel_d : Float = 0.32
    let front_wheel_d : Float = 0.28
    // Front-left wheel
    let fl_x = cx + sin_a * wz_front + cos_a * wx_off
    let fl_z = cz + cos_a * wz_front - sin_a * wx_off
    let fl_y = base_y + 0.11
    @raylib.draw_cube(
      @raylib.Vector3::new(fl_x, fl_y, fl_z),
      wheel_w,
      wheel_h,
      front_wheel_d,
      wheel_color,
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(fl_x, fl_y, fl_z),
      wheel_w + 0.02,
      0.06,
      0.06,
      hub_color,
    )
    // Front-right wheel
    let fr_x = cx + sin_a * wz_front - cos_a * wx_off
    let fr_z = cz + cos_a * wz_front + sin_a * wx_off
    let fr_y = base_y + 0.11
    @raylib.draw_cube(
      @raylib.Vector3::new(fr_x, fr_y, fr_z),
      wheel_w,
      wheel_h,
      front_wheel_d,
      wheel_color,
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(fr_x, fr_y, fr_z),
      wheel_w + 0.02,
      0.06,
      0.06,
      hub_color,
    )
    // Rear-left wheel (larger)
    let rl_x = cx - sin_a * wz_rear + cos_a * wx_off
    let rl_z = cz - cos_a * wz_rear - sin_a * wx_off
    let rl_y = base_y + 0.12
    @raylib.draw_cube(
      @raylib.Vector3::new(rl_x, rl_y, rl_z),
      wheel_w + 0.04,
      wheel_h + 0.04,
      wheel_d,
      wheel_color,
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(rl_x, rl_y, rl_z),
      wheel_w + 0.06,
      0.06,
      0.06,
      hub_color,
    )
    // Rear-right wheel (larger)
    let rr_x = cx - sin_a * wz_rear - cos_a * wx_off
    let rr_z = cz - cos_a * wz_rear + sin_a * wx_off
    let rr_y = base_y + 0.12
    @raylib.draw_cube(
      @raylib.Vector3::new(rr_x, rr_y, rr_z),
      wheel_w + 0.04,
      wheel_h + 0.04,
      wheel_d,
      wheel_color,
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(rr_x, rr_y, rr_z),
      wheel_w + 0.06,
      0.06,
      0.06,
      hub_color,
    )
    // --- Shield effect ---
    if kart.shield_timer > 0.0 {
      let pulse = @math.sinf(Float::from_int(game.frame_counter) * 0.2)
      let shield_size : Float = 1.2 + pulse * 0.1
      @raylib.draw_sphere(
        @raylib.Vector3::new(cx, draw_y + 0.2, cz),
        shield_size,
        @raylib.Color::new(100, 180, 255, 60),
      )
    }
    // --- Boost flames from dual exhausts ---
    if kart.boost_timer > 0.0 {
      let flicker = @math.sinf(
        Float::from_int(game.frame_counter) * 0.7 + Float::from_int(i),
      )
      let flame_len : Float = 0.4 + flicker * 0.12
      // Determine flame color: blue for drift boost, orange for mushroom
      let is_drift_boost = kart.boost_power < @types.boost_speed_add - 0.5
      let flame_r : Int = if is_drift_boost { 80 } else { 255 }
      let flame_g : Int = if is_drift_boost { 140 } else { 160 }
      let flame_b : Int = if is_drift_boost { 255 } else { 30 }
      // Left exhaust flame
      let fl_ex = cx - sin_a * (ex_back + flame_len * 0.5) + cos_a * ex_side
      let fl_ez = cz - cos_a * (ex_back + flame_len * 0.5) - sin_a * ex_side
      @raylib.draw_sphere(
        @raylib.Vector3::new(fl_ex, ex_ly, fl_ez),
        0.12 + flicker * 0.04,
        @raylib.Color::new(flame_r, flame_g, flame_b, 210),
      )
      // Right exhaust flame
      let fr_ex = cx - sin_a * (ex_back + flame_len * 0.5) - cos_a * ex_side
      let fr_ez = cz - cos_a * (ex_back + flame_len * 0.5) + sin_a * ex_side
      @raylib.draw_sphere(
        @raylib.Vector3::new(fr_ex, ex_ly, fr_ez),
        0.12 + flicker * 0.04,
        @raylib.Color::new(flame_r, flame_g, flame_b, 210),
      )
      // Hot core
      @raylib.draw_sphere(
        @raylib.Vector3::new(fl_ex, ex_ly, fl_ez),
        0.06,
        @raylib.Color::new(255, 255, 220, 240),
      )
      @raylib.draw_sphere(
        @raylib.Vector3::new(fr_ex, ex_ly, fr_ez),
        0.06,
        @raylib.Color::new(255, 255, 220, 240),
      )
    }
    // --- Drift sparks at rear wheels ---
    if kart.drift_left || kart.drift_right {
      if game.frame_counter % 3 == 0 {
        let dc = @types.get_drift_spark_color(kart.drift_level)
        let spark_side : Float = if kart.drift_left { 1.0 } else { -1.0 }
        let sx = cx - sin_a * wz_rear + cos_a * spark_side * wx_off
        let sz = cz - cos_a * wz_rear - sin_a * spark_side * wx_off
        @raylib.draw_sphere(
          @raylib.Vector3::new(sx, base_y + 0.08, sz),
          0.13,
          @raylib.Color::new(dc.0, dc.1, dc.2, 255),
        )
      }
    }
    // --- Player kart highlight: small diamond marker above ---
    if kart.is_player {
      let marker_y = draw_y + kh * 1.2
      let marker_pulse = @math.sinf(time_f * 3.0) * 0.05
      let marker_size : Float = 0.12 + marker_pulse
      @raylib.draw_cube(
        @raylib.Vector3::new(cx, marker_y + 0.15, cz),
        marker_size,
        marker_size * 1.5,
        marker_size,
        @raylib.Color::new(255, 230, 50, 200),
      )
      @raylib.draw_cube(
        @raylib.Vector3::new(cx, marker_y + 0.15, cz),
        marker_size * 1.5,
        marker_size,
        marker_size * 1.5,
        @raylib.Color::new(255, 255, 150, 150),
      )
    }
    ignore(visual_angle)
  }
}

///|
fn @types.Game::draw_powerups(game : @types.Game) -> Unit {
  for i in 0..<game.powerups.length() {
    let pu = game.powerups[i]
    if !pu.active || pu.collected {
      continue
    }
    let bob = @math.sinf(
        Float::from_int(game.frame_counter) * 0.08 + Float::from_int(i),
      ) *
      0.3
    let py = pu.y + bob
    let spin = Float::from_int(game.frame_counter) * 0.05
    let size : Float = 0.5
    let color = match pu.kind {
      Boost => @raylib.Color::new(255, 200, 0, 220)
      Shield => @raylib.Color::new(80, 180, 255, 220)
      _ => @raylib.Color::new(255, 80, 60, 220)
    }
    // Rotating cube for powerup
    @raylib.draw_cube(
      @raylib.Vector3::new(pu.x, py, pu.z),
      size,
      size,
      size,
      color,
    )
    @raylib.draw_cube_wires(
      @raylib.Vector3::new(pu.x, py, pu.z),
      size + 0.05,
      size + 0.05,
      size + 0.05,
      @raylib.Color::new(255, 255, 255, 150),
    )
    // Question mark base
    @raylib.draw_cube(
      @raylib.Vector3::new(pu.x, pu.y - 0.5, pu.z),
      0.2,
      0.3,
      0.2,
      @raylib.Color::new(100, 100, 100, 200),
    )
    ignore(spin)
  }
}

///|
fn @types.Game::draw_projectiles(game : @types.Game) -> Unit {
  for proj in game.projectiles {
    if !proj.active {
      continue
    }
    @raylib.draw_sphere(
      @raylib.Vector3::new(proj.x, proj.y, proj.z),
      0.25,
      @raylib.Color::new(255, 80, 30, 255),
    )
    // Trail
    let trail_x = proj.x - @math.sinf(proj.angle) * 0.5
    let trail_z = proj.z - @math.cosf(proj.angle) * 0.5
    @raylib.draw_sphere(
      @raylib.Vector3::new(trail_x, proj.y, trail_z),
      0.15,
      @raylib.Color::new(255, 150, 50, 150),
    )
  }
}

///|
fn @types.Game::draw_particles_3d(game : @types.Game) -> Unit {
  for p in game.particles {
    if !p.active {
      continue
    }
    let alpha = (p.life / p.max_life * 255.0).to_int()
    let a = alpha.clamp(min=0, max=255)
    @raylib.draw_cube(
      @raylib.Vector3::new(p.x, p.y, p.z),
      p.size,
      p.size,
      p.size,
      @raylib.Color::new(p.r, p.g, p.b, a),
    )
  }
}

// Draw theme-specific track decorations using decoration data from levels

///|
fn @types.Game::draw_themed_decorations(game : @types.Game) -> Unit {
  let wc = game.waypoint_count
  if wc < 3 {
    return
  }
  let deco_data = @levels.get_track_decoration_data(
    game.current_cup,
    game.current_race,
  )
  for deco in deco_data {
    let deco_type = deco.0
    let x_offset = deco.1
    let z_progress = deco.2
    let scale = deco.3
    // Place decoration along each segment based on z_progress
    for si in 0..<wc {
      let wp0 = game.waypoints[si]
      let wp1 = game.waypoints[(si + 1) % wc]
      let dx = wp1.x - wp0.x
      let dz = wp1.z - wp0.z
      let dist = @types.distance2d(wp0.x, wp0.z, wp1.x, wp1.z)
      if dist < 0.01 {
        continue
      }
      // Only place decorations at matching segment progress
      let seg_match_f : Float = Float::from_int(si) / Float::from_int(wc)
      let diff = (seg_match_f - z_progress).abs()
      if diff > 0.15 && diff < 0.85 {
        continue
      }
      let px = -dz / dist
      let pz = dx / dist
      let deco_x = wp0.x + px * x_offset
      let deco_z = wp0.z + pz * x_offset
      let deco_y = wp0.y
      draw_decoration_object(deco_type, deco_x, deco_y, deco_z, scale, game)
    }
  }
}

// Helper to scale a float value

///|
fn sf(v : Float, s : Float) -> Float {
  v * s
}

// Draw a single decoration object based on type

///|
fn draw_decoration_object(
  deco_type : Int,
  x : Float,
  y : Float,
  z : Float,
  scale : Float,
  game : @types.Game,
) -> Unit {
  ignore(game)
  if deco_type == @types.deco_tree_green {
    let trunk_h : Float = sf(1.8, scale)
    let canopy_r : Float = sf(1.0, scale)
    let half_trunk : Float = trunk_h * 0.5
    let trunk_w : Float = sf(0.25, scale)
    let canopy_y : Float = y + trunk_h + canopy_r * 0.5
    @raylib.draw_cube(
      @raylib.Vector3::new(x, y + half_trunk, z),
      trunk_w,
      trunk_h,
      trunk_w,
      @raylib.Color::new(100, 70, 40, 255),
    )
    @raylib.draw_sphere(
      @raylib.Vector3::new(x, canopy_y, z),
      canopy_r,
      @raylib.Color::new(40, 130, 30, 255),
    )
  } else if deco_type == @types.deco_tree_pine {
    let trunk_h : Float = sf(2.0, scale)
    let trunk_w : Float = sf(0.2, scale)
    let half_trunk : Float = trunk_h * 0.5
    @raylib.draw_cube(
      @raylib.Vector3::new(x, y + half_trunk, z),
      trunk_w,
      trunk_h,
      trunk_w,
      @raylib.Color::new(80, 55, 30, 255),
    )
    let c1w : Float = sf(1.2, scale)
    let c1h : Float = sf(0.8, scale)
    @raylib.draw_cube(
      @raylib.Vector3::new(x, y + half_trunk, z),
      c1w,
      c1h,
      c1w,
      @raylib.Color::new(30, 90, 40, 255),
    )
    let c2w : Float = sf(0.9, scale)
    let c2h : Float = sf(0.7, scale)
    let c2y : Float = y + trunk_h * 0.8
    @raylib.draw_cube(
      @raylib.Vector3::new(x, c2y, z),
      c2w,
      c2h,
      c2w,
      @raylib.Color::new(35, 100, 45, 255),
    )
    let c3w : Float = sf(0.6, scale)
    let c3y : Float = y + trunk_h * 1.1
    @raylib.draw_cube(
      @raylib.Vector3::new(x, c3y, z),
      c3w,
      c3w,
      c3w,
      @raylib.Color::new(40, 110, 50, 255),
    )
  } else if deco_type == @types.deco_tree_palm {
    let trunk_h : Float = sf(2.5, scale)
    let trunk_w : Float = sf(0.2, scale)
    let half_trunk : Float = trunk_h * 0.5
    @raylib.draw_cube(
      @raylib.Vector3::new(x, y + half_trunk, z),
      trunk_w,
      trunk_h,
      trunk_w,
      @raylib.Color::new(130, 100, 50, 255),
    )
    let top_y : Float = y + trunk_h
    let frond_l : Float = sf(1.0, scale)
    let frond_h : Float = sf(0.1, scale)
    let frond_w : Float = sf(0.3, scale)
    let frond_off : Float = sf(0.5, scale)
    @raylib.draw_cube(
      @raylib.Vector3::new(x + frond_off, top_y, z),
      frond_l,
      frond_h,
      frond_w,
      @raylib.Color::new(50, 150, 40, 255),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(x - frond_off, top_y, z),
      frond_l,
      frond_h,
      frond_w,
      @raylib.Color::new(45, 140, 35, 255),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(x, top_y, z + frond_off),
      frond_w,
      frond_h,
      frond_l,
      @raylib.Color::new(55, 145, 42, 255),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(x, top_y, z - frond_off),
      frond_w,
      frond_h,
      frond_l,
      @raylib.Color::new(48, 135, 38, 255),
    )
  } else if deco_type == @types.deco_rock_small {
    let ry : Float = y + sf(0.25, scale)
    @raylib.draw_cube(
      @raylib.Vector3::new(x, ry, z),
      sf(0.6, scale),
      sf(0.5, scale),
      sf(0.5, scale),
      @raylib.Color::new(110, 105, 95, 255),
    )
  } else if deco_type == @types.deco_rock_large {
    let ry : Float = y + sf(0.5, scale)
    @raylib.draw_cube(
      @raylib.Vector3::new(x, ry, z),
      sf(1.2, scale),
      sf(1.0, scale),
      sf(1.0, scale),
      @raylib.Color::new(90, 85, 75, 255),
    )
    let ry2 : Float = y + sf(0.8, scale)
    @raylib.draw_cube(
      @raylib.Vector3::new(x + sf(0.3, scale), ry2, z - sf(0.2, scale)),
      sf(0.6, scale),
      sf(0.4, scale),
      sf(0.5, scale),
      @raylib.Color::new(100, 95, 85, 255),
    )
  } else if deco_type == @types.deco_barrier_metal {
    let bh_half : Float = @types.barrier_height * 0.5
    @raylib.draw_cube(
      @raylib.Vector3::new(x, y + bh_half, z),
      @types.barrier_width * scale,
      @types.barrier_height * scale,
      sf(2.0, scale),
      @raylib.Color::new(160, 160, 170, 255),
    )
  } else if deco_type == @types.deco_barrier_tire {
    let tw : Float = sf(0.4, scale)
    @raylib.draw_cube(
      @raylib.Vector3::new(x, y + 0.2, z),
      tw,
      tw,
      tw,
      @raylib.Color::new(30, 30, 30, 255),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(x, y + 0.6, z),
      tw,
      tw,
      tw,
      @raylib.Color::new(35, 35, 35, 255),
    )
  } else if deco_type == @types.deco_grandstand {
    let gw : Float = sf(3.0, scale)
    let gh : Float = sf(2.0, scale)
    let gh_half : Float = gh * 0.5
    let gd : Float = sf(1.5, scale)
    @raylib.draw_cube(
      @raylib.Vector3::new(x, y + gh_half, z),
      gw,
      gh,
      gd,
      @raylib.Color::new(180, 170, 150, 255),
    )
    let roof_y : Float = y + gh + sf(0.1, scale)
    let roof_w : Float = gw + sf(0.5, scale)
    @raylib.draw_cube(
      @raylib.Vector3::new(x, roof_y, z),
      roof_w,
      sf(0.2, scale),
      sf(2.0, scale),
      @raylib.Color::new(140, 40, 40, 255),
    )
    let seat_w : Float = gw * 0.9
    let seat_z : Float = z + sf(0.4, scale)
    @raylib.draw_cube(
      @raylib.Vector3::new(x, y + sf(0.3, scale), seat_z),
      seat_w,
      sf(0.15, scale),
      sf(0.3, scale),
      @raylib.Color::new(200, 60, 60, 255),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(x, y + sf(0.7, scale), seat_z),
      seat_w,
      sf(0.15, scale),
      sf(0.3, scale),
      @raylib.Color::new(60, 60, 200, 255),
    )
  } else if deco_type == @types.deco_building_small {
    let bw : Float = sf(2.0, scale)
    let bh : Float = sf(3.0, scale)
    let bh_half : Float = bh * 0.5
    @raylib.draw_cube(
      @raylib.Vector3::new(x, y + bh_half, z),
      bw,
      bh,
      bw,
      @raylib.Color::new(160, 150, 140, 255),
    )
    let win_w : Float = sf(0.3, scale)
    let win_h : Float = sf(0.4, scale)
    let win_d : Float = sf(0.05, scale)
    let bw_off : Float = bw * 0.3
    let bw_front : Float = z + bw * 0.51
    let win_y1 : Float = y + bh * 0.3
    let win_y2 : Float = y + bh * 0.65
    @raylib.draw_cube(
      @raylib.Vector3::new(x - bw_off, win_y1, bw_front),
      win_w,
      win_h,
      win_d,
      @raylib.Color::new(100, 150, 200, 200),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(x + bw_off, win_y1, bw_front),
      win_w,
      win_h,
      win_d,
      @raylib.Color::new(100, 150, 200, 200),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(x - bw_off, win_y2, bw_front),
      win_w,
      win_h,
      win_d,
      @raylib.Color::new(100, 150, 200, 200),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(x + bw_off, win_y2, bw_front),
      win_w,
      win_h,
      win_d,
      @raylib.Color::new(100, 150, 200, 200),
    )
  } else if deco_type == @types.deco_building_tall {
    let bw : Float = sf(2.5, scale)
    let bh : Float = sf(6.0, scale)
    let bh_half : Float = bh * 0.5
    @raylib.draw_cube(
      @raylib.Vector3::new(x, y + bh_half, z),
      bw,
      bh,
      bw,
      @raylib.Color::new(140, 140, 150, 255),
    )
    let bw_off : Float = bw * 0.25
    let bw_front : Float = z + bw * 0.51
    let win_w : Float = sf(0.25, scale)
    let win_h : Float = sf(0.35, scale)
    let win_d : Float = sf(0.05, scale)
    for wy in 0..<4 {
      let wy_f = Float::from_int(wy)
      let win_y : Float = y + sf(1.0, scale) + wy_f * sf(1.2, scale)
      @raylib.draw_cube(
        @raylib.Vector3::new(x - bw_off, win_y, bw_front),
        win_w,
        win_h,
        win_d,
        @raylib.Color::new(150, 200, 240, 200),
      )
      @raylib.draw_cube(
        @raylib.Vector3::new(x + bw_off, win_y, bw_front),
        win_w,
        win_h,
        win_d,
        @raylib.Color::new(150, 200, 240, 200),
      )
    }
  } else if deco_type == @types.deco_cactus {
    @raylib.draw_cube(
      @raylib.Vector3::new(x, y + sf(0.8, scale), z),
      sf(0.3, scale),
      sf(1.6, scale),
      sf(0.3, scale),
      @raylib.Color::new(60, 120, 40, 255),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(x + sf(0.4, scale), y + sf(1.0, scale), z),
      sf(0.5, scale),
      sf(0.2, scale),
      sf(0.2, scale),
      @raylib.Color::new(55, 115, 35, 255),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(x + sf(0.6, scale), y + sf(1.3, scale), z),
      sf(0.2, scale),
      sf(0.5, scale),
      sf(0.2, scale),
      @raylib.Color::new(55, 115, 35, 255),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(x - sf(0.35, scale), y + sf(0.7, scale), z),
      sf(0.4, scale),
      sf(0.2, scale),
      sf(0.2, scale),
      @raylib.Color::new(50, 110, 30, 255),
    )
  } else if deco_type == @types.deco_snow_mound {
    @raylib.draw_sphere(
      @raylib.Vector3::new(x, y + sf(0.3, scale), z),
      sf(0.8, scale),
      @raylib.Color::new(230, 235, 240, 255),
    )
    @raylib.draw_sphere(
      @raylib.Vector3::new(
        x + sf(0.3, scale),
        y + sf(0.2, scale),
        z + sf(0.2, scale),
      ),
      sf(0.5, scale),
      @raylib.Color::new(225, 230, 235, 255),
    )
  } else if deco_type == @types.deco_lava_rock {
    @raylib.draw_cube(
      @raylib.Vector3::new(x, y + sf(0.4, scale), z),
      sf(0.8, scale),
      sf(0.8, scale),
      sf(0.7, scale),
      @raylib.Color::new(100, 40, 20, 255),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(x, y + 0.1, z),
      sf(0.9, scale),
      0.05,
      sf(0.8, scale),
      @raylib.Color::new(255, 100, 20, 150),
    )
  } else if deco_type == @types.deco_lamp_post {
    @raylib.draw_cube(
      @raylib.Vector3::new(x, y + sf(1.5, scale), z),
      sf(0.1, scale),
      sf(3.0, scale),
      sf(0.1, scale),
      @raylib.Color::new(120, 120, 130, 255),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(x, y + sf(3.0, scale), z),
      sf(0.4, scale),
      sf(0.15, scale),
      sf(0.4, scale),
      @raylib.Color::new(200, 200, 150, 255),
    )
    @raylib.draw_sphere(
      @raylib.Vector3::new(x, y + sf(2.9, scale), z),
      sf(0.2, scale),
      @raylib.Color::new(255, 240, 180, 100),
    )
  } else if deco_type == @types.deco_sign_board {
    @raylib.draw_cube(
      @raylib.Vector3::new(x, y + 0.8, z),
      0.1,
      1.6,
      0.1,
      @raylib.Color::new(100, 100, 110, 255),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(x, y + 1.5, z),
      sf(1.0, scale),
      sf(0.6, scale),
      0.05,
      @raylib.Color::new(180, 180, 40, 255),
    )
  }
}

// Draw track surface visual differences (boost pads, dirt patches, ice patches)

///|
fn @types.Game::draw_surface_indicators(game : @types.Game) -> Unit {
  let wc = game.waypoint_count
  if wc < 2 {
    return
  }
  for i in 0..<wc {
    let seg = game.segments[i]
    let wp0 = game.waypoints[i]
    let wp1 = game.waypoints[(i + 1) % wc]
    let mx = (wp0.x + wp1.x) / 2.0
    let my = (wp0.y + wp1.y) / 2.0
    let mz = (wp0.z + wp1.z) / 2.0
    match seg.surface_type {
      BoostPad => {
        // Boost pad arrows
        let pulse = @math.sinf(Float::from_int(game.frame_counter) * 0.15)
        let alpha_f : Float = 150.0 + pulse * 50.0
        let alpha = alpha_f.to_int().clamp(min=100, max=200)
        @raylib.draw_cube(
          @raylib.Vector3::new(mx, my + 0.08, mz),
          @types.road_width * seg.width_mult * 0.8,
          0.06,
          3.0,
          @raylib.Color::new(255, 200, 0, alpha),
        )
        // Arrow chevrons
        @raylib.draw_cube(
          @raylib.Vector3::new(mx, my + 0.09, mz - 0.8),
          @types.road_width * seg.width_mult * 0.5,
          0.04,
          0.3,
          @raylib.Color::new(255, 255, 100, alpha),
        )
        @raylib.draw_cube(
          @raylib.Vector3::new(mx, my + 0.09, mz + 0.8),
          @types.road_width * seg.width_mult * 0.5,
          0.04,
          0.3,
          @raylib.Color::new(255, 255, 100, alpha),
        )
      }
      Dirt => {
        // Dirt patch texture
        @raylib.draw_cube(
          @raylib.Vector3::new(mx - 1.0, my + 0.02, mz + 0.5),
          1.5,
          0.01,
          1.2,
          @raylib.Color::new(140, 110, 70, 80),
        )
        @raylib.draw_cube(
          @raylib.Vector3::new(mx + 1.5, my + 0.02, mz - 0.3),
          1.0,
          0.01,
          0.8,
          @raylib.Color::new(150, 120, 75, 60),
        )
      }
      SurfaceIce => {
        // Ice shimmer
        let shimmer = @math.sinf(
          Float::from_int(game.frame_counter) * 0.1 + Float::from_int(i),
        )
        let ice_alpha_f : Float = 50.0 + shimmer * 20.0
        let ice_alpha = ice_alpha_f.to_int().clamp(min=30, max=80)
        @raylib.draw_cube(
          @raylib.Vector3::new(mx, my + 0.05, mz),
          @types.road_width * seg.width_mult,
          0.03,
          3.0,
          @raylib.Color::new(200, 220, 255, ice_alpha),
        )
      }
      _ => ()
    }
  }
}

// Draw skybox elements based on theme

///|
fn @types.Game::draw_skybox_elements(game : @types.Game) -> Unit {
  let theme = @levels.get_track_theme(game.current_cup, game.current_race)
  let sky_c = @levels.get_track_sky_color(game.current_cup, game.current_race)
  let grad_c = @levels.get_sky_gradient_color(
    game.current_cup,
    game.current_race,
  )
  // Horizon gradient band
  let player = game.karts[@types.player_kart]
  let horizon_y : Float = -5.0
  let horizon_dist : Float = 80.0
  // Draw distant horizon cubes around the player
  for h in 0..<8 {
    let angle_f = Float::from_int(h) * @types.two_pi / 8.0
    let hx = player.x + @math.sinf(angle_f) * horizon_dist
    let hz = player.z + @math.cosf(angle_f) * horizon_dist
    @raylib.draw_cube(
      @raylib.Vector3::new(hx, horizon_y, hz),
      30.0,
      10.0,
      30.0,
      @raylib.Color::new(grad_c.0, grad_c.1, grad_c.2, 80),
    )
  }
  // Theme-specific sky objects
  match theme {
    Night =>
      // Stars in the sky
      for s in 0..<12 {
        let sa = Float::from_int(s) * @types.two_pi / 12.0 +
          game.preview_rotation * 0.1
        let sr : Float = 50.0 + Float::from_int(s % 3) * 10.0
        let star_x = player.x + @math.sinf(sa) * sr
        let star_z = player.z + @math.cosf(sa) * sr
        let star_y : Float = 25.0 + Float::from_int(s % 4) * 5.0
        let twinkle = @math.sinf(
          Float::from_int(game.frame_counter) * 0.1 + Float::from_int(s),
        )
        let star_alpha_f : Float = 150.0 + twinkle * 80.0
        let star_alpha = star_alpha_f.to_int().clamp(min=80, max=230)
        @raylib.draw_sphere(
          @raylib.Vector3::new(star_x, star_y, star_z),
          0.15,
          @raylib.Color::new(255, 255, 230, star_alpha),
        )
      }
    Volcano =>
      // Smoke/ash in the air
      for s in 0..<6 {
        let sa = Float::from_int(s) * @types.two_pi / 6.0
        let sr : Float = 30.0 + Float::from_int(s) * 5.0
        let smoke_x = player.x + @math.sinf(sa) * sr
        let smoke_z = player.z + @math.cosf(sa) * sr
        let smoke_y : Float = 10.0 + Float::from_int(s % 3) * 3.0
        @raylib.draw_sphere(
          @raylib.Vector3::new(smoke_x, smoke_y, smoke_z),
          2.0,
          @raylib.Color::new(80, 60, 50, 40),
        )
      }
    _ => ()
  }
  ignore(sky_c)
}

// Draw kart detail pass: now handled by draw_karts. Kept as no-op for call site compatibility.

///|
fn @types.Game::draw_kart_details(game : @types.Game) -> Unit {
  ignore(game)
}

// Sky gradient background drawn before 3D mode

///|
fn draw_sky_gradient(game : @types.Game) -> Unit {
  let theme = @levels.get_track_theme(game.current_cup, game.current_race)
  // Per-theme sky gradient: top color -> bottom color
  let top : (Int, Int, Int) = match theme {
    Circuit => (70, 140, 230)
    Beach => (80, 160, 240)
    Mountain => (100, 130, 190)
    Castle => (60, 70, 110)
    Desert => (200, 150, 80)
    ThemeIce => (160, 190, 220)
    Night => (8, 10, 30)
    Volcano => (90, 40, 25)
  }
  let bot : (Int, Int, Int) = match theme {
    Circuit => (200, 220, 255)
    Beach => (220, 240, 255)
    Mountain => (200, 210, 235)
    Castle => (140, 150, 185)
    Desert => (240, 220, 180)
    ThemeIce => (220, 235, 250)
    Night => (20, 22, 50)
    Volcano => (180, 100, 50)
  }
  let w = @types.screen_width
  let h = @types.screen_height
  // Draw vertical gradient in bands for smooth look
  let bands = 8
  let band_h = h / bands
  for b in 0..<bands {
    let t0 = Float::from_int(b) / Float::from_int(bands)
    let t1 = Float::from_int(b + 1) / Float::from_int(bands)
    let r0 = @types.lerpf(Float::from_int(top.0), Float::from_int(bot.0), t0).to_int().clamp(min=0, max=255)
    let g0 = @types.lerpf(Float::from_int(top.1), Float::from_int(bot.1), t0).to_int().clamp(min=0, max=255)
    let b0 = @types.lerpf(Float::from_int(top.2), Float::from_int(bot.2), t0).to_int().clamp(min=0, max=255)
    let r1 = @types.lerpf(Float::from_int(top.0), Float::from_int(bot.0), t1).to_int().clamp(min=0, max=255)
    let g1 = @types.lerpf(Float::from_int(top.1), Float::from_int(bot.1), t1).to_int().clamp(min=0, max=255)
    let b1 = @types.lerpf(Float::from_int(top.2), Float::from_int(bot.2), t1).to_int().clamp(min=0, max=255)
    @raylib.draw_rectangle_gradient_v(
      0,
      b * band_h,
      w,
      band_h + 1,
      @raylib.Color::new(r0, g0, b0, 255),
      @raylib.Color::new(r1, g1, b1, 255),
    )
  }
}

// Blob shadows under each active kart

///|
fn @types.Game::draw_kart_blob_shadows(game : @types.Game) -> Unit {
  let shadow_color = @raylib.Color::new(0, 0, 0, 55)
  let shadow_segments = 12
  for i in 0..<@types.max_karts {
    let kart = game.karts[i]
    if !kart.active {
      continue
    }
    // Shadow ellipse on the ground plane just below the kart
    let sx = kart.x
    let sz = kart.z
    // Shadow y is just above the ground at the kart's position
    let sy : Float = kart.y + 0.03
    // Elongate shadow along kart direction
    let sin_a = @math.sinf(kart.angle)
    let cos_a = @math.cosf(kart.angle)
    let rx : Float = @types.kart_width * 0.9
    let rz : Float = @types.kart_length * 0.7
    // Draw shadow as a fan of triangles for an ellipse
    for seg in 0..<shadow_segments {
      let a0 = Float::from_int(seg) * @types.two_pi / Float::from_int(shadow_segments)
      let a1 = Float::from_int(seg + 1) * @types.two_pi / Float::from_int(shadow_segments)
      // Ellipse local coords
      let lx0 = @math.cosf(a0) * rx
      let lz0 = @math.sinf(a0) * rz
      let lx1 = @math.cosf(a1) * rx
      let lz1 = @math.sinf(a1) * rz
      // Rotate by kart angle into world coords
      let wx0 = sx + lx0 * cos_a - lz0 * sin_a
      let wz0 = sz + lx0 * sin_a + lz0 * cos_a
      let wx1 = sx + lx1 * cos_a - lz1 * sin_a
      let wz1 = sz + lx1 * sin_a + lz1 * cos_a
      @raylib.draw_triangle_3d(
        @raylib.Vector3::new(sx, sy, sz),
        @raylib.Vector3::new(wx0, sy, wz0),
        @raylib.Vector3::new(wx1, sy, wz1),
        shadow_color,
      )
    }
  }
}

// Glowing surface for boost pad segments

///|
fn @types.Game::draw_boost_pad_glow(game : @types.Game) -> Unit {
  let wc = game.waypoint_count
  if wc < 2 {
    return
  }
  let pulse = @math.sinf(Float::from_int(game.frame_counter) * 0.12)
  let glow_alpha_f : Float = 80.0 + pulse * 40.0
  let glow_alpha = glow_alpha_f.to_int().clamp(min=40, max=130)
  let glow_color = @raylib.Color::new(255, 220, 50, glow_alpha)
  for i in 0..<wc {
    let seg = game.segments[i]
    if seg.surface_type != BoostPad {
      continue
    }
    let next = (i + 1) % wc
    let wp0 = game.waypoints[i]
    let wp1 = game.waypoints[next]
    let dx = wp1.x - wp0.x
    let dz = wp1.z - wp0.z
    let dist = @types.distance2d(wp0.x, wp0.z, wp1.x, wp1.z)
    if dist < 0.01 {
      continue
    }
    let px = -dz / dist
    let pz = dx / dist
    let half_w : Float = @types.road_half * seg.width_mult * 0.85
    let glow_y : Float = (wp0.y + wp1.y) * 0.5 + 0.06
    // Draw glowing quad on the road surface
    let v0 = @raylib.Vector3::new(wp0.x - px * half_w, glow_y, wp0.z - pz * half_w)
    let v1 = @raylib.Vector3::new(wp0.x + px * half_w, glow_y, wp0.z + pz * half_w)
    let v2 = @raylib.Vector3::new(wp1.x + px * half_w, glow_y, wp1.z + pz * half_w)
    let v3 = @raylib.Vector3::new(wp1.x - px * half_w, glow_y, wp1.z - pz * half_w)
    @raylib.draw_triangle_3d(v0, v1, v2, glow_color)
    @raylib.draw_triangle_3d(v0, v2, v3, glow_color)
    // Arrow chevrons on boost pad
    let arrow_color = @raylib.Color::new(255, 255, 150, glow_alpha)
    let num_arrows = 3
    for ai in 0..<num_arrows {
      let at = (Float::from_int(ai) + 0.5) / Float::from_int(num_arrows)
      let ax = @types.lerpf(wp0.x, wp1.x, at)
      let az = @types.lerpf(wp0.z, wp1.z, at)
      let ay = @types.lerpf(wp0.y, wp1.y, at) + 0.08
      let arrow_hw : Float = half_w * 0.4
      let arrow_tip_x = ax + dx / dist * 0.6
      let arrow_tip_z = az + dz / dist * 0.6
      @raylib.draw_triangle_3d(
        @raylib.Vector3::new(ax - px * arrow_hw, ay, az - pz * arrow_hw),
        @raylib.Vector3::new(ax + px * arrow_hw, ay, az + pz * arrow_hw),
        @raylib.Vector3::new(arrow_tip_x, ay, arrow_tip_z),
        arrow_color,
      )
    }
  }
}

// Draw a subtle glow halo around uncollected item boxes

///|
fn @types.Game::draw_powerup_halos(game : @types.Game) -> Unit {
  let halo_segments = 10
  for i in 0..<game.powerups.length() {
    let pu = game.powerups[i]
    if !pu.active || pu.collected {
      continue
    }
    let bob = @math.sinf(
      Float::from_int(game.frame_counter) * 0.08 + Float::from_int(i),
    ) * 0.3
    let py = pu.y + bob
    let pulse = @math.sinf(
      Float::from_int(game.frame_counter) * 0.1 + Float::from_int(i) * 0.7,
    )
    let halo_r : Float = 0.7 + pulse * 0.1
    let halo_alpha_f : Float = 40.0 + pulse * 15.0
    let halo_alpha = halo_alpha_f.to_int().clamp(min=20, max=60)
    let halo_color = @raylib.Color::new(255, 220, 100, halo_alpha)
    // Draw halo as triangle fan on a horizontal plane
    for seg in 0..<halo_segments {
      let a0 = Float::from_int(seg) * @types.two_pi / Float::from_int(halo_segments)
      let a1 = Float::from_int(seg + 1) * @types.two_pi / Float::from_int(halo_segments)
      @raylib.draw_triangle_3d(
        @raylib.Vector3::new(pu.x, py, pu.z),
        @raylib.Vector3::new(
          pu.x + @math.cosf(a0) * halo_r,
          py,
          pu.z + @math.sinf(a0) * halo_r,
        ),
        @raylib.Vector3::new(
          pu.x + @math.cosf(a1) * halo_r,
          py,
          pu.z + @math.sinf(a1) * halo_r,
        ),
        halo_color,
      )
    }
  }
}
