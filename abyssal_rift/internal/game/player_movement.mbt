///|
pub fn update_player_movement(
  game : @types.Game,
  input : InputState,
  dt : Float,
) -> Unit {
  let p = game.player
  if p.dead {
    return
  }
  p.dash_cooldown -= dt
  // During dash - override movement
  if p.dash_timer > 0.0 {
    p.dash_timer -= dt
    p.x += p.dash_dx * @types.dash_speed * dt
    p.y += p.dash_dy * @types.dash_speed * dt
    p.invuln_timer = @types.maxf(p.invuln_timer, p.dash_timer)
    collide_player_with_tiles(game)
    // Phantom Dash synergy: deal damage to nearby enemies during dash
    // Only damage on first frame of dash (when dash_timer is near max)
    let syn = game.synergies
    if syn.dash_damages && p.dash_timer > @types.dash_duration - 0.02 {
      let dash_radius : Float = 50.0
      for i in 0..<game.enemies.length() {
        let e = game.enemies[i]
        if !e.active {
          continue
        }
        match e.state {
          Dead(_) => continue
          _ => ()
        }
        let d2 = @types.dist2(p.x, p.y, e.x, e.y)
        if d2 < dash_radius * dash_radius {
          apply_damage_to_enemy(game, i, syn.dash_damage, false, 80.0)
        }
      }
      game.hit_pause_timer = 0.0 // Don't stutter during dash
    }
    if syn.dash_damages {
      // Visual trail particles (every frame during dash)
      spawn_particles_burst(game, p.x, p.y, 2, 160, 100, 255)
    }
    return
  }
  // Detect dash just ended
  if p.dash_timer <= 0.0 && p.dash_dx != 0.0 {
    // Landing burst
    spawn_particles_burst(game, p.x, p.y, 8, 100, 200, 255)
    // Clean dodge reward: small shield refund
    p.shield = @types.minf(p.shield + 5.0, p.max_shield)
    p.dash_dx = 0.0
    p.dash_dy = 0.0
  }
  // Dash input
  if input.dash_pressed && p.dash_cooldown <= 0.0 {
    let (dx, dy) = if @types.absf(input.move_x) > 0.01 ||
      @types.absf(input.move_y) > 0.01 {
      @types.normalize(input.move_x, input.move_y)
    } else {
      (p.facing_x, p.facing_y)
    }
    p.dash_dx = dx
    p.dash_dy = dy
    p.dash_timer = @types.dash_duration
    let cooldown_mult : Float = if p.passives.contains(DashCooldownDown) {
      0.75
    } else {
      1.0
    }
    let meta_dash_mult : Float = 1.0 -
      Float::from_int(game.meta.upgrades[4]) * 0.1
    p.dash_cooldown = @types.dash_cooldown * cooldown_mult * meta_dash_mult
    push_event(game, DashUsed(p.x, p.y, dx, dy))
    return
  }
  // Normal movement with acceleration (modified by status effects)
  let mut speed_mult = p.speed
  if has_status_slow(p) {
    speed_mult = speed_mult * 0.5
  }
  if has_status_haste(p) {
    speed_mult = speed_mult * 1.3
  }
  let speed = @types.player_base_speed * speed_mult
  let target_vx = input.move_x * speed
  let target_vy = input.move_y * speed
  if @types.absf(input.move_x) > 0.01 || @types.absf(input.move_y) > 0.01 {
    // Accelerate toward target
    let ax = (target_vx - p.vx) * @types.player_accel * dt
    let ay = (target_vy - p.vy) * @types.player_accel * dt
    p.vx += @types.clampf(
      ax,
      -@types.player_accel * dt,
      @types.player_accel * dt,
    )
    p.vy += @types.clampf(
      ay,
      -@types.player_accel * dt,
      @types.player_accel * dt,
    )
  } else {
    // Decelerate
    let decel = @types.player_decel * dt
    if @types.absf(p.vx) < decel {
      p.vx = 0.0
    } else if p.vx > 0.0 {
      p.vx -= decel
    } else {
      p.vx += decel
    }
    if @types.absf(p.vy) < decel {
      p.vy = 0.0
    } else if p.vy > 0.0 {
      p.vy -= decel
    } else {
      p.vy += decel
    }
  }
  // Apply velocity
  p.x += p.vx * dt
  p.y += p.vy * dt
  // Tile collision
  collide_player_with_tiles(game)
}

///|
fn collide_player_with_tiles(game : @types.Game) -> Unit {
  let p = game.player
  let r = @types.player_radius
  match game.floor {
    None => ()
    Some(floor) => {
      let ts = @types.tile_sizef
      // Check collision against all visited rooms so the player can
      // walk through doors into corridors and adjacent rooms.
      for ri in 0..<floor.rooms.length() {
        let room = floor.rooms[ri]
        if !(room.visited) && ri != floor.current_room {
          continue
        }
        let room_px = Float::from_int(room.x) * ts
        let room_py = Float::from_int(room.y) * ts
        let room_pw = Float::from_int(room.w) * ts
        let room_ph = Float::from_int(room.h) * ts
        // Quick bounds check: skip rooms far from player
        if p.x + r < room_px ||
          p.x - r > room_px + room_pw ||
          p.y + r < room_py ||
          p.y - r > room_py + room_ph {
          continue
        }
        // Check surrounding tiles
        let min_tx = ((p.x - r - room_px) / ts).to_int()
        let max_tx = ((p.x + r - room_px) / ts).to_int()
        let min_ty = ((p.y - r - room_py) / ts).to_int()
        let max_ty = ((p.y + r - room_py) / ts).to_int()
        for ty in min_ty..<=max_ty {
          for tx in min_tx..<=max_tx {
            if tx >= 0 && tx < room.w && ty >= 0 && ty < room.h {
              let tile = room.tiles[ty * room.w + tx]
              let is_wall = tile == 0 || (tile == 2 && room.state == Sealed)
              if is_wall {
                // Wall tile - push player out
                let tile_cx = room_px + Float::from_int(tx) * ts + ts / 2.0
                let tile_cy = room_py + Float::from_int(ty) * ts + ts / 2.0
                let half = ts / 2.0
                // AABB vs circle collision resolution
                let closest_x = @types.clampf(
                  p.x,
                  tile_cx - half,
                  tile_cx + half,
                )
                let closest_y = @types.clampf(
                  p.y,
                  tile_cy - half,
                  tile_cy + half,
                )
                let dx = p.x - closest_x
                let dy = p.y - closest_y
                let d2 = dx * dx + dy * dy
                if d2 < r * r && d2 > 0.001 {
                  let d = @types.dist(0.0, 0.0, dx, dy)
                  let overlap = r - d
                  p.x += dx / d * overlap
                  p.y += dy / d * overlap
                }
              }
            }
          }
        }
      }
    }
  }
}
