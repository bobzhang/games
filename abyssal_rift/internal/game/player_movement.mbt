///|
pub fn update_player_movement(
  game : @types.Game,
  input : InputState,
  dt : Float
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
    return
  }
  // Dash input
  if input.dash_pressed && p.dash_cooldown <= 0.0 {
    let (dx, dy) = if @types.absf(input.move_x) > 0.01 || @types.absf(input.move_y) > 0.01 {
      @types.normalize(input.move_x, input.move_y)
    } else {
      (p.facing_x, p.facing_y)
    }
    p.dash_dx = dx
    p.dash_dy = dy
    p.dash_timer = @types.dash_duration
    p.dash_cooldown = @types.dash_cooldown
    push_event(game, DashUsed(p.x, p.y, dx, dy))
    return
  }
  // Normal movement with acceleration
  let speed = @types.player_base_speed * p.speed
  let target_vx = input.move_x * speed
  let target_vy = input.move_y * speed
  if @types.absf(input.move_x) > 0.01 || @types.absf(input.move_y) > 0.01 {
    // Accelerate toward target
    let ax = (target_vx - p.vx) * @types.player_accel * dt
    let ay = (target_vy - p.vy) * @types.player_accel * dt
    p.vx += @types.clampf(ax, -@types.player_accel * dt, @types.player_accel * dt)
    p.vy += @types.clampf(ay, -@types.player_accel * dt, @types.player_accel * dt)
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
      let room = floor.rooms[floor.current_room]
      let ts = @types.tile_sizef
      let room_px = Float::from_int(room.x) * ts
      let room_py = Float::from_int(room.y) * ts
      // Check surrounding tiles
      let min_tx = ((p.x - r - room_px) / ts).to_int()
      let max_tx = ((p.x + r - room_px) / ts).to_int()
      let min_ty = ((p.y - r - room_py) / ts).to_int()
      let max_ty = ((p.y + r - room_py) / ts).to_int()
      for ty in min_ty..=max_ty {
        for tx in min_tx..=max_tx {
          if tx >= 0 && tx < room.w && ty >= 0 && ty < room.h {
            let tile = room.tiles[ty * room.w + tx]
            if tile == 0 {
              // Wall tile - push player out
              let tile_cx = room_px + Float::from_int(tx) * ts + ts / 2.0
              let tile_cy = room_py + Float::from_int(ty) * ts + ts / 2.0
              let half = ts / 2.0
              // AABB vs circle collision resolution
              let closest_x = @types.clampf(p.x, tile_cx - half, tile_cx + half)
              let closest_y = @types.clampf(p.y, tile_cy - half, tile_cy + half)
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
