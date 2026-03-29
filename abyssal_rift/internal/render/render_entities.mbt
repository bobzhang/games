///|
pub fn draw_player(game : @types.Game) -> Unit {
  let p = game.player
  if p.dead {
    return
  }
  // Flash during invulnerability
  if p.invuln_timer > 0.0 && game.frame_count % 6 < 3 {
    return
  }
  let px = p.x.to_int()
  let py = p.y.to_int()
  // Shield ring
  if p.shield > 0.0 {
    let shield_ratio = p.shield / p.max_shield
    @raylib.draw_circle_lines_v(
      @raylib.Vector2::new(p.x, p.y),
      @types.player_radius + 4.0,
      @raylib.Color::new(80, 160, 255, (shield_ratio * 120.0).to_int()),
    )
  }
  // Body circle
  @raylib.draw_circle(px, py, @types.player_radius, @types.color_player)
  // Inner circle
  @raylib.draw_circle(px, py, @types.player_radius - 4.0, @raylib.Color::new(130, 220, 255, 255))
  // Direction indicator (triangle pointing in facing direction)
  let fx = p.facing_x
  let fy = p.facing_y
  let tip_x = p.x + fx * (@types.player_radius + 8.0)
  let tip_y = p.y + fy * (@types.player_radius + 8.0)
  let base1_x = p.x + fx * @types.player_radius - fy * 5.0
  let base1_y = p.y + fy * @types.player_radius + fx * 5.0
  let base2_x = p.x + fx * @types.player_radius + fy * 5.0
  let base2_y = p.y + fy * @types.player_radius - fx * 5.0
  @raylib.draw_triangle(
    @raylib.Vector2::new(tip_x, tip_y),
    @raylib.Vector2::new(base1_x, base1_y),
    @raylib.Vector2::new(base2_x, base2_y),
    @raylib.white,
  )
  // Weapon attack visual
  draw_weapon_swing(game)
}

///|
fn draw_weapon_swing(game : @types.Game) -> Unit {
  let p = game.player
  match p.attack_state {
    Active(_) => {
      let stats = @data.get_weapon_stats(p.weapon)
      if !stats.is_ranged {
        // Draw arc
        let range = stats.range
        let arc = stats.arc_angle
        let fx = p.facing_x
        let fy = p.facing_y
        // Simple arc visualization: draw a few lines
        let steps = 5
        let half_arc_rad = arc / 2.0 / 180.0 * 3.14159
        for i in 0..=steps {
          let frac = Float::from_int(i) / Float::from_int(steps)
          let angle = -half_arc_rad + frac * 2.0 * half_arc_rad
          let cos_a = Float::from_double(@math.cos(angle.to_double()))
          let sin_a = Float::from_double(@math.sin(angle.to_double()))
          let dir_x = fx * cos_a - fy * sin_a
          let dir_y = fx * sin_a + fy * cos_a
          let end_x = p.x + dir_x * range
          let end_y = p.y + dir_y * range
          @raylib.draw_line_ex(
            @raylib.Vector2::new(p.x, p.y),
            @raylib.Vector2::new(end_x, end_y),
            2.0,
            @raylib.Color::new(255, 255, 255, 120),
          )
        }
      }
    }
    _ => ()
  }
}

///|
pub fn draw_enemies(game : @types.Game) -> Unit {
  for i in 0..<game.enemies.length() {
    let e = game.enemies[i]
    if !e.active {
      continue
    }
    let stats = @data.get_enemy_stats(e.kind, game.floor_num)
    let r = stats.radius
    let ex = e.x.to_int()
    let ey = e.y.to_int()
    // Flash white on hit
    let base_color = if e.flash_timer > 0.0 {
      @raylib.white
    } else {
      get_enemy_color(e.kind)
    }
    // Death fade
    match e.state {
      Dead(t) => {
        let alpha = (t / 0.5 * 255.0).to_int()
        let fade = @raylib.Color::new(base_color.r.to_int(), base_color.g.to_int(), base_color.b.to_int(), @types.clampi(alpha, 0, 255))
        draw_enemy_shape(e.kind, ex, ey, r, fade)
        continue
      }
      _ => ()
    }
    draw_enemy_shape(e.kind, ex, ey, r, base_color)
    // Health bar
    if e.hp < e.max_hp {
      let bar_w = r * 2.0
      let bar_h = 3.0
      let bar_x = e.x - r
      let bar_y = e.y - r - 8.0
      let hp_ratio = Float::from_int(e.hp) / Float::from_int(e.max_hp)
      @raylib.draw_rectangle(
        bar_x.to_int(), bar_y.to_int(),
        bar_w.to_int(), bar_h.to_int(),
        @raylib.Color::new(60, 20, 20, 200),
      )
      @raylib.draw_rectangle(
        bar_x.to_int(), bar_y.to_int(),
        (bar_w * hp_ratio).to_int(), bar_h.to_int(),
        @types.color_health,
      )
    }
  }
}

