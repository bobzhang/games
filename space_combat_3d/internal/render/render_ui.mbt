// 2D UI overlay

///|
/// Draws the 2D UI overlay for the current game state.
pub fn draw_ui(game : @types.Game) -> Unit {
  match game.state {
    StateMenu => game.draw_menu()
    StatePlaying => {
      game.draw_hud()
      game.draw_crosshair()
      if game.message_timer > 0.0 {
        game.draw_message()
      }
    }
    StatePaused => {
      game.draw_hud()
      game.draw_pause_overlay()
    }
    StateMissionComplete => {
      game.draw_hud()
      game.draw_mission_complete()
    }
    StateGameOver => game.draw_game_over()
    StateMissionBriefing => game.draw_mission_briefing()
    StateMissionSelect => game.draw_mission_select()
    StateLoadout => game.draw_loadout()
  }
}

///|
fn @types.Game::draw_menu(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(2, 2, 8, 255),
  )

  // Starfield effect on menu
  let frame_f = Float::from_int(game.frame_counter)
  for i in 0..<60 {
    let fi = Float::from_int(i)
    let sx = ((@math.sinf(fi * 3.7 + frame_f * 0.01) + 1.0) *
    0.5 *
    Float::from_int(@types.screen_width)).to_int()
    let sy = ((@math.cosf(fi * 2.1 + frame_f * 0.008) + 1.0) *
    0.5 *
    Float::from_int(@types.screen_height)).to_int()
    let bright = 80 + (fi * 2.5).to_int()
    @raylib.draw_rectangle(
      sx,
      sy,
      2,
      2,
      @raylib.Color::new(bright, bright, bright, 200),
    )
    ignore(i)
  }

  let title = "SPACE COMBAT 3D"
  let tw = @draw.measure_text(title, 52)
  @draw.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    120,
    52,
    @raylib.Color::new(100, 180, 255, 255),
  )

  let sub = "Dogfighting in the void"
  let sw = @draw.measure_text(sub, 20)
  @draw.draw_text(
    sub,
    (@types.screen_width - sw) / 2,
    185,
    20,
    @raylib.Color::new(80, 130, 200, 255),
  )

  let items : Array[String] = [
    "New Game", "Mission Select", "Continue", "Quick Start",
  ]
  for i in 0..<items.length() {
    let y = 300 + i * 50
    let is_sel = game.menu_cursor == i
    let blink = @math.sinf(game.menu_blink * 2.0)
    let color = if is_sel {
      if blink > 0.0 {
        @raylib.Color::new(255, 255, 100, 255)
      } else {
        @raylib.Color::new(200, 200, 80, 255)
      }
    } else {
      @raylib.Color::new(150, 150, 170, 255)
    }
    let prefix = if is_sel { "> " } else { "  " }
    let text = prefix + items[i]
    let full_w = @draw.measure_text(text, 28)
    @draw.draw_text(text, (@types.screen_width - full_w) / 2, y, 28, color)
  }

  @draw.draw_text(
    "Arrows: Select | Enter: Play",
    (
      @types.screen_width -
      @draw.measure_text("Arrows: Select | Enter: Play", 16)
    ) /
    2,
    @types.screen_height - 60,
    16,
    @raylib.Color::new(80, 100, 120, 255),
  )
  @draw.draw_text(
    "WASD: Fly | QE: Roll | Space: Fire | Tab: Target | 1-3: Weapons",
    (
      @types.screen_width -
      @draw.measure_text(
        "WASD: Fly | QE: Roll | Space: Fire | Tab: Target | 1-3: Weapons", 14,
      )
    ) /
    2,
    @types.screen_height - 35,
    14,
    @raylib.Color::new(60, 80, 100, 255),
  )
}

