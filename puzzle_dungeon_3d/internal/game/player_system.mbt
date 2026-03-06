// Player movement and interaction

///|
fn @types.Game::try_move_player(game : @types.Game, dir : @types.Dir) -> Unit {
  let dx = @types.dir_dx(dir)
  let dy = @types.dir_dy(dir)
  let nx = game.player_gx + dx
  let ny = game.player_gy + dy
  game.player_dir = dir
  // Check bounds
  if !@types.in_bounds(nx, ny) {
    return
  }
  let target_tile = @types.get_tile(game, nx, ny)
  // Check for wall
  if target_tile == TileWall {
    return
  }
  // Check for exit
  if target_tile == TileExitClosed {
    return
  }
  // Check for pit
  if target_tile == TilePit {
    return
  }
  // Check for active spikes
  if target_tile == TileSpikesOn {
    return
  }
  // Check for closed gate
  if target_tile == TileGateClosed {
    return
  }
  // Check for bridge off (gap)
  if target_tile == TileBridgeOff {
    return
  }
  // Check for laser source (wall-like)
  if @types.is_laser_source(target_tile) {
    return
  }
  // Check for entity at target
  let eidx = @types.entity_at(game, nx, ny)
  if eidx >= 0 {
    let entity = game.entities[eidx]
    match entity.kind {
      EntityBlock => {
        // Try to push block
        let bx = nx + dx
        let by = ny + dy
        if !@types.in_bounds(bx, by) {
          return
        }
        let behind_tile = @types.get_tile(game, bx, by)
        let behind_entity = @types.entity_at(game, bx, by)
        if behind_entity >= 0 {
          // Check push chain: can we push the second block too?
          let chain_entity = game.entities[behind_entity]
          if chain_entity.kind == EntityBlock {
            let cx = bx + dx
            let cy = by + dy
            if @types.in_bounds(cx, cy) {
              let chain_tile = @types.get_tile(game, cx, cy)
              let chain_behind = @types.entity_at(game, cx, cy)
              if @types.is_pushable_onto(chain_tile) && chain_behind < 0 {
                // Push chain: push second block, then first
                game.save_undo()
                // Move second block
                chain_entity.gx = cx
                chain_entity.gy = cy
                chain_entity.anim_timer = @types.push_anim_duration
                game.handle_block_land(chain_entity, chain_tile, cx, cy)
                // Move first block
                entity.gx = bx
                entity.gy = by
                entity.anim_timer = @types.push_anim_duration
                game.handle_block_land(entity, behind_tile, bx, by)
                // Move player
                game.move_player_to(nx, ny, dir)
                game.after_move()
                return
              }
            }
          }
          return // Can't push into another entity (non-chainable)
        }
        if !@types.is_pushable_onto(behind_tile) {
          return
        }
        // Save undo before move
        game.save_undo()
        // Move block
        entity.gx = bx
        entity.gy = by
        entity.anim_timer = @types.push_anim_duration
        game.handle_block_land(entity, behind_tile, bx, by)
        // If block lands on ice, slide it
        if behind_tile == TileIce {
          @types.ice_slide_entity(game, eidx, dir)
        }
        // Move player
        game.move_player_to(nx, ny, dir)
        game.player_push_anim = @types.push_anim_duration
        game.after_move()
      }
      EntityDiamond => {
        // Collect diamond
        game.save_undo()
        entity.active = false
        game.diamonds_collected += 1
        game.move_player_to(nx, ny, dir)
        // Particles
        @types.spawn_particles(
          game,
          Float::from_int(nx),
          0.5,
          Float::from_int(ny),
          @types.collect_particle_count,
          @types.color_diamond_r,
          @types.color_diamond_g,
          @types.color_diamond_b,
        )
        game.after_move()
      }
      EntityKey => {
        // Collect key
        game.save_undo()
        entity.active = false
        game.keys_held += 1
        game.move_player_to(nx, ny, dir)
        @types.spawn_particles(
          game,
          Float::from_int(nx),
          0.5,
          Float::from_int(ny),
          @types.collect_particle_count,
          @types.color_key_r,
          @types.color_key_g,
          @types.color_key_b,
        )
        game.after_move()
      }
      _ => return
    }
  } else {
    // Empty tile - just move
    if !@types.is_walkable(target_tile) {
      return
    }
    game.save_undo()
    game.move_player_to(nx, ny, dir)
    // Handle special tiles
    game.handle_tile_effect(target_tile, nx, ny, dir)
    game.after_move()
  }
}