///|
fn get_enemy_color(kind : @types.EnemyKind) -> @raylib.Color {
  match kind {
    Slime => @raylib.Color::new(80, 200, 80, 255)
    SlimeSmall => @raylib.Color::new(100, 220, 100, 255)
    Skeleton => @raylib.Color::new(200, 200, 180, 255)
    Archer => @raylib.Color::new(180, 130, 80, 255)
    Bat => @raylib.Color::new(150, 80, 180, 255)
    Spider => @raylib.Color::new(100, 80, 60, 255)
    Golem => @raylib.Color::new(140, 140, 160, 255)
  }
}

///|
fn draw_enemy_shape(
  kind : @types.EnemyKind,
  x : Int,
  y : Int,
  r : Float,
  color : @raylib.Color
) -> Unit {
  match kind {
    Slime | SlimeSmall =>
      // Circle
      @raylib.draw_circle(x, y, r, color)
    Skeleton =>
      // Diamond
      @raylib.draw_poly(
        @raylib.Vector2::new(Float::from_int(x), Float::from_int(y)),
        4, r, 45.0, color,
      )
    Archer =>
      // Triangle
      @raylib.draw_poly(
        @raylib.Vector2::new(Float::from_int(x), Float::from_int(y)),
        3, r, 0.0, color,
      )
    Bat =>
      // Small fast circle
      @raylib.draw_circle(x, y, r, color)
    Spider =>
      // Hexagon
      @raylib.draw_poly(
        @raylib.Vector2::new(Float::from_int(x), Float::from_int(y)),
        6, r, 0.0, color,
      )
    Golem =>
      // Large square
      @raylib.draw_rectangle(
        x - r.to_int(), y - r.to_int(),
        (r * 2.0).to_int(), (r * 2.0).to_int(), color,
      )
  }
}

///|
pub fn draw_projectiles(game : @types.Game) -> Unit {
  for i in 0..<game.projectiles.length() {
    let proj = game.projectiles[i]
    if !proj.active {
      continue
    }
    let color = if proj.is_player {
      if proj.is_crit {
        @types.color_crit
      } else {
        @raylib.Color::new(200, 230, 255, 255)
      }
    } else {
      @raylib.Color::new(255, 100, 80, 255)
    }
    @raylib.draw_circle(proj.x.to_int(), proj.y.to_int(), proj.radius, color)
    // Trail
    let trail_color = @raylib.Color::new(color.r.to_int(), color.g.to_int(), color.b.to_int(), 80)
    @raylib.draw_circle(
      (proj.x - proj.vx * 0.02).to_int(),
      (proj.y - proj.vy * 0.02).to_int(),
      proj.radius * 0.7, trail_color,
    )
  }
}

///|
pub fn draw_items(game : @types.Game) -> Unit {
  for i in 0..<game.items.length() {
    let item = game.items[i]
    if !item.active {
      continue
    }
    let bob = Float::from_double(@math.sin((item.bob_timer * 3.0).to_double())) * 3.0
    let ix = item.x.to_int()
    let iy = (item.y + bob).to_int()
    match item.kind {
      Gold(_) => {
        @raylib.draw_circle(ix, iy, 5.0, @types.color_gold_text)
        @raylib.draw_circle(ix, iy, 3.0, @raylib.Color::new(255, 240, 100, 255))
      }
      HealthPotion =>
        @raylib.draw_circle(ix, iy, 7.0, @raylib.Color::new(255, 50, 80, 255))
      WeaponPickup(_) =>
        @raylib.draw_rectangle(ix - 6, iy - 6, 12, 12, @raylib.Color::new(200, 200, 255, 255))
      PassiveItem(_) =>
        @raylib.draw_poly(
          @raylib.Vector2::new(item.x, item.y + bob),
          5, 8.0, 0.0, @raylib.Color::new(200, 100, 255, 255),
        )
    }
  }
}

///|
pub fn draw_stairs(game : @types.Game) -> Unit {
  if game.stairs_active {
    let sx = game.stairs_x.to_int()
    let sy = game.stairs_y.to_int()
    // Pulsing diamond
    let pulse = Float::from_double(
        @math.sin(Float::from_int(game.frame_count).to_double() * 0.08),
      ) *
      3.0 +
      12.0
    @raylib.draw_poly(
      @raylib.Vector2::new(game.stairs_x, game.stairs_y),
      4,
      pulse,
      45.0,
      @raylib.Color::new(255, 215, 0, 200),
    )
    // Inner glow
    @raylib.draw_poly(
      @raylib.Vector2::new(game.stairs_x, game.stairs_y),
      4,
      pulse * 0.6,
      45.0,
      @raylib.Color::new(255, 240, 150, 150),
    )
    // Label
    let text = "STAIRS"
    let tw = @raylib.measure_text(text, 12)
    @raylib.draw_text(
      text,
      sx - tw / 2,
      sy - 25,
      12,
      @raylib.Color::new(255, 215, 0, 180),
    )
  }
}