///|
fn @types.Game::draw_hud(game : @types.Game) -> Unit {
  let p = game.player

  // Top bar
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    36,
    @raylib.Color::new(0, 0, 0, 160),
  )
  @draw.draw_text(
    "Mission \{game.current_mission + 1}: \{@levels.mission_name(game.current_mission)}",
    10,
    8,
    20,
    @raylib.Color::new(200, 220, 255, 255),
  )
  @draw.draw_text(
    "Score: \{game.score}",
    @types.screen_width - 150,
    8,
    20,
    @raylib.Color::new(255, 255, 200, 255),
  )
  @draw.draw_text(
    "Enemies: \{game.enemies_remaining}",
    @types.screen_width / 2 - 50,
    8,
    20,
    @raylib.Color::new(255, 150, 100, 255),
  )

  // Survive timer (shown below top bar for survive missions)
  if game.survive_total > 0.0 && game.survive_timer > 0.0 {
    let secs = game.survive_timer.to_int()
    let timer_color = if secs > 30 {
      @raylib.Color::new(100, 255, 100, 255)
    } else if secs > 10 {
      @raylib.Color::new(255, 255, 100, 255)
    } else {
      @raylib.Color::new(255, 80, 80, 255)
    }
    let timer_text = "SURVIVE: \{secs}s"
    let timer_w = @draw.measure_text(timer_text, 24)
    @draw.draw_text(
      timer_text,
      (@types.screen_width - timer_w) / 2,
      42,
      24,
      timer_color,
    )
  }

  // Patrol waypoint indicator
  if game.patrol_total > 0 && game.patrol_current < game.patrol_total {
    let wp_num = game.patrol_current + 1
    let wp_total = game.patrol_total
    let wp_text = "WAYPOINT \{wp_num}/\{wp_total}"
    let wp_dist = @types.distance3d(
      game.player.x,
      game.player.y,
      game.player.z,
      game.patrol_waypoints_x[game.patrol_current],
      game.patrol_waypoints_y[game.patrol_current],
      game.patrol_waypoints_z[game.patrol_current],
    )
    let dist_i = wp_dist.to_int()
    let full_wp = "\{wp_text} - \{dist_i}m"
    let wp_w = @draw.measure_text(full_wp, 20)
    @draw.draw_text(
      full_wp,
      (@types.screen_width - wp_w) / 2,
      42,
      20,
      @raylib.Color::new(100, 200, 255, 255),
    )
  } else if game.patrol_total > 0 && game.patrol_current >= game.patrol_total {
    let done_text = "ALL WAYPOINTS REACHED"
    let done_w = @draw.measure_text(done_text, 20)
    @draw.draw_text(
      done_text,
      (@types.screen_width - done_w) / 2,
      42,
      20,
      @raylib.Color::new(100, 255, 100, 255),
    )
  }

  // Hull bar (bottom left)
  let bar_x = 10
  let bar_y = @types.screen_height - 80
  let bar_w = 200
  let bar_h = 16
  @raylib.draw_rectangle(
    bar_x,
    bar_y,
    bar_w,
    bar_h,
    @raylib.Color::new(40, 0, 0, 200),
  )
  let hull_w = (p.hull / p.max_hull * Float::from_int(bar_w)).to_int()
  let hull_color = if p.hull > 50.0 {
    @raylib.Color::new(0, 200, 0, 255)
  } else if p.hull > 25.0 {
    @raylib.Color::new(200, 200, 0, 255)
  } else {
    @raylib.Color::new(200, 0, 0, 255)
  }
  @raylib.draw_rectangle(bar_x, bar_y, hull_w, bar_h, hull_color)
  @raylib.draw_rectangle_lines(
    bar_x,
    bar_y,
    bar_w,
    bar_h,
    @raylib.Color::new(150, 150, 150, 200),
  )
  let hull_pct = (p.hull / p.max_hull * 100.0).to_int()
  @draw.draw_text(
    "HULL \{hull_pct}%",
    bar_x,
    bar_y - 16,
    14,
    @raylib.Color::new(200, 200, 200, 255),
  )

  // Shield bar
  let shield_y = @types.screen_height - 55
  @raylib.draw_rectangle(
    bar_x,
    shield_y,
    bar_w,
    bar_h,
    @raylib.Color::new(0, 0, 40, 200),
  )
  let shield_w = (p.shield / p.max_shield * Float::from_int(bar_w)).to_int()
  @raylib.draw_rectangle(
    bar_x,
    shield_y,
    shield_w,
    bar_h,
    @raylib.Color::new(80, 140, 255, 255),
  )
  @raylib.draw_rectangle_lines(
    bar_x,
    shield_y,
    bar_w,
    bar_h,
    @raylib.Color::new(100, 120, 180, 200),
  )
  @draw.draw_text(
    "SHIELD",
    bar_x,
    shield_y - 16,
    14,
    @raylib.Color::new(100, 150, 255, 255),
  )

  // Weapon energy bar
  let energy_y = @types.screen_height - 30
  @raylib.draw_rectangle(
    bar_x,
    energy_y,
    bar_w,
    10,
    @raylib.Color::new(20, 20, 0, 200),
  )
  let energy_fill = (p.weapon_energy /
  @types.max_weapon_energy *
  Float::from_int(bar_w)).to_int()
  let energy_color = if p.weapon_energy > 30.0 {
    @raylib.Color::new(200, 200, 50, 255)
  } else {
    @raylib.Color::new(200, 50, 50, 255)
  }
  @raylib.draw_rectangle(bar_x, energy_y, energy_fill, 10, energy_color)
  @raylib.draw_rectangle_lines(
    bar_x,
    energy_y,
    bar_w,
    10,
    @raylib.Color::new(120, 120, 80, 200),
  )
  @draw.draw_text(
    "ENERGY",
    bar_x + bar_w + 5,
    energy_y - 2,
    12,
    @raylib.Color::new(180, 180, 100, 255),
  )

  // Weapon indicator (bottom right) with ammo/energy info
  let wpn_x = @types.screen_width - 200
  let wpn_y = @types.screen_height - 90
  @raylib.draw_rectangle(
    wpn_x,
    wpn_y,
    190,
    72,
    @raylib.Color::new(0, 0, 0, 160),
  )
  @draw.draw_text(
    "WEAPON:",
    wpn_x + 5,
    wpn_y + 3,
    14,
    @raylib.Color::new(150, 150, 170, 255),
  )
  let wpn_name = @types.weapon_name(p.weapon)
  let wpn_color = match p.weapon {
    Laser => @raylib.Color::new(255, 255, 100, 255)
    Missile => @raylib.Color::new(255, 180, 80, 255)
    Plasma => @raylib.Color::new(100, 255, 150, 255)
    Railgun => @raylib.Color::new(150, 200, 255, 255)
  }
  @draw.draw_text(wpn_name, wpn_x + 5, wpn_y + 20, 20, wpn_color)

  // Ammo/energy cost display
  let ammo_text : String = match p.weapon {
    Laser => {
      let cost = @types.laser_energy_cost.to_int()
      "Cost: \{cost}e"
    }
    Missile => "Ammo: \{p.missile_ammo}/\{@types.missile_max_ammo}"
    Plasma => {
      let cost = @types.plasma_energy_cost.to_int()
      "Cost: \{cost}e"
    }
    Railgun => {
      let cost = @types.railgun_energy_cost.to_int()
      "Cost: \{cost}e"
    }
  }
  @draw.draw_text(
    ammo_text,
    wpn_x + 5,
    wpn_y + 42,
    14,
    @raylib.Color::new(180, 180, 180, 255),
  )

  // Weapon keys 1-4
  let key1_color = if p.weapon == Laser {
    @raylib.Color::new(255, 255, 100, 255)
  } else {
    @raylib.Color::new(100, 100, 100, 255)
  }
  let key2_color = if p.weapon == Missile {
    @raylib.Color::new(255, 180, 80, 255)
  } else {
    @raylib.Color::new(100, 100, 100, 255)
  }
  let key3_color = if p.weapon == Plasma {
    @raylib.Color::new(100, 255, 150, 255)
  } else {
    @raylib.Color::new(100, 100, 100, 255)
  }
  let key4_color = if p.weapon == Railgun {
    @raylib.Color::new(150, 200, 255, 255)
  } else {
    @raylib.Color::new(100, 100, 100, 255)
  }
  @draw.draw_text("1", wpn_x + 100, wpn_y + 20, 18, key1_color)
  @draw.draw_text("2", wpn_x + 120, wpn_y + 20, 18, key2_color)
  @draw.draw_text("3", wpn_x + 140, wpn_y + 20, 18, key3_color)
  @draw.draw_text("4", wpn_x + 160, wpn_y + 20, 18, key4_color)

  // Target info with health bar
  if game.target_idx >= 0 && game.target_idx < game.enemies.length() {
    let e = game.enemies[game.target_idx]
    if e.active {
      let tgt_x = @types.screen_width / 2 - 100
      let tgt_y = @types.screen_height - 100
      @raylib.draw_rectangle(
        tgt_x,
        tgt_y,
        200,
        70,
        @raylib.Color::new(0, 0, 0, 160),
      )
      // Lock status
      let lock_text = if game.target_lock_timer > 1.0 {
        "LOCKED"
      } else {
        "LOCKING..."
      }
      let lock_color = if game.target_lock_timer > 1.0 {
        @raylib.Color::new(0, 255, 0, 255)
      } else {
        @raylib.Color::new(255, 255, 0, 200)
      }
      @draw.draw_text(lock_text, tgt_x + 130, tgt_y + 3, 12, lock_color)
      let tgt_name = @types.enemy_type_name(e.kind)
      @draw.draw_text(
        "TGT: \{tgt_name}",
        tgt_x + 5,
        tgt_y + 3,
        14,
        @raylib.Color::new(255, 255, 0, 255),
      )
      let dist = @types.distance3d(
        game.player.x,
        game.player.y,
        game.player.z,
        e.x,
        e.y,
        e.z,
      )
      @draw.draw_text(
        "Dist: \{dist.to_int()}m",
        tgt_x + 5,
        tgt_y + 20,
        14,
        @raylib.Color::new(200, 200, 100, 255),
      )
      // Target health bar
      let tgt_bar_y = tgt_y + 38
      @raylib.draw_rectangle(
        tgt_x + 5,
        tgt_bar_y,
        190,
        12,
        @raylib.Color::new(60, 0, 0, 200),
      )
      let hp_pct = e.hp / e.max_hp
      let hp_fill = (hp_pct * 190.0).to_int()
      let hp_color = if hp_pct > 0.5 {
        @raylib.Color::new(0, 200, 0, 255)
      } else if hp_pct > 0.25 {
        @raylib.Color::new(200, 200, 0, 255)
      } else {
        @raylib.Color::new(255, 50, 50, 255)
      }
      @raylib.draw_rectangle(tgt_x + 5, tgt_bar_y, hp_fill, 12, hp_color)
      @raylib.draw_rectangle_lines(
        tgt_x + 5,
        tgt_bar_y,
        190,
        12,
        @raylib.Color::new(120, 120, 120, 200),
      )
      @draw.draw_text(
        "HP: \{e.hp.to_int()}/\{e.max_hp.to_int()}",
        tgt_x + 5,
        tgt_bar_y + 14,
        12,
        @raylib.Color::new(180, 180, 180, 255),
      )
    }
  }

  // Speed + boost fuel
  @draw.draw_text(
    "SPD: \{game.player.speed.to_int()}",
    @types.screen_width - 130,
    40,
    16,
    @raylib.Color::new(150, 200, 150, 255),
  )
  let boost_x = @types.screen_width - 130
  @raylib.draw_rectangle(
    boost_x,
    60,
    100,
    8,
    @raylib.Color::new(20, 20, 0, 180),
  )
  let boost_fill = (p.boost_fuel / @types.max_boost_fuel * 100.0).to_int()
  let boost_color = if p.boosting {
    @raylib.Color::new(255, 200, 50, 255)
  } else {
    @raylib.Color::new(150, 150, 80, 200)
  }
  @raylib.draw_rectangle(boost_x, 60, boost_fill, 8, boost_color)
  if p.boosting {
    @draw.draw_text(
      "BOOST",
      boost_x + 105,
      58,
      12,
      @raylib.Color::new(255, 200, 50, 255),
    )
  }

  // Combo display
  if game.combo_count >= 2 {
    let combo_text = "x\{game.combo_count} COMBO"
    let combo_tw = @draw.measure_text(combo_text, 24)
    let combo_alpha_f = @types.minf(
        game.combo_timer / @types.combo_timeout,
        1.0,
      ) *
      255.0
    let combo_a = combo_alpha_f.to_int().clamp(min=0, max=255)
    @draw.draw_text(
      combo_text,
      (@types.screen_width - combo_tw) / 2,
      50,
      24,
      @raylib.Color::new(255, 220, 50, combo_a),
    )
  }

  // Kill feed (top right)
  {
    let mut drawn = 0
    for i = @types.max_kill_feed - 1; i >= 0; i = i - 1 {
      if game.kill_feed[i].active && game.kill_feed[i].timer > 0.0 {
        let entry = game.kill_feed[i]
        let alpha_f = entry.timer / @types.kill_feed_duration * 200.0
        let alpha = alpha_f.to_int().clamp(min=0, max=255)
        @draw.draw_text(
          entry.text,
          @types.screen_width - 210,
          60 + drawn * 18,
          14,
          @raylib.Color::new(entry.r, entry.g, entry.b, alpha),
        )
        drawn += 1
        if drawn >= 4 {
          break
        }
      }
    }
  }

  // Mission objective progress
  if game.objectives_count > 0 {
    for i in 0..<game.objectives_count {
      let obj = game.objectives[i]
      let color = if obj.complete {
        @raylib.Color::new(100, 255, 100, 200)
      } else {
        @raylib.Color::new(220, 220, 220, 200)
      }
      let status = if obj.complete {
        "[DONE]"
      } else {
        "[\{obj.current_count}/\{obj.target_count}]"
      }
      @draw.draw_text(
        "\{status} \{obj.description}",
        10,
        42 + i * 18,
        14,
        color,
      )
    }
  }

  // Missile warning indicator - scan for incoming enemy projectiles
  {
    let mut incoming = false
    for proj in game.projectiles {
      if proj.active && !proj.from_player && proj.kind == Plasma {
        let dist = @types.distance3d(proj.x, proj.y, proj.z, p.x, p.y, p.z)
        if dist < 80.0 {
          incoming = true
          break
        }
      }
    }
    if incoming {
      let flash = game.frame_counter % 10 < 5
      if flash {
        let text = "!! INCOMING FIRE !!"
        let tw = @draw.measure_text(text, 24)
        @draw.draw_text(
          text,
          (@types.screen_width - tw) / 2,
          @types.screen_height - 100,
          24,
          @raylib.Color::new(255, 50, 50, 255),
        )
      }
    }
  }

  // Low hull damage effects (red flashing edges)
  if p.hull < p.max_hull * 0.3 {
    let hull_ratio : Float = p.hull / p.max_hull
    let alpha_f : Float = (1.0 - hull_ratio / 0.3) * 100.0
    let alpha = alpha_f.to_int().clamp(min=0, max=255)
    let edge_color = @raylib.Color::new(255, 0, 0, alpha)
    @raylib.draw_rectangle(0, 0, @types.screen_width, 6, edge_color)
    @raylib.draw_rectangle(
      0,
      @types.screen_height - 6,
      @types.screen_width,
      6,
      edge_color,
    )
    @raylib.draw_rectangle(0, 0, 6, @types.screen_height, edge_color)
    @raylib.draw_rectangle(
      @types.screen_width - 6,
      0,
      6,
      @types.screen_height,
      edge_color,
    )
  }

  // Near-miss indicator: screen edge flash in the direction of the projectile
  if game.near_miss_timer > 0.0 {
    let nm_alpha_f = game.near_miss_timer / @types.near_miss_duration * 200.0
    let nm_a = nm_alpha_f.to_int().clamp(min=0, max=200)
    let nm_color = @raylib.Color::new(255, 255, 100, nm_a)
    // Flash on screen edge based on direction
    let edge_w = 30
    if game.near_miss_dir_x > 0.3 {
      // Right edge flash
      @raylib.draw_rectangle(
        @types.screen_width - edge_w,
        0,
        edge_w,
        @types.screen_height,
        nm_color,
      )
    } else if game.near_miss_dir_x < -0.3 {
      // Left edge flash
      @raylib.draw_rectangle(0, 0, edge_w, @types.screen_height, nm_color)
    }
    if game.near_miss_dir_y > 0.3 {
      // Top edge flash (projectile ahead)
      @raylib.draw_rectangle(0, 0, @types.screen_width, edge_w, nm_color)
    } else if game.near_miss_dir_y < -0.3 {
      // Bottom edge flash (projectile behind)
      @raylib.draw_rectangle(
        0,
        @types.screen_height - edge_w,
        @types.screen_width,
        edge_w,
        nm_color,
      )
    }
    // "NEAR MISS" text
    let nm_text = "NEAR MISS"
    let nm_tw = @draw.measure_text(nm_text, 20)
    @draw.draw_text(
      nm_text,
      (@types.screen_width - nm_tw) / 2,
      @types.screen_height / 2 + 40,
      20,
      @raylib.Color::new(255, 255, 100, nm_a),
    )
  }

  // Weak point HUD indicator when targeting a capital ship
  if game.target_idx >= 0 && game.target_idx < game.enemies.length() {
    let tgt = game.enemies[game.target_idx]
    if tgt.active && tgt.kind == @types.enemy_capital {
      let wp_panel_x = @types.screen_width / 2 + 110
      let wp_panel_y = @types.screen_height - 100
      @raylib.draw_rectangle(
        wp_panel_x,
        wp_panel_y,
        120,
        55,
        @raylib.Color::new(0, 0, 0, 140),
      )
      @draw.draw_text(
        "WEAK POINTS",
        wp_panel_x + 5,
        wp_panel_y + 3,
        12,
        @raylib.Color::new(255, 200, 100, 255),
      )
      if tgt.weak_point_hp > 0.0 {
        let wp_pct = tgt.weak_point_hp / @types.capital_weak_point_hp
        let wp_fill = (wp_pct * 110.0).to_int()
        let wp_bar_color = if wp_pct > 0.5 {
          @raylib.Color::new(100, 255, 100, 255)
        } else if wp_pct > 0.25 {
          @raylib.Color::new(255, 255, 50, 255)
        } else {
          @raylib.Color::new(255, 80, 80, 255)
        }
        @raylib.draw_rectangle(
          wp_panel_x + 5,
          wp_panel_y + 18,
          110,
          10,
          @raylib.Color::new(40, 0, 0, 200),
        )
        @raylib.draw_rectangle(
          wp_panel_x + 5,
          wp_panel_y + 18,
          wp_fill,
          10,
          wp_bar_color,
        )
        let wp_hp_text = "HP: \{tgt.weak_point_hp.to_int()}"
        @draw.draw_text(
          wp_hp_text,
          wp_panel_x + 5,
          wp_panel_y + 30,
          11,
          @raylib.Color::new(200, 200, 200, 255),
        )
      } else {
        @draw.draw_text(
          "DESTROYED",
          wp_panel_x + 5,
          wp_panel_y + 20,
          14,
          @raylib.Color::new(255, 80, 80, 255),
        )
      }
      // Phase indicator
      let phase_hp = tgt.hp / tgt.max_hp
      let phase_text = if phase_hp < @types.capital_phase_death_spiral {
        "DEATH SPIRAL"
      } else if phase_hp < @types.capital_phase_slow {
        "SYSTEMS FAILING"
      } else if phase_hp < @types.capital_phase_shield_loss {
        "SHIELDS DOWN"
      } else {
        "SHIELDS ACTIVE"
      }
      let phase_color = if phase_hp < @types.capital_phase_death_spiral {
        @raylib.Color::new(255, 50, 50, 255)
      } else if phase_hp < @types.capital_phase_slow {
        @raylib.Color::new(255, 180, 50, 255)
      } else if phase_hp < @types.capital_phase_shield_loss {
        @raylib.Color::new(255, 255, 100, 255)
      } else {
        @raylib.Color::new(100, 200, 255, 255)
      }
      @draw.draw_text(
        phase_text,
        wp_panel_x + 5,
        wp_panel_y + 42,
        10,
        phase_color,
      )
    }
  }

  // Screen flash overlay
  if game.screen_flash > 0.0 {
    let flash_a = (game.screen_flash * 120.0).to_int().clamp(min=0, max=120)
    @raylib.draw_rectangle(
      0,
      0,
      @types.screen_width,
      @types.screen_height,
      @raylib.Color::new(game.flash_r, game.flash_g, game.flash_b, flash_a),
    )
  }

  // Bottom bar
  @raylib.draw_rectangle(
    0,
    @types.screen_height - 18,
    @types.screen_width,
    18,
    @raylib.Color::new(0, 0, 0, 100),
  )
  @draw.draw_text(
    "WASD: Fly | QE: Roll | Shift: Boost | Space: Fire | Tab: Target | 1-4: Weapons | P: Pause",
    10,
    @types.screen_height - 16,
    12,
    @raylib.Color::new(80, 90, 100, 255),
  )
}

