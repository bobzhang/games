///|
fn draw_shadow(x : Float, y : Float, radius : Float) -> Unit {
  @raylib.draw_ellipse(
    x.to_int(),
    (y + radius * 0.6).to_int(),
    radius * 0.8,
    radius * 0.3,
    @raylib.Color::new(0, 0, 0, 40),
  )
}

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
  // Low-HP heartbeat pulse
  let hp_ratio = Float::from_int(p.hp) / Float::from_int(p.max_hp)
  let pulse = if hp_ratio < 0.25 {
    Float::from_double(@math.sin(game.frame_count.to_double() * 0.15)) *
      2.0
  } else {
    0.0
  }
  let draw_radius = @types.player_radius + pulse
  // Shadow
  draw_shadow(p.x, p.y, draw_radius)
  // Shield ring
  if p.shield > 0.0 {
    let shield_ratio = p.shield / p.max_shield
    @raylib.draw_circle_lines_v(
      @raylib.Vector2::new(p.x, p.y),
      draw_radius + 4.0,
      @raylib.Color::new(80, 160, 255, (shield_ratio * 120.0).to_int()),
    )
  }
  // Body circle
  @raylib.draw_circle(px, py, draw_radius, @types.color_player)
  // Inner circle
  @raylib.draw_circle(px, py, draw_radius - 4.0, @raylib.Color::new(130, 220, 255, 255))
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
  // Weapon accent near direction indicator
  let wstats = @data.get_weapon_stats(p.weapon)
  let accent_color = if wstats.is_ranged {
    @raylib.Color::new(120, 200, 255, 180)
  } else {
    @raylib.Color::new(255, 220, 150, 180)
  }
  let accent_len : Float = if wstats.is_ranged { 6.0 } else { 10.0 }
  let accent_base_x = p.x + fx * (@types.player_radius + 10.0)
  let accent_base_y = p.y + fy * (@types.player_radius + 10.0)
  let accent_tip_x = accent_base_x + fx * accent_len
  let accent_tip_y = accent_base_y + fy * accent_len
  @raylib.draw_line_ex(
    @raylib.Vector2::new(accent_base_x, accent_base_y),
    @raylib.Vector2::new(accent_tip_x, accent_tip_y),
    2.0,
    accent_color,
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
        // Draw filled arc sector for melee swing
        let range = stats.range
        let arc = stats.arc_angle
        let base_angle = Float::from_double(
          @math.atan2(p.facing_y.to_double(), p.facing_x.to_double()),
        ) *
          180.0 /
          3.14159
        let start_deg = base_angle - arc / 2.0
        let end_deg = base_angle + arc / 2.0
        // Filled semi-transparent sector
        @raylib.draw_circle_sector(
          @raylib.Vector2::new(p.x, p.y),
          range,
          start_deg,
          end_deg,
          8,
          @raylib.Color::new(255, 255, 255, 50),
        )
        // Brighter edge lines for definition
        let half_arc_rad = arc / 2.0 / 180.0 * 3.14159
        let fx = p.facing_x
        let fy = p.facing_y
        for i in [0, 5] {
          let frac = Float::from_int(i) / 5.0
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
        // Fading trail at 80% range
        @raylib.draw_circle_sector(
          @raylib.Vector2::new(p.x, p.y),
          range * 0.8,
          start_deg,
          end_deg,
          8,
          @raylib.Color::new(255, 255, 255, 25),
        )
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
    // Elites are 1.3x size
    let r : Float = if e.is_elite { stats.radius * 1.3 } else { stats.radius }
    let ex = e.x.to_int()
    let ey = e.y.to_int()
    // Flash white on hit
    let base_color = if e.flash_timer > 0.0 {
      @raylib.white
    } else {
      get_enemy_color(e.kind)
    }
    // Shadow
    draw_shadow(e.x, e.y, r)
    // Death fade with shrink
    match e.state {
      Dead(t) => {
        let alpha = (t / 0.5 * 255.0).to_int()
        let death_progress : Float = (1.0 : Float) - t / (0.5 : Float)
        let shrink : Float = (1.0 : Float) - death_progress * (0.5 : Float)
        let draw_r = r * shrink
        let fade = @raylib.Color::new(base_color.r.to_int(), base_color.g.to_int(), base_color.b.to_int(), @types.clampi(alpha, 0, 255))
        draw_enemy_shape(e.kind, ex, ey, draw_r, fade)
        continue
      }
      _ => ()
    }
    // Elite: draw pulsing colored ring
    if e.is_elite {
      let affix_color = get_affix_color(e.affix)
      let pulse = Float::from_double(
        @math.sin((e.phase * 4.0).to_double()),
      ) * 3.0 + 4.0
      @raylib.draw_circle_lines_v(
        @raylib.Vector2::new(e.x, e.y),
        r + pulse,
        affix_color,
      )
      @raylib.draw_circle_lines_v(
        @raylib.Vector2::new(e.x, e.y),
        r + pulse + 1.0,
        @raylib.Color::new(
          affix_color.r.to_int(),
          affix_color.g.to_int(),
          affix_color.b.to_int(),
          120,
        ),
      )
    }
    draw_enemy_shape(e.kind, ex, ey, r, base_color)
    // Outline
    @raylib.draw_circle_lines_v(
      @raylib.Vector2::new(Float::from_int(ex), Float::from_int(ey)),
      r + 1.0,
      @raylib.Color::new(255, 255, 255, 30),
    )
    // Health bar
    if e.hp < e.max_hp {
      let bar_w = r * 2.0
      let bar_h : Float = if e.is_elite { 4.0 } else { 3.0 }
      let bar_x = e.x - r
      let bar_y = e.y - r - 8.0
      let hp_ratio = Float::from_int(e.hp) / Float::from_int(e.max_hp)
      @raylib.draw_rectangle(
        bar_x.to_int(), bar_y.to_int(),
        bar_w.to_int(), bar_h.to_int(),
        @raylib.Color::new(60, 20, 20, 200),
      )
      let hp_color = if e.is_elite {
        @raylib.Color::new(255, 180, 50, 255)
      } else {
        @types.color_health
      }
      @raylib.draw_rectangle(
        bar_x.to_int(), bar_y.to_int(),
        (bar_w * hp_ratio).to_int(), bar_h.to_int(),
        hp_color,
      )
    }
    // Elite: draw affix name above health bar
    if e.is_elite {
      let affix_name = get_affix_name(e.affix)
      let affix_color = get_affix_color(e.affix)
      let tw = @raylib.measure_text(affix_name, 10)
      @raylib.draw_text(
        affix_name,
        ex - tw / 2,
        (e.y - r - 18.0).to_int(),
        10,
        affix_color,
      )
    }
  }
}