///|
fn @types.Game::move_player_to(
  game : @types.Game,
  nx : Int,
  ny : Int,
  _dir : @types.Dir,
) -> Unit {
  game.player_gx = nx
  game.player_gy = ny
  game.player_moving = true
  game.player_anim_timer = @types.move_anim_duration
  game.moves += 1
  game.total_moves += 1
}

///|
fn @types.Game::handle_block_land(
  game : @types.Game,
  entity : @types.Entity,
  tile : @types.Tile,
  bx : Int,
  by : Int,
) -> Unit {
  // Check if block falls into pit
  if tile == TilePit {
    entity.falling = true
    entity.fall_timer = @types.fall_anim_duration
    // Fill the pit
    @types.set_tile(game, bx, by, TileFloor)
    @types.spawn_particles(
      game,
      Float::from_int(bx),
      0.0,
      Float::from_int(by),
      6,
      80,
      70,
      60,
    )
  }
  // Check if block is on cracked floor
  if tile == TileCracked {
    @types.set_tile(game, bx, by, TilePit)
    entity.falling = true
    entity.fall_timer = @types.fall_anim_duration
  }
}

///|
fn @types.Game::handle_tile_effect(
  game : @types.Game,
  target_tile : @types.Tile,
  nx : Int,
  ny : Int,
  dir : @types.Dir,
) -> Unit {
  if target_tile == TileSwitchOff {
    @types.set_tile(game, nx, ny, TileSwitchOn)
    game.toggle_spikes()
    @types.toggle_bridges(game)
    @types.spawn_ambient_particles(
      game,
      Float::from_int(nx),
      0.3,
      Float::from_int(ny),
      6,
      50,
      200,
      50,
      0.2,
      1.0,
    )
  } else if target_tile == TileSwitchOn {
    @types.set_tile(game, nx, ny, TileSwitchOff)
    game.toggle_spikes()
    @types.toggle_bridges(game)
    @types.spawn_ambient_particles(
      game,
      Float::from_int(nx),
      0.3,
      Float::from_int(ny),
      6,
      200,
      50,
      50,
      0.2,
      1.0,
    )
  } else if target_tile == TileTeleportA {
    // Find teleport B
    let pos = game.find_tile(TileTeleportB)
    if pos.0 >= 0 {
      game.player_gx = pos.0
      game.player_gy = pos.1
      @types.spawn_particles(
        game,
        Float::from_int(nx),
        0.5,
        Float::from_int(ny),
        @types.teleport_particle_count,
        150,
        100,
        255,
      )
      @types.spawn_particles(
        game,
        Float::from_int(pos.0),
        0.5,
        Float::from_int(pos.1),
        @types.teleport_particle_count,
        150,
        100,
        255,
      )
    }
  } else if target_tile == TileTeleportB {
    let pos = game.find_tile(TileTeleportA)
    if pos.0 >= 0 {
      game.player_gx = pos.0
      game.player_gy = pos.1
      @types.spawn_particles(
        game,
        Float::from_int(nx),
        0.5,
        Float::from_int(ny),
        @types.teleport_particle_count,
        150,
        100,
        255,
      )
      @types.spawn_particles(
        game,
        Float::from_int(pos.0),
        0.5,
        Float::from_int(pos.1),
        @types.teleport_particle_count,
        150,
        100,
        255,
      )
    }
  } else if target_tile == TileCracked {
    @types.set_tile(game, nx, ny, TilePit)
    @types.spawn_ambient_particles(
      game,
      Float::from_int(nx),
      0.0,
      Float::from_int(ny),
      4,
      100,
      85,
      70,
      0.3,
      0.5,
    )
  } else if target_tile == TileExitOpen {
    // Level complete!
    game.complete_floor()
    return
  } else if @types.is_mirror(target_tile) {
    // Player can walk on mirrors (they just affect lasers)
    // Nothing special happens
    ignore(target_tile)
  } else if target_tile == TileRotatePlatform {
    // Rotate adjacent mirrors when stepping on rotating platform
    game.rotate_adjacent_mirrors(nx, ny)
    @types.spawn_ambient_particles(
      game,
      Float::from_int(nx),
      0.2,
      Float::from_int(ny),
      6,
      @types.color_rotate_r,
      @types.color_rotate_g,
      @types.color_rotate_b,
      0.3,
      1.0,
    )
  }
  // Ice sliding
  if target_tile == TileIce {
    game.handle_ice_sliding(nx, ny, dir)
  }
  // Conveyor effect on player
  if @types.is_conveyor(target_tile) {
    let conv_dir = @types.conveyor_direction(target_tile)
    let cdx = @types.dir_dx(conv_dir)
    let cdy = @types.dir_dy(conv_dir)
    let slide_x = nx + cdx
    let slide_y = ny + cdy
    if @types.in_bounds(slide_x, slide_y) {
      let slide_tile = @types.get_tile(game, slide_x, slide_y)
      let slide_entity = @types.entity_at(game, slide_x, slide_y)
      if @types.is_walkable(slide_tile) && slide_entity < 0 {
        game.player_gx = slide_x
        game.player_gy = slide_y
        if slide_tile == TileExitOpen {
          game.complete_floor()
          return
        }
      }
    }
  }
}