///|
fn @types.Game::draw_crosshair(game : @types.Game) -> Unit {
  let cx = @types.screen_width / 2
  let cy = @types.screen_height / 2
  let s = 12
  let color = if game.target_idx >= 0 {
    @raylib.Color::new(255, 255, 0, 200)
  } else {
    @raylib.Color::new(100, 200, 100, 150)
  }
  // Crosshair lines
  @raylib.draw_line(cx - s, cy, cx - 4, cy, color)
  @raylib.draw_line(cx + 4, cy, cx + s, cy, color)
  @raylib.draw_line(cx, cy - s, cx, cy - 4, color)
  @raylib.draw_line(cx, cy + 4, cx, cy + s, color)
  // Center dot
  @raylib.draw_rectangle(cx - 1, cy - 1, 2, 2, color)
}

///|
fn @types.Game::draw_message(game : @types.Game) -> Unit {
  let text = game.message_text
  let tw = @draw.measure_text(text, 32)
  let alpha = @types.minf(game.message_timer * 2.0, 1.0)
  let a = (alpha * 255.0).to_int()
  @draw.draw_text(
    text,
    (@types.screen_width - tw) / 2,
    @types.screen_height / 2 - 120,
    32,
    @raylib.Color::new(255, 255, 200, a.clamp(min=0, max=255)),
  )
}

