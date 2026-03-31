///|
pub fn update_room_flow(game : @types.Game, dt : Float) -> Unit {
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
          if (
              room.kind == Combat ||
              room.kind == Boss ||
              room.kind == EliteVault ||
              room.kind == Challenge
            ) &&
            !(has_been_cleared(floor, floor.current_room)) {
            seal_room(game)
          }
          // Shop for treasure rooms
          if room.kind == Treasure &&
            !(has_been_cleared(floor, floor.current_room)) {
            setup_shop(game)
            room.state = Cleared
          }
          // Shrine rooms
          if room.kind == Shrine &&
            !(has_been_cleared(floor, floor.current_room)) {
            setup_shrine(game)
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
          if game.wave_active {
            if alive == 0 {
              game.wave_count += 1
              if game.wave_count >= game.wave_max {
                game.wave_active = false
                clear_room(game)
              } else {
                // Spawn next wave after delay
                game.wave_timer -= dt
                if game.wave_timer <= 0.0 {
                  spawn_wave(game, game.wave_count)
                  game.wave_timer = 1.5
                }
              }
            }
          } else if alive == 0 {
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
  if p.x >= cur_px &&
    p.x < cur_px + cur_pw &&
    p.y >= cur_py &&
    p.y < cur_py + cur_ph {
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
fn spawn_wave(game : @types.Game, wave_num : Int) -> Unit {
  match game.floor {
    None => ()
    Some(floor) => {
      let room = floor.rooms[floor.current_room]
      let ts = @types.tile_sizef
      let cx = Float::from_int(room.x) * ts + Float::from_int(room.w) * ts / 2.0
      let cy = Float::from_int(room.y) * ts + Float::from_int(room.h) * ts / 2.0
      let hw = Float::from_int(room.w - 4) * ts / 2.0
      let hh = Float::from_int(room.h - 4) * ts / 2.0
      let count = 3 + wave_num * 2
      for _i in 0..<count {
        let (s1, ox) = @types.rng_range(game.rng_state, -hw, hw)
        let (s2, oy) = @types.rng_range(s1, -hh, hh)
        game.rng_state = s2
        let kind : @types.EnemyKind = match wave_num % 3 {
          0 => SlimeSmall
          1 => Skeleton
          _ => Bat
        }
        if @types.dist2(cx + ox, cy + oy, game.player.x, game.player.y) >
          80.0 * 80.0 {
          spawn_enemy(game, kind, cx + ox, cy + oy)
        }
      }
    }
  }
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
        let cx = Float::from_int(room.x) * ts +
          Float::from_int(room.w) * ts / 2.0
        let cy = Float::from_int(room.y) * ts +
          Float::from_int(room.h) * ts / 2.0
        spawn_boss(game, cx, cy)
        game.current_encounter = Standard
      } else if room.kind == EliteVault ||
        room.kind == Challenge ||
        room.kind == Combat {
        let encounter_type : @types.EncounterType = if room.kind == EliteVault {
          BossRush // EliteVault always spawns boss rush
        } else if room.kind == Challenge {
          SurvivalWave
        } else {
          let (enc, s) = select_encounter_with_path(
            game.floor_num,
            game.rng_state,
            game.current_path,
          )
          game.rng_state = s
          enc
        }
        game.current_encounter = encounter_type
        game.encounter_flash_timer = 2.0
        spawn_encounter(game, encounter_type, room)
        if encounter_type == SurvivalWave {
          game.wave_active = true
          game.wave_count = 0
          game.wave_max = 3 + game.floor_num / 3
          game.wave_timer = 0.0
        }
      } else {
        // Fallback: spawn with budget
        let budget = 3 + game.floor_num * 2
        spawn_room_enemies(game, budget)
        game.current_encounter = Standard
      }
    }
  }
}

///|
fn get_encounter_pack(
  floor_num : Int,
  rng : UInt,
) -> (Array[@types.EnemyKind], UInt) {
  let (s, roll) = @types.rng_next(rng)
  let pack : Array[@types.EnemyKind] = if floor_num <= 3 {
    // Early floors: simple packs
    if roll < 0.25 {
      [Slime, Slime, Slime]
    } else if roll < 0.5 {
      [Skeleton, Skeleton]
    } else if roll < 0.75 {
      [Slime, Skeleton, Bat]
    } else {
      [Archer, Slime, Slime]
    }
  } else if floor_num <= 6 {
    // Mid floors: mixed packs
    if roll < 0.2 {
      [Skeleton, Skeleton, Archer]
    } else if roll < 0.4 {
      [Spider, Slime, Slime, Bat]
    } else if roll < 0.6 {
      [Skeleton, Archer, Bat, Bat]
    } else if roll < 0.8 {
      [Golem, Slime, Slime]
    } else {
      [Spider, Archer, Skeleton]
    }
    // Late floors: hard packs
  } else if roll < 0.2 {
    [Golem, Spider, Archer]
  } else if roll < 0.4 {
    [Skeleton, Skeleton, Skeleton, Archer, Archer]
  } else if roll < 0.6 {
    [Golem, Bat, Bat, Bat]
  } else if roll < 0.8 {
    [Spider, Spider, Skeleton, Skeleton]
  } else {
    [Golem, Golem, Slime, Slime]
  }
  (pack, s)
}

///|
fn spawn_room_enemies(game : @types.Game, budget : Int) -> Unit {
  match game.floor {
    None => ()
    Some(floor) => {
      let room = floor.rooms[floor.current_room]
      let ts = @types.tile_sizef
      // Spawn 1-3 packs based on budget
      let num_packs = if budget <= 5 { 1 } else if budget <= 9 { 2 } else { 3 }
      for _pack_i in 0..<num_packs {
        let (pack, s_new) = get_encounter_pack(game.floor_num, game.rng_state)
        game.rng_state = s_new
        for j in 0..<pack.length() {
          let kind = pack[j]
          let mut attempts = 0
          while attempts < 10 {
            attempts += 1
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
            let d2 = @types.dist2(rx, ry, game.player.x, game.player.y)
            if d2 < 100.0 * 100.0 {
              continue
            }
            spawn_enemy(game, kind, rx, ry)
            break
          }
        }
      }
      // Elite spawning on floors 3+
      if game.floor_num >= 3 {
        let elite_chance : Float = 0.15 + Float::from_int(game.floor_num) * 0.05
        let (s_elite, roll) = @types.rng_next(game.rng_state)
        game.rng_state = s_elite
        if roll < elite_chance {
          let affixes : Array[@types.EliteAffix] = [
            Fast,
            Armored,
            Splitting,
            Vampiric,
            Explosive,
          ]
          let (s_affix, affix_idx) = @types.rng_int(game.rng_state, 0, 4)
          game.rng_state = s_affix
          let affix = affixes[affix_idx]
          // Find a random active non-boss enemy to upgrade
          let candidates : Array[Int] = []
          for i in 0..<game.enemies.length() {
            let ei = game.enemies[i]
            if ei.active &&
              !ei.is_elite &&
              ei.room_id == floor.current_room &&
              ei.kind != BroodMother &&
              ei.kind != LichKing {
              match ei.state {
                Dead(_) => ()
                _ => candidates.push(i)
              }
            }
          }
          if candidates.length() > 0 {
            let (s_pick, pick_idx) = @types.rng_int(
              game.rng_state,
              0,
              candidates.length() - 1,
            )
            game.rng_state = s_pick
            let target = game.enemies[candidates[pick_idx]]
            target.is_elite = true
            target.affix = affix
            target.hp = (Float::from_int(target.hp) * 2.0).to_int()
            target.max_hp = target.hp
          }
        }
      }
    }
  }
}

///|
fn trigger_reward_choice(game : @types.Game) -> Unit {
  game.reward_active = true
  game.reward_choices.clear()
  // Generate build-directed smart rewards
  let raw_choices = generate_smart_rewards(game)
  let (center_x, center_y) = match game.floor {
    Some(floor) => {
      let room = floor.rooms[floor.current_room]
      let ts = @types.tile_sizef
      (
        Float::from_int(room.x) * ts + Float::from_int(room.w) * ts / 2.0,
        Float::from_int(room.y) * ts + Float::from_int(room.h) * ts / 2.0,
      )
    }
    None => (game.player.x, game.player.y)
  }
  let spacing : Float = 120.0
  // Position them at room center with spacing
  for i in 0..<raw_choices.length() {
    let choice = raw_choices[i]
    choice.x = center_x - spacing + Float::from_int(i) * spacing
    choice.y = center_y
    game.reward_choices.push(choice)
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
      // Boss rooms, EliteVault, and every 3rd combat room: trigger choice-of-3 reward
      if room.kind == Boss ||
        room.kind == EliteVault ||
        game.floor_rooms_cleared % 3 == 0 {
        trigger_reward_choice(game)
        // Boss bonus: substantial extra gold reward
        if room.kind == Boss {
          let boss_gold = 50 + game.floor_num * 10
          let bg_idx = @types.alloc_item(game.items)
          let bg_item = game.items[bg_idx]
          bg_item.active = true
          bg_item.kind = Gold(boss_gold)
          bg_item.x = game.player.x + 20.0
          bg_item.y = game.player.y - 60.0
          bg_item.bob_timer = 0.0
        }
        // EliteVault bonus: drop an extra passive item
        if room.kind == EliteVault {
          let passives = all_passives()
          let (s_ev, pidx_ev) = @types.rng_int(
            game.rng_state,
            0,
            passives.length() - 1,
          )
          game.rng_state = s_ev
          let pi_ev = @types.alloc_item(game.items)
          let pitem_ev = game.items[pi_ev]
          pitem_ev.active = true
          pitem_ev.kind = PassiveItem(passives[pidx_ev])
          pitem_ev.x = game.player.x + 50.0
          pitem_ev.y = game.player.y - 50.0
          pitem_ev.bob_timer = 0.0
        }
      } else if room.kind == Challenge {
        // Challenge room: big reward on success
        trigger_reward_choice(game)
        // Bonus gold
        let bonus_gold = 20 + game.floor_num * 5
        let gi = @types.alloc_item(game.items)
        let gitem = game.items[gi]
        gitem.active = true
        gitem.kind = Gold(bonus_gold)
        gitem.x = game.player.x - 30.0
        gitem.y = game.player.y - 60.0
        gitem.bob_timer = 0.0
      } else {
        // Normal rooms: standard random drops
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
        let (s5, proll) = @types.rng_next(game.rng_state)
        game.rng_state = s5
        let passive_chance : Float = 10.0 / 100.0 +
          Float::from_int(game.floor_num) * (3.0 / 100.0)
        if proll < passive_chance {
          let passives = all_passives()
          let (s6, pidx) = @types.rng_int(
            game.rng_state,
            0,
            passives.length() - 1,
          )
          game.rng_state = s6
          let pi = @types.alloc_item(game.items)
          let pitem = game.items[pi]
          pitem.active = true
          pitem.kind = PassiveItem(passives[pidx])
          pitem.x = game.player.x - 30.0
          pitem.y = game.player.y - 50.0
          pitem.bob_timer = 0.0
        }
      }
      // Gauntlet path: guarantee weapon reward on every room clear
      let is_gauntlet = match game.current_path {
        Some(Gauntlet) => true
        _ => false
      }
      if is_gauntlet {
        let weapons : Array[@types.WeaponKind] = [Sword, Daggers, Bow, Staff]
        let (sg, gwidx) = @types.rng_int(game.rng_state, 0, 3)
        game.rng_state = sg
        let gwi = @types.alloc_item(game.items)
        let gwitem = game.items[gwi]
        gwitem.active = true
        gwitem.kind = WeaponPickup(weapons[gwidx])
        gwitem.x = game.player.x + 40.0
        gwitem.y = game.player.y - 40.0
        gwitem.bob_timer = 0.0
      }
      // Gold reward (always) - Forge path: gold * 1.3
      let gold_mult : Float = match game.current_path {
        Some(Forge) => 1.3
        _ => 1.0
      }
      let gold_amount = (Float::from_int(5 + game.floor_num * 3) * gold_mult).to_int()
      let (s4, gx_off) = @types.rng_range(game.rng_state, -20.0, 20.0)
      game.rng_state = s4
      let gold_idx = @types.alloc_item(game.items)
      let gold_item = game.items[gold_idx]
      gold_item.active = true
      gold_item.kind = Gold(gold_amount)
      gold_item.x = game.player.x + gx_off
      gold_item.y = game.player.y - 50.0
      gold_item.bob_timer = 0.0
      // Deactivate all hostile (non-player) projectiles
      for i in 0..<game.projectiles.length() {
        let proj = game.projectiles[i]
        if proj.active && !proj.is_player {
          proj.active = false
        }
      }
      // Check if stairs should appear:
      // On boss floors: stairs appear after boss room is cleared
      // On normal floors: stairs appear after clearing 60% of combat rooms (min 3)
      let stairs_unlocked = if game.floor_num % 5 == 0 {
        // Boss floor: only require the Boss room to be cleared
        let mut boss_cleared = false
        for i in 0..<floor.rooms.length() {
          let r = floor.rooms[i]
          if r.kind == Boss && r.state == Cleared {
            boss_cleared = true
            break
          }
        }
        boss_cleared
      } else {
        // Normal floor: 60% of combat rooms, minimum 3
        let mut total_combat_rooms = 0
        for i in 0..<floor.rooms.length() {
          let r = floor.rooms[i]
          if r.kind == Combat ||
            r.kind == Boss ||
            r.kind == EliteVault ||
            r.kind == Challenge {
            total_combat_rooms += 1
          }
        }
        let required = @types.maxf(
          Float::from_int(total_combat_rooms) * 0.6,
          3.0,
        ).to_int()
        game.floor_rooms_cleared >= required
      }
      if stairs_unlocked {
        // Place stairs in the center of the last cleared room
        let ts = @types.tile_sizef
        let cx = Float::from_int(room.x) * ts +
          Float::from_int(room.w) * ts / 2.0
        let cy = Float::from_int(room.y) * ts +
          Float::from_int(room.h) * ts / 2.0
        game.stairs_active = true
        game.stairs_x = cx
        game.stairs_y = cy
      }
      // Vanguard kit bonus: restore shield on room clear
      if game.player.passives.contains(DefenseUp) {
        game.player.shield = @types.minf(
          game.player.shield + 10.0,
          game.player.max_shield,
        )
      }
      // Offer a pact after boss or elite vault clears
      if room.kind == Boss || room.kind == EliteVault {
        offer_pact(game)
      }
      // Room cleared timer for UI flash
      game.room_clear_timer = 1.5
      // Brief Haste boost on room clear
      apply_status_effect(game.player, Haste(1.5))
      // Event
      push_event(game, RoomCleared)
      // Brief slow-motion celebration
      game.hit_pause_timer = 0.15
      // Celebration particles in a ring pattern
      let ring_count = 24
      for ring_i in 0..<ring_count {
        let angle = Float::from_int(ring_i) /
          Float::from_int(ring_count) *
          2.0 *
          3.14159
        let cos_a = Float::from_double(@math.cos(angle.to_double()))
        let sin_a = Float::from_double(@math.sin(angle.to_double()))
        let ring_r : Float = 40.0
        let idx = @types.alloc_particle(game.particles)
        let ptcl = game.particles[idx]
        ptcl.active = true
        ptcl.x = game.player.x + cos_a * ring_r
        ptcl.y = game.player.y + sin_a * ring_r
        ptcl.vx = cos_a * 180.0
        ptcl.vy = sin_a * 180.0
        ptcl.life = 0.6
        ptcl.max_life = 0.6
        ptcl.size = 4.0
        ptcl.r = 100
        ptcl.g = 200
        ptcl.b = 255
      }
      // Extra random burst on top
      spawn_particles_burst(game, game.player.x, game.player.y, 12, 255, 215, 0)
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
      // Path price modifier: Pilgrim = 0.7, others = 1.0
      let price_mult : Float = match game.current_path {
        Some(Pilgrim) => 0.7
        _ => 1.0
      }
      // Forge path: second slot is also a weapon
      let forge_active = match game.current_path {
        Some(Forge) => true
        _ => false
      }
      // Generate 3 shop items: weapon, passive/weapon, health potion
      // Item 0: Weapon
      let weapons : Array[@types.WeaponKind] = [Sword, Daggers, Bow, Staff]
      let (s1, widx) = @types.rng_int(game.rng_state, 0, 3)
      let (s2, wprice) = @types.rng_int(s1, 30, 50)
      game.rng_state = s2
      let shop0 = game.shop_items[0]
      shop0.active = true
      shop0.kind = WeaponPickup(weapons[widx])
      shop0.price = (Float::from_int(wprice) * price_mult).to_int()
      shop0.x = cx - 80.0
      shop0.y = cy - 20.0
      // Item 1: Passive (or weapon if Forge)
      if forge_active {
        let (s3, widx2) = @types.rng_int(game.rng_state, 0, 3)
        let (s4, wprice2) = @types.rng_int(s3, 25, 45)
        game.rng_state = s4
        let shop1 = game.shop_items[1]
        shop1.active = true
        shop1.kind = WeaponPickup(weapons[widx2])
        shop1.price = (Float::from_int(wprice2) * price_mult).to_int()
        shop1.x = cx
        shop1.y = cy - 20.0
      } else {
        let passives = all_passives()
        let (s3, pidx) = @types.rng_int(
          game.rng_state,
          0,
          passives.length() - 1,
        )
        let (s4, pprice) = @types.rng_int(s3, 40, 80)
        game.rng_state = s4
        let shop1 = game.shop_items[1]
        shop1.active = true
        shop1.kind = PassiveItem(passives[pidx])
        shop1.price = (Float::from_int(pprice) * price_mult).to_int()
        shop1.x = cx
        shop1.y = cy - 20.0
      }
      // Item 2: Health potion
      let shop2 = game.shop_items[2]
      shop2.active = true
      shop2.kind = HealthPotion
      shop2.price = (Float::from_int(15) * price_mult).to_int()
      shop2.x = cx + 80.0
      shop2.y = cy - 20.0
      // MerchantsDebt pact: all prices +50%
      if @types.has_pact(game.player, MerchantsDebt) {
        for si in 0..<game.shop_items.length() {
          let s = game.shop_items[si]
          if s.active {
            s.price = (Float::from_int(s.price) * 1.5).to_int()
          }
        }
      }
      game.shop_active = true
    }
  }
}