///|
fn @types.Game::handle_ice_sliding(
  game : @types.Game,
  start_x : Int,
  start_y : Int,
  dir : @types.Dir,
) -> Unit {
  let dx = @types.dir_dx(dir)
  let dy = @types.dir_dy(dir)
  let mut cur_x = start_x
  let mut cur_y = start_y
  let mut sliding = true
  while sliding {
    let slide_x = cur_x + dx
    let slide_y = cur_y + dy
    if !@types.in_bounds(slide_x, slide_y) {
      sliding = false
    } else {
      let slide_tile = @types.get_tile(game, slide_x, slide_y)
      let slide_entity = @types.entity_at(game, slide_x, slide_y)
      if @types.is_walkable(slide_tile) && slide_entity < 0 {
        cur_x = slide_x
        cur_y = slide_y
        game.player_gx = slide_x
        game.player_gy = slide_y
        // Check the slid-to tile
        if slide_tile == TileExitOpen {
          game.complete_floor()
          return
        }
        if slide_tile != TileIce {
          sliding = false
        }
      } else {
        sliding = false
      }
    }
  }
}

///|
fn @types.Game::rotate_adjacent_mirrors(
  game : @types.Game,
  gx : Int,
  gy : Int,
) -> Unit {
  // Check all 4 adjacent tiles for mirrors and rotate them
  let neighbors : Array[(Int, Int)] = [
    (gx - 1, gy),
    (gx + 1, gy),
    (gx, gy - 1),
    (gx, gy + 1),
  ]
  for neighbor in neighbors {
    let nx = neighbor.0
    let ny = neighbor.1
    if @types.in_bounds(nx, ny) {
      let tile = @types.get_tile(game, nx, ny)
      if @types.is_mirror(tile) {
        let new_tile = rotate_mirror(tile)
        @types.set_tile(game, nx, ny, new_tile)
      }
    }
  }
}

///|
fn rotate_mirror(tile : @types.Tile) -> @types.Tile {
  match tile {
    TileMirrorNe => TileMirrorNw
    TileMirrorNw => TileMirrorSw
    TileMirrorSw => TileMirrorSe
    TileMirrorSe => TileMirrorNe
    _ => tile
  }
}

