///|
pub fn update_enemies(game : @types.Game, dt : Float) -> Unit {
  let p = game.player
  for i in 0..<game.enemies.length() {
    let e = game.enemies[i]
    if !e.active {
      continue
    }
    if e.kind == BroodMother || e.kind == LichKing {
      // Boss enemies are handled by update_boss, skip generic loop
      // But still update flash/knockback timers
      if e.flash_timer > 0.0 {
        e.flash_timer -= dt
      }
      continue
    }
    // Flash timer
    if e.flash_timer > 0.0 {
      e.flash_timer -= dt
    }
    // Knockback
    if e.knockback_timer > 0.0 {
      e.knockback_timer -= dt
      e.x += e.vx * dt
      e.y += e.vy * dt
      e.vx *= 0.85
      e.vy *= 0.85
      collide_enemy_with_tiles(game, e)
      continue
    }
    match e.state {
      Dead(t) => {
        let new_t = t - dt
        if new_t <= 0.0 {
          e.active = false
        } else {
          e.state = Dead(new_t)
        }
        continue
      }
      Hurt(t) => {
        let new_t = t - dt
        if new_t <= 0.0 {
          e.state = Idle
        } else {
          e.state = Hurt(new_t)
        }
        continue
      }
      Attack(t) => {
        let new_t = t - dt
        if new_t <= 0.0 {
          e.state = Chase
          // Melee attack hits player if close
          let stats = @data.get_enemy_stats(e.kind, game.floor_num)
          let d2 = @types.dist2(e.x, e.y, p.x, p.y)
          if d2 < (stats.attack_range + @types.player_radius) * (stats.attack_range + @types.player_radius) {
            damage_player(game, stats.damage)
          }
        } else {
          e.state = Attack(new_t)
        }
        continue
      }
      _ => ()
    }
    // AI update
    update_enemy_ai(game, e, dt)
    // Apply velocity
    e.x += e.vx * dt
    e.y += e.vy * dt
    // Tile collision for enemies (simplified)
    collide_enemy_with_tiles(game, e)
    // Contact damage to player (for melee enemies)
    let e_radius = @data.get_enemy_stats(e.kind, game.floor_num).radius
    let d2 = @types.dist2(e.x, e.y, p.x, p.y)
    let contact_r = e_radius + @types.player_radius
    if d2 < contact_r * contact_r {
      match e.kind {
        Slime | SlimeSmall | Bat => {
          let stats = @data.get_enemy_stats(e.kind, game.floor_num)
          if e.attack_cooldown <= 0.0 {
            damage_player(game, stats.damage)
            e.attack_cooldown = stats.attack_cooldown
          }
        }
        Spider => {
          // Spider contact applies Slow
          let stats = @data.get_enemy_stats(e.kind, game.floor_num)
          if e.attack_cooldown <= 0.0 {
            damage_player(game, stats.damage)
            apply_status_effect(p, Slow(3.0))
            e.attack_cooldown = stats.attack_cooldown
          }
        }
        _ => ()
      }
    }
  }
}

///|
fn collide_enemy_with_tiles(game : @types.Game, e : @types.Enemy) -> Unit {
  let r = @data.get_enemy_stats(e.kind, game.floor_num).radius
  match game.floor {
    None => ()
    Some(floor) => {
      let room_idx = if e.room_id >= 0 && e.room_id < floor.rooms.length() {
        e.room_id
      } else {
        floor.current_room
      }
      let room = floor.rooms[room_idx]
      let ts = @types.tile_sizef
      let room_px = Float::from_int(room.x) * ts
      let room_py = Float::from_int(room.y) * ts
      let min_tx = ((e.x - r - room_px) / ts).to_int()
      let max_tx = ((e.x + r - room_px) / ts).to_int()
      let min_ty = ((e.y - r - room_py) / ts).to_int()
      let max_ty = ((e.y + r - room_py) / ts).to_int()
      for ty in min_ty..=max_ty {
        for tx in min_tx..=max_tx {
          if tx >= 0 && tx < room.w && ty >= 0 && ty < room.h {
            let tile = room.tiles[ty * room.w + tx]
            let is_wall_tile = tile == 0 || (tile == 2 && room.state == Sealed)
            if is_wall_tile {
              let tile_cx = room_px + Float::from_int(tx) * ts + ts / 2.0
              let tile_cy = room_py + Float::from_int(ty) * ts + ts / 2.0
              let half = ts / 2.0
              let closest_x = @types.clampf(e.x, tile_cx - half, tile_cx + half)
              let closest_y = @types.clampf(e.y, tile_cy - half, tile_cy + half)
              let dx = e.x - closest_x
              let dy = e.y - closest_y
              let d2 = dx * dx + dy * dy
              if d2 < r * r && d2 > 0.001 {
                let d = @types.dist(0.0, 0.0, dx, dy)
                let overlap = r - d
                e.x += dx / d * overlap
                e.y += dy / d * overlap
              }
            }
          }
        }
      }
    }
  }
}

///|
fn spawn_small_slimes(game : @types.Game, x : Float, y : Float) -> Unit {
  for offset in 0..<2 {
    let idx = @types.alloc_enemy(game.enemies)
    let e = game.enemies[idx]
    let stats = @data.get_enemy_stats(SlimeSmall, game.floor_num)
    let ox : Float = if offset == 0 { -15.0 } else { 15.0 }
    e.active = true
    e.kind = SlimeSmall
    e.x = x + ox
    e.y = y
    e.vx = 0.0
    e.vy = 0.0
    e.hp = stats.hp
    e.max_hp = stats.hp
    e.state = Idle
    e.facing_x = 1.0
    e.facing_y = 0.0
    e.patrol_x = e.x
    e.patrol_y = e.y
    e.attack_cooldown = 0.5
    e.anim_timer = 0.0
    e.anim_frame = 0
    e.flash_timer = 0.0
    e.knockback_timer = 0.0
    e.phase = 0.0
    e.room_id = match game.floor {
      Some(floor) => floor.current_room
      None => -1
    }
  }
}

///|
pub fn spawn_enemy(
  game : @types.Game,
  kind : @types.EnemyKind,
  x : Float,
  y : Float
) -> Unit {
  let idx = @types.alloc_enemy(game.enemies)
  let e = game.enemies[idx]
  let stats = @data.get_enemy_stats(kind, game.floor_num)
  e.active = true
  e.kind = kind
  e.x = x
  e.y = y
  e.vx = 0.0
  e.vy = 0.0
  e.hp = stats.hp
  e.max_hp = stats.hp
  e.state = Idle
  e.facing_x = 1.0
  e.facing_y = 0.0
  e.patrol_x = x
  e.patrol_y = y
  e.attack_cooldown = 1.0
  e.anim_timer = 0.0
  e.anim_frame = 0
  e.flash_timer = 0.0
  e.knockback_timer = 0.0
  e.phase = 0.0
  e.room_id = match game.floor {
    Some(floor) => floor.current_room
    None => -1
  }
}
