// Block interaction: targeting, breaking, placing, mining

// DDA ray march to find the block the player is looking at

///|
/// Ray-marches from the camera through the world to find the currently targeted
/// solid block face and stores hit position/normal in `game.target`.
pub fn update_block_target(game : @types.Game) -> Unit {
  let target = game.target
  target.hit = false
  let player = game.player
  let cos_yaw = @math.cosf(player.yaw)
  let sin_yaw = @math.sinf(player.yaw)
  let cos_pitch = @math.cosf(player.pitch)
  let sin_pitch = @math.sinf(player.pitch)
  // Ray direction
  let dx = sin_yaw * cos_pitch
  let dy = sin_pitch
  let dz = cos_yaw * cos_pitch
  // Ray origin (at eye level)
  let mut rx = game.cam_pos_x
  let mut ry = game.cam_pos_y
  let mut rz = game.cam_pos_z
  let step = @types.ray_step
  let max_steps = (@types.reach_distance / step).to_int()
  let mut prev_bx = rx.floor().to_int()
  let mut prev_by = ry.floor().to_int()
  let mut prev_bz = rz.floor().to_int()
  for i in 0..<max_steps {
    rx += dx * step
    ry += dy * step
    rz += dz * step
    let bx = rx.floor().to_int()
    let by = ry.floor().to_int()
    let bz = rz.floor().to_int()
    let block = @types.get_world_block(game, bx, by, bz)
    if @types.is_solid(block) {
      target.hit = true
      target.bx = bx
      target.by = by
      target.bz = bz
      target.distance = Float::from_int(i) * step
      // Normal is the direction we came from
      target.nx = prev_bx - bx
      target.ny = prev_by - by
      target.nz = prev_bz - bz
      // Clamp normals to -1..1
      if target.nx > 1 {
        target.nx = 1
      }
      if target.nx < -1 {
        target.nx = -1
      }
      if target.ny > 1 {
        target.ny = 1
      }
      if target.ny < -1 {
        target.ny = -1
      }
      if target.nz > 1 {
        target.nz = 1
      }
      if target.nz < -1 {
        target.nz = -1
      }
      return
    }
    prev_bx = bx
    prev_by = by
    prev_bz = bz
    ignore(i)
  }
}

// Handle block breaking (with mining time) and placing

