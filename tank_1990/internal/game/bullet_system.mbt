///|
/// Finds and returns the index of the first inactive bullet slot that can be reused.
/// Returns -1 if all bullet slots are currently in use.
fn @types.Game::alloc_bullet(game : @types.Game) -> Int {
  for i, bullet in game.bullets {
    if !bullet.active {
      break i
    }
  } nobreak {
    -1
  }
}

///|
/// Creates a new bullet traveling in the given direction at the specified speed.
/// Allocates a bullet slot, sets its position, velocity, damage, and time-to-live.
fn @types.Game::spawn_bullet(
  game : @types.Game,
  owner_team : @types.Team,
  x : Float,
  y : Float,
  dir : @types.Dir,
  speed : Float,
  power : Int,
) -> Unit {
  let idx = game.alloc_bullet()
  if idx < 0 {
    return
  }

  game.bullets[idx].active = true
  game.bullets[idx].owner_team = owner_team
  game.bullets[idx].x = x
  game.bullets[idx].y = y
  game.bullets[idx].vx = @types.dir_vector_x(dir) * speed
  game.bullets[idx].vy = @types.dir_vector_y(dir) * speed
  game.bullets[idx].ttl = 3.2
  game.bullets[idx].damage = 1
  game.bullets[idx].power = power
  game.bullets[idx].radius = @types.bullet_radius
}

///|
/// Checks whether a bullet collides with any active enemy tank.
/// If a hit is detected, the enemy takes damage, sparks are spawned, and the
/// enemy is destroyed if its health drops to zero. Returns true on a hit.
fn @types.Game::bullet_hit_enemy(
  game : @types.Game,
  bullet : @types.Bullet,
) -> Bool {
  for i, enemy in game.enemies {
    if !enemy.active {
      continue
    }
    if enemy.invuln_timer > 0.0 {
      continue
    }

    let radius = @types.tank_half + bullet.radius
    if @types.distance_sq(bullet.x, bullet.y, enemy.x, enemy.y) <=
      radius * radius {
      enemy.hp -= bullet.damage
      @particles.spawn_spark_burst(game, bullet.x, bullet.y, 6)
      if enemy.hp <= 0 {
        let team : @types.Team = match bullet.owner_team {
          Player2 => Player2
          _ => Player1
        }
        game.destroy_enemy(i, team)
      } else {
        enemy.blink_timer = 0.8
        @types.push_camera_shake(game, 0.8)
      }
      return true
    }
  }
  false
}

///|
/// Checks whether a bullet collides with any active player tank.
/// If a hit is detected, the player is destroyed and the function returns true.
fn @types.Game::bullet_hit_player(
  game : @types.Game,
  bullet : @types.Bullet,
) -> Bool {
  for i in 0..<@types.max_players {
    let player = game.players[i]
    if !player.active {
      continue
    }
    let radius = @types.tank_half + bullet.radius
    if @types.distance_sq(bullet.x, bullet.y, player.x, player.y) <=
      radius * radius {
      game.on_player_destroyed(i)
      return true
    }
  }
  false
}

///|
/// Detects collisions between bullets from opposing teams.
/// When two enemy bullets overlap, both are destroyed and a spark effect is spawned
/// at the midpoint between them.
fn @types.Game::update_bullet_vs_bullet(game : @types.Game) -> Unit {
  for i in 0..<game.bullets.length() {
    if !game.bullets[i].active {
      continue
    }
    for j in (i + 1)..<game.bullets.length() {
      if !game.bullets[j].active {
        continue
      }
      if game.bullets[i].owner_team == game.bullets[j].owner_team {
        continue
      }
      let r = game.bullets[i].radius + game.bullets[j].radius
      if @types.distance_sq(
          game.bullets[i].x,
          game.bullets[i].y,
          game.bullets[j].x,
          game.bullets[j].y,
        ) <=
        r * r {
        let mx = (game.bullets[i].x + game.bullets[j].x) * 0.5
        let my = (game.bullets[i].y + game.bullets[j].y) * 0.5
        @particles.spawn_spark_burst(game, mx, my, 10)
        game.bullets[i].active = false
        game.bullets[j].active = false
      }
    }
  }
}

///|
/// Advances every active bullet by one frame. Each bullet is moved in sub-steps
/// for accurate collision detection against walls, tiles, players, and enemies.
/// Bullets that expire, leave the world, or hit something are deactivated.
fn @types.Game::update_bullets(game : @types.Game, dt : Float) -> Unit {
  for bullet in game.bullets {
    if !bullet.active {
      continue
    }

    bullet.ttl -= dt
    if bullet.ttl <= 0.0 {
      bullet.active = false
      continue
    }

    // Sub-steps for robust collision with narrow walls.
    let steps = 2
    let step_dt = dt / Float::from_int(steps)
    let hit_something = for _ in 0..<steps {
      if !bullet.active {
        break false
      }

      bullet.x += bullet.vx * step_dt
      bullet.y += bullet.vy * step_dt

      if !@world.point_in_world(bullet.x, bullet.y) {
        bullet.active = false
        break true
      }

      if game.damage_tile_at_point(bullet.x, bullet.y, bullet.power) {
        bullet.active = false
        break true
      }

      if bullet.owner_team is Enemy {
        if game.bullet_hit_player(bullet) {
          bullet.active = false
          break true
        }
      } else if game.bullet_hit_enemy(bullet) {
        bullet.active = false
        break true
      }
    } nobreak {
      false
    }

    if hit_something {
      continue
    }
  }

  game.update_bullet_vs_bullet()
}
