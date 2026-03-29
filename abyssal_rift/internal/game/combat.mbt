///|
pub fn apply_damage_to_enemy(
  game : @types.Game,
  enemy_idx : Int,
  damage : Int,
  is_crit : Bool,
  knockback : Float
) -> Unit {
  let e = game.enemies[enemy_idx]
  let p = game.player
  e.hp -= damage
  e.flash_timer = 0.1
  // Knockback
  let (dx, dy) = @types.normalize(e.x - p.x, e.y - p.y)
  e.vx = dx * knockback
  e.vy = dy * knockback
  e.knockback_timer = @types.knockback_duration
  // Hit pause
  game.hit_pause_timer = @types.hit_pause_duration
  // Events
  push_event(game, Hit(e.x, e.y, damage, is_crit))
  shake_camera(game, if is_crit { 4.0 } else { 2.0 }, 0.1)
  // Spawn damage number
  let idx = @types.alloc_damage_num(game.damage_numbers)
  let dn = game.damage_numbers[idx]
  dn.active = true
  dn.x = e.x
  dn.y = e.y - 20.0
  dn.vy = -80.0
  dn.life = 0.8
  dn.value = damage
  dn.is_crit = is_crit
  // Check death
  if e.hp <= 0 {
    e.state = Dead(0.5)
    let stats = @data.get_enemy_stats(e.kind, game.floor_num)
    push_event(game, Kill(e.kind, e.x, e.y))
    // Drop gold
    let item_idx = @types.alloc_item(game.items)
    let item = game.items[item_idx]
    item.active = true
    item.kind = Gold(stats.reward_gold)
    item.x = e.x
    item.y = e.y
    item.bob_timer = 0.0
  }
}

///|
fn check_projectile_wall_collision(game : @types.Game, proj : @types.Projectile) -> Bool {
  match game.floor {
    None => false
    Some(floor) => {
      let room = floor.rooms[floor.current_room]
      let ts = @types.tile_sizef
      let room_px = Float::from_int(room.x) * ts
      let room_py = Float::from_int(room.y) * ts
      let tx = ((proj.x - room_px) / ts).to_int()
      let ty = ((proj.y - room_py) / ts).to_int()
      if tx >= 0 && tx < room.w && ty >= 0 && ty < room.h {
        room.tiles[ty * room.w + tx] == 0
      } else {
        true  // out of bounds = wall
      }
    }
  }
}

///|
pub fn update_projectiles(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.projectiles.length() {
    let proj = game.projectiles[i]
    if !proj.active {
      continue
    }
    proj.lifetime -= dt
    if proj.lifetime <= 0.0 {
      proj.active = false
      continue
    }
    proj.x += proj.vx * dt
    proj.y += proj.vy * dt
    if check_projectile_wall_collision(game, proj) {
      proj.active = false
      continue
    }
    if proj.is_player {
      // Check collision with enemies
      for j in 0..<game.enemies.length() {
        let e = game.enemies[j]
        if !e.active {
          continue
        }
        match e.state {
          Dead(_) => continue
          _ => ()
        }
        let e_radius = @data.get_enemy_stats(e.kind, game.floor_num).radius
        let d2 = @types.dist2(proj.x, proj.y, e.x, e.y)
        let hit_r = proj.radius + e_radius
        if d2 <= hit_r * hit_r {
          apply_damage_to_enemy(game, j, proj.damage, proj.is_crit, 100.0)
          if !proj.piercing {
            proj.active = false
            break
          }
        }
      }
    } else {
      // Enemy projectile - check collision with player
      let p = game.player
      let d2 = @types.dist2(proj.x, proj.y, p.x, p.y)
      let hit_r = proj.radius + @types.player_radius
      if d2 <= hit_r * hit_r {
        damage_player(game, proj.damage)
        proj.active = false
      }
    }
  }
}

///|
pub fn update_damage_numbers(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.damage_numbers.length() {
    let dn = game.damage_numbers[i]
    if !dn.active {
      continue
    }
    dn.life -= dt
    if dn.life <= 0.0 {
      dn.active = false
      continue
    }
    dn.y += dn.vy * dt
    dn.vy *= 0.95
  }
}
