///|
pub fn update_room_flow(game : @types.Game, _dt : Float) -> Unit {
  match game.floor {
    None => ()
    Some(floor) => {
      let room = floor.rooms[floor.current_room]
      match room.state {
        Idle => {
          // Check if player has entered the room and enemies should spawn
          if room.kind == Combat && not(has_been_cleared(game, floor.current_room)) {
            seal_room(game)
          }
        }
        Sealed => {
          // Count active enemies belonging to this room
          let mut alive = 0
          for i in 0..<game.enemies.length() {
            let e = game.enemies[i]
            if e.active && e.room_id == floor.current_room {
              match e.state {
                Dead(_) => ()
                _ => alive += 1
              }
            }
          }
          if alive == 0 {
            clear_room(game)
          }
        }
        Cleared => ()
      }
    }
  }
}

///|
fn has_been_cleared(_game : @types.Game, _room_idx : Int) -> Bool {
  // For now, rooms can only be cleared once per entry
  // This will be enhanced in Phase 3 with proper floor tracking
  false
}

///|
fn seal_room(game : @types.Game) -> Unit {
  match game.floor {
    None => ()
    Some(floor) => {
      let room = floor.rooms[floor.current_room]
      room.state = Sealed
      // Spawn enemies based on budget
      let budget = 3 + game.floor_num * 2
      spawn_room_enemies(game, budget)
    }
  }
}

///|
fn spawn_room_enemies(game : @types.Game, budget : Int) -> Unit {
  match game.floor {
    None => ()
    Some(floor) => {
      let room = floor.rooms[floor.current_room]
      let ts = @types.tile_sizef
      let mut remaining = budget
      let mut attempts = 0
      while remaining > 0 && attempts < 50 {
        attempts += 1
        // Pick enemy kind based on cost
        let (s1, roll) = @types.rng_next(game.rng_state)
        game.rng_state = s1
        let (kind, cost) : (@types.EnemyKind, Int) = if roll < 0.3 {
          (Slime, 1)
        } else if roll < 0.55 {
          (Skeleton, 2)
        } else if roll < 0.7 {
          (Archer, 2)
        } else if roll < 0.85 {
          (Bat, 1)
        } else if roll < 0.93 {
          (Spider, 3)
        } else {
          (Golem, 4)
        }
        if cost > remaining {
          continue
        }
        // Random position in room (avoiding center where player spawns)
        let (s2, rx) = @types.rng_range(
          game.rng_state,
          Float::from_int(room.x + 2) * ts,
          Float::from_int(room.x + room.w - 2) * ts,
        )
        let (s3, ry) = @types.rng_range(
          s2,
          Float::from_int(room.y + 2) * ts,
          Float::from_int(room.y + room.h - 2) * ts,
        )
        game.rng_state = s3
        // Don't spawn too close to player
        let d2 = @types.dist2(rx, ry, game.player.x, game.player.y)
        if d2 < 100.0 * 100.0 {
          continue
        }
        spawn_enemy(game, kind, rx, ry)
        remaining -= cost
      }
    }
  }
}

///|
fn clear_room(game : @types.Game) -> Unit {
  match game.floor {
    None => ()
    Some(floor) => {
      let room = floor.rooms[floor.current_room]
      room.state = Cleared
      // Reward: spawn health potion chance
      let (s1, roll) = @types.rng_next(game.rng_state)
      game.rng_state = s1
      if roll < 0.3 {
        let idx = @types.alloc_item(game.items)
        let item = game.items[idx]
        item.active = true
        item.kind = HealthPotion
        item.x = game.player.x
        item.y = game.player.y - 40.0
        item.bob_timer = 0.0
      }
      // Weapon pickup chance
      let (s2, wroll) = @types.rng_next(game.rng_state)
      game.rng_state = s2
      if wroll < 0.15 {
        let idx = @types.alloc_item(game.items)
        let item = game.items[idx]
        item.active = true
        let weapons : Array[@types.WeaponKind] = [Sword, Daggers, Bow, Staff]
        let (s3, widx) = @types.rng_int(game.rng_state, 0, 3)
        game.rng_state = s3
        item.kind = WeaponPickup(weapons[widx])
        item.x = game.player.x + 30.0
        item.y = game.player.y - 40.0
        item.bob_timer = 0.0
      }
      // Deactivate all hostile (non-player) projectiles
      for i in 0..<game.projectiles.length() {
        let proj = game.projectiles[i]
        if proj.active && !proj.is_player {
          proj.active = false
        }
      }
      // Room cleared timer for UI flash
      game.room_clear_timer = 1.5
      // Event
      push_event(game, RoomCleared)
      // Celebration particles
      spawn_particles_burst(game, game.player.x, game.player.y, 30, 100, 200, 255)
    }
  }
}