///|
/// Handles mining progress, block breaking drops, and block placement using current
/// input state and targeted block data.
pub fn handle_block_interaction(game : @types.Game, dt : Float) -> Unit {
  let target = game.target
  let player = game.player

  // Mining system: hold left mouse button to mine
  if @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) ||
    @raylib.is_key_down(@raylib.KeyF) {
    if target.hit {
      let block = @types.get_world_block(game, target.bx, target.by, target.bz)
      if @types.is_solid(block) && block != @types.block_bedrock {
        // Tool-class gating: check if tool can mine this block
        let can_mine = @types.can_mine_block(player.equipped_tool, block)
        let drop = if can_mine {
          @types.get_block_drop(block)
        } else {
          @types.block_air
        }
        // Speed multiplier: wrong tool = 4x slower
        let speed_mult = @types.mining_speed_multiplier(
          player.equipped_tool,
          block,
        )
        // Check inventory full before mining
        if drop != @types.block_air && player.inventory.is_full() {
          game.inv_full_timer = 1.5
          player.mining_active = false
          player.mining_progress = 0.0
        } else if player.mining_active &&
          player.mining_block_x == target.bx &&
          player.mining_block_y == target.by &&
          player.mining_block_z == target.bz {
          // Continue mining (apply speed multiplier for wrong tool)
          let mine_time = @types.get_mining_time(block, player.equipped_tool) *
            speed_mult
          player.mining_progress += dt / mine_time
          // Spawn crack particles as mining progresses
          let cr = @levels.block_color_r(block)
          let cg = @levels.block_color_g(block)
          let cb = @levels.block_color_b(block)
          if player.mining_progress > 0.25 && game.frame_counter % 8 == 0 {
            @types.spawn_mining_crack_particles(
              game,
              target.bx,
              target.by,
              target.bz,
              cr,
              cg,
              cb,
            )
          }
          if player.mining_progress >= 1.0 {
            // Block broken!
            @types.set_world_block(
              game,
              target.bx,
              target.by,
              target.bz,
              @types.block_air,
            )
            game.blocks_broken += 1
            player.mining_active = false
            player.mining_progress = 0.0
            // Add to inventory (only if tool can mine the block)
            if drop != @types.block_air {
              let leftover = player.inventory.add_item(drop, 1)
              if leftover > 0 {
                game.inv_full_timer = 1.5
              }
            }
            // Loot from chest blocks
            if block == @types.block_chest {
              game.loot_chest()
            }
            // Spawn break particles burst
            @types.spawn_break_particles(
              game,
              target.bx,
              target.by,
              target.bz,
              cr,
              cg,
              cb,
            )
            // Deduct tool durability
            if player.equipped_tool != @types.tool_hand {
              player.tool_durability -= 1
              if player.tool_durability <= 0 {
                @types.show_message(game, "Tool broke!", 2.0)
                player.equipped_tool = @types.tool_hand
                player.tool_durability = 0
              }
            }
            if !can_mine {
              @types.show_message(
                game,
                "Need better pickaxe for \{@types.block_name(block)}!",
                2.0,
              )
            } else {
              @types.show_message(
                game,
                "Broke \{@types.block_name(block)}",
                1.0,
              )
            }
          }
        } else {
          // Start mining new block
          player.mining_active = true
          player.mining_block_x = target.bx
          player.mining_block_y = target.by
          player.mining_block_z = target.bz
          player.mining_progress = 0.0
        }
      }
    } else {
      // Not looking at a block, cancel mining
      player.mining_active = false
      player.mining_progress = 0.0
    }
    // Released mouse button, cancel mining
  } else if player.mining_active {
    player.mining_active = false
    player.mining_progress = 0.0
  }

  // Place block: right mouse button or G key
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) ||
    @raylib.is_key_pressed(@raylib.KeyG) {
    if target.hit {
      let place_x = target.bx + target.nx
      let place_y = target.by + target.ny
      let place_z = target.bz + target.nz
      // Make sure placement position is valid and not occupied
      let existing = @types.get_world_block(game, place_x, place_y, place_z)
      if !@types.is_solid(existing) && place_y >= 0 && place_y < @types.chunk_y {
        // Make sure we are not placing inside the player
        let pr = @types.player_radius + 0.1
        let fpx = Float::from_int(place_x) + 0.5
        let fpy = Float::from_int(place_y) + 0.5
        let fpz = Float::from_int(place_z) + 0.5
        let ddx = (game.player.x - fpx).abs()
        let ddy = (game.player.y + @types.player_height * 0.5 - fpy).abs()
        let ddz = (game.player.z - fpz).abs()
        let collides = ddx < pr + 0.5 &&
          ddy < @types.player_height * 0.5 + 0.5 &&
          ddz < pr + 0.5
        if !collides {
          // Use item from inventory
          let sel = player.inventory.selected
          let slot = player.inventory.slots[sel]
          if slot.count > 0 && slot.item_id > 0 {
            let item_id = slot.item_id
            // Check if item is a tool (can't place tools)
            if @types.is_tool_item(item_id) {
              // Equip the tool from hotbar instead of placing
              game.player.equipped_tool = item_id
              game.player.tool_durability = @types.get_tool_max_durability(
                item_id,
              )
              @types.show_message(
                game,
                "Equipped \{@types.tool_name(item_id)}",
                1.0,
              )
              slot.count -= 1
              if slot.count <= 0 {
                slot.item_id = 0
                slot.count = 0
              }
            } else if @types.is_placeable_item(item_id) ||
              (item_id > 0 && item_id <= @types.block_shrine_stone) {
              // Placeable block or workstation
              let block_to_place = item_id
              slot.count -= 1
              if slot.count <= 0 {
                slot.item_id = 0
                slot.count = 0
              }
              @types.set_world_block(
                game, place_x, place_y, place_z, block_to_place,
              )
              game.blocks_placed += 1
              @types.show_message(
                game,
                "Placed \{@types.block_name(block_to_place)}",
                1.0,
              )
            } else {
              @types.show_message(game, "Can't place this item!", 1.0)
            }
          } else {
            @types.show_message(game, "No blocks to place!", 1.0)
          }
        }
      }
    }
  }
}

