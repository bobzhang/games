///|
pub fn update_room_flow(game : @types.Game, _dt : Float) -> Unit {
  match game.floor {
    None => ()
    Some(floor) => {
      // Check if player has moved into a different room
      check_room_transition(game, floor)
      let room = floor.rooms[floor.current_room]
      match room.state {
        Idle => {
          // Mark room as visited when player enters
          room.visited = true
          // Check if player has entered the room and enemies should spawn
          if (room.kind == Combat || room.kind == Boss) && not(has_been_cleared(floor, floor.current_room)) {
            seal_room(game)
          }
          // Shop for treasure rooms
          if room.kind == Treasure && not(has_been_cleared(floor, floor.current_room)) {
            setup_shop(game)
            room.state = Cleared
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
fn check_room_transition(game : @types.Game, floor : @types.Floor) -> Unit {
  let p = game.player
  let ts = @types.tile_sizef
  // Check if the player is still within the current room
  let cur = floor.rooms[floor.current_room]
  let cur_px = Float::from_int(cur.x) * ts
  let cur_py = Float::from_int(cur.y) * ts
  let cur_pw = Float::from_int(cur.w) * ts
  let cur_ph = Float::from_int(cur.h) * ts
  if p.x >= cur_px && p.x < cur_px + cur_pw && p.y >= cur_py && p.y < cur_py + cur_ph {
    return // Still in current room
  }
  // Player is outside current room - find which room they're in
  for i in 0..<floor.rooms.length() {
    if i == floor.current_room {
      continue
    }
    let r = floor.rooms[i]
    let rpx = Float::from_int(r.x) * ts
    let rpy = Float::from_int(r.y) * ts
    let rpw = Float::from_int(r.w) * ts
    let rph = Float::from_int(r.h) * ts
    if p.x >= rpx && p.x < rpx + rpw && p.y >= rpy && p.y < rpy + rph {
      floor.current_room = i
      r.visited = true
      // Reveal adjacent rooms (overlapping or nearby) for rendering
      reveal_adjacent_rooms(floor, i)
      return
    }
  }
}

///|
fn reveal_adjacent_rooms(floor : @types.Floor, room_idx : Int) -> Unit {
  let r = floor.rooms[room_idx]
  let ts = @types.tile_sizef
  let rpx = Float::from_int(r.x) * ts
  let rpy = Float::from_int(r.y) * ts
  let rpw = Float::from_int(r.w) * ts
  let rph = Float::from_int(r.h) * ts
  // Expand bounds by a small margin to catch adjacent/overlapping rooms
  let margin = ts * 2.0
  for i in 0..<floor.rooms.length() {
    if i == room_idx {
      continue
    }
    let other = floor.rooms[i]
    let opx = Float::from_int(other.x) * ts
    let opy = Float::from_int(other.y) * ts
    let opw = Float::from_int(other.w) * ts
    let oph = Float::from_int(other.h) * ts
    // Check if rooms overlap or are adjacent (within margin)
    if rpx - margin < opx + opw &&
      rpx + rpw + margin > opx &&
      rpy - margin < opy + oph &&
      rpy + rph + margin > opy {
      other.visited = true
    }
  }
}

///|
fn has_been_cleared(floor : @types.Floor, room_idx : Int) -> Bool {
  floor.rooms[room_idx].state == Cleared
}

///|
fn seal_room(game : @types.Game) -> Unit {
  match game.floor {
    None => ()
    Some(floor) => {
      let room = floor.rooms[floor.current_room]
      room.state = Sealed
      if room.kind == Boss {
        let ts = @types.tile_sizef
        let cx = Float::from_int(room.x) * ts + Float::from_int(room.w) * ts / 2.0
        let cy = Float::from_int(room.y) * ts + Float::from_int(room.h) * ts / 2.0
        spawn_boss(game, cx, cy)
      } else {
        // Spawn enemies based on budget
        let budget = 3 + game.floor_num * 2
        spawn_room_enemies(game, budget)
      }
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
        // Pick enemy kind based on cost, scaled by floor difficulty
        let (s1, roll) = @types.rng_next(game.rng_state)
        game.rng_state = s1
        // Later floors shift probability toward tougher enemies
        let golem_chance : Float = if game.floor_num >= 5 {
          0.12
        } else if game.floor_num >= 3 {
          0.06
        } else {
          0.0
        }
        let spider_chance : Float = if game.floor_num >= 3 {
          0.10
        } else {
          0.0
        }
        // Thresholds: slime [0, 0.25), skeleton [0.25, 0.50), archer [0.50, 0.65),
        //   bat [0.65, 0.85 - spider - golem), spider, golem
        let golem_start : Float = Float::from_double(1.0) - golem_chance
        let spider_start : Float = golem_start - spider_chance
        let (kind, cost) : (@types.EnemyKind, Int) = if roll < 0.25 {
          (Slime, 1)
        } else if roll < 0.50 {
          (Skeleton, 2)
        } else if roll < 0.65 {
          (Archer, 2)
        } else if roll < spider_start {
          (Bat, 1)
        } else if roll < golem_start {
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
      game.rooms_cleared += 1
      game.floor_rooms_cleared += 1
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
      // Gold reward
      let gold_amount = 5 + game.floor_num * 3
      let (s4, gx_off) = @types.rng_range(game.rng_state, -20.0, 20.0)
      game.rng_state = s4
      let gold_idx = @types.alloc_item(game.items)
      let gold_item = game.items[gold_idx]
      gold_item.active = true
      gold_item.kind = Gold(gold_amount)
      gold_item.x = game.player.x + gx_off
      gold_item.y = game.player.y - 50.0
      gold_item.bob_timer = 0.0
      // Passive item chance (increases with floor)
      let (s5, proll) = @types.rng_next(game.rng_state)
      game.rng_state = s5
      let passive_chance : Float = 10.0 / 100.0 + Float::from_int(game.floor_num) * (3.0 / 100.0)
      if proll < passive_chance {
        let passives : Array[@types.PassiveKind] = [
          MaxHpUp, DamageUp, SpeedUp, CritUp,
          DashCooldownDown, DefenseUp, AttackSpeedUp, PickupRange,
        ]
        let (s6, pidx) = @types.rng_int(game.rng_state, 0, passives.length() - 1)
        game.rng_state = s6
        let pi = @types.alloc_item(game.items)
        let pitem = game.items[pi]
        pitem.active = true
        pitem.kind = PassiveItem(passives[pidx])
        pitem.x = game.player.x - 30.0
        pitem.y = game.player.y - 50.0
        pitem.bob_timer = 0.0
      }
      // Deactivate all hostile (non-player) projectiles
      for i in 0..<game.projectiles.length() {
        let proj = game.projectiles[i]
        if proj.active && !proj.is_player {
          proj.active = false
        }
      }
      // Check if stairs should appear: all combat/boss rooms cleared
      let mut all_cleared = true
      let mut combat_count = 0
      let mut boss_cleared = true
      for i in 0..<floor.rooms.length() {
        let r = floor.rooms[i]
        if r.kind == Combat || r.kind == Boss {
          combat_count += 1
          if r.state != Cleared {
            all_cleared = false
          }
        }
        if r.kind == Boss && r.state != Cleared {
          boss_cleared = false
        }
      }
      // On boss floors (every 5th), require the boss room to be cleared
      let is_boss_floor = game.floor_num % 5 == 0
      // Stairs appear once all combat/boss rooms are cleared, or enough rooms on this floor
      let threshold = combat_count / 2 + 1
      let stairs_ok = if is_boss_floor {
        boss_cleared && (all_cleared || game.floor_rooms_cleared >= threshold)
      } else {
        all_cleared || game.floor_rooms_cleared >= threshold
      }
      if stairs_ok {
        game.stairs_active = true
        game.stairs_x = game.player.x
        game.stairs_y = game.player.y - 60.0
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

///|
fn setup_shop(game : @types.Game) -> Unit {
  match game.floor {
    None => ()
    Some(floor) => {
      let room = floor.rooms[floor.current_room]
      let ts = @types.tile_sizef
      let cx = Float::from_int(room.x) * ts + Float::from_int(room.w) * ts / 2.0
      let cy = Float::from_int(room.y) * ts + Float::from_int(room.h) * ts / 2.0
      // Generate 3 shop items: weapon, passive, health potion
      // Item 0: Weapon
      let weapons : Array[@types.WeaponKind] = [Sword, Daggers, Bow, Staff]
      let (s1, widx) = @types.rng_int(game.rng_state, 0, 3)
      let (s2, wprice) = @types.rng_int(s1, 30, 50)
      game.rng_state = s2
      let shop0 = game.shop_items[0]
      shop0.active = true
      shop0.kind = WeaponPickup(weapons[widx])
      shop0.price = wprice
      shop0.x = cx - 80.0
      shop0.y = cy - 20.0
      // Item 1: Passive
      let passives : Array[@types.PassiveKind] = [
        MaxHpUp, DamageUp, SpeedUp, CritUp,
        DashCooldownDown, DefenseUp, AttackSpeedUp, PickupRange,
      ]
      let (s3, pidx) = @types.rng_int(game.rng_state, 0, passives.length() - 1)
      let (s4, pprice) = @types.rng_int(s3, 40, 80)
      game.rng_state = s4
      let shop1 = game.shop_items[1]
      shop1.active = true
      shop1.kind = PassiveItem(passives[pidx])
      shop1.price = pprice
      shop1.x = cx
      shop1.y = cy - 20.0
      // Item 2: Health potion
      let shop2 = game.shop_items[2]
      shop2.active = true
      shop2.kind = HealthPotion
      shop2.price = 15
      shop2.x = cx + 80.0
      shop2.y = cy - 20.0
      game.shop_active = true
    }
  }
}