///|
fn @types.Game::draw_pause_overlay(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(0, 0, 0, 150),
  )
  let text = "PAUSED"
  let tw = @draw.measure_text(text, 60)
  @draw.draw_text(
    text,
    (@types.screen_width - tw) / 2,
    @types.screen_height / 2 - 80,
    60,
    @raylib.white,
  )

  let items : Array[String] = ["Resume", "Restart Mission", "Quit to Menu"]
  for i in 0..<items.length() {
    let y = @types.screen_height / 2 + i * 40
    let is_sel = game.pause_cursor == i
    let color = if is_sel {
      @raylib.Color::new(255, 255, 100, 255)
    } else {
      @raylib.Color::new(150, 150, 170, 255)
    }
    let prefix = if is_sel { "> " } else { "  " }
    let item_text = prefix + items[i]
    let item_w = @draw.measure_text(item_text, 24)
    @draw.draw_text(item_text, (@types.screen_width - item_w) / 2, y, 24, color)
  }
}

///|
fn @types.Game::draw_mission_complete(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(0, 10, 30, 200),
  )
  let text = "MISSION COMPLETE"
  let tw = @draw.measure_text(text, 48)
  @draw.draw_text(
    text,
    (@types.screen_width - tw) / 2,
    @types.screen_height / 2 - 80,
    48,
    @raylib.Color::new(100, 255, 100, 255),
  )
  let score_text = "Score: \{game.score}  Kills: \{game.total_kills}"
  let sw = @draw.measure_text(score_text, 24)
  @draw.draw_text(
    score_text,
    (@types.screen_width - sw) / 2,
    @types.screen_height / 2 - 10,
    24,
    @raylib.Color::new(200, 255, 200, 255),
  )
  let next_text = if game.current_mission + 1 >= @types.total_missions {
    "All missions complete! Enter: Menu"
  } else {
    "Enter: Next Mission"
  }
  let nw = @draw.measure_text(next_text, 20)
  @draw.draw_text(
    next_text,
    (@types.screen_width - nw) / 2,
    @types.screen_height / 2 + 40,
    20,
    @raylib.Color::new(180, 200, 180, 255),
  )
}