///|
/// Gives random loot from a broken chest block.
fn @types.Game::loot_chest(game : @types.Game) -> Unit {
  let roll = @types.rand_next(game) % 100
  if roll < 30 {
    ignore(game.player.inventory.add_item(@types.item_coal, 3))
    @types.show_message(game, "Found coal in chest!", 2.0)
  } else if roll < 55 {
    ignore(game.player.inventory.add_item(@types.item_iron_ingot, 1))
    @types.show_message(game, "Found iron ingot in chest!", 2.0)
  } else if roll < 75 {
    ignore(game.player.inventory.add_item(@types.block_torch, 4))
    @types.show_message(game, "Found torches in chest!", 2.0)
  } else if roll < 90 {
    ignore(game.player.inventory.add_item(@types.item_stick, 6))
    @types.show_message(game, "Found sticks in chest!", 2.0)
  } else {
    ignore(game.player.inventory.add_item(@types.block_ore_gold, 1))
    @types.show_message(game, "Found gold ore in chest!", 2.0)
  }
}

// Handle block selection via number keys and scroll wheel

///|
/// Updates hotbar slot selection from number keys and mouse wheel, then syncs
/// `selected_block` from the chosen inventory slot.
pub fn handle_block_selection(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyOne) {
    game.player.inventory.selected = 0
  }
  if @raylib.is_key_pressed(@raylib.KeyTwo) {
    game.player.inventory.selected = 1
  }
  if @raylib.is_key_pressed(@raylib.KeyThree) {
    game.player.inventory.selected = 2
  }
  if @raylib.is_key_pressed(@raylib.KeyFour) {
    game.player.inventory.selected = 3
  }
  if @raylib.is_key_pressed(@raylib.KeyFive) {
    game.player.inventory.selected = 4
  }
  if @raylib.is_key_pressed(@raylib.KeySix) {
    game.player.inventory.selected = 5
  }
  if @raylib.is_key_pressed(@raylib.KeySeven) {
    game.player.inventory.selected = 6
  }
  if @raylib.is_key_pressed(@raylib.KeyEight) {
    game.player.inventory.selected = 7
  }
  if @raylib.is_key_pressed(@raylib.KeyNine) {
    game.player.inventory.selected = 8
  }
  // Mouse wheel cycling through hotbar slots
  let wheel = @raylib.get_mouse_wheel_move()
  if wheel > 0.0 {
    let mut next = game.player.inventory.selected - 1
    if next < 0 {
      next = @types.hotbar_slots - 1
    }
    game.player.inventory.selected = next
  } else if wheel < 0.0 {
    let mut next = game.player.inventory.selected + 1
    if next >= @types.hotbar_slots {
      next = 0
    }
    game.player.inventory.selected = next
  }
  // Update selected_block from inventory and auto-equip tools
  let sel_slot = game.player.inventory.slots[game.player.inventory.selected]
  if sel_slot.count > 0 {
    game.player.selected_block = sel_slot.item_id
    // Auto-equip if the selected slot is a tool
    if @types.is_tool_item(sel_slot.item_id) {
      game.player.equipped_tool = sel_slot.item_id
      game.player.tool_durability = @types.get_tool_max_durability(
        sel_slot.item_id,
      )
    }
  }
}