///|
fn @types.Game::after_move(game : @types.Game) -> Unit {
  // Check plate activation
  game.check_plates()
  // Update gates
  @types.update_gates(game)
  // Resolve conveyors
  @types.resolve_conveyors(game)
  // Recalculate laser paths
  @types.calculate_laser_paths(game)
  // Check exit
  game.check_exit()
  // Dismiss tutorial after first move
  if game.tutorial_active && game.moves > 0 {
    game.tutorial_timer += 1.0
    if game.tutorial_timer > 3.0 {
      game.tutorial_active = false
    }
  }
}

///|
fn @types.Game::update_player_animation(game : @types.Game, dt : Float) -> Unit {
  if game.player_moving {
    game.player_anim_timer -= dt
    if game.player_anim_timer <= 0.0 {
      game.player_anim_timer = 0.0
      game.player_moving = false
    }
    let t : Float = if game.player_anim_timer > 0.0 {
      1.0 - game.player_anim_timer / @types.move_anim_duration
    } else {
      1.0
    }
    let smooth_t = @types.smooth_step(t)
    game.player_anim_x = @types.lerpf(
      game.player_anim_x,
      Float::from_int(game.player_gx),
      smooth_t,
    )
    game.player_anim_z = @types.lerpf(
      game.player_anim_z,
      Float::from_int(game.player_gy),
      smooth_t,
    )
    // Walk cycle
    game.player_walk_cycle += dt * 12.0
  } else {
    game.player_anim_x = Float::from_int(game.player_gx)
    game.player_anim_z = Float::from_int(game.player_gy)
    game.player_walk_cycle = 0.0
  }
  // Push animation decay
  if game.player_push_anim > 0.0 {
    game.player_push_anim -= dt
    if game.player_push_anim < 0.0 {
      game.player_push_anim = 0.0
    }
  }
}

///|
fn @types.Game::update_entity_animations(
  game : @types.Game,
  dt : Float,
) -> Unit {
  for e in game.entities {
    if !e.active {
      continue
    }
    if e.falling {
      e.fall_timer -= dt
      if e.fall_timer <= 0.0 {
        e.active = false
        @types.spawn_particles(
          game,
          Float::from_int(e.gx),
          0.0,
          Float::from_int(e.gy),
          8,
          @types.color_block_r,
          @types.color_block_g,
          @types.color_block_b,
        )
      }
      continue
    }
    if e.anim_timer > 0.0 {
      e.anim_timer -= dt
      if e.anim_timer <= 0.0 {
        e.anim_timer = 0.0
      }
      let t : Float = if e.anim_timer > 0.0 {
        1.0 - e.anim_timer / @types.push_anim_duration
      } else {
        1.0
      }
      let smooth_t = @types.smooth_step(t)
      e.anim_x = @types.lerpf(e.anim_x, Float::from_int(e.gx), smooth_t)
      e.anim_y = @types.lerpf(e.anim_y, Float::from_int(e.gy), smooth_t)
    } else {
      e.anim_x = Float::from_int(e.gx)
      e.anim_y = Float::from_int(e.gy)
    }
  }
}

///|
fn @types.Game::check_plates(game : @types.Game) -> Unit {
  game.plates_active = @types.count_active_plates(game)
}

///|
fn @types.Game::check_exit(game : @types.Game) -> Unit {
  // Exit opens when all plates have blocks AND all diamonds collected AND laser targets hit
  let plates_ok = game.plates_total == 0 ||
    game.plates_active >= game.plates_total
  let diamonds_ok = game.diamonds_total == 0 ||
    game.diamonds_collected >= game.diamonds_total
  let lasers_ok = game.laser_targets_total == 0 ||
    game.laser_targets_hit >= game.laser_targets_total
  let should_open = plates_ok && diamonds_ok && lasers_ok
  if should_open && !game.exit_open {
    game.exit_open = true
    // Set exit tiles to open
    for gy in 0..<@types.grid_h {
      for gx in 0..<@types.grid_w {
        if @types.get_tile(game, gx, gy) == TileExitClosed {
          @types.set_tile(game, gx, gy, TileExitOpen)
          @types.spawn_particles(
            game,
            Float::from_int(gx),
            0.5,
            Float::from_int(gy),
            @types.teleport_particle_count,
            @types.color_exit_r,
            @types.color_exit_g,
            @types.color_exit_b,
          )
        }
      }
    }
  } else if !should_open && game.exit_open {
    game.exit_open = false
    for gy in 0..<@types.grid_h {
      for gx in 0..<@types.grid_w {
        if @types.get_tile(game, gx, gy) == TileExitOpen {
          @types.set_tile(game, gx, gy, TileExitClosed)
        }
      }
    }
  }
}