///|
fn @types.Game::draw_game_over(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(30, 0, 0, 220),
  )
  let text = "DESTROYED"
  let tw = @draw.measure_text(text, 60)
  @draw.draw_text(
    text,
    (@types.screen_width - tw) / 2,
    @types.screen_height / 2 - 60,
    60,
    @raylib.Color::new(255, 80, 60, 255),
  )
  let score_text = "Score: \{game.score}  Mission: \{game.current_mission + 1}"
  let sw = @draw.measure_text(score_text, 24)
  @draw.draw_text(
    score_text,
    (@types.screen_width - sw) / 2,
    @types.screen_height / 2 + 20,
    24,
    @raylib.Color::new(200, 200, 200, 255),
  )
  @draw.draw_text(
    "Enter: Menu",
    (@types.screen_width - @draw.measure_text("Enter: Menu", 18)) / 2,
    @types.screen_height / 2 + 60,
    18,
    @raylib.Color::new(180, 180, 200, 255),
  )
}

///|
fn @types.Game::draw_mission_briefing(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(2, 2, 12, 255),
  )

  let title = "MISSION BRIEFING"
  let tw = @draw.measure_text(title, 40)
  @draw.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    60,
    40,
    @raylib.Color::new(100, 180, 255, 255),
  )

  let mission_num = game.current_mission + 1
  let header = "Mission \{mission_num}: \{@levels.mission_name(game.current_mission)}"
  let hw = @draw.measure_text(header, 28)
  @draw.draw_text(
    header,
    (@types.screen_width - hw) / 2,
    130,
    28,
    @raylib.Color::new(255, 255, 200, 255),
  )

  // Briefing text
  let briefing = @levels.mission_briefing(game.current_mission)
  let bw = @draw.measure_text(briefing, 18)
  let bx = if bw < @types.screen_width - 100 {
    (@types.screen_width - bw) / 2
  } else {
    50
  }
  @draw.draw_text(briefing, bx, 200, 18, @raylib.Color::new(180, 190, 210, 255))

  // Objective summary (enhanced)
  let obj_summary = @levels.mission_objective_summary(game.current_mission)
  let os_text = "Objective: \{obj_summary}"
  let osw = @draw.measure_text(os_text, 20)
  let os_x = if osw < @types.screen_width - 100 {
    (@types.screen_width - osw) / 2
  } else {
    50
  }
  @draw.draw_text(
    os_text,
    os_x,
    280,
    20,
    @raylib.Color::new(255, 200, 100, 255),
  )

  // Difficulty and AI level
  let diff_label = @levels.mission_difficulty_text(game.current_mission)
  let ai_diff = @types.mission_ai_difficulty(game.current_mission)
  let ai_label = if ai_diff == 0 {
    "Basic"
  } else if ai_diff == 1 {
    "Adaptive"
  } else if ai_diff == 2 {
    "Tactical"
  } else {
    "Elite"
  }
  let full_diff = "Difficulty: \{diff_label}  |  Enemy AI: \{ai_label}"
  let dw = @draw.measure_text(full_diff, 18)
  @draw.draw_text(
    full_diff,
    (@types.screen_width - dw) / 2,
    320,
    18,
    @raylib.Color::new(200, 160, 120, 255),
  )

  // Wave and enemy info
  let wave_text = "Waves: \{@levels.mission_wave_info(game.current_mission)}  |  \{@levels.mission_enemy_estimate(game.current_mission)}"
  let ww = @draw.measure_text(wave_text, 18)
  @draw.draw_text(
    wave_text,
    (@types.screen_width - ww) / 2,
    355,
    18,
    @raylib.Color::new(180, 180, 200, 255),
  )

  // Ship class
  let ship_text = "Ship: \{@types.ship_class_name(game.selected_ship_class)}"
  let stw = @draw.measure_text(ship_text, 18)
  @draw.draw_text(
    ship_text,
    (@types.screen_width - stw) / 2,
    390,
    18,
    @raylib.Color::new(150, 200, 150, 255),
  )

  // Controls hint
  let hint = "Enter: Launch Mission | Esc: Back to Menu"
  let hint_w = @draw.measure_text(hint, 18)
  @draw.draw_text(
    hint,
    (@types.screen_width - hint_w) / 2,
    @types.screen_height - 60,
    18,
    @raylib.Color::new(100, 120, 140, 255),
  )
}