///|
fn offer_pact(game : @types.Game) -> Unit {
  // Pick 2 random pacts the player doesn't already have
  let all_pacts : Array[@types.PactKind] = [
    BloodPrice, GlassStep, MerchantsDebt, CursedStrength, VoidHeart,
  ]
  let available : Array[@types.PactKind] = []
  for i in 0..<all_pacts.length() {
    if !@types.has_pact(game.player, all_pacts[i]) {
      available.push(all_pacts[i])
    }
  }
  if available.length() == 0 {
    return
  }
  game.pact_offers.clear()
  // Shuffle and pick up to 2
  let count = @types.mini(available.length(), 2)
  for _i in 0..<count {
    let (s, roll) = @types.rng_int(game.rng_state, 0, available.length() - 1)
    game.rng_state = s
    game.pact_offers.push(available[roll])
    ignore(available.remove(roll))
  }
  game.pact_offer_active = true
}

///|
pub fn update_pact_offer(game : @types.Game, input : InputState) -> Unit {
  if !game.pact_offer_active {
    return
  }
  // Press 1 or 2 to accept a pact, ESC to decline
  if game.pact_offers.length() > 0 && @raylib.is_key_pressed(@raylib.KeyOne) {
    accept_pact(game, game.pact_offers[0])
    game.pact_offer_active = false
    return
  }
  if game.pact_offers.length() > 1 && @raylib.is_key_pressed(@raylib.KeyTwo) {
    accept_pact(game, game.pact_offers[1])
    game.pact_offer_active = false
    return
  }
  // Decline
  if @raylib.is_key_pressed(@raylib.KeyEscape) || input.interact_pressed {
    game.pact_offer_active = false
  }
}

///|
fn accept_pact(game : @types.Game, pact : @types.PactKind) -> Unit {
  let p = game.player
  p.pacts.push(pact)
  // Apply immediate effects
  match pact {
    VoidHeart => {
      // Reduce max HP by 30
      p.max_hp -= 30
      if p.max_hp < 1 {
        p.max_hp = 1
      }
      if p.hp > p.max_hp {
        p.hp = p.max_hp
      }
    }
    _ => ()
  }
}
