///|
/// Spawns enemies in a V-shape formation centered on the road.
fn @types.Game::spawn_v_formation(
  game : @types.Game,
  y : Float,
  center : Float,
) -> Unit {
  let arm_count = 2 + game.stage.clamp(min=0, max=3)
  let hp = scaled_foe_hp(game.stage, 16.0, 2.0)
  for i in 0..<arm_count {
    let offset = Float::from_int(i) * @types.lane_gap * 0.7
    let dy = Float::from_int(i) * 36.0
    // Left arm
    game.spawn_entity(
      FoeBike,
      center - offset,
      y - dy,
      @types.randf(-30.0, 30.0),
      @types.randf(-10.0, 30.0),
      44.0,
      76.0,
      hp,
      @types.randf(0.6, 1.4),
      false,
      130,
    )
    // Right arm
    if i > 0 {
      game.spawn_entity(
        FoeBike,
        center + offset,
        y - dy,
        @types.randf(-30.0, 30.0),
        @types.randf(-10.0, 30.0),
        44.0,
        76.0,
        hp,
        @types.randf(0.6, 1.4),
        false,
        130,
      )
    }
  }
}

///|
/// Spawns enemies in a tight column rushing down a single lane.
fn @types.Game::spawn_column_rush(
  game : @types.Game,
  y : Float,
  center : Float,
) -> Unit {
  let lane = @types.randi(0, @types.lanes_count - 1)
  let x = @types.lane_x(lane, center)
  let count = 3 + game.stage.clamp(min=0, max=2)
  let hp = scaled_foe_hp(game.stage, 14.0, 2.0)
  for i in 0..<count {
    game.spawn_entity(
      FoeDrone,
      x + @types.randf(-10.0, 10.0),
      y - Float::from_int(i) * 52.0,
      @types.randf(-20.0, 20.0),
      @types.randf(20.0, 60.0),
      40.0,
      40.0,
      hp,
      @types.randf(0.4, 0.9),
      false,
      120,
    )
  }
}

///|
/// Spawns enemies in flanking pairs on opposite sides of the road.
fn @types.Game::spawn_flanking_pairs(
  game : @types.Game,
  y : Float,
  center : Float,
) -> Unit {
  let pairs = 2 + (game.stage / 2).clamp(min=0, max=2)
  let hp = scaled_foe_hp(game.stage, 20.0, 3.0)
  for i in 0..<pairs {
    let dy = Float::from_int(i) * 58.0
    let hw = @types.road_half_width(
      game.stage,
      game.distance + (Float::from_int(@types.screen_h) - y),
      game.time_s,
    )
    // Left flanker
    game.spawn_entity(
      FoeBike,
      center - hw * 0.6,
      y - dy,
      @types.randf(30.0, 80.0),
      @types.randf(10.0, 40.0),
      44.0,
      76.0,
      hp,
      @types.randf(0.5, 1.2),
      false,
      140,
    )
    // Right flanker
    game.spawn_entity(
      FoeBike,
      center + hw * 0.6,
      y - dy,
      @types.randf(-80.0, -30.0),
      @types.randf(10.0, 40.0),
      44.0,
      76.0,
      hp,
      @types.randf(0.5, 1.2),
      false,
      140,
    )
  }
}

///|
/// Spawns a boss entity (heavy truck variant) at the top of the screen.
fn @types.Game::spawn_boss(game : @types.Game, center : Float) -> Unit {
  let hp = @types.boss_hp_base +
    Float::from_int(game.stage) * @types.boss_hp_per_stage
  game.boss_active = true
  game.boss_hp = hp
  game.boss_max_hp = hp
  game.spawn_entity(
    FoeTruck,
    center,
    -60.0,
    0.0,
    @types.randf(10.0, 24.0),
    120.0,
    160.0,
    hp,
    @types.randf(0.8, 1.4),
    false,
    @types.boss_kill_bonus,
  )
  // Boss escort drones
  game.spawn_entity(
    FoeDrone,
    center - 100.0,
    -80.0,
    @types.randf(-20.0, 20.0),
    @types.randf(14.0, 30.0),
    40.0,
    40.0,
    scaled_foe_hp(game.stage, 16.0, 3.0),
    @types.randf(0.3, 0.7),
    false,
    110,
  )
  game.spawn_entity(
    FoeDrone,
    center + 100.0,
    -80.0,
    @types.randf(-20.0, 20.0),
    @types.randf(14.0, 30.0),
    40.0,
    40.0,
    scaled_foe_hp(game.stage, 16.0, 3.0),
    @types.randf(0.3, 0.7),
    false,
    110,
  )
}

///|
/// Returns balanced enemy HP for a given stage with base and per-stage gain.
/// Uses diminishing returns to avoid late-game HP inflation.
fn scaled_foe_hp(stage : Int, base : Float, per_stage : Float) -> Float {
  let s = Float::from_int((stage - 1).clamp(min=0, max=20))
  // Diminishing returns: sqrt scaling after stage 4
  let linear = @types.minf(s, 3.0) * per_stage
  let diminishing = if s > 3.0 {
    (s - 3.0).sqrt() * per_stage * 1.4
  } else {
    0.0
  }
  base + linear + diminishing
}