///|
fn @types.Game::draw_mission_select(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(2, 2, 12, 255),
  )

  let title = "MISSION SELECT"
  let tw = @draw.measure_text(title, 40)
  @draw.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    40,
    40,
    @raylib.Color::new(100, 180, 255, 255),
  )

  for i in 0..<@types.total_missions {
    let y = 110 + i * 42
    let is_sel = game.select_cursor == i
    let color = if is_sel {
      @raylib.Color::new(255, 255, 100, 255)
    } else {
      @raylib.Color::new(150, 150, 170, 255)
    }
    let prefix = if is_sel { "> " } else { "  " }
    let mission_num = i + 1
    let item_text = prefix + "\{mission_num}. \{@levels.mission_name(i)}"
    let item_w = @draw.measure_text(item_text, 20)
    @draw.draw_text(
      item_text,
      (@types.screen_width - item_w) / 2 - 100,
      y,
      20,
      color,
    )

    // Objective type
    let obj_type = @levels.mission_objective_type(i)
    let obj_short = @types.objective_type_name(obj_type)
    let obj_color = match obj_type {
      Survive => @raylib.Color::new(255, 180, 80, 255)
      PatrolMission => @raylib.Color::new(80, 200, 255, 255)
      BossFight => @raylib.Color::new(255, 80, 80, 255)
      DefendStation => @raylib.Color::new(100, 255, 100, 255)
      _ => @raylib.Color::new(160, 160, 180, 255)
    }
    @draw.draw_text(obj_short, @types.screen_width / 2 + 100, y, 14, obj_color)

    // Difficulty on the right
    let diff = @levels.mission_difficulty_text(i)
    @draw.draw_text(
      diff,
      @types.screen_width / 2 + 280,
      y,
      16,
      @raylib.Color::new(180, 150, 100, 255),
    )
  }

  // Controls hint
  let hint = "Up/Down: Select | Enter: Choose | Esc: Back"
  let hint_w = @draw.measure_text(hint, 16)
  @draw.draw_text(
    hint,
    (@types.screen_width - hint_w) / 2,
    @types.screen_height - 40,
    16,
    @raylib.Color::new(80, 100, 120, 255),
  )
}