///|
fn get_affix_color(affix : @types.EliteAffix) -> @raylib.Color {
  match affix {
    Fast => @raylib.Color::new(255, 255, 80, 255)
    Armored => @raylib.Color::new(160, 160, 180, 255)
    Splitting => @raylib.Color::new(80, 255, 80, 255)
    Vampiric => @raylib.Color::new(255, 50, 80, 255)
    Explosive => @raylib.Color::new(255, 150, 30, 255)
    None => @raylib.white
  }
}

///|
fn get_affix_name(affix : @types.EliteAffix) -> String {
  match affix {
    Fast => "FAST"
    Armored => "ARMORED"
    Splitting => "SPLITTING"
    Vampiric => "VAMPIRIC"
    Explosive => "EXPLOSIVE"
    None => ""
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
    BroodMother => @raylib.Color::new(120, 70, 40, 255)
    LichKing => @raylib.Color::new(140, 60, 200, 255)
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
    BroodMother =>
      // Large octagon
      @raylib.draw_poly(
        @raylib.Vector2::new(Float::from_int(x), Float::from_int(y)),
        8, r, 0.0, color,
      )
    LichKing => {
      // Large diamond with inner glow
      @raylib.draw_poly(
        @raylib.Vector2::new(Float::from_int(x), Float::from_int(y)),
        4, r, 45.0, color,
      )
      @raylib.draw_poly(
        @raylib.Vector2::new(Float::from_int(x), Float::from_int(y)),
        4, r * 0.6, 45.0, @raylib.Color::new(200, 120, 255, 180),
      )
    }
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
pub fn draw_shop_items(game : @types.Game) -> Unit {
  if !game.shop_active {
    return
  }
  for i in 0..<game.shop_items.length() {
    let shop = game.shop_items[i]
    if !shop.active {
      continue
    }
    let sx = shop.x.to_int()
    let sy = shop.y.to_int()
    // Draw pedestal
    @raylib.draw_rectangle(
      sx - 16, sy - 4, 32, 8,
      @raylib.Color::new(80, 70, 90, 200),
    )
    // Draw item
    let bob = Float::from_double(@math.sin(
      (Float::from_int(game.frame_count) * 0.04 + Float::from_int(i) * 2.0).to_double(),
    )) * 3.0
    let iy = (shop.y - 20.0 + bob).to_int()
    match shop.kind {
      HealthPotion =>
        @raylib.draw_circle(sx, iy, 8.0, @raylib.Color::new(255, 50, 80, 255))
      WeaponPickup(_) =>
        @raylib.draw_rectangle(sx - 7, iy - 7, 14, 14, @raylib.Color::new(200, 200, 255, 255))
      PassiveItem(_) =>
        @raylib.draw_poly(
          @raylib.Vector2::new(shop.x, Float::from_int(iy)),
          5, 9.0, 0.0, @raylib.Color::new(200, 100, 255, 255),
        )
      Gold(_) =>
        @raylib.draw_circle(sx, iy, 6.0, @types.color_gold_text)
    }
    // Draw price tag
    let price_text = "\{shop.price}g"
    let tw = @raylib.measure_text(price_text, 12)
    @raylib.draw_text(
      price_text,
      sx - tw / 2,
      sy + 8,
      12,
      @types.color_gold_text,
    )
    // Draw item name
    let name = shop_item_name(shop.kind)
    let nw = @raylib.measure_text(name, 10)
    @raylib.draw_text(
      name,
      sx - nw / 2,
      sy - 38 + bob.to_int(),
      10,
      @raylib.Color::new(220, 220, 240, 200),
    )
    // Highlight if player is near
    let d2 = @types.dist2(game.player.x, game.player.y, shop.x, shop.y)
    if d2 < 60.0 * 60.0 {
      @raylib.draw_circle_lines_v(
        @raylib.Vector2::new(shop.x, shop.y - 20.0 + bob),
        14.0,
        @raylib.Color::new(255, 255, 100, 150),
      )
      let hint = "[E] Buy"
      let hw = @raylib.measure_text(hint, 10)
      @raylib.draw_text(
        hint,
        sx - hw / 2,
        sy + 22,
        10,
        @raylib.Color::new(255, 255, 200, 200),
      )
    }
  }
}

///|
fn shop_item_name(kind : @types.ItemKind) -> String {
  match kind {
    HealthPotion => "Health Potion"
    WeaponPickup(wk) => {
      let stats = @data.get_weapon_stats(wk)
      stats.name
    }
    PassiveItem(pk) => {
      let stats = @data.get_passive_stats(pk)
      stats.name
    }
    Gold(amount) => "\{amount} Gold"
  }
}

///|
pub fn draw_reward_choices(game : @types.Game) -> Unit {
  if !game.reward_active {
    return
  }
  for i in 0..<game.reward_choices.length() {
    let choice = game.reward_choices[i]
    let cx = choice.x.to_int()
    let cy = choice.y.to_int()
    // Pedestal
    @raylib.draw_rectangle(
      cx - 25, cy + 10, 50, 8,
      @raylib.Color::new(80, 80, 100, 200),
    )
    // Glow
    let pulse = Float::from_double(
        @math.sin(
          game.frame_count.to_double() * 0.06 +
            Float::from_int(i).to_double() * 2.0,
        ),
      ) *
      20.0 +
      40.0
    @raylib.draw_circle(cx, cy, pulse, @raylib.Color::new(255, 215, 0, 20))
    // Item icon
    match choice.kind {
      WeaponPickup(_) =>
        @raylib.draw_rectangle(
          cx - 8, cy - 8, 16, 16,
          @raylib.Color::new(200, 200, 255, 230),
        )
      PassiveItem(_) =>
        @raylib.draw_poly(
          @raylib.Vector2::new(choice.x, choice.y),
          5, 12.0, 0.0,
          @raylib.Color::new(200, 100, 255, 230),
        )
      HealthPotion =>
        @raylib.draw_circle(
          cx, cy, 10.0,
          @raylib.Color::new(255, 80, 80, 230),
        )
      _ =>
        @raylib.draw_circle(
          cx, cy, 8.0,
          @raylib.Color::new(255, 215, 0, 230),
        )
    }
    // Description below
    let tw = @raylib.measure_text(choice.description, 12)
    @raylib.draw_text(
      choice.description,
      cx - tw / 2, cy + 22, 12,
      @raylib.Color::new(220, 220, 220, 200),
    )
    // Proximity hint
    let d2 = @types.dist2(game.player.x, game.player.y, choice.x, choice.y)
    if d2 < 50.0 * 50.0 {
      let hint = "[E] Choose"
      let hw = @raylib.measure_text(hint, 14)
      @raylib.draw_text(
        hint,
        cx - hw / 2, cy - 30, 14,
        @raylib.Color::new(255, 215, 0, 255),
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