///|
fn @types.Game::complete_floor(game : @types.Game) -> Unit {
  // Calculate stars
  let par = @levels.get_par_moves(game.current_floor)
  let stars = if game.moves <= par {
    3
  } else if game.moves <= par + @types.star_threshold_2 {
    2
  } else {
    1
  }
  game.complete_stars = stars
  game.complete_timer = 0.0
  // Update floor info
  let info = game.floor_info[game.current_floor]
  info.completed = true
  if game.moves < info.best_moves {
    info.best_moves = game.moves
  }
  if stars > info.stars {
    info.stars = stars
  }
  // Update totals
  game.total_stars = @types.count_total_stars(game)
  game.levels_completed += 1
  // Unlock next floor
  if game.current_floor + 1 < @types.max_floors {
    game.floor_info[game.current_floor + 1].unlocked = true
  }
  // Check achievements
  game.check_achievements()
  game.state = StateLevelComplete
  // Celebration particles
  @types.spawn_particles(
    game,
    Float::from_int(game.player_gx),
    1.0,
    Float::from_int(game.player_gy),
    @types.complete_particle_count,
    @types.color_exit_r,
    @types.color_exit_g,
    @types.color_exit_b,
  )
}

///|
fn @types.Game::check_achievements(game : @types.Game) -> Unit {
  // First clear
  if !game.achievements[@types.achievement_first_clear].unlocked {
    game.achievements[@types.achievement_first_clear].unlocked = true
    game.show_achievement("First Steps - Completed a level!")
  }
  // World completions
  let world = game.current_world
  let world_idx = @types.world_to_int(world)
  let world_start = world_idx * @types.floors_per_world
  let mut world_done = true
  for i in world_start..<(world_start + @types.floors_per_world) {
    if i < @types.max_floors && !game.floor_info[i].completed {
      world_done = false
    }
  }
  if world_done {
    let ach_id = @types.achievement_world_1 + world_idx
    if ach_id < @types.max_achievements && !game.achievements[ach_id].unlocked {
      game.achievements[ach_id].unlocked = true
      let wname = @types.get_world_name(world)
      game.show_achievement("Completed \{wname}!")
    }
  }
  // No undo achievement
  if !game.used_undo && !game.achievements[@types.achievement_no_undo].unlocked {
    if game.current_floor >= 5 {
      game.achievements[@types.achievement_no_undo].unlocked = true
      game.show_achievement("Purist - No undo used!")
    }
  }
}

///|
fn @types.Game::show_achievement(game : @types.Game, text : String) -> Unit {
  game.achievement_display_timer = 3.0
  game.achievement_display_text = text
}

///|
fn @types.Game::find_tile(
  game : @types.Game,
  tile_type : @types.Tile,
) -> (Int, Int) {
  for gy in 0..<@types.grid_h {
    for gx in 0..<@types.grid_w {
      if @types.get_tile(game, gx, gy) == tile_type {
        return (gx, gy)
      }
    }
  }
  (-1, -1)
}

///|
fn @types.Game::toggle_spikes(game : @types.Game) -> Unit {
  for gy in 0..<@types.grid_h {
    for gx in 0..<@types.grid_w {
      let tile = @types.get_tile(game, gx, gy)
      match tile {
        TileSpikesOff => @types.set_tile(game, gx, gy, TileSpikesOn)
        TileSpikesOn => @types.set_tile(game, gx, gy, TileSpikesOff)
        _ => ()
      }
    }
  }
}