///|
fn @types.Game::draw_loadout(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(2, 2, 12, 255),
  )

  let title = "SHIP LOADOUT"
  let tw = @draw.measure_text(title, 40)
  @draw.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    50,
    40,
    @raylib.Color::new(100, 180, 255, 255),
  )

  let sub = "Choose your ship class"
  let sub_w = @draw.measure_text(sub, 20)
  @draw.draw_text(
    sub,
    (@types.screen_width - sub_w) / 2,
    100,
    20,
    @raylib.Color::new(180, 180, 200, 255),
  )

  // Ship class options (5 classes: 0-4)
  for i in 0..<5 {
    let y = 170 + i * 90
    let is_sel = game.loadout_cursor == i
    let color = if is_sel {
      @raylib.Color::new(255, 255, 100, 255)
    } else {
      @raylib.Color::new(150, 150, 170, 255)
    }
    let prefix = if is_sel { "> " } else { "  " }
    let sk = @types.ship_kind_from_int(i)
    let name_text = prefix + @types.ship_class_name(sk)
    @draw.draw_text(name_text, 200, y, 26, color)

    // Stats
    let hull_val = @types.ship_class_hull(sk).to_int()
    let shield_val = @types.ship_class_shield(sk).to_int()
    let speed_val = @types.ship_class_speed(sk).to_int()
    let turn_val = @types.ship_class_turn(sk)
    let turn_text = turn_val.to_string()
    let stats_color = if is_sel {
      @raylib.Color::new(200, 200, 150, 255)
    } else {
      @raylib.Color::new(120, 120, 140, 255)
    }
    @draw.draw_text("Hull: \{hull_val}", 500, y, 16, stats_color)
    @draw.draw_text("Shield: \{shield_val}", 620, y, 16, stats_color)
    @draw.draw_text("Speed: \{speed_val}", 500, y + 20, 16, stats_color)
    @draw.draw_text("Turn: \{turn_text}", 620, y + 20, 16, stats_color)
  }

  // Controls hint
  let hint = "Up/Down: Select | Enter: Confirm | Esc: Back"
  let hint_w = @draw.measure_text(hint, 16)
  @draw.draw_text(
    hint,
    (@types.screen_width - hint_w) / 2,
    @types.screen_height - 40,
    16,
    @raylib.Color::new(80, 100, 120, 255),
  )
}