///|
/// Encounter director: replaces raw spawn_enemy_pack with formation-aware spawning.
fn @types.Game::encounter_spawn(game : @types.Game, y : Float) -> Unit {
  let depth = game.distance + (Float::from_int(@types.screen_h) - y)
  let center = @types.road_center_at(depth, game.time_s)
  // Check if we should spawn a boss (every 3rd stage, once per stage at midpoint)
  if @types.is_boss_stage(game.stage) &&
    !game.boss_active &&
    game.distance > game.stage_goal * 0.5 {
    game.spawn_boss(center)
    return
  }
  // Formation cooldown: don't spawn formations too close together
  if game.formation_cd > 0.0 {
    game.spawn_random_pack(y, center)
    return
  }
  let roll = @types.randi(0, 99)
  let formation = @types.select_formation(game.stage, roll)
  match formation {
    VShape => {
      game.spawn_v_formation(y, center)
      game.formation_cd = 2.4
    }
    ColumnRush => {
      game.spawn_column_rush(y, center)
      game.formation_cd = 2.0
    }
    FlankingPairs => {
      game.spawn_flanking_pairs(y, center)
      game.formation_cd = 2.6
    }
    Random => game.spawn_random_pack(y, center)
  }
}

///|
/// Spawns a random pack of enemies/items (refactored from the original spawn_enemy_pack).
fn @types.Game::spawn_random_pack(
  game : @types.Game,
  y : Float,
  center : Float,
) -> Unit {
  let pack = 1 + @types.randi(0, 2)
  for _i in 0..<pack {
    let roll = @types.randi(0, 99)
    if roll < 34 {
      let lane = @types.randi(0, @types.lanes_count - 1)
      let x = @types.lane_x(lane, center) + @types.randf(-12.0, 12.0)
      game.spawn_entity(
        FoeBike,
        x,
        y + @types.randf(-28.0, 20.0),
        @types.randf(-44.0, 44.0),
        @types.randf(-20.0, 40.0),
        44.0,
        76.0,
        scaled_foe_hp(game.stage, 18.0, 3.0),
        @types.randf(0.42, 1.22),
        false,
        120,
      )
    } else if roll < 56 {
      let lane = @types.randi(0, @types.lanes_count - 1)
      let x = @types.lane_x(lane, center) + @types.randf(-16.0, 16.0)
      game.spawn_entity(
        FoeDrone,
        x,
        y + @types.randf(-26.0, 24.0),
        @types.randf(-60.0, 60.0),
        @types.randf(-10.0, 30.0),
        40.0,
        40.0,
        scaled_foe_hp(game.stage, 12.0, 2.0),
        @types.randf(0.26, 0.9),
        game.stage >= 3 && @types.chance(26),
        110,
      )
    } else if roll < 70 {
      let lane = @types.randi(0, @types.lanes_count - 1)
      let x = @types.lane_x(lane, center)
      game.spawn_entity(
        FoeTruck,
        x,
        y + @types.randf(-32.0, 22.0),
        @types.randf(-18.0, 18.0),
        @types.randf(-16.0, 18.0),
        82.0,
        124.0,
        scaled_foe_hp(game.stage, 46.0, 5.0),
        @types.randf(0.7, 1.8),
        false,
        190,
      )
    } else if roll < 80 {
      let lane = @types.randi(0, @types.lanes_count - 1)
      let x = @types.lane_x(lane, center)
      game.spawn_entity(
        FoeLaser,
        x,
        y + @types.randf(-14.0, 12.0),
        0.0,
        @types.randf(-6.0, 12.0),
        126.0,
        18.0,
        16.0,
        @types.randf(0.9, 2.0),
        false,
        96,
      )
    } else if roll < 90 {
      let x = @types.road_spawn_x(game.distance, game.time_s, game.stage, y)
      game.spawn_entity(
        ItemCredit,
        x,
        y + @types.randf(-18.0, 18.0),
        @types.randf(-34.0, 34.0),
        @types.randf(-14.0, 16.0),
        34.0,
        34.0,
        1.0,
        0.0,
        false,
        0,
      )
    } else if roll < 96 {
      let x = @types.road_spawn_x(game.distance, game.time_s, game.stage, y)
      game.spawn_entity(
        ItemBattery,
        x,
        y + @types.randf(-18.0, 18.0),
        @types.randf(-28.0, 28.0),
        @types.randf(-12.0, 18.0),
        38.0,
        38.0,
        1.0,
        0.0,
        false,
        0,
      )
    } else {
      let x = @types.road_spawn_x(game.distance, game.time_s, game.stage, y)
      game.spawn_entity(
        ItemHackcell,
        x,
        y + @types.randf(-14.0, 14.0),
        @types.randf(-20.0, 20.0),
        @types.randf(-10.0, 14.0),
        34.0,
        34.0,
        1.0,
        0.0,
        false,
        0,
      )
    }
  }
}
