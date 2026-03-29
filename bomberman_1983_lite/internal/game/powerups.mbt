///|
fn @types.Game::alloc_powerup(game : @types.Game) -> Int {
  for i, slot in game.powerups {
    if !slot.active {
      break i
    }
  } nobreak {
    -1
  }
}

///|
fn @types.Game::spawn_powerup(
  game : @types.Game,
  kind : @types.PowerupKind,
  x : Float,
  y : Float,
) -> Unit {
  let idx = game.alloc_powerup()
  if idx < 0 {
    return
  }
  game.powerups[idx].active = true
  game.powerups[idx].kind = kind
  game.powerups[idx].x = @types.clampf(
    x,
    Float::from_int(@types.tile_size),
    Float::from_int(@types.map_pixel_w - @types.tile_size),
  )
  game.powerups[idx].y = @types.clampf(
    y,
    Float::from_int(@types.tile_size),
    Float::from_int(@types.map_pixel_h - @types.tile_size),
  )
  game.powerups[idx].ttl = @types.powerup_life
  game.powerups[idx].blink = 0.0
  game.powerups[idx].pulse = @types.rand_rangef(game, 0.0, 6.2)
}

///|
/// Returns the Grenade drop percentage scaled by stage progression.
/// Early stages get 10%, stage 20+ gets 15%, stage 50+ gets 18%.
fn grenade_chance(stage : Int) -> Int {
  if stage >= 50 {
    18
  } else if stage >= 20 {
    15
  } else {
    10
  }
}

///|
/// Picks a random powerup kind with stage-scaled drop rates.
/// Grenade chance is reduced in early stages; the freed budget goes
/// to Shield and ExtraLife for better early-game survivability.
fn @types.Game::spawn_random_powerup(
  game : @types.Game,
  x : Float,
  y : Float,
) -> Unit {
  let roll = @types.rand_range(game, 0, 99)
  let grenade_pct = grenade_chance(game.stage_index)
  // Redistribute the budget freed by reducing Grenade (base 18 -> variable).
  // Extra points split evenly between Shield and ExtraLife.
  let grenade_saved = 18 - grenade_pct
  let shield_extra = grenade_saved / 2
  let extra_life_extra = grenade_saved - shield_extra
  let shield_end = 18 + shield_extra
  let star_end = shield_end + 18
  let grenade_end = star_end + grenade_pct
  let clock_end = grenade_end + 17
  let shovel_end = clock_end + 14
  // ExtraLife gets the remainder: 15 + extra_life_extra.
  ignore(shovel_end + 15 + extra_life_extra)
  let kind : @types.PowerupKind = if roll < shield_end {
    Shield
  } else if roll < star_end {
    Star
  } else if roll < grenade_end {
    Grenade
  } else if roll < clock_end {
    Clock
  } else if roll < shovel_end {
    Shovel
  } else {
    ExtraLife
  }
  game.spawn_powerup(kind, x, y)
}

///|
fn @types.Game::clear_all_enemies_by_grenade(
  game : @types.Game,
  team : @types.Team,
) -> Unit {
  let killed = for enemy in game.enemies; killed = 0 {
    if enemy.active {
      enemy.active = false
      game.enemies_alive -= 1
      @particles.spawn_explosion(game, enemy.x, enemy.y, 1.4)
      @score.grant_score(game, team, @types.enemy_score(enemy.enemy_kind))
      continue killed + 1
    }
  } nobreak {
    killed
  }
  if killed > 0 {
    @score.bump_combo(game)
    let bonus = killed * 25
    @score.grant_score(game, team, bonus)
  }
}

///|
fn @types.Game::apply_powerup(
  game : @types.Game,
  player_index : Int,
  kind : @types.PowerupKind,
) -> Unit {
  let player = game.players[player_index]
  let team = @types.team_of_player(player_index)
  match kind {
    Shield => {
      player.shield_timer = 8.0
      player.invuln_timer = 2.0
      @particles.spawn_respawn_burst(game, player.x, player.y)
    }
    Star => {
      player.weapon_level = (player.weapon_level + 1).clamp(min=0, max=3)
      player.reload_delay = @types.player_reload_base *
        (1.0 - Float::from_int(player.weapon_level) * 0.08)
      if player.reload_delay < 0.12 {
        player.reload_delay = 0.12
      }
      @particles.spawn_spark_burst(game, player.x, player.y, 20)
    }
    Grenade => {
      game.clear_all_enemies_by_grenade(team)
      @types.push_camera_shake(game, 2.2)
    }
    Clock => {
      game.freeze_all_timer = @types.freeze_duration
      @particles.spawn_spark_burst(game, player.x, player.y, 26)
    }
    Shovel => {
      game.cache_base_ring()
      game.apply_shovel_fortress()
      game.shovel_timer = @types.shovel_duration
      @particles.spawn_spark_burst(
        game,
        @types.tile_center_x(@types.base_tile_x),
        @types.tile_center_y(@types.base_tile_y),
        24,
      )
    }
    ExtraLife => {
      player.lives += 1
      @particles.spawn_respawn_burst(game, player.x, player.y)
    }
  }
  @score.grant_score(game, team, 120)
}

///|
fn powerup_radius(kind : @types.PowerupKind) -> Float {
  match kind {
    Shield => 11.0
    Star => 10.0
    Grenade => 12.0
    Clock => 11.0
    Shovel => 11.0
    ExtraLife => 12.0
  }
}

///|
fn @types.Game::update_powerups(game : @types.Game, dt : Float) -> Unit {
  for p in game.powerups {
    if !p.active {
      continue
    }

    p.ttl -= dt
    p.blink += dt
    p.pulse += dt * 3.0
    if p.ttl <= 0.0 {
      p.active = false
      continue
    }

    for j in 0..<@types.max_players {
      let player = game.players[j]
      if !player.active {
        continue
      }
      let r = @types.tank_half + powerup_radius(p.kind)
      if @types.distance_sq(player.x, player.y, p.x, p.y) <= r * r {
        game.apply_powerup(j, p.kind)
        p.active = false
        break
      }
    }
  }
}

///|
fn @types.Game::update_global_effects(game : @types.Game, dt : Float) -> Unit {
  if game.freeze_all_timer > 0.0 {
    game.freeze_all_timer -= dt
    if game.freeze_all_timer < 0.0 {
      game.freeze_all_timer = 0.0
    }
  }

  if game.shovel_timer > 0.0 {
    game.shovel_timer -= dt
    if game.shovel_timer <= 0.0 {
      game.shovel_timer = 0.0
      game.restore_base_ring()
    }
  }
}
